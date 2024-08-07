These are dts files that can be used to create undervolted dtbo files for supported rk3566 devices.  This can be useful to minimize 
heat generation during intense usage like high end emulation such as Dreamcast, N64, PSP, and Saturn.

From within ArkOS (via terminal or a ssh session), copy the provided dtb files to /boot/overlays then do: \
`sudo fdtoverlay -i /boot/rk3566-OC.dtb -o /boot/rk3566-OC.dtb.undervolt /boot/overlays/undervolt.(low or medium or high).dtbo` \
Then edit the `FDT` line in /boot/extlinux/extlinux.conf to point to the newly created undervolt file. \
If booting fails, just revert the `FDT` line to the previous `/rk3566-OC.dtb` line to restore the stock cpu voltages.

Thanks to sydarn and the rest of the ROCKNIX team for the research on this.

Reference: https://github.com/ROCKNIX/distribution/tree/dev/packages/kernel/device-tree-overlays/sources
