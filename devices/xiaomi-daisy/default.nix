{ config, lib, pkgs, ... }:

{
  mobile.device.name = "xiaomi-daisy";
  mobile.device.identity = {
    name = "A2 Lite";
    manufacturer = "Xiaomi";
  };

  mobile.hardware = {
    soc = "qualcomm-msm8953";

    ram = 1024 * 3;
    screen = {
      width = 1080;
      height = 2280;
    };
  };

  mobile.boot.stage-1 = { kernel.package = pkgs.callPackage ./kernel { }; };

  mobile.system.type = "android";
  mobile.system.android.device_name = "daisy";
  mobile.system.android = {
    # This device adds skip_initramfs to cmdline for normal boots
    boot_as_recovery = true;

    bootimg.flash = {
      offset_base = "0x80000000";
      offset_kernel = "0x00008000";
      offset_ramdisk = "0x01000000";
      offset_second = "0x00f00000";
      offset_tags = "0x00000100";
      pagesize = "2048";
    };
  };

  boot.kernelParams = [
    # "earlycon"
    # "console=ttyMSM0,115200"
    "panic=1"
  ];

  mobile.usb = {
    mode = "gadgetfs";
    # Google - Nexus 5
    idVendor = "18d1";
    idProduct = "d001";
  };

  mobile.usb.gadgetfs.functions = {
    adb = "ffs.adb";
    rndis = "rndis.usb0";
  };
}
