#!/bin/sh

stage1variant=750
disk=/dev/sda

echo "Mount disk to get the regular system available"
DISK_PATH="/zyxel/mnt/sysdisk"

/bin/mkdir -p ${DISK_PATH}
IMG_PATH="/ram_bin"
/bin/mount -t ext2 -o loop,ro ${DISK_PATH}/sysdisk.img ${IMG_PATH} || exit 0

# Mount some read-only directories and make everything available for us
/bin/mount --bind ${IMG_PATH}/usr /usr
/bin/mount --bind ${IMG_PATH}/lib/security /lib/security
/bin/mount --bind ${IMG_PATH}/lib/modules /lib/modules
cp -a ${IMG_PATH}/bin/* /bin/
cp -a ${IMG_PATH}/sbin/* /sbin/

/sbin/udhcpc -i egiga0
if [ $? == 0 ]; then
    echo "OK, get IP via DHCP"
else
    echo "Error: Cannot get IP via DHCP!"
    echo "continue boot process..."
    exit 1
fi

dd if=/dev/zero of=$disk bs=512 count=65536 || exit 0
dd if=stage1.wrapped$stage1variant of=$disk bs=512 seek=34 || exit 0
dd if=stage1.wrapped$stage1variant of=$disk bs=512 seek=57088 || exit 0
dd if=u-boot.wrapped of=$disk bs=512 seek=154 || exit 0
dd if=u-boot.wrapped of=$disk bs=512 seek=57208 || exit 0
dd if=uImage.nopci of=$disk bs=512 bs=512 seek=1290 || exit 0
dd if=uImage.nopci of=$disk bs=512 bs=512 seek=58344 || exit 0

parted <<EOF
mklabel msdos
mkpart primary linux-swap 65536s 1114111s
mkpart primary ext3 1114112s -1s
quit
EOF
mke2fs -j "$disk"2 || exit 0
mkdir /install || exit 0
mount -t ext3 "$disk"2 /install || exit 0
echo "Installing ArchLinuxARM rootfs"
cd /install
if [ ! -f /mnt/parnerkey/ArchLinuxARM-oxnas-latest.tar.gz ] ; then
    echo "Downloading ArchLinuxARM rootfs"
    wget http://archlinuxarm.org/os/ArchLinuxARM-oxnas-latest.tar.gz || exit 0
    tar xfvz ArchLinuxARM-oxnas-latest.tar.gz || exit 0
    echo "Extracting ArchLinuxARM rootfs"
    rm ArchLinuxARM-oxnas-latest.tar.gz || exit 0
else
    echo "Installing ArchLinuxARM rootfs from USB stick"
    tar xfvz /mnt/parnerkey/ArchLinuxARM-oxnas-latest.tar.gz || exit 0
fi
echo "Extracting MAC address"
/sbin/ifconfig egiga0 | grep ether | awk "{ print \$2 }" >usr/local/mac_addr
cat /usr/local/mac_addr
umount "$disk"2 || exit 0

# Restore special MBR of PLX
dd if=mbr.bin of=$disk count=446 bs=1

reboot