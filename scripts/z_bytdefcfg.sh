#!/bin/bash
cp arch/x86/configs/nextbook_defconfig arch/x86/configs/baytrail_defconfig
sed -i 's|CONFIG_ACPI_CUSTOM_DSDT_FILE="/home/zefie/dsdt.hex"|# CONFIG_ACPI_CUSTOM_DSDT_FILE is not set|' arch/x86/configs/baytrail_defconfig
sed -i 's|CONFIG_ACPI_CUSTOM_DSDT=y|# CONFIG_ACPI_CUSTOM_DSDT is not set|' arch/x86/configs/baytrail_defconfig
