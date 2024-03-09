#!/bin/sh
# This script is called once after inital setup

# prepare swap
fallocate -l 128M /mnt/swap
mkswap /mnt/swap
chmod 0600 /mnt/swap

##############################
# static data setup
##############################

static_dir="/mnt/data/.klipper_mod/static"
mkdir -p $static_dir

setup_static_data()
{
  # initial static data is initialized from the chroot
  if [ ! -e "$static_dir/$1" ]; then
    mkdir -p "$static_dir/"$(dirname "$1")
    mv "$1" "$static_dir/$1"
  fi

  # symlink the target to the static data dir
  rm -rf "$1"
  ln -s "$static_dir$1" "$1"
}

# keep essential network settings
setup_static_data /etc/hostname
setup_static_data /var/lib/iwd
setup_static_data /etc/network/interfaces

# keep dropbear keys (that is a symlink to /var/run/dropbear originally)
rm -f /etc/dropbear
mkdir -p /etc/dropbear
setup_static_data /etc/dropbear

# keep moonraker database
mkdir -p /root/printer_data/database
setup_static_data /root/printer_data/database
# keep gcode files
mkdir -p /root/printer_data/gcodes
setup_static_data /root/printer_data/gcodes

##############################
# user provided overlay
##############################

# install usb flash drive is mounted to /media if available
if [ -d /media/klipper_mod/ ]; then
    # copy everything into the chroot
    rsync -rltvK /media/klipper_mod/* /
fi
umount /media
