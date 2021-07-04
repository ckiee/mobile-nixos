{ lib
, pkgs
, name

# mkbootimg specific values
, kernel
, initrd
, cmdline
, bootimg
}:

let
  inherit (lib) optionalString;
  inherit (pkgs) buildPackages;
in
pkgs.runCommandNoCC name {
  nativeBuildInputs = with buildPackages; [
    mkbootimg
    dtbTool
    lk2nd
  ];
} ''
  echo Using kernel: ${kernel}
  (
  PS4=" $ "
  set -x
  cat ${kernel} > kernel.tmp
  ${optionalString (bootimg.appendDt != null) ''
    cat ${bootimg.dt}  >> kernel.tmp
  ''}
  ls -l ${kernel} ${bootimg.dt} kernel.tmp

  mkbootimg \
    --kernel  kernel.tmp \
    ${optionalString ((bootimg.appendDt == null) && (bootimg.dt != null)) "--dt ${bootimg.dt}"} \
    --ramdisk ${initrd} \
    --cmdline       "${cmdline}" \
    --base           ${bootimg.flash.offset_base   } \
    --kernel_offset  ${bootimg.flash.offset_kernel } \
    --second_offset  ${bootimg.flash.offset_second } \
    --ramdisk_offset ${bootimg.flash.offset_ramdisk} \
    --tags_offset    ${bootimg.flash.offset_tags   } \
    --pagesize       ${bootimg.flash.pagesize      } \
    -o $out
  )
''
