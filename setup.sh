#!/bin/zsh

# ===================
# Rosetta Shenanigans
# ===================

source init.sh

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
ln -sf "${HOMEBREW_PREFIX}/opt/gcc/bin/g++-12" "${DYNA_BIN_DIR}/g++"
ln -sf "${HOMEBREW_PREFIX}/opt/gcc/bin/gcc-ar-12" "${DYNA_BIN_DIR}/ar"
ln -sf "${HOMEBREW_PREFIX}/opt/gcc/bin/gcc-nm-12" "${DYNA_BIN_DIR}/nm"
ln -sf "${HOMEBREW_PREFIX}/opt/gcc/bin/gcc-ranlib-12" "${DYNA_BIN_DIR}/ranlib"

# Shadow the global `cc` and `c++` so CMake doesn't get confused.
ln -sf "${DYNA_BIN_DIR}/gcc" "${DYNA_BIN_DIR}/cc" 
ln -sf "${DYNA_BIN_DIR}/g++" "${DYNA_BIN_DIR}/c++"

# ==================
# Other Dependencies
# ==================

# Notes: 
#   - MacOS provides Tcl/Tk,  but we need an x86_64 copy.
#   - We also want our own copy of pkg-config.
${DYNA_BREW} install \
    pkg-config \
    tcl-tk \
    imagemagick@6 \
    poppler \
    cmake \
    ninja \
    berkeley-db

ln -sf "${HOMEBREW_PREFIX}/opt/pkg-config/bin/pkg-config" "${DYNA_BIN_DIR}/pkg-config"

# In our isolated x86_64 brew environment, this is safe to do. 
# Do NOT do this globally on your machine!
${DYNA_BREW} link imagemagick@6 --force

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

# ================================
# Build Dynapad as Normal (Mostly)
# ================================
