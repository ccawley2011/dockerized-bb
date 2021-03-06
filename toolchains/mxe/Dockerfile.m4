FROM toolchains/common AS helpers

m4_include(`paths.m4')m4_dnl

m4_include(`packages.m4')m4_dnl
m4_define(`mxe_package', RUN cd "${MXE_DIR}" && \
	$3 make $1 $2 PREFIX="${MXE_PREFIX_DIR}" && \
	make PREFIX="${MXE_PREFIX_DIR}" clean-junk && \
	rm -f $HOME/.wget-hsts && find /tmp -mindepth 1 -delete)m4_dnl
m4_dnl FIXME: don't hardcode /usr/src here
m4_define(`local_mxe_package', COPY packages/$1 lib-helpers/packages/$1/
mxe_package($1, MXE_PLUGIN_DIRS="/usr/src/lib-helpers/packages/$1/" $2, $3))


FROM debian:stable-slim
USER root

WORKDIR /usr/src

# Copy and execute each step separately to avoid invalidating cache
COPY --from=helpers /lib-helpers/prepare.sh lib-helpers/
RUN lib-helpers/prepare.sh

COPY --from=helpers /lib-helpers/functions.sh lib-helpers/

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		bison \
		flex \
		g++ \
		gperf \
		intltool \
		libgdk-pixbuf2.0-bin \
		libssl-dev \
		libtool-bin \
		lzip \
		p7zip-full \
		python \
		ruby && \
	rm -rf /var/lib/apt/lists/*

# MXE_DIR is where tree will be located and MXE_PREFIX_DIR is where stuff gets installed
# As MXE changes are mainly packages related, set version here instead of in toolchain script
ENV MXE_DIR=/opt/mxe-src \
	MXE_PREFIX_DIR=/opt/mxe \
	MXE_VERSION=2d95bd76abfbba76af6f856c7fbac276f8808a48

local_package(toolchain)

# Install CMake now as it's used for several packages later as it's cleaner
# That will install cmake configuration files as well
mxe_package(cmake)

# Install everything through MXE to not mess with environment variables
# This lets MXE build all platforms and avoids to mess with its settings

mxe_package(zlib)

mxe_package(libpng)

# Patch libjpeg-turbo to not install it in its own subdirectory
local_mxe_package(libjpeg-turbo)

mxe_package(faad2)

mxe_package(libmad)

mxe_package(ogg)

mxe_package(theora)

mxe_package(vorbis)

mxe_package(flac)

mxe_package(libmpeg2)

mxe_package(a52dec)

# No iconv as Win32 API is used instead

local_mxe_package(curl-light)

mxe_package(freetype-bootstrap)

mxe_package(fribidi)

mxe_package(glew)

mxe_package(sdl2)

mxe_package(sdl2_net)

local_mxe_package(fluidsynth-light)

local_mxe_package(winsparkle)

local_mxe_package(discord-rpc)
