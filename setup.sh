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

DYNA_BIN_DIR=$(realpath ./bin)
DYNA_INCLUDE_DIR=$(realpath ./include)
DYNA_LIB_DIR=$(realpath ./lib)
DYNA_OPT_DIR=$(realpath ./opt)
DYNA_SRC_DIR=$(realpath ./src)

DYNA_BREW="${DYNA_BIN_DIR}/brew"
DYNA_GCC="${DYNA_BIN_DIR}/gcc"
DYNA_RACKET="${DYNA_BIN_DIR}/racketcgc"
DYNA_RACO="${DYNA_BIN_DIR}/racocgc"

# ==============
# Homebrew Setup
# ==============

export HOMEBREW_PREFIX=$(realpath ./opt/brew)

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

# To avoid fragility with linking (since brew doesn't link gcc -> gcc-\d+), pin v12.
${DYNA_BREW} install gcc@12

ln -sf "${HOMEBREW_PREFIX}/opt/gcc/bin/gcc-12" "${DYNA_BIN_DIR}/gcc"

# ==================
# Other Dependencies
# ==================

${DYNA_BREW} install \
    imagemagick@6 \
    poppler \
    cmake \
    ninja \
    berkeley-db

# ======
# Racket 
# ======

export CC=${DYNA_GCC}
export CFLAGS="-L${HOMEBREW_PREFIX}/include -I${HOMEBREW_PREFIX}/lib"

pushd src/racket/racket/src  # yes... I know... I know...

./configure --enable-macprefix --prefix="${DYNA_OPT_DIR}/racket" \
    --enable-float \
    --enable-foreign \
    --disable-libs \
    --disable-bcdefault \
    --disable-csdefault \
    --enable-cs \
    --enable-bc \
    --enable-gracket \
    --enable-jit \
    --enable-places \
    --enable-futures \
    --enable-pthread \
    --enable-libffi

make cgc
make install-cgc

popd # src/racket/racket/src

ln -sf ${DYNA_OPT_DIR}/racket/bin/* ${DYNA_BIN_DIR}

