#!/bin/bash

# Ensure libvirtd is installed
if [[ ! -d /etc/libvirt/ ]]; then
  echo "\"/etc/libvirt/\" doesn't exist!"
  echo "Make sure you have libvirtd installed!"
  exit 1
fi

# Change to dir of script and load variables
cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" || exit
. install_variables.sh

# Uninstall files
rm -f \
  "$SCRIPTS_DIR/vfio-startup.sh" \
  "$SCRIPTS_DIR/vfio-teardown.sh" \
  "$HOOKS_DIR/qemu"

# Remove systemd service
cp -f systemd-no-sleep/libvirt-nosleep@.service /etc/systemd/system/libvirt-nosleep@.service
systemctl daemon-reload
