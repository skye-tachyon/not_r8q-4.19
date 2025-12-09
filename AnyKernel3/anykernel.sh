# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=not_Kernel by @skye // tachyon
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=r8q
device.name2=r8qxx
device.name3=r8qxxx
device.name4=mustang
supported.versions=11 - 18
supported.patchlevels=
'; } # end properties
# i use pixel 10 pro xl spoof in my r8q, thats why mustang is there, no-one will flash a 4.19 kernel on p10pxl anyway

# shell variables
block=/dev/block/platform/soc/1d84000.ufshc/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 755 644 $ramdisk/*;
set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;

## AnyKernel boot install
dump_boot;

# begin kernel/dtb/dtbo changes
oneui=$(file_getprop /system/build.prop ro.build.version.oneui);
gsi=$(file_getprop /system/build.prop ro.product.system.device);
cos=$(file_getprop /system/build.prop ro.product.system.brand);
if [ -n "$oneui" ]; then
   ui_print " "
   ui_print " • OneUI ROM detected! • " # OneUI 7.X/6.X/5.X/4.X/3.X bomb
   ui_print " "
   ui_print " • Patching Fingerprint Sensor... • "
   patch_cmdline "android.is_aosp" "android.is_aosp=0";
elif [ $gsi == generic ]; then
   ui_print " "
   ui_print " • GSI ROM detected! • " # i hope the gsi doesnt boot :)
   ui_print " "
   ui_print " • Patching Fingerprint Sensor... • "
   patch_cmdline "android.is_aosp" "android.is_aosp=0";
   ui_print " "
   ui_print " • Patching SELinux... • "
   patch_cmdline "androidboot.selinux" "androidboot.selinux=permissive";
elif [ $cos == oplus ]; then
   ui_print " "
   ui_print " • Oplus ROM detected! • " # Damn
   ui_print " "
   ui_print " • Patching Fingerprint Sensor... • "
   patch_cmdline "android.is_aosp" "android.is_aosp=0";
   ui_print " "
   ui_print " • Patching SELinux... • "
   patch_cmdline "androidboot.selinux" "androidboot.selinux=permissive";
   ui_print " "
   ui_print " • Spoofing verified boot state to green... • "
   patch_cmdline "ro.boot.verifiedbootstate" "ro.boot.verifiedbootstate=green";
else
   ui_print " "
   ui_print " • AOSP ROM detected! • " # Android 16/15/14/13 veri gud
   ui_print " "
   ui_print " • Patching Fingerprint Sensor... • "
   patch_cmdline "android.is_aosp" "android.is_aosp=1";
   ui_print " "
   ui_print " • Spoofing verified boot state to green... • "
   patch_cmdline "ro.boot.verifiedbootstate" "ro.boot.verifiedbootstate=green";
fi

ui_print " "
ui_print " • Patching vbmeta unconditionally... • "
dd if=$home/vbmeta.img of=/dev/block/platform/soc/1d84000.ufshc/by-name/vbmeta

ui_print " "
ui_print " • Patching dtbo unconditionally... • "

write_boot;
## end boot install
