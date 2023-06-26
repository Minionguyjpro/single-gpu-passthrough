#!/bin/bash

# Ensure libvirtd is installed
if [[ ! -d /etc/libvirt/ ]]; then
  echo "\"/etc/libvirt/\" doesn't exist!"
  echo "Make sure you have libvirtd installed!"
  exit 1
fi

# Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root. Re-running with sudo..."
  sudo bash "-$-" -- "$0" "$@"
  # Preserve the exit code of the original script
  exit
fi

. install_variables.sh
