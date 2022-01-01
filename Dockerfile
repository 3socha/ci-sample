FROM ubuntu:21.10 as builder
ARG TARGETARCH
ENV DEBIAN_FRONTEND noninteractive
RUN apt update -qq \
  && apt install -y -qq curl git libmecab-dev mecab build-essential ca-certificates
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd
COPY pre/mecab-ipadic/mecab-ipadic-2.7.0-20070801.tar.gz /mecab-ipadic-neologd/build/
RUN mkdir /mecab-ipadic-neologd-utf8
RUN apt install -y -qq file
RUN /mecab-ipadic-neologd/bin/install-mecab-ipadic-neologd -u -y -p /mecab-ipadic-neologd-utf8
COPY pre/egison/egison-linux-${TARGETARCH}.tar.gz /egison/
RUN if [ "$(uname -m)" = "x86_64" ]; then curl -sfSL https://github.com/egison/egison-package-builder/releases/download/4.1.3/egison-4.1.3.x86_64.deb -o /egison/egison.deb; fi

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
RUN --mount=type=bind,target=/egison,from=builder,source=/egison \
  case $(uname -m) in \
    x86_64) dpkg --install /egison/egison.deb ;; \
    aarch64) mkdir -p /usr/lib/egison; tar xf /egison/egison-*.tar.gz -C /usr/lib/egison --strip-components 1 ;; \
  esac
ENV PATH $PATH:/usr/lib/egison/bin
