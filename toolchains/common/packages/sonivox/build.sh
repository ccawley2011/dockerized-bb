#! /bin/sh

SONIVOX_VERSION=82ff2ab1b35c777f60886e972e6b830d7c198a65

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../..
. $HELPERS_DIR/functions.sh

do_make_bdir

do_http_fetch sonivox \
	"https://github.com/pedrolcl/sonivox/archive/${SONIVOX_VERSION}.tar.gz" 'tar xzf'

# -DCMAKE_SYSTEM_NAME=Windows for Windows

do_cmake -DBUILD_SONIVOX_SHARED=OFF -DBUILD_TESTING=OFF "$@"
do_make
do_make install

do_clean_bdir
