#!/bin/sh

[ "x$1" == "x"] && {
    echo "Usage: $0 hard-disk-device [stage1-variant] [u-boot-variant]"
    echo "Stage1 Variants: 700 750"
    echo "U-Boot Variants: 1.1.2-WarheadsSE 1.1.2-sata"
    exit 1
}

stage1variant=750
[ "x$2" != "x" ] && {
    stage1variant="$2"
}

ubootvariant="1.1.2-WarheadsSE"
[ "x$3" != "x" ] && {
    ubootvariant="$3"
}

dd if=/dev/zero of=$1 bs=512 count=65536
dd if=mbr.bin of=$1 bs=512
dd if=stage1.wrapped$stage1variant of=$1 bs=512 seek=34
dd if=stage1.wrapped$stage1variant of=$1 bs=512 seek=57088
dd if=u-boot-$ubootvariant.wrapped of=$1 seek=154 bs=512
dd if=u-boot-$ubootvariant.wrapped of=$1 seek=57208 bs=512
