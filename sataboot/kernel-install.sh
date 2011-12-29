#!/bin/sh

[ "x$1" == "x"] && {
    echo "Usage: $0 hard-disk-device kernel"
    exit 1
}

[ "x$2" == "x"] && {
    echo "Usage: $0 hard-disk-device kernel"
    exit 1
}

set -x

dd "if=$2" of=$1 seek=1290 bs=512
dd "if=$2" of=$1 seek=58344 bs=512
