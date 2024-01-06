m4_include(`paths.m4')m4_dnl
m4_include(`packages.m4')m4_dnl

m4_dnl Include Debian base preparation steps
m4_dnl This ensures all common steps are shared by all toolchains
m4_include(`debian-toolchain-base.m4')m4_dnl

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		bison \
		flex \
		curl \
		gcc \
		g++ \
		make \
		texinfo \
		zlib1g-dev \
		unzip \
		nasm && \
	rm -rf /var/lib/apt/lists/*

ENV DJGPP_PREFIX=/usr/local/djgpp

local_package(toolchain)

ENV PREFIX=${DJGPP_PREFIX}/i586-pc-msdosdjgpp HOST=i586-pc-msdosdjgpp

ENV \
	def_binaries(`${DJGPP_PREFIX}/bin/${HOST}-', `ar, as, c++filt, ld, nm, objcopy, objdump, ranlib, readelf, strings, strip') \
	def_binaries(`${DJGPP_PREFIX}/bin/${HOST}-', `gcc, cpp, c++') \
	CC="${DJGPP_PREFIX}/bin/${HOST}-gcc" \
	def_aclocal(`${PREFIX}') \
	def_pkg_config(`${PREFIX}') \
	PATH="${PATH}:${DJGPP_PREFIX}/bin"

helpers_package(zlib)

helpers_package(libpng1.6)

helpers_package(libjpeg-turbo, -DWITH_SIMD=0)

helpers_package(giflib)

helpers_package(libmad)

COPY packages/libogg lib-helpers/packages/libogg
helpers_package(libogg)

helpers_package(libvorbis)

COPY packages/libvorbisidec lib-helpers/packages/libvorbisidec
helpers_package(libvorbisidec)

helpers_package(libtheora)

helpers_package(flac, --disable-stack-smash-protection)

helpers_package(libmikmod)

helpers_package(faad2)

# error: requested alignment '32' exceeds object file maximum 16
# helpers_package(mpeg2dec)

helpers_package(a52dec)

# error: requested alignment '256' exceeds object file maximum 16
# helpers_package(libvpx, --disable-multithread)

# helpers_package(openssl)

# helpers_package(curl)

# Check for working C compiler: /usr/local/djgpp/bin/i586-pc-msdosdjgpp-gcc - broken
# error: unrecognized command-line option '-rdynamic'
# helpers_package(fluidlite)

helpers_package(freetype, , CPPFLAGS="-U__STRICT_ANSI__")

helpers_package(fribidi, , CPPFLAGS="-U__STRICT_ANSI__")

# helpers_package(libsdl1.2)

# helpers_package(sdl-net1.2)
