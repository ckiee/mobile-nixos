{ config, pkgs, lib, modules, baseModules, ... }:

let
  enabled = config.mobile.system.type == "uefi";

  inherit (lib) mkEnableOption mkIf mkOption types;
  inherit (pkgs) hostPlatform imageBuilder runCommandNoCC;
  inherit (config.system.build) recovery stage-0;
  cfg = config.mobile.quirks.uefi;
  deviceName = config.mobile.device.name;
  kernel = stage-0.mobile.boot.stage-1.kernel.package;
  kernelFile = "${kernel}/${kernel.file}";

  # Look-up table to translate from targetPlatform to U-Boot names.
  uefiPlatforms = {
    "i686-linux"    = "ia32";
    "x86_64-linux"  =  "x64";
    "aarch64-linux" = "aa64";
  };
  uefiPlatform = uefiPlatforms.${pkgs.targetPlatform.system};

  kernelParamsFile = pkgs.writeText "${deviceName}-boot.cmd" config.boot.kernelParams;

  efiKernel = pkgs.runCommandNoCC "${deviceName}-efiKernel" {
    nativeBuildInputs = [
      pkgs.stdenv.cc.bintools.bintools_bin
    ];
  } ''
    (PS4=" $ "; set -x
    ${pkgs.stdenv.cc.bintools.targetPrefix}objcopy \
      --add-section .cmdline="${kernelParamsFile}"          --change-section-vma  .cmdline=0x30000 \
      --add-section .linux="${kernelFile}"                  --change-section-vma  .linux=0x2000000 \
      --add-section .initrd="${config.system.build.initrd}" --change-section-vma .initrd=0x3000000 \
      "${pkgs.libudev}/lib/systemd/boot/efi/linux${uefiPlatform}.efi.stub" \
      "$out"
    )
  '';

  boot-partition =
    imageBuilder.fileSystem.makeESP {
      name = "mobile-nixos-ESP";
      partitionLabel = "mn-ESP";
      partitionID   = "966D4E021684";
      partitionUUID = "CFB21B5C-A580-DE40-940F-B9644B4466E2";

      # Let's give us a *bunch* of space to play around.
      # And let's not forget we have the kernel and stage-1 twice.
      size = imageBuilder.size.MiB 128;

      populateCommands = ''
        mkdir -p EFI/boot
        cp ${stage-0.system.build.efiKernel}  EFI/boot/boot${uefiPlatform}.efi
        cp ${recovery.system.build.efiKernel} EFI/boot/recovery${uefiPlatform}.efi
      '';
    }
  ;

  miscPartition = {
    # Used as a BCB.
    name = "misc";
    partitionLabel = "misc";
    partitionUUID = "5A7FA69C-9394-8144-A74C-6726048B129D";
    length = imageBuilder.size.MiB 1;
    partitionType = "EF32A33B-A409-486C-9141-9FFB711F6266";
    filename = "/dev/null";
  };

  persistPartition = imageBuilder.fileSystem.makeExt4 {
    # To work more like Android-based systems.
    name = "persist";
    partitionLabel = "persist";
    partitionID = "5553F4AD-53E1-2645-94BA-2AFC60C12D38";
    partitionUUID = "5553F4AD-53E1-2645-94BA-2AFC60C12D39";
    size = imageBuilder.size.MiB 16;
    partitionType = "EBC597D0-2053-4B15-8B64-E0AAC75F4DB1";
  };

  disk-image = imageBuilder.diskImage.makeGPT {
    name = "mobile-nixos";
    diskID = "01234567";
    headerHole = cfg.initialGapSize;
    partitions = [
      config.system.build.boot-partition
      miscPartition
      persistPartition
      config.system.build.rootfs
    ];
  };
in
{
  imports = [
    ./vm.nix
  ];

  options.mobile = {
    quirks.uefi = {
      initialGapSize = mkOption {
        type = types.int;
        default = 0;
        description = ''
          Size (in bytes) to keep reserved in front of the first partition.
        '';
      };
    };
  };

  config = lib.mkMerge [
    { mobile.system.types = [ "uefi" ]; }
    (mkIf enabled {
      system.build = {
        inherit efiKernel;
        inherit boot-partition;
        inherit disk-image;
        default = config.system.build.disk-image;
      };
    })
  ];
}
