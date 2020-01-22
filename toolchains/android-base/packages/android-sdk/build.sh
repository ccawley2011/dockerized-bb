#! /bin/sh

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../..
. $HELPERS_DIR/functions.sh

do_make_bdir

# TODO: We are forced to use this older version of the SDK tools because ScummVM
# uses the obsolete ndk-build process instead of the newer CMake+Gradle process.
SDK_VERSION=r25.2.5

mkdir -p ${ANDROID_HOME}
do_http_fetch "" "https://dl.google.com/android/repository/tools_${SDK_VERSION}-linux.zip" "unzip -d $ANDROID_HOME"

# we could probably prune tools files even more aggressively for space, if
# needed
rm -rf \
	$ANDROID_HOME/tools/apps \
	$ANDROID_HOME/tools/lib/monitor-x86 \
	$ANDROID_HOME/tools/lib/monitor-x86_64 \
	$ANDROID_HOME/tools/lib64 \
	$ANDROID_HOME/tools/proguard \
	$ANDROID_HOME/tools/qemu

# yes | sdkmanager --licenses

# android-28 is needed because the code is compiled for API 14, but the
# packaging is done for API 28, apparently for some vague manifest-related
# reason in commit a32c53f936f8b3fbf90d016d3c07de62c96798b1
yes | sdkmanager "platform-tools" "build-tools;25.0.3" "platforms;android-28"

do_clean_bdir
