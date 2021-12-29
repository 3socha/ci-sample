# syntax = docker/dockerfile:1.3-labs
FROM ubuntu:21.10
ENV DEBIAN_FRONTEND noninteractive
RUN <<EOL
  apt update
  apt install -y curl bats
  apt cache clean
  rm -rf /var/lib/apt/lists/*
EOL
