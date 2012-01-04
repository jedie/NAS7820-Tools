#!/bin/sh

# Here is a examle do script
# We try to get a IP via DHCP and start telnet
# If something wring, we continue the boot process by 'exit 1'
# You should see something via 'dmesg'

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

echo "******************************"
echo "Hello from do.sh !!!"
echo "******************************"


# Get IP via DHCP (for P89626 based systems)
/sbin/udhcpc -i egiga0
if [ $? == 0 ]; then
    echo "OK, get IP via DHCP."
else
    echo "Error: Can't get IP via DHCP!"
    echo "continue boot process..."
    exit 1
fi


# Startup telnet:
telnetd -l /bin/sh &
if [ $? == 0 ]; then
    echo "OK, start telnet."
else
    echo "Error: Can't start telnet!"
    echo "continue boot process..."
    exit 1
fi
