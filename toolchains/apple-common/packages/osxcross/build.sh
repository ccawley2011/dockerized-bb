#! /bin/sh

OSXCROSS_VERSION=a78f48ae2ae5c1b2d968d386e59f691d7a331b11
export XAR_VERSION=fb897139262d7ac5c9e187a9f9c219255f465983

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../..
. $HELPERS_DIR/functions.sh

do_make_bdir

do_git_fetch osxcross "https://github.com/tpoechtrager/osxcross.git" "${OSXCROSS_VERSION}"

# Link SDK tarballs
for f in "${SDK_DIR}"/*; do
	ln -s "$f" tarballs/
done

# This will let build.sh use our own clang
export PATH=$PATH:${TARGET_DIR}/bin

# Don't ask anything
UNATTENDED=1 ./build.sh

# Prevent installation
sed -i -e '/mkdir -p \${CLANG_INCLUDE_DIR}/,+1d' ./build_compiler_rt.sh

./build_compiler_rt.sh

BDIR=$PWD/build

# Copy to built files to our place
mkdir -p ${TARGET_DIR}/compiler_rt/include ${TARGET_DIR}/compiler_rt/lib/darwin
cp -rv $BDIR/compiler-rt/compiler-rt/include/sanitizer ${TARGET_DIR}/compiler_rt/include/
cp -v  $BDIR/compiler-rt/compiler-rt/build/lib/darwin/*.a ${TARGET_DIR}/compiler_rt/lib/darwin/
cp -v  $BDIR/compiler-rt/compiler-rt/build/lib/darwin/*.dylib ${TARGET_DIR}/compiler_rt/lib/darwin/

# Now install manually by linking
CLANG_LIB_DIR=$(clang -print-search-dirs | grep "libraries: =" | \
	                tr '=' ' ' | tr ':' ' ' | awk '{print $2}')
CLANG_INCLUDE_DIR="${CLANG_LIB_DIR}/include"
CLANG_DARWIN_LIB_DIR="${CLANG_LIB_DIR}/lib/darwin"

# Don't install includes, they are already here
mkdir -p "$(dirname "${CLANG_DARWIN_LIB_DIR}")"
ln -s ${TARGET_DIR}/compiler_rt/lib/darwin ${CLANG_DARWIN_LIB_DIR}

do_clean_bdir
