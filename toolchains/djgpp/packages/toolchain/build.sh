#! /bin/sh

BUILD_DJGPP_VERSION=0dc28365825f853c3cc6ad0d8f10f8570bed5828
GCC_VERSION=12.2.0

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../..
. $HELPERS_DIR/functions.sh

do_make_bdir

do_http_fetch build-djgpp "https://github.com/andrewwutw/build-djgpp/archive/${BUILD_DJGPP_VERSION}.tar.gz" 'tar xzf'

./build-djgpp.sh ${GCC_VERSION}

do_clean_bdir
