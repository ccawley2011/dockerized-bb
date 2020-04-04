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

# 9 is the minimum supported API version required by ScummVM.
RUN PLATFORM_API_VERSION=9 \
	PLATFORM_ARCH=arm \
	PLATFORM_PREFIX=arm-linux-androideabi-4.9 \
	lib-helpers/packages/android-ndk/build.sh

ENV HOST=arm-linux-androideabi PREFIX=${ANDROID_NDK_HOME}/arm/arm-linux-androideabi

# We add PATH here for *-config and platform specific binaries
ENV \
	def_binaries(`${HOST}-', `ar, as, c++filt, ld, nm, objcopy, objdump, ranlib, readelf, strings, strip') \
	def_binaries(`${HOST}-', `clang, cpp, c++') \
	CC=${HOST}-clang \
# clang++ is a wrapper script which sets up the Android API version correctly
	CXX=${HOST}-clang++ \
	def_aclocal(`${PREFIX}') \
	def_pkg_config(`${PREFIX}') \
	CPPFLAGS="-isystem ${ANDROID_NDK_HOME}/arm/${HOST}/include" \
	LDFLAGS="-L${ANDROID_NDK_HOME}/arm/${HOST}/lib" \
        PATH=$PATH:${ANDROID_NDK_HOME}/arm/bin:${ANDROID_NDK_HOME}/arm/${HOST}/bin

# Android comes with a suitable zlib already

helpers_package(libpng1.6)

helpers_package(libjpeg-turbo)

helpers_package(faad2)

RUN lib-helpers/packages/libmad/build.sh

helpers_package(libogg)

RUN lib-helpers/packages/libtheora/build.sh

helpers_package(libvorbis)

helpers_package(flac)

RUN lib-helpers/packages/mpeg2dec/build.sh

RUN lib-helpers/packages/a52dec/build.sh

# helpers_package(curl, --without-ssl)

helpers_package(freetype)

helpers_package(fluidsynth-lite)

# HACK: The zlib library provided by the toolchain does not have a .pc file
RUN sed -i '/zlib/d' ${PREFIX}/lib/pkgconfig/*.pc
