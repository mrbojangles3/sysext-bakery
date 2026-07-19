#!/bin/ash

#
# Build script helper for quemu guest agent binary
# Runs inside an ephemeral alpine container. Builds the guest agent statically

set -euo pipefail

version="$1"
export_user_group="$2"

apk update
apk --no-cache add \
	build-base \
	curl \
	python3 \
	pcre2-static \
	meson \
	glib-static \



# Qemu doesn't seem to always have verified tags and pipeline passes. Select version with care
curl -fsSLO "https://gitlab.com/qemu-project/qemu/-/archive/${version}/qemu-${version}.tar.bz2?ref_type=tags"
ls qemu-*
tar -xf "qemu-${version}-tar.bz2"
cd "qemu-${version}"
mkdir build
pushd build
../configure --enable-guest-agent \
  --disable-system \ 
  --disable-user   \
  --disable-tools  \
  --disable-docs   \
  --disable-xen    \
  --disable-werror \
  --static

# This does the build
ninja

mv qga/qemu-ga /install_root

# TODO  - check on install_root, PREFIX=/usr, SBINDIR=/usr/bin? 

chown -R "${export_user_group}"

