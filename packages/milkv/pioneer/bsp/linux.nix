{ flake, pkgs, ... }:

flake.ccache.stdenv.mkDerivation rec {
  pname = "milkv-pioneer-bsp-linux";
  version = "6.8";

  nativeBuildInputs = with pkgs; linuxPackages_6_8.kernel.nativeBuildInputs ++ [
    breakpointHook
    flake.ccache.stdenv-riscv64.cc
  ];

  src = pkgs.fetchFromGitHub {
    owner = "milkv-community";
    repo = "linux";
    rev = "dfe9dcc";
    hash = "sha256-zCrQwjFn09gyal511xLCxVP2+Uvlp1gsVta42PL8+zQ=";
    fetchSubmodules = true;
  };

  RISCV64_LINUX_CROSS_COMPILE = "${flake.ccache.stdenv-riscv64.cc.targetPrefix}";
  VENDOR = "sophgo";
  CHIP = "mango";
  KERNEL_VARIANT = "minimum";
  LOCALVERSION = "milkv-community";
  SG2042_BSP_LINUX_CONFIG = "${VENDOR}_${CHIP}_${KERNEL_VARIANT}_defconfig";
  SG2042_BSP_LINUX_SRC_DIR = "/build/${src.repo}";
  SG2042_BSP_LINUX_BUILD_DIR = "${SG2042_BSP_LINUX_SRC_DIR}/build/${CHIP}/${KERNEL_VARIANT}";

  unpackPhase = ''
    cp -a $src $SG2042_BSP_LINUX_SRC_DIR
    chmod -R u+w $SG2042_BSP_LINUX_SRC_DIR
  '';

  buildPhase = ''
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
  '';

  installPhase = ''
    mkdir -p $out
    cp $SG2042_BSP_LINUX_BUILD_DIR/arch/riscv/boot/Image $out/riscv64_Image
    cp $SG2042_BSP_LINUX_BUILD_DIR/arch/riscv/boot/dts/sophgo/*.dtb $out
  '';
}
