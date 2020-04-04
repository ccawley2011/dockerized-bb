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

ENV HOST=i686-linux-android PREFIX=${ANDROID_NDK_HOME}/libs/i686-linux-android

# We add PATH here for *-config and platform specific binaries
ENV \
	def_binaries(`${HOST}-', `ar, as, c++filt, dwp, ld, nm, objcopy, objdump, ranlib, readelf, strings, strip') \
	CC=i686-linux-android16-clang \
# i686-linux-android16-clang++ is a wrapper script which sets up the Android API version correctly
	CXX=i686-linux-android16-clang++ \
	def_aclocal(`${PREFIX}') \
	def_pkg_config(`${PREFIX}') \
	CPPFLAGS="-isystem ${PREFIX}/include" \
	LDFLAGS="-L${PREFIX}/lib" \
        PATH=$PATH:${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/bin:${PREFIX}/bin

# Android comes with a suitable zlib already

helpers_package(libpng1.6)

helpers_package(libjpeg-turbo)

helpers_package(faad2)

RUN lib-helpers/packages/libmad/build.sh

helpers_package(libogg)

RUN lib-helpers/packages/libtheora/build.sh

local_package(libvorbis)

helpers_package(flac)

RUN lib-helpers/packages/mpeg2dec/build.sh

RUN lib-helpers/packages/a52dec/build.sh

# helpers_package(curl, --without-ssl)

helpers_package(freetype)

helpers_package(fluidsynth-lite)

# HACK: The zlib library provided by the toolchain does not have a .pc file
RUN sed -i '/zlib/d' ${PREFIX}/lib/pkgconfig/*.pc
