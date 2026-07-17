#!/usr/bin/env bash
# vim: et ts=2 syn=bash
#
# Extension creation skeleton script for sysext bakery extensions.
#

# Functions in this script will be called by bakery.sh.
# All library functions from lib/ will be available.

# NOTE: If you only ship static files in your sysext (in the files/ subdirectory)
#       just delete create.sh for your sysext.

# Set to "true" to cause a service units reload on merge, to make systemd aware
#  of new service files shipped by this extension.
# If you want to start your service on merge, ship an `upholds=...` drop-in
#  for `multi-user.target` in the "files/..." directory of this extension.
RELOAD_SERVICES_ON_MERGE="true"


function list_available_versions() {
  list_gitlab_tags "gitlab.com" "11167699" 
}
# --

# Download the application shipped with the sysext and populate the sysext root directory.
# This function runs in a subshell inside of a temporary work directory.
# It is safe to download / build directly in "./" as the work directory
#   will be removed after this function returns.
# Called by 'bakery.sh create <sysext>' with:
#   "sysextroot" - First positional argument.
#                    Root directory of the sysext to be created.
#   "arch"       - Second positional argument.
#                    Target architecture of the sysext.
#   "version"    - Third positional argument.
#                    Version number to build.
function populate_sysext_root() {
  local sysextroot="$1"
  local arch="$2"
  local version="$3"

  # TODO: add code to populate ${sysextroot} here.
  # e.g.
  # local rel_arch="$(arch_transform "x86-64" "amd64" "$arch")"
  # curl --parallel --fail --silent --show-error --location \
  #      --remote-name "...url..."
  # tar --force-local -xf "..." -C "${sysextroot}/usr"
  #   and / or
  # cp -a ...

  # WARNING: NEVER ship /usr/sbin in a sysext.
  # On Flatcar, /usr/sbin is a symlink to /usr/bin; shipping it in a sysext
  # would overwrite /usr/sbin at merge and make its contents disappear.
}
function populate_sysext_root() {
  local sysextroot="$1"
  local arch="$2"
  local version="$3"

  local img_arch
  img_arch="$(arch_transform 'x86-64' 'amd64' "$arch")"
  img_arch="$(arch_transform 'arm64' 'arm64/v8' "$img_arch")"

  local image="docker.io/alpine:3.21"

  announce "Building haproxy $version for $arch"

  local user_group="$(id -u):$(id -g)"

  cp "${scriptroot}/haproxy.sysext/build.sh" .
  docker run --rm \
    -i \
    -v "$(pwd)":/install_root \
    --platform "linux/${img_arch}" \
    --pull always \
    --network host \
    "${image}" \
        /install_root/build.sh "${version}" "$user_group"

  # build.sh installs to /install_root/usr; merge that on top of the
  # static files already staged in ${sysextroot}/usr. Use the /. trick
  # so cp merges into an existing directory instead of nesting.
  mkdir -p "${sysextroot}/usr"
  cp -a usr/. "${sysextroot}/usr/"
}

