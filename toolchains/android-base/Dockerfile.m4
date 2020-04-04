FROM toolchains/common AS helpers

m4_include(`packages.m4')m4_dnl

FROM debian:9.2
USER root

WORKDIR /usr/src

RUN echo "deb-src http://deb.debian.org/debian/ buster main" >> /etc/apt/sources.list && \
	apt-get update && \
	mkdir -p /usr/share/man/man1 && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		ca-certificates \
		file \
		git \
		libncurses5 \
		openjdk-8-jdk-headless \
		python \
		unzip \
		wget && \
	rm -rf /var/lib/apt/lists/*

ENV ANDROID_HOME=/opt/android/sdk
ENV ANDROID_SDK_ROOT=${ANDROID_HOME} \
    ANDROID_SDK_HOME=${ANDROID_HOME} \
    ANDROID_SDK=${ANDROID_HOME}
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

# Don't need to run prepare as everything we need is already installed (we don't use all build stuff, just fetch)

# Copy and execute each step separately to avoid invalidating cache
COPY --from=helpers /lib-helpers/functions.sh lib-helpers/

local_package(android-sdk)

RUN sdkmanager "platform-tools"

RUN sdkmanager "build-tools;29.0.3"

RUN sdkmanager "platforms;android-29"

RUN sdkmanager "ndk;21.0.6113669"

ENV ANDROID_NDK_ROOT=${ANDROID_SDK_ROOT}/ndk/21.0.6113669
ENV ANDROID_NDK_HOME=${ANDROID_NDK_ROOT} \
    ANDROID_NDK=${ANDROID_NDK_HOME}/build

COPY packages/a52dec lib-helpers/packages/a52dec/
COPY packages/libmad lib-helpers/packages/libmad/
COPY packages/libtheora lib-helpers/packages/libtheora/
COPY packages/mpeg2dec lib-helpers/packages/mpeg2dec/
