#!/bin/zsh

# START setup 
export HOMEBREW_PREFIX=$(realpath ./opt/brew)

export DYNA_PREFIX=$(realpath .)
export DYNA_BIN_DIR=$(realpath ./bin)
export DYNA_INCLUDE_DIR=$(realpath ./include)
export DYNA_LIB_DIR=$(realpath ./lib)
export DYNA_OPT_DIR=$(realpath ./opt)
export DYNA_SRC_DIR=$(realpath ./src)

export DYNA_BREW="${DYNA_BIN_DIR}/brew"
export DYNA_GCC="${DYNA_BIN_DIR}/gcc"
export DYNA_RACKET="${DYNA_BIN_DIR}/racketcgc"
export DYNA_RACO="${DYNA_BIN_DIR}/racocgc"
export DYNA_RACKET_DIR="${DYNA_OPT_DIR}/racket"

# Let homebrew do its setup...
eval "$(${DYNA_BREW} shellenv)"

export PATH="${DYNA_BIN_DIR}:${PATH}"
# export CC=${DYNA_GCC}

# END setup

# Detect if this script is being used via `source init.sh`.
IS_SOURCED=0
if [ -n "$ZSH_VERSION" ]; then 
  case $ZSH_EVAL_CONTEXT in *:file) IS_SOURCED=1;; esac
elif [ -n "$KSH_VERSION" ]; then
  [ "$(cd -- "$(dirname -- "$0")" && pwd -P)/$(basename -- "$0")" != "$(cd -- "$(dirname -- "${.sh.file}")" && pwd -P)/$(basename -- "${.sh.file}")" ] && sourced=1
elif [ -n "$BASH_VERSION" ]; then
  (return 0 2>/dev/null) && IS_SOURCED=1 
else # All other shells: examine $0 for known shell binary filenames.
     # Detects `sh` and `dash`; add additional shell filenames as needed.
  case ${0##*/} in sh|-sh|dash|-dash) IS_SOURCED=1;; esac
fi

# If not being sourced, open a new shell with the environment set up.
if [[ $IS_SOURCED == 0 ]]; then
    echo "Dropping into configured x86_64 shell..."
    echo "Check \`uname -m\` to double-check you're definitely in x86_64!"
    exec arch -x86_64 env DYNA_ENV=1 $SHELL
else
    echo "Environment configured by init.sh"
    uname -a
fi

