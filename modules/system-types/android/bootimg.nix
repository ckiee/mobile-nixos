{ lib
, pkgs
, name

# mkbootimg specific values
, kernel
, kernelPackage
, initrd
, cmdline
, bootimg
, lk2nd
}:

let
  inherit (lib) optionalString;
  inherit (pkgs) buildPackages pkgsBuildBuild;
in
pkgs.runCommandNoCC name {
  nativeBuildInputs = with buildPackages; [
    mkbootimg
    dtbTool
  ];
} ''
  echo Using kernel: ${kernel}
  (
  PS4=" $ "
  set -x
  find ${kernelPackage} -ls
  cat ${kernel} > kernel.tmp
  ${optionalString (bootimg.appendDt != null) ''
    cat ${kernelPackage}/dtbs/${bootimg.appendDt}  >> kernel.tmp
  ''}
  ls -l ${kernel} ${kernelPackage}/dtbs/${bootimg.appendDt} kernel.tmp

  mkbootimg \
    --kernel  kernel.tmp \
    ${optionalString (bootimg.dt != null) "--dt ${bootimg.dt}"} \
    --ramdisk ${initrd} \
    --cmdline       "${cmdline}" \
    --base           ${bootimg.flash.offset_base   } \
    --kernel_offset  ${bootimg.flash.offset_kernel } \
    --second_offset  ${bootimg.flash.offset_second } \
    --ramdisk_offset ${bootimg.flash.offset_ramdisk} \
    --tags_offset    ${bootimg.flash.offset_tags   } \
    --pagesize       ${bootimg.flash.pagesize      } \
    -o boot.img
  cat ${buildPackages.lk2nd}/lib/lk2nd.img > out.tmp
  dd seek=1 obs=1M if=boot.img of=out.tmp
  cp out.tmp $out
  )
''
