#!/bin/sh

[ "x$1" == "x"] && {
    echo "Usage: $0 hard-disk-device"
    exit 1
}

dd if=/dev/zero of=$1 bs=512 count=65536
dd if=mbr.bin of=$1 bs=512
dd if=signature.bin of=$1 bs=512 seek=57080
dd if=stage1.bin of=$1 bs=512 seek=34
dd if=stage1.bin of=$1 bs=512 seek=57088
dd if=u-boot-1.1.2-sata.wrapped of=$1 seek=154 bs=512
dd if=u-boot-1.1.2-sata.wrapped of=$1 seek=57208 bs=512
