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
    ./0001-remove-unneeded-dtbs.patch
  ];

  isModular = true;
  isQcdt = false;
}
