# Individual progression + arcane torrent for High Elf warriors

Contains both mods combined, since you can't install one then the other on top of it, it would replace the first one installed.

## Installation

First, install the base mod.

### Server:

Copy DBC files to the server and replace

cp -a DBFilesClient/. $AC_CODE_DIR/build/data/dbc

Apply mod-individual-progression/zz_highelf_individual_prog.sql to acore_world database *after* installation of Individual Progression

Restart worldserver


### Client:

Copy patch-z.mpq into the client's Data folder

Delete the Cache folder of the client

Start the client
