# Dynapad Workspace

## Directory Structure

```sh
.
├── README.md               # ⭐️ YOU ARE HERE.
├── setup.sh
├── init.sh
│
├── src/                        
│   └── dynapad/            # (Submodule) Dynapad sources.
│   └── racket/             # (Submodule) Racket 8.6 sources.
│
├── opt/
│   └── racket/             # Installation root for Racket ($RACKETDIR)
│   └── dynapad/            # Installation root for Dynapad
│
├── bin/
│   └── ...                 # Symlinks to binaries.
├── lib/                    # Symlinks to libraries.
│   └── ...
└── include/                # Symlinks to headers.
    └── ... 

```