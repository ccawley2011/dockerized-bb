#! /bin/sh

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../..
. $HELPERS_DIR/functions.sh

do_make_bdir

do_pkg_fetch libtheora

# libtheora has an outdated autotools config which does not know of androideabi,
# so replace it with a new one
dh_update_autotools_config

# Avoid compiling and installing doc
sed -ie 's/^\(SUBDIRS.*\) doc/\1/' Makefile.am

autoreconf -fi -I m4
do_configure --disable-examples --disable-spec --disable-doc
do_make
do_make install

do_clean_bdir
