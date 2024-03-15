{ pkgs, ... }:

# This derivation builds the zsbl artifact from the Sophgo SG2042 bsp.
#
# For reference, see the upstream zsbl repository:
#   https://github.com/sophgo/zsbl
#
# For reference, see the `build_rv_zsbl` function in `scripts/envsetup.sh`:
#   https://github.com/sophgo/bootloader-riscv

pkgs.pkgsCross.riscv64.stdenv.mkDerivation rec {
  pname = "milkv-pioneer-bsp-zsbl";
  version = "0.0.0";

  # NOTE: linker fails with `undefined reference to `__stack_chk_fail'` without disabling hardening.
  hardeningDisable = [ "all" ];

  nativeBuildInputs = with pkgs; [
    bison
    flex
    gcc
  ];

  src = pkgs.fetchFromGitHub {
    owner = "milkv-community";
    repo = "sophgo-zsbl";
    rev = "cc80627";
    hash = "sha256-zOlBM7mwz8FUM/BlzOxJmpI8LI/KcFOGXegvgiilbaM=";
    fetchSubmodules = true;
  };

  RISCV64_LINUX_CROSS_COMPILE = "${pkgs.pkgsCross.riscv64.stdenv.cc.targetPrefix}";
  CHIP = "mango";
  CHIP_NUM = "single";
  KERNEL_VARIANT = "minimum";
  RV_ZSBL_SRC_DIR = "/build/zsbl";
  RV_ZSBL_BUILD_DIR = "${RV_ZSBL_SRC_DIR}/build/${CHIP}/${KERNEL_VARIANT}";

  phases = [
    "unpackPhase"
    "buildPhase"
    "installPhase"
  ];

  unpackPhase = ''
    cp -a $src $RV_ZSBL_SRC_DIR
    chmod -R u+w $RV_ZSBL_SRC_DIR
  '';

  buildPhase = ''
    pushd $RV_ZSBL_SRC_DIR
      make CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE O=$RV_ZSBL_BUILD_DIR ARCH=riscv sg2042_defconfig
      err=$?
    popd

    if [ $err -ne 0 ]; then
      echo "making zsbl config failed"
      return $err
    fi

    pushd $RV_ZSBL_BUILD_DIR
      make -j$(nproc) CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE ARCH=riscv
      err=$?
    popd

    if [ $err -ne 0 ]; then
      echo "making zsbl failed"
      return $err
    fi
  '';

  installPhase = ''
    mkdir -p $out
    cp -a $RV_ZSBL_BUILD_DIR/zsbl.bin $out
  '';

  passthru = {
    inherit src;
  };
}
