#!/bin/ash
#
# Build script helper for the haproxy sysext.
# Runs inside an ephemeral alpine container. Builds a static haproxy
# against musl with a broad feature set and installs the binary to a
# bind-mounted volume.
#
set -euo pipefail

version="$1"

name=sysstat
bins='cifsiostat iostat mpstat pidstat sa1 sa2 sadc sadf sar sysstat tapestat'

apk --no-cache add \
  build-base \
  ca-certificates \
  curl \
  automake \
  libtool

src=/tmp/sysstat-build
mkdir -p "${src}"
cd "${src}"

curl -fsSLO "https://github.com/${name}/${name}/archive/refs/tags/${version}.tar.gz"

tar -xf "${version}.tar.gz"
cd "sysstat-${version#v}"

# TODO put the systemd files into /install_root/files
# This should be the local dir
# TODO make the build script output the bins to /install_root/bins
#      check the permissions on the files 
#      
#
./configure CFLAGS='-static -s' LDFLAGS='-static -lc -ldl'

make

# TODO run make install to the right location

mkdir -p /install_root/bins/
for file in ${bins}; do
	cp "$file" /install_root/bins/
done

exit 0
