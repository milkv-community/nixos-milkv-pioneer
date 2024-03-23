{ bsp, flake, pkgs, ... }:

# This derivation builds the booloader raw image artifact from the Sophgo SG2042 bsp.
#
# For reference, see the `build_rv_fimware_image` function in `scripts/envsetup. sh`:
#   https://github.com/sophgo/bootloader-riscv

flake.ccache.stdenv.mkDerivation rec {
  pname = "milkv-pioneer-bsp-bootloader-raw-image";
  version = "0.0.0";

  nativeBuildInputs = [
    # breakpointHook
    bsp.edk2
    bsp.linux
    bsp.opensbi
    bsp.uroot-initrd
    bsp.zsbl
    pkgs.guestfs-tools
  ];

  src = pkgs.fetchFromGitHub {
    owner = "milkv-community";
    repo = "sg2042-bsp";
    rev = "2b6ab25";
    hash = "sha256-IemyWYreN6i5DahNKL9Bv+6LA7MMMqYxSc+5fmSU4Zw=";
  };

  SG2042_BSP_BOOTLOADER_SRC_DIR = "/build/${src.repo}";
  SG2042_BSP_BOOTLOADER_EFI_DIR = "${SG2042_BSP_BOOTLOADER_SRC_DIR}/efi";

  conf-ini = pkgs.writeText "${pname}+conf.ini" ''
    [sophgo-config]

    [devicetree]
    name = mango-milkv-pioneer.dtb

    [kernel]
    name = riscv64_Image

    [firmware]
    name = fw_dynamic.bin

    [ramfs]
    name = initrd.img

    [eof]
  '';

  phases = [
    "unpackPhase"
    "preBuild"
    "buildPhase"
    "installPhase"
  ];

  unpackPhase = ''
    cp -a $src $SG2042_BSP_BOOTLOADER_SRC_DIR
    chmod -R u+w $SG2042_BSP_BOOTLOADER_SRC_DIR
  '';

  preBuild = ''
    mkdir -p $SG2042_BSP_BOOTLOADER_EFI_DIR/riscv64
    cp ${conf-ini} $SG2042_BSP_BOOTLOADER_EFI_DIR/riscv64/conf.ini
    cp $SG2042_BSP_BOOTLOADER_SRC_DIR/firmware/fip.bin $SG2042_BSP_BOOTLOADER_EFI_DIR
    cp ${bsp.edk2}/SG2042.fd $SG2042_BSP_BOOTLOADER_EFI_DIR/riscv64
    cp ${bsp.linux}/*.dtb $SG2042_BSP_BOOTLOADER_EFI_DIR/riscv64
    cp ${bsp.linux}/riscv64_Image $SG2042_BSP_BOOTLOADER_EFI_DIR/riscv64
    cp ${bsp.opensbi}/fw_dynamic.bin $SG2042_BSP_BOOTLOADER_EFI_DIR/riscv64
    cp ${bsp.uroot-initrd}/initrd.img $SG2042_BSP_BOOTLOADER_EFI_DIR/riscv64
    cp ${bsp.zsbl}/zsbl.bin $SG2042_BSP_BOOTLOADER_EFI_DIR
    touch $SG2042_BSP_BOOTLOADER_EFI_DIR/BOOT
  '';

  buildPhase = ''
    virt-make-fs --partition --size=268MB --format=raw --type=vfat $SG2042_BSP_BOOTLOADER_EFI_DIR firmware.img
  '';

  installPhase = ''
    mkdir -p $out
    cp firmware.img $out/firmware.img
  '';
}
