### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers & GitHub @xx2901318208

### AnyKernel setup
# global properties
properties() { '
kernel.string=KernelSU by KernelSU Developers | Build by 1263599071
do.devicecheck=0
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties

### AnyKernel install
## boot shell variables
block=boot
is_slot_device=auto
ramdisk_compression=auto
patch_vbmeta_flag=auto
no_magisk_check=1

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh

kernel_version=$(cat /proc/version | awk -F '-' '{print $1}' | awk '{print $3}')
case $kernel_version in
    5.1*) ksu_supported=true ;;
    6.1*) ksu_supported=true ;;
    6.6*) ksu_supported=true ;;
    *) ksu_supported=false ;;
esac

ui_print "内核构建者: Coolapk@R1263599071"
ui_print " " "  -> ksu_supported: $ksu_supported"
$ksu_supported || abort "  -> Non-GKI device, abort."

# boot install
if [ -L "/dev/block/bootdevice/by-name/init_boot_a" -o -L "/dev/block/by-name/init_boot_a" ]; then
    split_boot # for devices with init_boot ramdisk
    flash_boot # for devices with init_boot ramdisk
else
    dump_boot # use split_boot to skip ramdisk unpack, e.g. for devices with init_boot ramdisk
    write_boot # use flash_boot to skip ramdisk repack, e.g. for devices with init_boot ramdisk
fi
## end boot install
# 优先选择模块路径
if [ -f "$AKHOME/ZRAM-Module.zip" ]; then
    MODULE_PATH="$AKHOME/ZRAM-Module.zip"
    KSUD_PATH="/data/adb/ksud"
    if [ -f "$KSUD_PATH" ]; then
        ui_print "Installing zram Module..."
        /data/adb/ksud module install "$MODULE_PATH"
        ui_print "Installation Complete!"
    else
        ui_print "KSUD Not Found, skipping installation..."
    fi
else
    ui_print "ZRAM-Module module Not Found, skipping ZRAM-Module module installation"
fi
ui_print " ";
ui_print ">> Loading custom modules...";
# 在 init.rc 的 post-fs_data 阶段，插入加载 baseband_guard 模块的命令
# 使用 -d 指定模块目录，确保在正确的路径下查找
insert_line init.rc "on post-fs_data" "    exec u:r:su:s0 root root -- /system/bin/modprobe -d /vendor/lib/modules baseband_guard"
# ======================= 添加结束 =======================
