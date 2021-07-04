{
  mobile-nixos
, stdenv
, fetchFromGitHub
, ...
}:


mobile-nixos.kernel-builder {
  version = "5.13.0-rc6";
  configfile = ./config.aarch64;

  src = fetchFromGitHub {
    owner = "msm8953-mainline";
    repo = "linux";
    name = "kernel-postmarketos";
    rev = "fd14627435bd3e71da770b2ee004e5d90086b5b4";
    sha256 = "1srzc38vq6g7r9vjm4fc3jgazyalihgxb3sk7ln4iinz5vhns760";
  };

  patches = [
    ./0001-remove-unneeded-dtbs.patch
  ];

  isModular = true;
  isQcdt = false;
}
