#!/bin/sh

echo "Building pivot_root based setup"
echo "Partition info:"
echo "/dev/sda1 init-system with kernel modules"
echo "/dev/sda2 Base system"
echo "/dev/sda3 Linux-swap"
echo "/dev/sda4 Data partition"

../parted <<EOF
mklabel gpt
mkpart primary ext3 65536s 589823s
mkpart primary ext3 589824s 17367039s
mkpart primary linux-swap 17367040s 18415615s
mkpart primary ext4 18415616s -1s
quit
EOF
# Restore special MBR of PLX
dd if=mbr.bin of=/dev/sda count=446 bs=1
