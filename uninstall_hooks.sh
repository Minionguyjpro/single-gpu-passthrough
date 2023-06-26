#!/bin/bash

# Change to dir of script and load variables
cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" || exit
. common.sh

# Uninstall files
rm -f \
  "$SCRIPTS_DIR"/vfio-startup.sh{,.old} \
  "$SCRIPTS_DIR"/vfio-teardown.sh{,.old} \
  "$HOOKS_DIR"/qemu{,.old}

# Remove systemd service
rm -f /etc/systemd/system/libvirt-nosleep@.service
systemctl daemon-reload
