#!/bin/ash

#
# Build script helper for quemu guest agent binary
# Runs inside an ephemeral alpine container. Builds the guest agent statically

set -euo pipefail

version="$1"
export_user_group="$2"

apk update
apk --no-cache add \
	pkgconf \
	curl \
	pcre2-static \
	glib-dev \
	glib-static \
	git \
	flex \
	bison \
	build-base \
	python3 \
	meson \



# Qemu doesn't seem to always have verified tags and pipeline passes. Select version with care
curl -fsSLO "https://gitlab.com/qemu-project/qemu/-/archive/${version}/qemu-${version}.tar.bz2?ref_type=tags"
tar -xf "qemu-${version}.tar.bz2"
cd "qemu-${version}"
mkdir build
cd build
../configure \
  --target-list= \
  --without-default-features \
  --enable-guest-agent \
  --qemu-ga-distro=flatcar \
  --qemu-ga-manufacturer=flatcar \
  --static

# This does the build
ninja qemu-ga

mv qga/qemu-ga /install_root/

# TODO  - check on install_root, PREFIX=/usr, SBINDIR=/usr/bin? 
chown -R "${export_user_group}" /install_root/

