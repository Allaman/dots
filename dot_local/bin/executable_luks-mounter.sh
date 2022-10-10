#!/bin/bash

# Mount a luks encrypted file system

for i in "$@"
do

  case $i in
    -m|--mount)
      echo "Decrypt container and mount device to /mnt"
      sudo cryptsetup luksOpen /dev/sdb volume01 ## NOTE: adjust device
      sudo vgchange -ay
      sudo mount /dev/mapper/volume01 /mnt
      echo "Mounted..."
      shift
      ;;
    -u|--umount)
      echo "Umounting and closing container"
      sudo umount /mnt
      sudo cryptsetup luksClose /dev/mapper/volume01
      echo "Done"
      shift
      ;;
    \?)
      echo "invalid option"
  esac
done
