#!/bin/sh

device="$1"
macaddr="$2"

if [ "x$macaddr" == "x" ] ; then
    echo "Usage: $0 device mac-addr"
    echo "mac-addr must have following style xx:xx:xx:xx:xx:xx"
    exit 1
fi

echo "Deleting partitions on device"
# Delete partitions first
dd if=/dev/zero of=$device bs=512 seek=0 count=34 conv=notrunc status=noxfer &>/dev/null || {
    echo "Failed to write disk"
    exit 1
}
echo "Adding MBR to device"
# Make MBR
dd if=../mbr.bin of=$device bs=512 seek=0 conv=notrunc status=noxfer &>/dev/null || {
    echo "Failed to write disk"
    exit 1
}
# Add stage1 and u-boot
echo "Adding stage1"
dd if=stage1.wrapped750 of=$device bs=512 seek=34 conv=notrunc status=noxfer &>/dev/null || {
    echo "Failed to write disk"
    exit 1
}
echo "Adding U-Boot"
dd if=../u-boot.wrapped of=$device bs=512 seek=154 bs=512 conv=notrunc status=noxfer &>/dev/null || {
    echo "Failed to write disk"
    exit 1
}

echo "Generating NAND U-Boot Environment"
# Sector Starts (all values in HDD sectors)
# MTD1 => 1024
# MTD2 => 1024 + MTD1Size 
# => 1536
# MTD3 => 1024 + MTD1Size + MTD2Size 
# => 8704
# MTD4 => 1024 + MTD1Size + MTD2Size + MTD3Size 
# => 9728
# MTD6 => 1024 + MTD1Size + MTD2Size + MTD3Size + MTD4Size
# => 30208
# MTD7 => 1024 + MTD1Size + MTD2Size + MTD3Size + MTD4Size + MTD6Size
# => 50688

# MTD1Size = 512
# MTD2Size = 7168
# MTD3Size = 1024
# MTD4Size = 20480
# MTD6Size = 20480
# MTD7Size = 192000

# Generate MTD3
echo -en "bootargs= console=ttyS0,115200 elevator=cfq mac_addr=0x00,0x30,0xe0,0x00,0x00,0x01\0" >mtd3.data
echo -en "bootcmd=run boot_nand\0" >>mtd3.data
echo -en "bootdelay=2\0" >>mtd3.data
echo -en "baudrate=115200\0" >>mtd3.data
echo -en "ipaddr=192.168.50.100\0" >>mtd3.data
echo -en "serverip=192.168.50.59\0" >>mtd3.data
echo -en "autoload=n\0" >>mtd3.data
echo -en "netmask=255.255.0.0\0" >>mtd3.data
echo -en "bootfile=\"uImage\"\0" >>mtd3.data
echo -en "load_nand=nboot 61000000 0 440000\0" >>mtd3.data
echo -en "boot=bootm 61000000\0" >>mtd3.data
echo -en "boot_nand=run load_nand boot\0" >>mtd3.data
echo -en "MODEL_ID=AB03\0" >>mtd3.data
echo -en "PRODUCT_NAME=STG-212\0" >>mtd3.data
echo -en "VENDOR_NAME=MitraStar Technology Corp.\0" >>mtd3.data
echo -en "ethaddr=${macaddr}\0" >>mtd3.data
echo -en "\0" >>mtd3.data
# Enlarge the image
dd if=/dev/zero of=mtd3.data conv=notrunc seek=131067 bs=1 count=1 status=noxfer &>/dev/null || {
    echo "Failed to write disk"
    exit 1
}
cksum <mtd3.data >cksum.data
read CRC32 REMAINDER <cksum.data 
# Byte 0
CRC32_OCTAL0L=$((CRC32 & 7))
CRC32_OCTAL0M=$(((CRC32 >> 3) & 7))
CRC32_OCTAL0H=$(((CRC32 >> 6) & 3))
# Byte 1
CRC32_OCTAL1L=$(((CRC32 >> 8) & 7))
CRC32_OCTAL1M=$(((CRC32 >> 11) & 7))
CRC32_OCTAL1H=$(((CRC32 >> 14) & 3))
# Byte 2
CRC32_OCTAL2L=$(((CRC32 >> 16) & 7))
CRC32_OCTAL2M=$(((CRC32 >> 19) & 7))
CRC32_OCTAL2H=$(((CRC32 >> 22) & 3))
# Byte 3
CRC32_OCTAL3L=$(((CRC32 >> 24) & 7))
CRC32_OCTAL3M=$(((CRC32 >> 27) & 7))
CRC32_OCTAL3H=$(((CRC32 >> 30) & 3))

CRC32_STRING="\0$CRC32_OCTAL0H$CRC32_OCTAL0M$CRC32_OCTAL0L"
CRC32_STRING="$CRC32_STRING\0$CRC32_OCTAL1H$CRC32_OCTAL1M$CRC32_OCTAL1L"
CRC32_STRING="$CRC32_STRING\0$CRC32_OCTAL2H$CRC32_OCTAL2M$CRC32_OCTAL2L"
CRC32_STRING="$CRC32_STRING\0$CRC32_OCTAL3H$CRC32_OCTAL3M$CRC32_OCTAL3L"
echo -en "$CRC32_STRING" >mtd3.crc
cat mtd3.crc mtd3.data >mtd3.bin

echo "Adding MTD1 data (stage1)"
dd if=mtd1.backup of=$device bs=512 seek=1024 bs=512 conv=notrunc status=noxfer &>/dev/null || {
    echo "Failed to write disk"
    exit 1
}
echo "Adding MTD2 data (NAND U-Boot)"
dd if=mtd2.backup of=$device bs=512 seek=1536 bs=512 conv=notrunc status=noxfer &>/dev/null || {
    echo "Failed to write disk"
    exit 1
}
echo "Adding MTD3 data (U-Boot Environment)"
dd if=mtd3.bin of=$device bs=512 seek=8704 bs=512 conv=notrunc status=noxfer &>/dev/null || {
    echo "Failed to write disk"
    exit 1
}
echo "Adding MTD4 data (Kernel)"
dd if=mtd4.backup of=$device bs=512 seek=9728 bs=512 conv=notrunc status=noxfer &>/dev/null || {
    echo "Failed to write disk"
    exit 1
}
echo "Adding MTD6 data (info)"
dd if=mtd6.backup of=$device bs=512 seek=30208 bs=512 conv=notrunc status=noxfer &>/dev/null || {
    echo "Failed to write disk"
    exit 1
}
echo "Adding MTD7 data (sysdisk)"
dd if=mtd7.backup of=$device bs=512 seek=50688 bs=512 conv=notrunc status=noxfer &>/dev/null || {
    echo "Failed to write disk"
    exit 1
}

rm mtd3.data mtd3.crc mtd3.bin cksum.data

echo "Generate SATA U-Boot Environment"
echo -en "bootcmd=run select0 erase_nand mtd1 mtd2 mtd3 mtd4 mtd6 mtd7\0" >env.data
echo -en "bootdelay=2\0" >>env.data
echo -en "baudrate=115200\0" >>env.data
echo -en "ipaddr=192.168.50.100\0" >>env.data
echo -en "serverip=192.168.50.59\0" >>env.data
echo -en "autoload=n\0" >>env.data
echo -en "netmask=255.255.0.0\0" >>env.data
echo -en "bootfile=\"uImage\"\0" >>env.data
echo -en "select0=ide dev 0\0" >>env.data
echo -en "selectnand=nand device 0\0" >>env.data
echo -en "erase_nand=nand erase\0" >>env.data
echo -en "mtd1=run load_mtd1 flash_mtd1\0" >>env.data
echo -en "mtd2=run load_mtd2 flash_mtd2\0" >>env.data
echo -en "mtd3=run load_mtd3 flash_mtd3\0" >>env.data
echo -en "mtd4=run load_mtd4 flash_mtd4\0" >>env.data
echo -en "mtd6=run load_mtd6 flash_mtd6\0" >>env.data
echo -en "mtd7=run load_mtd7 flash_mtd7\0" >>env.data
echo -en "ethaddr=${macaddr}\0" >>mtd3.data
echo -en "load_mtd1=ide read 61000000 400 200\0" >>env.data
echo -en "load_mtd2=ide read 61000000 1c00 400\0" >>env.data
echo -en "load_mtd3=ide read 61000000 2200 400\0" >>env.data
echo -en "load_mtd4=ide read 61000000 2600 5000\0" >>env.data
echo -en "load_mtd6=ide read 61000000 7600 5000\0" >>env.data
echo -en "load_mtd7=ide read 61000000 c600 2ee00\0" >>env.data
echo -en "flash_mtd1=nand write 61000000 0 40000\0" >>env.data
echo -en "flash_mtd2=nand write 61000000 40000 380000\0" >>env.data
echo -en "flash_mtd3=nand write 61000000 3C0000 80000\0" >>env.data
echo -en "flash_mtd4=nand write 61000000 440000 a00000\0" >>env.data
echo -en "flash_mtd6=nand write 61000000 1840000 a00000\0" >>env.data
echo -en "flash_mtd7=nand write 61000000 2240000 5dc0000\0" >>env.data
echo -en "MODEL_ID=AB03\0" >>env.data
echo -en "PRODUCT_NAME=STG-212\0" >>env.data
echo -en "VENDOR_NAME=MitraStar Technology Corp.\0" >>env.data
echo -en "\0" >>env.data
# Enlarge the image
dd if=/dev/zero of=mtd3.data conv=notrunc seek=8187 bs=1 count=1 status=noxfer &>/dev/null || {
    echo "Failed to write disk"
    exit 1
}
cksum <env.data >cksum.data
read CRC32 REMAINDER <cksum.data 
# Byte 0
CRC32_OCTAL0L=$((CRC32 & 7))
CRC32_OCTAL0M=$(((CRC32 >> 3) & 7))
CRC32_OCTAL0H=$(((CRC32 >> 6) & 3))
# Byte 1
CRC32_OCTAL1L=$(((CRC32 >> 8) & 7))
CRC32_OCTAL1M=$(((CRC32 >> 11) & 7))
CRC32_OCTAL1H=$(((CRC32 >> 14) & 3))
# Byte 2
CRC32_OCTAL2L=$(((CRC32 >> 16) & 7))
CRC32_OCTAL2M=$(((CRC32 >> 19) & 7))
CRC32_OCTAL2H=$(((CRC32 >> 22) & 3))
# Byte 3
CRC32_OCTAL3L=$(((CRC32 >> 24) & 7))
CRC32_OCTAL3M=$(((CRC32 >> 27) & 7))
CRC32_OCTAL3H=$(((CRC32 >> 30) & 3))

CRC32_STRING="\0$CRC32_OCTAL0H$CRC32_OCTAL0M$CRC32_OCTAL0L"
CRC32_STRING="$CRC32_STRING\0$CRC32_OCTAL1H$CRC32_OCTAL1M$CRC32_OCTAL1L"
CRC32_STRING="$CRC32_STRING\0$CRC32_OCTAL2H$CRC32_OCTAL2M$CRC32_OCTAL2L"
CRC32_STRING="$CRC32_STRING\0$CRC32_OCTAL3H$CRC32_OCTAL3M$CRC32_OCTAL3L"
echo -en "$CRC32_STRING" >env.crc
cat env.crc env.data >env.bin

echo "Integrating SATA U-Boot Environment"
dd if=env.bin of=$device bs=512 seek=558 conv=notrunc status=noxfer &>/dev/null || {
    echo "Failed to write disk"
    exit 1
}
rm env.data env.crc env.bin cksum.data
