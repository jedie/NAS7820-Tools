#!/bin/sh

stage1variant=750
disk=/dev/sda

/sbin/dhcpc -i egiga0
if [ $? == 0 ]; then
    echo "OK, get IP via DHCP"
else
    echo "Error: Cannot get IP via DHCP!"
    echo "continue boot process..."
    exit 1
fi

dd if=/dev/zero of=$disk bs=512 count=65536
dd if=mbr.bin of=$disk bs=512
dd if=stage1.wrapped$stage1variant of=$disk bs=512 seek=34
dd if=stage1.wrapped$stage1variant of=$disk bs=512 seek=57088
dd if=u-boot.wrapped of=$disk bs=512 seek=154
dd if=u-boot.wrapped of=$disk bs=512 seek=57208
dd if=uImage.nopci of=$disk bs=512 bs=512 seek=1290
dd if=uImage.nopci of=$disk bs=512 bs=512 seek=58344

./parted <<EOF
mklabel gpt
mkpart primary linux-swap 65536s 1114111s
mkpart primary ext3 1114112s -1s
quit
EOF
# Restore special MBR of PLX
dd if=mbr.bin of=$disk count=446 bs=1
mke2fs -j "$disk"1
mkdir /install
mount -t ext3 "$disk"1 /install
cd /install
if [ ! -f /mnt/parnerkey/ArchLinuxARM-oxnas-latest.tar.gz ] ; then
    wget http://archlinuxarm.org/os/ArchLinuxARM-oxnas-latest.tar.gz
    tar xfvz ArchLinuxARM-oxnas-latest.tar.gz
    rm ArchLinuxARM-oxnas-latest.tar.gz
else
    tar xfvz /mnt/parnerkey/ArchLinuxARM-oxnas-latest.tar.gz
fi
/sbin/ifconfig egiga0 | grep ether | awk "{ print \$2 }" >usr/local/mac_addr
umount /dev/sda1

reboot