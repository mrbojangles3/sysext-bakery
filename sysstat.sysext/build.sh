#!/bin/ash
#
# Build script helper for the haproxy sysext.
# Runs inside an ephemeral alpine container. Builds a static haproxy
# against musl with a broad feature set and installs the binary to a
# bind-mounted volume.
#
set -euo pipefail

set -x

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
cd "sysstat-${version#v}" # TODO without the "v" for reasons

# TODO figure out the systemd files etc. 

./configure CFLAGS='-static -s' LDFLAGS='-static -lc -ldl'

make

# TODO make a list of all the executables to move to their final spot
#make install-bin DESTDIR=/install_root PREFIX=/usr SBINDIR=/usr/bin

#rm -rf /install_root/usr/share /install_root/usr/doc /install_root/etc

for file in ${bins}; do
	cp "$file" /install_root/
done

exit 0
