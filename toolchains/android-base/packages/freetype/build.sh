#! /bin/sh

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../..
. $HELPERS_DIR/functions.sh

do_make_bdir

do_pkg_fetch freetype
tar xf freetype-2*.tar.bz2
cd freetype*/

do_configure
do_make
do_make install

do_clean_bdir
