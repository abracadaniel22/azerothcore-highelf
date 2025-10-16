# Individual progression patch

Elected to give Human (and Night Elf for Hunter) starting gear to High Elves for a couple of reasons:

- Match weapon skills set by Individual Progression.
- Better alignment with Elwynn Forest quest reward weapons.
- Better alignment with Elwynn Forest art style.

## Installation

First, install the base mod.

### Server:

Copy DBC files to the server and replace

cp -a DBFilesClient/. $AC_CODE_DIR/build/data/dbc

Apply zz_highelf_individual_prog.sql to acore_world database *after* installation of Individual Progression

Restart worldserver


### Client:

Copy patch-z.mpq into the client's Data folder

Delete the Cache folder of the client

Start the client
