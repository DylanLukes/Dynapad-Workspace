#!/bin/zsh

# ===================
# Rosetta Shenanigans
# ===================

echo -n "Checking that host architecture is x86_64... "

if [[ $(arch) == "arm64" ]]; then
    echo "NO"
    echo "Activating Rosetta 2 and re-running this script... "
    exec arch -x86_64 $SHELL -i $0
else
    echo "OK"
fi

# ================
# Useful Variables
# ================

export DYNA_BIN_DIR=$(realpath ./bin)
export DYNA_INCLUDE_DIR=$(realpath ./include)
export DYNA_LIB_DIR=$(realpath ./lib)
export DYNA_OPT_DIR=$(realpath ./opt)
export DYNA_SRC_DIR=$(realpath ./src)

# ==============
# Homebrew Setup
# ==============

export DYNA_BREW="${DYNA_BIN_DIR}/brew"

BIN_DIR=$(realpath ./bin)
HOMEBREW_PREFIX=$(realpath ./opt/brew)

echo -n "Checking if Homebrew has been cloned... "
if [[ -d "${HOMEBREW_PREFIX}/.git" ]]; then 
    echo "OK"
else
    echo "NO"
    git clone https://github.com/Homebrew/brew ${HOMEBREW_PREFIX}
fi

echo -n "Creating x86_64 brew shim at ${DYNA_BIN_DIR}/brew... "
tee ${DYNA_BREW} <<EOF > /dev/null
#!/bin/bash
exec arch -x86_64 ${HOMEBREW_PREFIX}/bin/brew "\$@"
EOF
chmod u+x ${DYNA_BREW} 
echo "OK"

echo -n "Activating brew shell environment... "
eval "$(${DYNA_BREW} shellenv)"
echo "OK"

echo -n "Updating and setting up brew... "
${DYNA_BREW} update --force --quiet
chmod -R go-w "$(${DYNA_BREW} --prefix)/share/zsh"
echo "OK"

# ===================
# GCC Toolchain Setup
# ===================
${DYNA_BREW} install gcc


# ==================
# Other Dependencies
# ==================

${DYNA_BREW} install \
    imagemagick@6 \
    poppler \
    cmake \
    ninja \
    berkeley-db

# ==================
# Other Dependencies
# ==================

