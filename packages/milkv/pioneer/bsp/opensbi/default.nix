{ flake, pkgs, ... }:

# This derivation builds the opensbi artifact from the Sophgo SG2042 bsp.
#
# For reference, see the upstream opensbi repositories:
#   https://github.com/sophgo/opensbi
#   https://github.com/riscv-software-src/opensbi
#
# For reference, see the `build_rv_sbi` function in `scripts/envsetup.sh`:
#   https://github.com/sophgo/bootloader-riscv

flake.caching.stdenv.mkDerivation rec {
  pname = "milkv-pioneer-bsp-opensbi";
  version = "0.0.0";

  nativeBuildInputs = with pkgs; [
    # breakpointHook
    flake.caching.stdenv-riscv64.cc
    python3
  ];

  src = pkgs.fetchFromGitHub {
    owner = "milkv-community";
    repo = "opensbi";
    rev = "e270237";
    hash = "sha256-28dY49OM79vxRM5xDgomxbJzuV6/LIY35QsfWYmGCAU=";
  };

  RISCV64_LINUX_CROSS_COMPILE = "${flake.caching.stdenv-riscv64.cc.targetPrefix}";
  PLATFORM = "generic";
  SG2042_BSP_SBI_SRC_DIR = "/build/${src.repo}";

  unpackPhase = ''
    runHook preUnpack

    cp -a $src $SG2042_BSP_SBI_SRC_DIR
    chmod -R u+w $SG2042_BSP_SBI_SRC_DIR

    runHook postUnpack
  '';

  patchPhase = ''
    runHook prePatch

    patchShebangs $SG2042_BSP_SBI_SRC_DIR/scripts

    runHook postPatch
  '';

  # TODO:
  # - disable BUILD_INFO
  # - disable DEBUG_INFO
  buildPhase = ''
    runHook preBuild

    pushd $SG2042_BSP_SBI_SRC_DIR
      make -j$NIX_BUILD_CORES CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE PLATFORM=$PLATFORM FW_PIC=y BUILD_INFO=y DEBUG=1
    popd

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -a $SG2042_BSP_SBI_SRC_DIR/build/platform/$PLATFORM/firmware/fw_dynamic.bin $out
    cp -a $SG2042_BSP_SBI_SRC_DIR/build/platform/$PLATFORM/firmware/fw_dynamic.elf $out

    runHook postInstall
  '';
}
