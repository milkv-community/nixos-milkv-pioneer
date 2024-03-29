{ flake, pkgs, ... }:

# This derivation builds the linux kernel artifact from the Sophgo SG2042 bsp.
#
# For reference, see the upstream linux repositories:
#   https://github.com/sophgo/linux-riscv
#   https://github.com/torvalds/linux
#
# For reference, see the `build_rv_kernel` function in `scripts/envsetup. sh`:
#   https://github.com/sophgo/bootloader-riscv

flake.caching.stdenv.mkDerivation rec {
  pname = "milkv-pioneer-bsp-linux";
  version = "6.8";

  nativeBuildInputs = with pkgs; linuxPackages_6_8.kernel.nativeBuildInputs ++ [
    # breakpointHook
    flake.caching.stdenv-riscv64.cc
  ];

  src = pkgs.fetchFromGitHub {
    owner = "milkv-community";
    repo = "linux";
    rev = "dfe9dcc";
    hash = "sha256-zCrQwjFn09gyal511xLCxVP2+Uvlp1gsVta42PL8+zQ=";
  };

  RISCV64_LINUX_CROSS_COMPILE = "${flake.caching.stdenv-riscv64.cc.targetPrefix}";
  VENDOR = "sophgo";
  CHIP = "mango";
  KERNEL_VARIANT = "normal";
  LOCALVERSION = "milkv-community";
  SG2042_BSP_LINUX_CONFIG = "${VENDOR}_${CHIP}_${KERNEL_VARIANT}_defconfig";
  SG2042_BSP_LINUX_SRC_DIR = "/build/${src.repo}";
  SG2042_BSP_LINUX_BUILD_DIR = "${SG2042_BSP_LINUX_SRC_DIR}/build/${CHIP}/${KERNEL_VARIANT}";

  unpackPhase = ''
    runHook preUnpack

    cp -a $src $SG2042_BSP_LINUX_SRC_DIR
    chmod -R u+w $SG2042_BSP_LINUX_SRC_DIR

    runHook postUnpack
  '';

  buildPhase = ''
    runHook preBuild

    pushd $SG2042_BSP_LINUX_SRC_DIR
      make -j$NIX_BUILD_CORES CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE O=$SG2042_BSP_LINUX_BUILD_DIR ARCH=riscv $SG2042_BSP_LINUX_CONFIG
      err=$?
    popd

    if [ $err -ne 0 ]; then
      echo "making kernel config failed"
      return $err
    fi

    pushd $SG2042_BSP_LINUX_BUILD_DIR
      make -j$NIX_BUILD_CORES CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE O=$SG2042_BSP_LINUX_BUILD_DIR LOCALVERESION=$LOCALVERSION ARCH=riscv Image dtbs modules
      err=$?
    popd

    if [ $err -ne 0 ]; then
      echo "making kernel failed"
      return $err
    fi

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -a $SG2042_BSP_LINUX_BUILD_DIR/arch/riscv/boot/Image $out/riscv64_Image
    cp -a $SG2042_BSP_LINUX_BUILD_DIR/arch/riscv/boot/dts/sophgo/*.dtb $out

    runHook postInstall
  '';
}
