# syntax = docker/dockerfile:1.3-labs
FROM ubuntu:20.04

RUN <<EOL
  apt update
  apt install -y curl bats
  apt cache clean
  rm -rf /var/lib/apt/lists/*
EOL
