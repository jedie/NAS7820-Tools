#!/bin/sh


# Put this script into a linux root directory and start
# to switch via chroot
# More info:
# http://www.mikrocontroller.net/articles/P89626/debootstrap
# http://www.mikrocontroller.net/articles/P89626/ArchLinuxARM
#
# copyleft 2011 by Jens Diemer, release under GNU GPL v3 or above


ROOT=`pwd`

if [ -d ${ROOT}/boot ]; then
    echo "Root directory found on ${ROOT}."
else
    echo "Error: No root found here: ${ROOT} :("
    exit 1
fi


do_bind() {
    echo "____________________________________________________________________"
    echo "*** bind $1 ***"

    for path in `ls /$1`; do
        mount_point=/$1/${path}
        if [ "${mount_point}" = "${ROOT}" ]; then
            echo "Skip ${mount_point}"
        else
            dev=`mount | grep "on ${mount_point} type" | awk '{print $1}'`
            if [ "${dev}" = "" ]; then
                echo "Skip ${mount_point}"
            else
                dest=${ROOT}${mount_point}
                (
                    set -x
                    mkdir -p ${dest}
                    mount -o bind ${dev} ${dest}
                )
            fi
        fi
    done
}

# Bind aller Datenträger ins chroot System
do_bind e-data
do_bind i-data

(
    echo "____________________________________________________________________"
    echo "*** bind special dirs ***"

    set -x

    # TODO: Bind von /dev Funktioniert nicht, siehe:
    #           http://www.mikrocontroller.net/topic/240238?page=2#2450527
    #~ mount -o bind /dev ${ROOT}dev
    mount --rbind /dev ${ROOT}/dev

    mount -o bind /sys ${ROOT}/sys
    mount -t proc /proc ${ROOT}/proc

    cp /etc/resolv.conf ${ROOT}/etc/resolv.conf

    # Den eigentlichen chroot Ausführen
    ${ROOT}/usr/sbin/chroot ${ROOT} /bin/bash
)

echo
echo "Bye..."
echo

# Aufräumen nach chroot 'exit':
ROOT=`pwd`
(
    set -x
    umount ${ROOT}/dev
    umount ${ROOT}/sys
    umount ${ROOT}/proc

    umount ${ROOT}/i-data
    umount ${ROOT}/e-data

    rm -r ${ROOT}/i-data
    rm -r ${ROOT}/e-data
)