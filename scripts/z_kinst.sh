#!/bin/bash

KVERS=`file arch/x86/boot/bzImage | cut -d' ' -f9`
USBDISK=NXT_AND_X86

echo "  INSTALL kernel"
cp arch/x86/boot/bzImage /media/zefie/$USBDISK/kernel

