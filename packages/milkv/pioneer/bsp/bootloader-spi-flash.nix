{ bsp, flake, pkgs, ... }:

# This derivation builds the booloader spi flash artifact from the Sophgo SG2042 bsp.
#
# For reference, see the `build_rv_fimware_bin` function in `scripts/envsetup. sh`:
#   https://github.com/sophgo/bootloader-riscv

flake.ccache.stdenv.mkDerivation rec {
  pname = "milkv-pioneer-bsp-bootloader-spi-flash";
  version = "0.0.0";

  nativeBuildInputs = [
    # breakpointHook
    bsp.edk2
    bsp.linux
    bsp.opensbi
    bsp.uroot-initrd
    bsp.zsbl
  ];

  src = pkgs.fetchFromGitHub {
    owner = "milkv-community";
    repo = "sg2042-bsp";
    rev = "2b6ab25";
    hash = "sha256-IemyWYreN6i5DahNKL9Bv+6LA7MMMqYxSc+5fmSU4Zw=";
  };

  SG2042_BSP_BOOTLOADER_SRC_DIR = "/build/${src.repo}";
  SG2042_BSP_BOOTLOADER_BUILD_DIR = "${SG2042_BSP_BOOTLOADER_SRC_DIR}/build";

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
    mkdir -p $SG2042_BSP_BOOTLOADER_BUILD_DIR
    cp $SG2042_BSP_BOOTLOADER_SRC_DIR/firmware/fip.bin $SG2042_BSP_BOOTLOADER_BUILD_DIR
    cp ${bsp.edk2}/SG2042.fd $SG2042_BSP_BOOTLOADER_BUILD_DIR
    cp ${bsp.linux}/*.dtb $SG2042_BSP_BOOTLOADER_BUILD_DIR
    cp ${bsp.linux}/riscv64_Image $SG2042_BSP_BOOTLOADER_BUILD_DIR
    cp ${bsp.opensbi}/fw_dynamic.bin $SG2042_BSP_BOOTLOADER_BUILD_DIR
    cp ${bsp.uroot-initrd}/initrd.img $SG2042_BSP_BOOTLOADER_BUILD_DIR
    cp ${bsp.zsbl}/zsbl.bin $SG2042_BSP_BOOTLOADER_BUILD_DIR
  '';

  buildPhase = ''
    pushd $SG2042_BSP_BOOTLOADER_BUILD_DIR
      $CC -g -Wall $SG2042_BSP_BOOTLOADER_SRC_DIR/scripts/gen_spi_flash.c -o gen_spi_flash
      ./gen_spi_flash \
          $(ls *.dtb | awk '{print ""$1" "$1" 0x020000000 "}') \
          fw_dynamic.bin fw_dynamic.bin 0x00000000 \
          riscv64_Image riscv64_Image 0x02000000 \
          initrd.img initrd.img 0x30000000 \
          zsbl.bin zsbl.bin 0x40000000 \
          SG2042.fd SG2042.fd 0x02000000
    popd
  '';

  installPhase = ''
    mkdir -p $out
    cp $SG2042_BSP_BOOTLOADER_BUILD_DIR/spi_flash.bin $out/firmware.bin
  '';
}
