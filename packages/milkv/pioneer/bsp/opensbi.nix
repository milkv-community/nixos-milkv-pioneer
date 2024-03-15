{ pkgs, ... }:

# This derivation builds the opensbi artifact from the Sophgo SG2042 bsp.
#
# For reference, see the upstream opensbi repositories:
#   https://github.com/sophgo/opensbi
#   https://github.com/riscv-software-src/opensbi
#
# For reference, see the `build_rv_sbi` function in `scripts/envsetup.sh`:
#   https://github.com/sophgo/bootloader-riscv

pkgs.pkgsCross.riscv64.stdenv.mkDerivation rec {
  pname = "milkv-pioneer-bsp-opensbi";
  version = "0.0.0";

  nativeBuildInputs = with pkgs; [
    python3
  ];

  src = pkgs.fetchFromGitHub {
    owner = "milkv-community";
    repo = "opensbi";
    rev = "e270237";
    hash = "sha256-28dY49OM79vxRM5xDgomxbJzuV6/LIY35QsfWYmGCAU=";
    fetchSubmodules = true;
  };

  RISCV64_LINUX_CROSS_COMPILE = "${pkgs.pkgsCross.riscv64.stdenv.cc.targetPrefix}";
  PLATFORM = "generic";
  BSP_SBI_SRC_DIR = "/build/opensbi";

  unpackPhase = ''
    cp -a $src $BSP_SBI_SRC_DIR
    chmod -R u+w $BSP_SBI_SRC_DIR
  '';

  patchPhase = ''
    patchShebangs $BSP_SBI_SRC_DIR/scripts
  '';

  # TODO:
  # - disable BUILD_INFO
  # - disable DEBUG_INFO
  buildPhase = ''
    pushd $BSP_SBI_SRC_DIR
      make -j$NIX_BUILD_CORES CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE PLATFORM=$PLATFORM FW_PIC=y BUILD_INFO=y DEBUG=1 V=1
    popd
  '';

  installPhase = ''
    mkdir -p $out
    cp $BSP_SBI_SRC_DIR/build/platform/$PLATFORM/firmware/fw_dynamic.bin $out
    cp $BSP_SBI_SRC_DIR/build/platform/$PLATFORM/firmware/fw_dynamic.elf $out
  '';

  passthru = {
    inherit src;
  };
}
