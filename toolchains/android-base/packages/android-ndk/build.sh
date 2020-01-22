#! /bin/sh

NDK_VERSION=r14b
# 9 is the minimum supported API version required by ScummVM.
# 21 is the minimum supported API version for 64-bit architectures
#PLATFORM_API_VERSION=9
# Possible values: arm arm64 x86 x86_64
#PLATFORM_ARCH=arm
# Possible values: arm-linux-androideabi-4.9 aarch64-linux-android-4.9 x86-4.9 x86_64-4.9
#PLATFORM_PREFIX=arm-linux-androideabi-4.9

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../..
. $HELPERS_DIR/functions.sh

do_make_bdir

do_http_fetch "android-ndk" "https://dl.google.com/android/repository/android-ndk-${NDK_VERSION}-linux-x86_64.zip" 'unzip'

python ./build/tools/make_standalone_toolchain.py \
	--arch ${PLATFORM_ARCH} \
	--install-dir ${ANDROID_NDK_HOME}/${PLATFORM_ARCH} \
	--api ${PLATFORM_API_VERSION} \
	--force

# All these acrobatics, plus the build tools and sources, are needed for
# ndk-build. They may not all be needed for future builds that use CMake+Gradle
# instead.
mkdir -p ${ANDROID_NDK_HOME}/toolchains/${PLATFORM_PREFIX}/prebuilt/
ln -s ${ANDROID_NDK_HOME}/${PLATFORM_ARCH}/ ${ANDROID_NDK_HOME}/toolchains/${PLATFORM_PREFIX}/prebuilt/linux-x86_64
mv build ${ANDROID_NDK_HOME}/build
mv sources ${ANDROID_NDK_HOME}/sources
mkdir -p ${ANDROID_NDK_HOME}/platforms/android-${PLATFORM_API_VERSION}/
ln -s ${ANDROID_NDK_HOME}/${PLATFORM_ARCH}/sysroot ${ANDROID_NDK_HOME}/platforms/android-${PLATFORM_API_VERSION}/arch-${PLATFORM_ARCH}

do_clean_bdir
