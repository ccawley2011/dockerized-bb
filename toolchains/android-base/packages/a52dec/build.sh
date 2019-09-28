#! /bin/sh

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../..
. $HELPERS_DIR/functions.sh

do_make_bdir

do_pkg_fetch a52dec

# liba52 has an outdated autotools config which does not know of androideabi,
# so replace it with a new one
dh_update_autotools_config

do_configure
do_make -C liba52
do_make -C liba52 install
# No need to build includes
do_make -C include install

do_clean_bdir
