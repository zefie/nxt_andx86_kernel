#!/bin/sh
KVERS=`file arch/x86/boot/bzImage | cut -d' ' -f9`
USBDISK=NXT_AND_X86

echo "  MOUNT   /media/zefie/$USBDISK/system.img"
mount -o loop -t ext4 /media/zefie/$USBDISK/system.img /home/zefie/tmp

echo "  REMOVE  Existing modules for: $KVERS"
rm -r /home/zefie/tmp/lib/modules/$KVERS

make INSTALL_MOD_PATH=/home/zefie/tmp modules_install

echo "  REMOVE  sound/soc/intel/common/snd-soc-sst-acpi.ko"
rm /home/zefie/tmp/lib/modules/$KVERS/kernel/sound/soc/intel/common/snd-soc-sst-acpi.ko

#echo "  REMOVE  drivers/bluetooth/btintel.ko"
#rm /home/zefie/tmp/lib/modules/$KVERS/kernel/drivers/bluetooth/btintel.ko

#echo "  REMOVE  drivers/bluetooth/btbcm.ko"
#rm /home/zefie/tmp/lib/modules/$KVERS/kernel/drivers/bluetooth/btbcm.ko

#echo "  REMOVE  drivers/bluetooth/btqca.ko"
#rm /home/zefie/tmp/lib/modules/$KVERS/kernel/drivers/bluetooth/btqca.ko

echo "  DEPMOD  $KVERS"
depmod $KVERS -b /home/zefie/tmp -a

echo "  INSTALL kernel"
cp arch/x86/boot/bzImage /media/zefie/$USBDISK/kernel

echo "  UMOUNT  /media/zefie/$USBDISK/system.img"
umount /home/zefie/tmp
