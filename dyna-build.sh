# ========
# libpad++
# ========

# NOTE: This is needed for CMake's find_package to correctly find ImageMagick
# later because homebrew treats imagemagick@6 as cask only!
export PATH="${HOMEBREW_PREFIX}/opt/imagemagick@6/bin:${PATH}"
export CFLAGS="${CFLAGS}"

pushd src/dynapad
rm -fr build
mkdir build

pushd build
cmake .. -G Ninja -DRACKET_DIR="${DYNA_OPT_DIR}/racket"
ninja
popd # build

# =======
# Dynapad
# =======

# Disabled until cmake issue above can be figured out.

${DYNA_RACO} pkg install cext-lib  # needed for racocgc ctool below
${DYNA_RACO} pkg install --no-docs --auto gui compatibility # needed for dynapad (docs are missing, need to skip)

SUBPATH=$(${DYNA_RACKET} -e "(display (path->string (system-library-subpath)))")
SO_SUFFIX=$(${DYNA_RACKET} -e "(display (bytes->string/utf-8 (system-type 'so-suffix)))")

mkdir -p dynapad/compiled/bc/native/${SUBPATH}
${DYNA_RACO} ctool --cgc \
    ++ldf -Wl,-rpath,"${PWD}/build/" \
    --ld dynapad/compiled/bc/native/${SUBPATH}/libdynapad_rkt${SO_SUFFIX} \
    "${PWD}/build/libdynapad${SO_SUFFIX}"
${DYNA_RACO} pkg install dynapad-collects/ dynapad/
${DYNA_RACO} make dynapad/base.rkt
${DYNA_RACO} make apps/paddraw/paddraw.rkt
${DYNA_RACO} make apps/uberapp/uberapp.rkt