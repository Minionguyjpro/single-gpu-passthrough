#!/bin/bash

#############################################################################
##     ______  _                _  _______         _                 _     ##
##    (_____ \(_)              | |(_______)       | |               | |    ##
##     _____) )_  _   _  _____ | | _    _   _   _ | |__   _____   __| |    ##
##    |  ____/| |( \ / )| ___ || || |  | | | | | ||  _ \ | ___ | / _  |    ##
##    | |     | | ) X ( | ____|| || |__| | | |_| || |_) )| ____|( (_| |    ##
##    |_|     |_|(_/ \_)|_____) \_)\______)|____/ |____/ |_____) \____|    ##
##                                                                         ##
#############################################################################
###################### Credits ###################### ### Update PCI ID'S ###
## Lily (PixelQubed) for editing the scripts       ## ##                   ##
## RisingPrisum for providing the original scripts ## ##   update-pciids   ##
## Void for testing and helping out in general     ## ##                   ##
## .Chris. for testing and helping out in general  ## ## Run this command  ##
## WORMS for helping out with testing              ## ## if you dont have  ##
## BrainStone for general script cleanup           ## ## names in you're   ##
##################################################### ## lspci feedback    ##
## The VFIO community for using the scripts and    ## ## in your terminal  ##
## testing them for us!                            ## ##                   ##
##################################################### #######################

################################# Variables #################################

## Adds current time to var for use in echo for a cleaner log and script ##
DATE_FORMAT="%Y-%m-%d %R:%S"

################################# Functions #################################

# Log message with timestamp
function log() {
  echo "$(date +"$DATE_FORMAT") : $*"
}

################################## Script ###################################

log "Beginning of Teardown!"

############################
## Unload VFIO-PCI driver ##
############################
modprobe -r vfio_pci
modprobe -r vfio_iommu_type1
modprobe -r vfio

if grep -q "nvidia" "/tmp/vfio-gpu-type"; then
  ## Load NVIDIA drivers ##
  log "Loading NVIDIA GPU Drivers"

  modprobe drm
  modprobe drm_kms_helper
  modprobe i2c_nvidia_gpu
  modprobe nvidia
  modprobe nvidia_modeset
  modprobe nvidia_drm
  modprobe nvidia_uvm

  log "NVIDIA GPU Drivers Loaded"
fi

if grep -q "amd" "/tmp/vfio-gpu-type"; then
  ## Load AMD drivers ##
  log "Loading AMD GPU Drivers"

  modprobe drm
  modprobe amdgpu
  modprobe radeon
  modprobe drm_kms_helper

  log "AMD GPU Drivers Loaded"
fi

############################################################################################################
## Rebind VT consoles (adapted and modernised from https://www.kernel.org/doc/Documentation/fb/fbcon.txt) ##
############################################################################################################
while read -r consoleNumber; do
  if [[ -d "/sys/class/vtconsole/vtcon${consoleNumber}" && "$(grep -c "frame buffer" "/sys/class/vtconsole/vtcon${consoleNumber}/name")" -eq 1 ]]; then
    log "Rebinding console ${consoleNumber}"
    echo 1 >"/sys/class/vtconsole/vtcon${consoleNumber}/bind"
  fi
done </tmp/vfio-bound-consoles

#############################
## Restart Display Manager ##
#############################
while read -r DISPMGR; do
  if [[ -d /run/systemd/system ]]; then
    ## Make sure the variable got collected ##
    log "Var has been collected from file: $DISPMGR"

    systemctl start "$DISPMGR.service"
  fi
done </tmp/vfio-store-display-manager

log "End of Teardown!"
