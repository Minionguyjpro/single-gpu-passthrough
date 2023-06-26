#!/bin/bash

# Ensure libvirtd is installed
if [[ ! -d /etc/libvirt/ ]]; then
  echo "\"/etc/libvirt/\" doesn't exist!"
  echo "Make sure you have libvirtd installed!"
  exit 1
fi

# Change these if you want
HOOKS_DIR=/etc/libvirt/hooks
SCRIPTS_DIR=/usr/local/share/single-gpu-passthrough

# Helper stuff
function install_file() {
  if [[ $# -ne 2 ]]; then
    echo "install_file expects 2 arguments!"

    return 1
  fi

  local source="$1"
  local target="$2"

  # Ensure target is a file
  [[ -d "$target" ]] && target="$target/$(basename "$source")"

  if [[ -f "$target" ]]; then
    mv -f "$target" "$target.old"
    chmod -x "$target.old"
  fi

  sed -e "s%@HOOKS_DIR@%$HOOKS_DIR%g" -e "s%@SCRIPTS_DIR@%$SCRIPTS_DIR%g" "$source" >"$target"
  chmod +x "$target"
}

# Create all necessary dirs
mkdir -p /etc/libvirt/hooks
mkdir -p /usr/local/share/single-gpu-passthrough

# Install files
install_file hooks/vfio-startup.sh "$SCRIPTS_DIR"
install_file hooks/vfio-teardown.sh "$SCRIPTS_DIR"
install_file hooks/qemu "$HOOKS_DIR"

# Setup systemd service
cp -f systemd-no-sleep/libvirt-nosleep@.service /etc/systemd/system/libvirt-nosleep@.service
systemctl daemon-reload
