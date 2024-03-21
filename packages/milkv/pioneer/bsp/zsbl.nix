{ flake, pkgs, ... }:

# This derivation builds the zsbl artifact from the Sophgo SG2042 bsp.
#
# For reference, see the upstream zsbl repositories:
#   https://github.com/sophgo/zsbl
#
# For reference, see the `build_rv_zsbl` function in `scripts/envsetup. sh`:
#   https://github.com/sophgo/bootloader-riscv

flake.ccache.stdenv.mkDerivation rec {
  pname = "milkv-pioneer-bsp-zsbl";
  version = "0.0.0";

  # NOTE: linker fails with `undefined reference to `__stack_chk_fail'` without disabling hardening.
  hardeningDisable = [ "all" ];

  nativeBuildInputs = with pkgs; [
    # breakpointHook
    flake.ccache.stdenv-riscv64.cc
    bison
    flex
  ];

  src = pkgs.fetchFromGitHub {
    owner = "milkv-community";
    repo = "sg2042-zsbl";
    rev = "cc80627";
    hash = "sha256-zOlBM7mwz8FUM/BlzOxJmpI8LI/KcFOGXegvgiilbaM=";
  };

  RISCV64_LINUX_CROSS_COMPILE = "${flake.ccache.stdenv-riscv64.cc.targetPrefix}";
  CHIP = "mango";
  CHIP_NUM = "single";
  KERNEL_VARIANT = "normal";
  SG2042_BSP_ZSBL_SRC_DIR = "/build/${src.repo}";
  SG2042_BSP_ZSBL_BUILD_DIR = "${SG2042_BSP_ZSBL_SRC_DIR}/build/${CHIP}/${KERNEL_VARIANT}";

  unpackPhase = ''
    cp -a $src $SG2042_BSP_ZSBL_SRC_DIR
    chmod -R u+w $SG2042_BSP_ZSBL_SRC_DIR
  '';

  buildPhase = ''
    pushd $SG2042_BSP_ZSBL_SRC_DIR
      make -j$NIX_BUILD_CORES CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE O=$SG2042_BSP_ZSBL_BUILD_DIR ARCH=riscv sg2042_defconfig
      err=$?
    popd

    if [ $err -ne 0 ]; then
      echo "making zsbl config failed"
      return $err
    fi

    pushd $SG2042_BSP_ZSBL_BUILD_DIR
      make -j$NIX_BUILD_CORES CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE ARCH=riscv
      err=$?
    popd

    if [ $err -ne 0 ]; then
      echo "making zsbl failed"
      return $err
    fi
  '';

  installPhase = ''
    mkdir -p $out
    cp -a $SG2042_BSP_ZSBL_BUILD_DIR/zsbl.bin $out
  '';
}
