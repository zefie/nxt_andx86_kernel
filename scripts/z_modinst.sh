#!/bin/bash
if [ "$UID" -ne "0" ]; then
	echo "Please run as root."
	exit 1
fi

KVERS=`file arch/x86/boot/bzImage | cut -d' ' -f9`
USBDISK=NXT_AND_X86

echo "  MOUNT   /media/zefie/$USBDISK/system.img"
mount -o loop -t ext4 /media/zefie/$USBDISK/system.img /home/zefie/tmp

if [ "$(df -h | grep /home/zefie/tmp | wc -l)" -ne "1" ]; then
	echo "  ERROR   Failed to mount system.img"
	exit 1;
fi

echo "  REMOVE  Existing modules for: $KVERS"
rm -r /home/zefie/tmp/lib/modules/$KVERS

make INSTALL_MOD_PATH=/home/zefie/tmp modules_install

echo "  REMOVE  sound/soc/intel/common/snd-soc-sst-acpi.ko"
rm /home/zefie/tmp/lib/modules/$KVERS/kernel/sound/soc/intel/common/snd-soc-sst-acpi.ko

echo "  BUILD   external/rtl8723bs-bluetooth/hci_uart.ko"
make SUBDIRS=external/rtl8723bs-bluetooth clean 2>&1 > /dev/null
make SUBDIRS=external/rtl8723bs-bluetooth 2>&1 > /dev/null

echo "  CHECK   external/rtl8723bs-bluetooth/hci_uart.ko"
if [ ! -f "external/rtl8723bs-bluetooth/hci_uart.ko" ]; then
	echo "  ERROR   Building rtl8723bs-bluetooth hci_uart failed"
else
	echo "  INSTALL drivers/bluetooth/hci_uart.ko"
	cp external/rtl8723bs-bluetooth/hci_uart.ko /home/zefie/tmp/lib/modules/$KVERS/kernel/drivers/bluetooth/hci_uart.ko
fi

echo "  CLEAN   external/rtl8723bs-bluetooth/hci_uart.ko"
make SUBDIRS=external/rtl8723bs-bluetooth clean 2>&1 > /dev/null

echo "  DEPMOD  $KVERS"
depmod $KVERS -b /home/zefie/tmp -a

echo "  INSTALL kernel"
cp arch/x86/boot/bzImage /media/zefie/$USBDISK/kernel

echo "  UMOUNT  /media/zefie/$USBDISK/system.img"
umount /home/zefie/tmp
