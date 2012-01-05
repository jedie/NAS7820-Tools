#!/usr/bin/env python

"""
    Write stage1 start sequence into a file.
"""

FILENAME="start_sequence.dat"

f = file(FILENAME, "wb")
f.write("\x00" * 420)
f.write(
    "\x00\x5f\x01\x00"
    "\x00\xdf\x00\x00"
    "\x00\x80\x00\x00"

    # In the original perl code was here this line:
    #"\x00" * (0x1b0 -0x1a4 -12)
    # But this is IMHO not needed, because:
    # 0x1b0 is 432 and 0x1a4 is 420 so: 432 - 420 - 12 are 0 ;)

    "\x22\x80\x00\x00"
    "\x22\x00\x00\x00"
    "\x00\x80\x00\x00"
)
f.close()

print "Start sequence file %r created." % FILENAME