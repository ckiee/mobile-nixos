{ fetchurl, stdenv, lib, dtc, dtbTool, python, gcc-arm-embedded, fetchFromGitHub
}:
let project = "msm8953-secondary";
in stdenv.mkDerivation rec {
  pname = "lk2nd";
  version = "git";

  # lk2nd ships its own copy of mkbootimg, which needs python
  nativeBuildInputs = [ dtc dtbTool python ];
  depsBuildBuild = [ gcc-arm-embedded ];

  preConfigure = ''
    substituteInPlace make/build.mk --replace scripts/dtbTool ${dtbTool}/bin/dtbTool
    patchShebangs scripts/mkbootimg
  '';

  patches = [ ./fix-dprintf.patch ./boot_into_fastboot.patch ];

  src = fetchFromGitHub {
    owner = "msm8953-mainline";
    repo = "lk2nd";
    rev = "d4e6f14d53260835782707f1b8cfd12458b47e75";
    sha256 = "sha256-11KOSdb9G3T9tNs6YiyC6LyoZ2JvIFzykEwogDY9dRc=";
  };

  installPhase = ''
    mkdir -p $out/lib
    ls -l build-${project}
    cp build-${project}/lk2nd.img build-${project}/lk.bin $out/lib
  '';
  makeFlags = [ "LD=arm-none-eabi-ld" "TOOLCHAIN_PREFIX=arm-none-eabi-" "NOECHO=" project ];

}
