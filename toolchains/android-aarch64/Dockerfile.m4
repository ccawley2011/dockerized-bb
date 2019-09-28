FROM toolchains/common AS helpers

m4_include(`paths.m4')m4_dnl

m4_include(`packages.m4')m4_dnl

FROM toolchains/android-base
USER root

WORKDIR /usr/src

# Copy and execute each step separately to avoid invalidating cache
COPY --from=helpers /lib-helpers/prepare.sh lib-helpers/
RUN lib-helpers/prepare.sh

COPY --from=helpers /lib-helpers/functions.sh lib-helpers/

# 21 is the minimum supported API version for 64-bit architectures.
RUN PLATFORM_API_VERSION=21 \
	PLATFORM_ARCH=arm64 \
	PLATFORM_PREFIX=aarch64-linux-android-4.9 \
	lib-helpers/packages/android-ndk/build.sh

ENV HOST=aarch64-linux-android PREFIX=${ANDROID_NDK_HOME}/arm64/aarch64-linux-android

# We add PATH here for *-config and platform specific binaries
ENV \
	def_binaries(`${HOST}-', `ar, as, c++filt, ld, nm, objcopy, objdump, ranlib, readelf, strings, strip') \
	def_binaries(`${HOST}-', `clang, cpp, c++') \
	CC=${HOST}-clang \
# clang++ is a wrapper script which sets up the Android API version correctly
	CXX=${HOST}-clang++ \
	def_aclocal(`${PREFIX}') \
	def_pkg_config(`${PREFIX}') \
	CPPFLAGS="-isystem ${ANDROID_NDK_HOME}/arm64/${HOST}/include" \
	LDFLAGS="-L${ANDROID_NDK_HOME}/arm64/${HOST}/lib" \
        PATH=$PATH:${ANDROID_NDK_HOME}/arm64/bin:${ANDROID_NDK_HOME}/arm64/${HOST}/bin

# Android comes with a suitable zlib already

helpers_package(libpng1.6)

RUN lib-helpers/packages/libjpeg-turbo/build.sh

RUN lib-helpers/packages/faad2/build.sh

RUN lib-helpers/packages/libmad/build.sh

helpers_package(libogg)

RUN lib-helpers/packages/libtheora/build.sh

helpers_package(libvorbis)

helpers_package(flac)

RUN lib-helpers/packages/mpeg2dec/build.sh

RUN lib-helpers/packages/a52dec/build.sh

# helpers_package(curl, --without-ssl)

RUN lib-helpers/packages/freetype/build.sh

helpers_package(fluidsynth-lite)
