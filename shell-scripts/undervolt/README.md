These are dts files that can be used to create undervolted dtbo files for supported rk3566 devices.  This can be useful to minimize 
heat generation during intense usage like high end emulation such as Dreamcast, N64, PSP, and Saturn.  This can also lead to failed
booting of devices, however, this can be reverted per the instructions below.

From within ArkOS (via terminal or a ssh session), copy the provided dtb files to /boot/overlays then do: \
`sudo fdtoverlay -i /boot/rk3566-OC.dtb -o /boot/rk3566-OC.dtb.undervolt /boot/overlays/undervolt.(light or medium or maximum).dtbo` \
Then edit the `FDT` line in /boot/extlinux/extlinux.conf to point to the newly created undervolt file. \

If booting fails, just revert the `FDT` line to the previous `/rk3566-OC.dtb` text to restore the stock cpu voltages.

To create the dtbo overlay file using the supplied dts source files from within ArkOS: \
`dtc -@ -I dts -O dtb -o yourchoiceofname.dtbo undervolt.(low or medium or high).dts`

Thanks to sydarn and the rest of the ROCKNIX team for the research on this.

Reference: https://github.com/ROCKNIX/distribution/tree/dev/packages/kernel/device-tree-overlays/sources
