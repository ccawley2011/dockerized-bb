#! /bin/sh

TOOLCHAIN_VERSION=724a64c6e0c95a8f548be23a084843200d11e63d

# Versions of components to use provided by toolchain
BINUTILS_VER=2.23.2
GCC_VER=8

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../..
. $HELPERS_DIR/functions.sh

do_make_bdir

do_git_fetch adtools "https://github.com/sba1/adtools.git" "${TOOLCHAIN_VERSION}"

# gild uses git am which needs author information
# Don't pollute home directory
HOME="$(pwd)" git config --global user.email "nobody@localhost"
HOME="$(pwd)" git config --global user.name "Gild patch"

# Don't gild clone as it will download everything
# Checkout will shallow clone what's needed, more efficient

HOME="$(pwd)" gild/bin/gild checkout binutils "${BINUTILS_VER}"
HOME="$(pwd)" gild/bin/gild checkout gcc "${GCC_VER}"

do_make -C native-build gcc-cross

# Fix missing rights for library files
chmod -R go+rX "${CROSS_PREFIX}"

do_clean_bdir

# Cleanup wget HSTS
rm -f $HOME/.wget-hsts
