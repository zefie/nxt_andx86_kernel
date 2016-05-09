#!/bin/bash
if [ "$UID" -ne "0" ]; then
	echo "Please run as root."
	exit 1
fi

NOMOUNT=0
if [ "$1" == "nomount" ]; then
	NOMOUNT=1;
fi

USBDISK=NXT_AND_X86

KVERS=`file arch/x86/boot/bzImage | cut -d' ' -f9`
MOUNTD=/media/$SUDO_USER/$USBDISK
MOUNTP=$HOME/zefie_processing


if [ ! -d $MOUNTD ]; then
	MOUNTD=$MOUNTD
	if [ ! -d $MOUNTD ]; then
		echo "  ERROR   Cannot find $USBDISK"
		echo "This is not a download-and-run script. It was designed to"
		echo "make my life easier, and may need adjustment for usage"
		echo "on other systems."
		exit 1;
	fi
fi

if [ ! -d "$MOUNTP" ]; then
        echo "    INFO  Creating $MOUNTP"
        mkdir $MOUNTP;
fi

function clean_mountp() {
        if [ "$(ls -A $MOUNTP)" ]; then
                echo "    WARN  Not removing $MOUNTP ... Not empty"
        else
                echo "    INFO  Removing $MOUNTP"
                rmdir $MOUNTP
        fi
}

trap ctrl_c INT

function ctrl_c() {
	echo -ne '\r'
        echo "    WARN  CTRL-C Pressed... cancelling"
        echo "  UMOUNT  $MOUNTD/system.img"
        umount $MOUNTP 2>/dev/null
	clean_mountp
        exit 130
}

if [ "$NOMOUNT" -ne "1" ]; then
	echo "   MOUNT  $MOUNTD/system.img"
	mount -o loop -t ext4 $MOUNTD/system.img $MOUNTP 2>/dev/null
fi

if [ "$(df -h | grep $MOUNTP | wc -l)" -ne "1" ]; then
	echo "  ERROR   Failed to mount system.img"
	exit 1;
fi

echo "  REMOVE  ALL Existing modules"
rm -r $MOUNTP/lib/modules/* 2>/dev/null

make INSTALL_MOD_PATH=$MOUNTP modules_install

echo "  REMOVE  sound/soc/intel/common/snd-soc-sst-acpi.ko"
rm $MOUNTP/lib/modules/$KVERS/kernel/sound/soc/intel/common/snd-soc-sst-acpi.ko

echo "  BUILD   external/rtl8723bs-bluetooth/hci_uart.ko"
make SUBDIRS=external/rtl8723bs-bluetooth clean 2>&1 > /dev/null
make SUBDIRS=external/rtl8723bs-bluetooth 2>&1 > /dev/null

echo "  CHECK   external/rtl8723bs-bluetooth/hci_uart.ko"
if [ ! -f "external/rtl8723bs-bluetooth/hci_uart.ko" ]; then
	echo "  ERROR   Building rtl8723bs-bluetooth hci_uart failed"
else
	echo "  INSTALL drivers/bluetooth/hci_uart.ko"
	cp external/rtl8723bs-bluetooth/hci_uart.ko $MOUNTP/lib/modules/$KVERS/kernel/drivers/bluetooth/hci_uart.ko
fi

echo "  CLEAN   external/rtl8723bs-bluetooth/hci_uart.ko"
make SUBDIRS=external/rtl8723bs-bluetooth clean 2>&1 > /dev/null

echo "  DEPMOD  $KVERS"
depmod $KVERS -b $MOUNTP -a

echo "  INSTALL kernel"
cp arch/x86/boot/bzImage $MOUNTD/kernel

if [ "$NOMOUNT" -ne "1" ]; then
	echo "  UMOUNT  $MOUNTD/system.img"
	umount $MOUNTP
	clean_mountp
fi
