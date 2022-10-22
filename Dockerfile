# syntax = docker/dockerfile:latest
FROM ubuntu:22.04 AS apt-cache
RUN apt-get update

FROM ubuntu:22.04 AS base
ENV DEBIAN_FRONTEND noninteractive
RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/no-install-recommends
RUN --mount=type=bind,target=/var/lib/apt/lists,from=apt-cache,source=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt \
    apt-get install -y -qq build-essential ca-certificates curl git unzip

## Node.js
FROM base AS nodejs-builder
ARG TARGETARCH
COPY prefetched/$TARGETARCH/nodejs.tar.gz .
RUN tar xf nodejs.tar.gz \
    && mv node-* /usr/local/nodejs
ENV PATH $PATH:/usr/local/nodejs/bin
RUN --mount=type=cache,target=/root/.npm \
    npm install -g --silent faker-cli chemi fx yukichant @amanoese/muscular kana2ipa receiptio bats
# enable png output on receiptio; do not install chromium here
RUN --mount=type=cache,target=/root/.npm \
    if [ "${TARGETARCH}" = "amd64" ]; then npm install -g puppeteer --ignore-scripts; fi \
    && sed "s/puppeteer.launch({/& args: ['--no-sandbox'],/" -i /usr/local/nodejs/lib/node_modules/receiptio/lib/receiptio.js

## General
FROM base AS general-builder
ARG TARGETARCH
WORKDIR /downloads

# Chromium
COPY prefetched/$TARGETARCH/chrome-linux.zip .
WORKDIR /

## Runtime
FROM base AS runtime
ARG TARGETARCH

# Set environments
ENV LANG ja_JP.UTF-8
ENV TZ JST-9
ENV PATH /usr/games:$PATH
# for idn command
ENV CHARSET UTF-8

# apt
RUN --mount=type=bind,target=/var/lib/apt/lists,from=apt-cache,source=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt \
    apt-get install -y -qq \
      language-pack-ja-base language-pack-ja

# Node.js
COPY --from=nodejs-builder /usr/local/nodejs /usr/local/nodejs
ENV PATH $PATH:/usr/local/nodejs/bin

# chromium
RUN --mount=type=bind,target=/downloads,from=general-builder,source=/downloads \
    if [ "${TARGETARCH}" = "amd64" ]; then unzip /downloads/chrome-linux.zip -d /usr/local; fi
ENV PUPPETEER_EXECUTABLE_PATH=/usr/local/chrome-linux/chrome
ENV PATH $PATH:/usr/local/chrome-linux

# reset apt config
RUN rm /etc/apt/apt.conf.d/keep-cache /etc/apt/apt.conf.d/no-install-recommends
COPY --from=ubuntu:22.04 /etc/apt/apt.conf.d/docker-clean /etc/apt/apt.conf.d/
