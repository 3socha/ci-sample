FROM ubuntu:21.10 as builder
ENV DEBIAN_FRONTEND noninteractive
RUN apt update -qq \
  && apt install -y -qq curl git libmecab-dev mecab build-essential ca-certificates
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd
COPY pre/mecab-ipadic/mecab-ipadic-2.7.0-20070801.tar.gz /mecab-ipadic-neologd/build/
RUN mkdir /mecab-ipadic-neologd-utf8
RUN apt install -y -qq file
RUN /mecab-ipadic-neologd/bin/install-mecab-ipadic-neologd -u -y -p /mecab-ipadic-neologd-utf8

FROM ubuntu:21.10 as runtime
ARG TARGETARCH
ENV DEBIAN_FRONTEND noninteractive
RUN apt update -qq \
  && apt install -y -qq curl bats git mecab mecab-ipadic mecab-ipadic-utf8 language-pack-ja locales \
  && rm -rf /var/lib/apt/lists/*
RUN locale-gen ja_JP.UTF-8
ENV LANG=ja_JP.UTF-8
COPY pre/${TARGETARCH}/arch.txt .
RUN --mount=type=bind,target=/mecab-ipadic-neologd-utf8,from=builder,source=/mecab-ipadic-neologd-utf8 \
  cp -r /mecab-ipadic-neologd-utf8/* /var/lib/mecab/dic/ipadic-utf8/
