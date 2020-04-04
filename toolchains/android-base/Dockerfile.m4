FROM toolchains/common AS helpers

m4_include(`packages.m4')m4_dnl

FROM debian:9.2
USER root

WORKDIR /usr/src

RUN echo "deb-src http://deb.debian.org/debian/ buster main" >> /etc/apt/sources.list && \
	apt-get update && \
	mkdir -p /usr/share/man/man1 && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		ant \
		ca-certificates \
		file \
		gradle \
		libncurses5 \
		openjdk-8-jdk-headless \
		python \
		unzip \
		wget && \
	rm -rf /var/lib/apt/lists/*

ENV ANDROID_HOME=/opt/android/sdk ANDROID_NDK_HOME=/opt/android/ndk
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

# Don't need to run prepare as everything we need is already installed (we don't use all build stuff, just fetch)

# Copy and execute each step separately to avoid invalidating cache
COPY --from=helpers /lib-helpers/functions.sh lib-helpers/

local_package(android-sdk)

COPY packages/android-ndk lib-helpers/packages/android-ndk/
COPY packages/a52dec lib-helpers/packages/a52dec/
COPY packages/faad2 lib-helpers/packages/faad2/
COPY packages/freetype lib-helpers/packages/freetype/
COPY packages/libjpeg-turbo lib-helpers/packages/libjpeg-turbo/
COPY packages/libmad lib-helpers/packages/libmad/
COPY packages/libtheora lib-helpers/packages/libtheora/
COPY packages/mpeg2dec lib-helpers/packages/mpeg2dec/

# ScummVM configure-specific
ENV ANDROID_NDK=/opt/android/ndk/build \
	ANDROID_SDK=/opt/android/sdk
