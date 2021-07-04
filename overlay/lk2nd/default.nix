{fetchurl, stdenv, lib, dtc, dtbTool, python,  pkgsCross }:
let cstdenv = pkgsCross.arm-embedded.stdenv;
    project = "msm8953-secondary";
in stdenv.mkDerivation rec {
  pname = "lk2nd";
  # la.um.6.6.r1-V2 is the branch name
  version = "la.um.6.6.r1-V2_1";
  # lk2nd ships its own copy of mkbootimg, which needs python
  nativeBuildInputs = [ dtc dtbTool python ];
  buildInputs = [ cstdenv.cc ];
  preConfigure = ''
  substituteInPlace make/build.mk --replace scripts/dtbTool ${dtbTool}/bin/dtbTool
  patchShebangs scripts/mkbootimg
  '';
  patches = [
    ./fix-dprintf.patch
    ./boot_into_fastboot.patch
  ];
  src = fetchurl {
    url = "https://github.com/SirSireesh/lk2nd/archive/e3ad85f97261b09fa7fa226950a45bead630fadf.tar.gz";
    sha256 = "0a47if9a02v97ql5pm514xjsp08b30vhfr596vd2h3rb9ckkwhg8";
  };
  installPhase = ''
  mkdir -p $out/lib
  ls -l build-${project}
  cp build-${project}/lk2nd.img build-${project}/lk.bin $out/lib
  '';
  makeFlags = [ "TOOLCHAIN_PREFIX=arm-none-eabi-"
                "NOECHO="
                project];

}
