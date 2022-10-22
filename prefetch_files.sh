#!/usr/bin/env bash
# docker build中のダウンロードに失敗しやすいファイルを事前にダウンロードしておく
set -eu

arch="${1:-$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')}"
[ "$arch" != "amd64" ] && [ "$arch" != "arm64" ] && {
  echo "$0: unsupported architecture: $arch"
  exit 1
}

DOWNLOAD_DIR=$(cd "$(dirname "$0")"; pwd)/prefetched
mkdir -p "$DOWNLOAD_DIR/$arch"

download() {
  local url="$1"
  local filename="$2"

  echo "downloading $filename ..."
  [ -f "$DOWNLOAD_DIR/$arch/$filename" ] || {
    curl -fSL --retry 5 "$url" -o "$DOWNLOAD_DIR/$arch/$filename"
  }
}

# chromium (x64 only)
if [ "$arch" = "amd64" ]; then download "https://download-chromium.appspot.com/dl/Linux_x64?type=snapshots" chrome-linux.zip; fi
if [ "$arch" = "arm64" ]; then touch "$DOWNLOAD_DIR/$arch/chrome-linux.zip" ; fi  # dummy

# nodejs
node_version="$(curl -s https://nodejs.org/dist/index.json | jq -r '[.[]|select(.lts)][0].version')"
if [ "$arch" = "amd64" ]; then download "https://nodejs.org/dist/$node_version/node-$node_version-linux-x64.tar.gz"   nodejs.tar.gz; fi
if [ "$arch" = "arm64" ]; then download "https://nodejs.org/dist/$node_version/node-$node_version-linux-arm64.tar.gz" nodejs.tar.gz; fi
