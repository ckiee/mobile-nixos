{
  mobile-nixos
, stdenv
, fetchFromGitHub
, ...
}:


mobile-nixos.kernel-builder {
  version = "5.13.0-rc4";
  configfile = ./config.aarch64;

  src = fetchFromGitHub {
    owner = "msm8953-mainline";
    repo = "linux";
    name = "kernel-postmarketos";
    rev = "c9d3de2";
    sha256 = "15899m43q70nlwyb06px2qq41jmz1w5zrir6p718fcrwfpay81p4";
  };

  patches = [
    # ./04_fix_camera_msm_isp.patch
    # ./99_framebuffer.patch
    # ./0001-Allow-building-WCD9335_CODEC-without-REGMAP_ALLOW_WR.patch
    # ./0005-Allow-building-with-sound-disabled.patch
    # ./0007-Coalesce-identical-device-trees.patch
    # ./0008-Notify-clients-when-FB-opened.patch
  ];

#  enableRemovingWerror = true;
  isModular = true;
  isQcdt = true;
}
