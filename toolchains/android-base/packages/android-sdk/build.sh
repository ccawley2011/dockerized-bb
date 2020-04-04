#! /bin/sh

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../..
. $HELPERS_DIR/functions.sh

do_make_bdir

SDK_VERSION=3859397

mkdir -p ${ANDROID_HOME}
do_http_fetch "" "https://dl.google.com/android/repository/sdk-tools-linux-${SDK_VERSION}.zip" "unzip -d $ANDROID_HOME"

yes | sdkmanager --licenses

do_clean_bdir
