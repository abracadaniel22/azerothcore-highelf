# AzerothCore High Elf custom race

Mod to add High Elves as playable characters on Azeroth Core with support for mod-playerbots. By Abracadaniel22.

## Goals

The goals for this project are very simple and limited, allowing for quick feedback and a quick POC:

1. Duplicate blood elf models into a new high elf race
2. Copy everything else from humans (starting zone, mounts, reputation, quests, etc)

## Features

- A new High Elf alliance race is added
  - It shares the same models as the Blood Elf race
  - It shares the same starting zone, reputation, skills as the humans
  - High Elves can be any class except shaman or druid
- Compatible with HD models

### Extra features

The "extras" directory contains optional features that can be installed on top of the base installation:
- Compatibility patch to work with mod-individual-progression (thanks to Dasbadman)
- Arcane Torrent spell for High Elf warriors (thanks to Dasbadman)

## Known limitations

- No audio in emotes (such as /hi, /joke, etc)

## Open issues

- See [the issues page](https://github.com/abracadaniel22/azerothcore-highelf/issues) for known issues. Feel free to report anything there, or to fix issues if you are willing to contribute.

## Other considerations

- AzerothCore supports modules but the race list is hardcoded and can't be extended, so this "module" consists of a patch to be applied to AzerothCore core code after cloning it. Another option would be forking and keeping it up-to-date with the source but maintaining that would go against the simplicity constraints of this project.

## Requirements

- This requires a patched version of WoW.exe that allows interface edits (SIG & MD5 Protection removed). The version downloaded from Warmane or ChromieCraft should work. You can also download a patcher tool from the WoW Modding Community discord or from ownedcore.com and do it yourself. Without a patched version, the client will not accept the interface changes and will not allow you to play the game, throwing out errors such as "Your login interface files are corrupt".

## Installation

The mod requires both server and client files. The files are located in the `base mod/server` and `base mod/client` folders.

Make sure you understand what each file and command does, and adjust the steps accordingly based on your setup. It is likely that some things don't apply to you if you don't have a Ubuntu + Playerbots setup.

Installation consists of applying a patch in code and replacing DBC files on the server, recompiling, applying some data changes in the db, and applying some mpq patches on the client.

### Server installation

- Fully install and configure Azeroth Core with or without playerbots. Installing and setting up the basic Azeroth Core is out of scope of this doc. Installation instructions can be found in https://www.azerothcore.org/ .

- If installing on an existing server, run full backups using your standard backup scripts

- Stop servers (no need to stop database if only one server)

```
sudo service ac-worldserver stop
sudo service ac-authserver stop
```

- Apply patch to core (patch files located in "base mod" folder).

```
cd $AC_CODE_DIR && git apply highelf.patch
```

- Apply patch to playerbots (if you have playerbots)

```
cd $AC_CODE_DIR/modules/mod-playerbots && git apply highelf_playerbots.patch
```

- Recompile

```
cd $AC_CODE_DIR/build && \
cmake ../ -DCMAKE_INSTALL_PREFIX=$AC_CODE_DIR/env/dist/ -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ -DWITH_WARNINGS=0 -DENABLE_EXTRA_LOGS=0 -DTOOLS_BUILD=all -DSCRIPTS=static -DMODULES=static && \
make -j$(nproc --ignore=1) && \
make install
```

- Copy DBC files to the server and replace

```
cp -a "base mod/server/." $AC_CODE_DIR/build/data/dbc
```

- Run database updates in the database server:

```
sudo ./highelf_post_install.sh
```

- Start server

```
sudo service ac-authserver start
sudo service ac-worldserver start
```

### Client installation

- Copy the files from the "base mod/client/Data" folder into the client's Data folder

- Delete the Cache folder of the client

- Start the client

### Updating azerothcore

When updating azerothcore server follow the standard update steps found in www.azerothcore.org. Just keep in mind that you have installed a local patch and you have local changes. If any conflicts occur, that means this mod wasn't updated yet to the version of azerothcore you are trying to install. You can manually stash the changes, get the latest code, then pop the changes and fix conflicts.

## How this was built

With the help of the WoW Modding Community channel on Discord and https://github.com/araxiaonline/mod-worgoblin.

See DBC `Creation Step by Step.txt` and `DBC Creation Step by Step SQL.sql`.

## Screenshots

![abracadaniel22_highelf_azerothcore_00](https://github.com/user-attachments/assets/1dcc02a7-b7cb-445c-b559-6614f68c913e)

![abracadaniel22_highelf_azerothcore_01](https://github.com/user-attachments/assets/77effdb0-1735-4cc3-b7be-5693145ba2be)

![abracadaniel22_highelf_azerothcore_02](https://github.com/user-attachments/assets/c7c4ed6e-94cc-40ec-83f8-9a43e293b80d)

## Reporting bugs and contributing

Bug reports and contributions are welcome. Please go to the Issues tab to submit a bug or enhancement request, or submit your contribution via Pull Request.

Special thanks to [Dasbadman](https://github.com/Dasbadman) for many contributions. Including bugfixes, new features, and optional patches.