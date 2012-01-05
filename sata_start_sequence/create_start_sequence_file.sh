#!/bin/bash

# Based on a script by WarheadsSE

perl <<EOF | dd of=start_sequence.dat bs=512
    print "\x00" x 0x1a4;
    print "\x00\x5f\x01\x00";
    print "\x00\xdf\x00\x00";
    print "\x00\x80\x00\x00";
    print "\x00" x (0x1b0 -0x1a4 -12 );
    print "\x22\x80\x00\x00";
    print "\x22\x00\x00\x00";
    print "\x00\x80\x00\x00";
EOF
echo "File 'start_sequence.dat' created."