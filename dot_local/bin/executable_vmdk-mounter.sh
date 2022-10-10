#!/bin/bash

# Mount a VirtualBox Machine Disk

for i in "$@"
do

  case $i in
    -m|--mount)
      echo "modprobe nbd, creating device and mounting"
      sudo rmmod nbd
      sudo modprobe nbd max_part=63
      sudo qemu-nbd -c /dev/nbd0 '$HOME/disk1.vmdk' # NOTE: adjust file
      echo "Device created"
      if [[ -f /dev/nbd0p1 ]]
      then
        sudo mount /dev/nbd0p1 /mnt
      else
        sudo partprobe /dev/nbd0
        sudo mount /dev/nbd0p1 /mnt
      fi
      echo "Mounted at /mnt"
      shift
      ;;
    -u|--umount)
      echo "Unmounting, deleting device and removing nbd module"
      sudo umount /mnt
      sudo qemu-nbd -d /dev/nbd0
      sudo rmmod nbd
      shift
      echo "Done"
      ;;
    \?)
      echo "invalid option"
  esac
done
