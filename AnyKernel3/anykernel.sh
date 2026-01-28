# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=not
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=r8q
device.name2=r8qxx
device.name3=r8qxxx
device.name4=ossi
device.name5=komodo
supported.versions=11 - 16
supported.patchlevels=
'; } # end properties

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

ui_print " "
ui_print " • Spliting boot image... • "

split_boot;

case "$ZIPFILE" in
   *-eff*)
    ui_print " "
    ui_print " • Using efficient cpu frequency table! • "
    mv $home/kona-eff.dtb $home/dtb
    ;;
   *)
    ui_print " "
    ui_print " • Using custom cpu frequency table! • "
    mv $home/kona.dtb $home/dtb
    ;;
esac

# begin cmdline changes
oneui=$(file_getprop /system/build.prop ro.build.version.oneui);
cos=$(file_getprop /system/build.prop ro.product.system.brand);
gos=$(file_getprop /system/build.prop ro.build.host);
if [ $oneui == 80000 ]; then
   ui_print " "
   ui_print " • OneUI 8 ROM Detected • " # OneUI 8.0 real bomb
   ui_print " "
   ui_print " • Patching Fingerprint Sensor... • "
   patch_cmdline "android.is_aosp" "android.is_aosp=0";
   ui_print " "
   ui_print " • Patching OTG... • "
   patch_cmdline "android.is_uos" "android.is_ous=1";
   ui_print " "
elif [ -n "$oneui" ]; then
   ui_print " "
   ui_print " • OneUI ROM Detected • " # OneUI 7.X/6.X/5.X/4.X/3.X bomb
   ui_print " "
   ui_print " • Patching Fingerprint Sensor... • "
   patch_cmdline "android.is_aosp" "android.is_aosp=0";
   patch_cmdline "android.is_uos" "android.is_ous=0";
elif [ $gos == tachyon ]; then
   ui_print " "
   ui_print " • GrapheneOS detected! • "
   ui_print " "
   ui_print " • Patching SELinux... • "
   patch_cmdline "androidboot.selinux" "androidboot.selinux=permissive";
   patch_cmdline "android.is_aosp" "android.is_aosp=0";
   patch_cmdline "android.is_uos" "android.is_ous=0";
   ui_print " "
   ui_print " • Setting android verified boot state to green... • "
   patch_cmdline "ro.boot.verifiedbootstate=orange" "ro.boot.verifiedbootstate=green";
   patch_cmdline "androidboot.verifiedbootstate=orange" "androidboot.verifiedbootstate=green";
elif [ $cos == oplus ]; then
   ui_print " "
   ui_print " • Oplus ROM detected! • " # Damn
   ui_print " "
   ui_print " • Patching SELinux... • "
   patch_cmdline "androidboot.selinux" "androidboot.selinux=permissive";
   patch_cmdline "android.is_aosp" "android.is_aosp=1";
   patch_cmdline "android.is_uos" "android.is_ous=0";
else
   ui_print " "
   ui_print " • AOSP ROM detected! • " # Android 16/15/14/13 veri gud
   ui_print " "
   ui_print " • Spoofing verified boot state to green... • "
   patch_cmdline "ro.boot.verifiedbootstate=orange" "ro.boot.verifiedbootstate=green";
   ui_print " "
   ui_print " • Patching Fingerprint Sensor... • "
   patch_cmdline "android.is_aosp" "android.is_aosp=1";
   patch_cmdline "android.is_uos" "android.is_ous=0";
fi

ui_print " "
ui_print " • Patching vbmeta unconditionally... • "
dd if=$home/vbmeta.img of=/dev/block/platform/soc/1d84000.ufshc/by-name/vbmeta


ui_print " "
ui_print " • Patching dtbo unconditionally... • "
dd if=$home/dtbo.img of=/dev/block/platform/soc/1d84000.ufshc/by-name/dtbo

ui_print " "
ui_print " • Flashing boot image... • "

flash_boot;
## end boot install
