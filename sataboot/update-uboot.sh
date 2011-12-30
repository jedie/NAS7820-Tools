#!/bin/sh

[ "x$1" == "x"] && {
    echo "Usage: $0 hard-disk-device [u-boot-variant]"
    echo "U-Boot Variants: 1.1.2-WarheadsSE 1.1.2-sata"
    exit 1
}

ubootvariant="1.1.2-WarheadsSE"
[ "x$2" != "x" ] && {
    ubootvariant="$2"
}

dd if=u-boot-$ubootvariant.wrapped of=$1 seek=154 bs=512
dd if=u-boot-$ubootvariant.wrapped of=$1 seek=57208 bs=512
