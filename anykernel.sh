# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=ExampleKernel by osm0sis @ xda-developers
do.devicecheck=1
do.modules=1
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=pineapple
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=1;
ramdisk_compression=auto;
patch_vbmeta_flag=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 755 644 $ramdisk/*;
set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;


## AnyKernel boot install
dump_boot;

# begin ramdisk changes

# init.rc
backup_file init.rc;
replace_string init.rc "cpuctl cpu,timer_slack" "cpuctl cpu,timer_slack,none";
replace_string init.rc "mount cgroup none /dev/cpuctl cpu" "mount cgroup none /dev/cpuctl cpu,timer_slack";

# init.tuna.rc
backup_file init.tuna.rc;
replace_string init.tuna.rc "cgroup /dev/cpuctl" "cgroup /dev/cpuctl cpu,timer_slack";

# fstab.tuna
backup_file fstab.tuna;
patch_fstab fstab.tuna /system ext4 options "noatime,barrier=1" "noatime,barrier=1,discard";
patch_fstab fstab.tuna /cache ext4 options "nosuid,nodev" "nosuid,nodev,discard";
patch_fstab f-stab.tuna /data ext4 options "nosuid,nodev,noauto_da_alloc" "nosuid,nodev,noauto_da_alloc,discard";

write_boot;
## end boot install


# shell variables
#block=vendor_boot;
#is_slot_device=1;
#ramdisk_compression=auto;
#patch_vbmeta_flag=auto;

# reset for vendor_boot patching
#reset_ak;


## AnyKernel vendor_boot install
#split_boot; # skip unpack/repack ramdisk since we don't need vendor_ramdisk access

#flash_boot;
## end vendor_boot install

# =================================================================
# 【在这里添加我们的自定义模块加载命令】
# =================================================================
ui_print " ";
ui_print ">> Loading custom modules...";
# 在 init.rc 的 post-fs_data 阶段，插入加载 baseband_guard 模块的命令
# 使用 -d 指定模块目录，确保在正确的路径下查找
insert_line init.rc "on post-fs_data" "    exec u:r:su:s0 root root -- /system/bin/modprobe -d /vendor/lib/modules baseband_guard"
# ======================= 添加结束 =======================
