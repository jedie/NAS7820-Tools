#!/bin/sh


echo "*****************************************************"
echo "Hello from usb_key_func.sh !!! I reinstall your sysdisk"
echo "*****************************************************"

/bin/mkdir /sysdisk
/bin/mount -t yaffs2 -o rw /dev/mtdblock7 /sysdisk
cp /sysdisk.img /sysdisk
/bin/umount /sysdisk

exit 0

