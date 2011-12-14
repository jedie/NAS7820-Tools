#!/bin/sh
# -*- coding: utf-8 -*-


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
    echo "Put and start this script in the 'root' of the other linux system!"
    exit 1
fi


do_mount() {
    echo "____________________________________________________________________"
    echo "*** mount $1 ***"

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
                    mount ${dev} ${dest}
                )
            fi
        fi
    done
}

# Mount internal HDD and USB-Sticks into chroot system
do_mount e-data
do_mount i-data

(
    echo "____________________________________________________________________"
    echo "*** bind special dirs ***"

    set -x

    # FIXME: "mount -o bind /dev ${ROOT}dev" doesn't work. You will get:
    #        mount: mounting /dev on /e-data/XXX/dev failed: Invalid argument
    # see also:
    #   http://whrl.pl/Rc1xZV (en)
    #   http://www.mikrocontroller.net/topic/240238?page=2#2450527 (de)
    #
    # Used work-a-round from http://whrl.pl/Rc1AWq
    # See also: http://www.mikrocontroller.net/topic/240238?goto=2458396#2458417 (de)
    cp -R /dev ${ROOT}/

    mount -t devpts devpts ${ROOT}/dev/pts

    mount -o bind /sys ${ROOT}/sys
    mount -t proc /proc ${ROOT}/proc

    cp /etc/resolv.conf ${ROOT}/etc/resolv.conf
)

echo "--------------------------------------------------------------------"
echo
echo "Do chroot to ${ROOT}"
echo
(
    set -x
    ${ROOT}/usr/sbin/chroot ${ROOT} /bin/bash
)

echo
echo "Cleanup after chroot 'exit':"
echo


ROOT=`pwd`


do_unmount() {
    echo "____________________________________________________________________"
    echo "*** umount $1 ***"

    for path in `ls ${ROOT}/$1`; do
        abs_path=${ROOT}/$1/${path}
        (
            set -x
            umount ${abs_path}
        )
        if [ "`ls ${abs_path}`" = "" ]; then
            (
                set -x
                rm -r ${abs_path}
            )
        else
            echo "Error: path not empty: ${abs_path}"
        fi
    done
}


(
    set -x
    #umount ${ROOT}/dev
    umount ${ROOT}/dev/pts
    umount ${ROOT}/sys
    umount ${ROOT}/proc
)
do_unmount e-data
do_unmount i-data
