#!/bin/sh


MODEL_NAME=STG212

CHECKSUM_FILE=usb_key_func.md5
SCRIPT_FILE=usb_key_func.sh
CHECK_FILE=/etc/Zy_Private
MOUNT_POINT=/mnt/parnerkey


if [ -f ${CHECK_FILE} ]; then
    echo "Use ${CHECK_FILE}, ok."
else
    echo "Error: File '${CHECK_FILE}' not found!"
    echo "You must run this script on your NAS."
    exit
fi


echo
echo "________________________________________________________________________"
echo "Create/Update ${CHECKSUM_FILE}"
cat /etc/Zy_Private ${SCRIPT_FILE} | md5sum > ${CHECKSUM_FILE}
echo

echo "${CHECKSUM_FILE} content is:"
echo "------------------------------------------------------------------------"
cat ${CHECKSUM_FILE}
echo "------------------------------------------------------------------------"


if [ ! "`mount | grep ${MOUNT_POINT}`" = "" ]; then
    echo "Error: mount point ${MOUNT_POINT} used!"
    echo "We can't test with '/sbin/check_key' :("
    exit
fi

if [ -d ${MOUNT_POINT} ]; then
    echo "Error: mount point ${MOUNT_POINT} exist!"
    echo "We can't test with '/sbin/check_key' :("
    exit
fi


mkdir -p ${MOUNT_POINT}

cp ${MODEL_NAME}_check_file ${MOUNT_POINT}/${MODEL_NAME}_check_file
cp ${SCRIPT_FILE} ${MOUNT_POINT}/${SCRIPT_FILE}
cp ${CHECKSUM_FILE} ${MOUNT_POINT}/${CHECKSUM_FILE}

echo
echo "________________________________________________________________________"
echo "Test via '/sbin/check_key' like '/etc/init.d/rcS' it does."
echo "If you not see something like 'check_key OK', then the test failed:"
echo
(
    set -x
    /sbin/check_key ${MOUNT_POINT}/${MODEL_NAME}_check_file
)
if [ $? == 0 ]; then
    echo "check_key OK"
else
    echo "check_key Error!"
fi

rm -r ${MOUNT_POINT}