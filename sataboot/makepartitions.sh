#!/bin/sh

parted <<EOF
mklabel msdos
mkpart primary ext3 65536s 8323071s
mkpart primary linux-swap 8323072s 9371647s
mkpart primary ext4 9371648s -1s
quit
EOF
