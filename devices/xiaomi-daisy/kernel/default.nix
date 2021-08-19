{ mobile-nixos
, fetchFromGitHub
, ...
}:

mobile-nixos.kernel-builder rec {
  version = "5.13.0-rc6-qcom-msm8953";
  configfile = ./config.aarch64;

  src = fetchFromGitHub {
    owner = "msm8953-mainline";
    repo = "linux";
    rev = "fd0f81dcec8023ea37d854c3d6d426ce41efb455";
    sha256 = "sha256-7VyYgg44HJj2mKM+DCMEy0GGEedECyeYewgO+2rs8rk=";
  };

  patches = [
    ./0001-HACK-Add-back-TEXT_OFFSET-in-the-built-image.patch
    ./0003-arch-arm64-Add-config-option-to-fix-bootloader-cmdli.patch
  ];

  # TODO: generic mainline build; append per-device...
  postInstall = ''
    echo ':: Copying kernel'
    (PS4=" $ "; set -x
    cp -v \
      $buildRoot/arch/arm64/boot/Image.${isCompressed} \
      $out/
    )
    echo ':: Appending DTB'
    (PS4=" $ "; set -x
    cat \
      $buildRoot/arch/arm64/boot/Image.${isCompressed} \
      $buildRoot/arch/arm64/boot/dts/qcom/sdm625-xiaomi-daisy.dtb \
      > $out/Image.${isCompressed}-dtb
    )
  '';

  isModular = false;
  enableRemovingWerror = true;
  isCompressed = "gz";
  kernelFile = "Image.${isCompressed}-dtb";
}
