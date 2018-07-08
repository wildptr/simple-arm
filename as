#!/usr/bin/env python3

import os
import sys

AS = 'arm-none-eabi-as'
OBJCOPY = 'arm-none-eabi-objcopy'

def main():
    asmfile = sys.argv[1]
    output_stem = f'run/{os.path.basename(asmfile)}'
    objfile = f'{output_stem}.o'
    binfile = f'{output_stem}.bin'
    os.spawnlp(os.P_WAIT, AS, AS, '-o', objfile, asmfile)
    os.spawnlp(os.P_WAIT, OBJCOPY, OBJCOPY, '-O', 'binary', objfile, binfile)
    with open('run/mem.hex', 'w') as fo:
        with open(binfile, 'rb') as fi:
            while True:
                b = fi.read(4)
                if b == b'':
                    break
                fo.write('%02x %02x %02x %02x\n' % (b[0], b[1], b[2], b[3]))

main()
