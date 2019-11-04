#! /bin/sh

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../..
. $HELPERS_DIR/functions.sh

do_make_bdir

do_pkg_fetch mpeg2dec

# mpeg2dec has an outdated autotools config which does not know of androideabi,
# so replace it with a new one
rm -rf .auto
dh_update_autotools_config
autoreconf -i

# mpeg2dec includes non-PIC ARM assembly which is forbidden in Android 23+, so
# disable it from being used
sed -i 's/arm\*)/xxarmxx)/' configure

do_configure
do_make -C libmpeg2
do_make -C libmpeg2 install
# No need to build includes
do_make -C include install

do_clean_bdir
