KVER?= $(shell uname -r)
ifneq ($(KERNELRELEASE),)
	obj-m		:= hci_uart.o
	hci_uart-y	:= hci_ldisc.o hci_h4.o hci_rtk_h5.o rtk_coex.o
	#EXTRA_CFLAGS += -DDEBUG

else
	PWD := $(shell pwd)
	KVER := $(KVER)
	KDIR := /home/zefie/dev/kernel_nextbook

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	rm -rf *.o *.mod.c *.mod.o *.ko *.symvers *.order *.a

endif
