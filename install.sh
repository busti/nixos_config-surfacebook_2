#!/bin/sh
set -e

DEVICE="/dev/nvme0n1"
PART_BOOT="p5"
PART_ROOT="p6"

mkdir ~/install
( cd ~/install
  # echo -n "luks password: "
  # read -s LUKS_PASSWORD

  # echo -n "root password: "
  # read -s ROOT_PASSWORD

  # echo -n "user password: "
  # read -s user_password_in

  LUKS_PASSWORD='changeme'
  ROOT_PASSWORD='changeme'

  echo "unmounting lvm image if present"
  if [ -d /dev/vg0 ]; then
    mount | grep target | awk '{print $3}' | sort -r | while read LINE; do
      umount -l $LINE
    done
    if [ -b /dev/vg0/swap ]; then
      swapoff /dev/vg0/swap || true
    fi
    vgchange -an /dev/vg0
  fi

  if [ -b /dev/mapper/cryptlvm ]; then
    cryptsetup luksClose cryptlvm
  fi

  lsblk

  echo "deleting old linux partitions if present"
  (
    echo d # delete a partition
    echo 5 # partition number	=> 5
    echo d # delete a partition
    echo 6 # partition number	=> 6
    echo w # write changes to disk
  ) | fdisk "$DEVICE"

  lsblk

  echo "partitioning disk"
  (
    echo n   # add a new partition	=> boot
    echo     # partition number		=> count + 1
    echo     # first sector		=> after last
    echo +1G # last sector		=> 2GB size
    echo n   # add a new partition	=> root
    echo     # partition number		=> count + 1
    echo     # first sector		=> after last
    echo     # last sector		=> fill remaining space
    echo t   # change partition type
    echo 5   # select partition 5 => /boot
    echo 1   # select efi partition type
    echo w   # write changes to disk
  ) | fdisk "$DEVICE"

  lsblk

  echo "generating boot partition filesystem"
  yes | mkfs.fat -F 32 -n boot "$DEVICE$PART_BOOT"

  echo "setting up cryptlvm"
  (
    echo $LUKS_PASSWORD
    echo $LUKS_PASSWORD
  ) | cryptsetup -q luksFormat --label cryptroot "$DEVICE$PART_ROOT"
  BOOT_UUID=$(blkid -s UUID -o value "$DEVICE$PART_ROOT")
  echo $LUKS_PASSWORD | cryptsetup luksOpen "/dev/disk/by-uuid/$BOOT_UUID" cryptlvm
  pvcreate /dev/mapper/cryptlvm
  vgcreate vg0 /dev/mapper/cryptlvm

  echo "creating swap volume"
  lvcreate /dev/vg0 -n swap -L 8G
  mkswap -L swap /dev/vg0/swap
  swapon /dev/disk/by-label/swap

  echo "creating radix volume"
  lvcreate /dev/vg0 -n radix -l 100%FREE
  yes | mkfs.ext4 -L radix /dev/vg0/radix

  sleep 1

  echo "mounting radix directory to /mnt"
  mount /dev/disk/by-label/radix /mnt

  echo "mounting boot partition"
  mkdir /mnt/boot
  mount /dev/disk/by-label/boot /mnt/boot

  lsblk

  mkdir /mnt/tmp

  echo "cloning nixos config"
  mkdir /mnt/etc
  git clone https://github.com/busti/nixos_config-surfacebook_2 /mnt/etc/nixos

  echo -n "/dev/disk/by-uuid/$BOOT_UUID" > /mnt/etc/nixos/uuid_boot

  nixos-generate-config --root /mnt

  echo "installing"
  nixos-install
  nixos-enter --root /mnt
  (
    echo $ROOT_PASSWORD
    echo $ROOT_PASSWORD
  ) | passwd
  exit
)
