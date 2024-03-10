{ bison
, buildPackages
, fetchFromGitHub
, flex
, hexdump
, lib
, stdenvNoCC
, ...
}:

# TODO: make compiling with GCC 14 + xthead optional

# This derivation builds the zsbl artifact from the Sophgo SG2042 bsp.
#
# For reference, see the upstream zsbl repositories:
#   https://github.com/sophgo/zsbl
#
# For reference, see the `build_rv_zsbl` function in `scripts/envsetup. sh`:
#   https://github.com/sophgo/bootloader-riscv


# NOTE: See `depsBuildBuild` below for the rationale behind `stdenvNoCC`.
stdenvNoCC.mkDerivation {
  pname = "milkv-pioneer-bsp-zsbl";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "milkv-community";
    repo = "sg2042-zsbl";
    rev = "cc80627";
    hash = "sha256-zOlBM7mwz8FUM/BlzOxJmpI8LI/KcFOGXegvgiilbaM=";
  };

  patches = [
    # Depending on the sdcard, reading larger initrds (say >= 25MB) can hit the timeout.
    ./patches/000-zsbl-increase-timeout.patch
  ];

  nativeBuildInputs = [
    bison
    flex
    hexdump
  ];

  # NOTE: The build process specifically checks for `gcc` rather than `cc` (unless LLVM mode is
  # selected, but that hasn't been tested). So just to be explicit about it, we include
  # `gccStdenv.cc` in the build dependencies.

  # NOTE: If cross-compiling, we need a `gcc` that targets the build platform, since some
  # preliminary kconfig-related compilation happens before the main build.
  depsBuildBuild = lib.optionals (with stdenvNoCC; buildPlatform != targetPlatform) [
    buildPackages.gccStdenv.cc
  ];

  depsBuildTarget = [
    buildPackages.xthead.gcc14
  ];

  dontStrip = true;
  enableParallelBuilding = true;
  hardeningDisable = [
    "fortify"
    "stackprotector"
  ];

  configurePhase = ''
    runHook preConfigure
    make sg2042_defconfig
    runHook postConfigure
  '';

  makeFlags = [
    "CROSS_COMPILE=${buildPackages.xthead.gcc14.targetPrefix}"
    "KCFLAGS+=-O3"
    "KCFLAGS+=-march=rv64gc_xtheadvector_zihintpause"
    "KCFLAGS+=-mcpu=thead-c906"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -a zsbl.bin $out
    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/sophgo/zsbl";
    description = "Sophgo RISC-V Zero Stage Boot Loader";
    license = lib.licenses.gpl2;
    platforms = [ "riscv64-linux" ];
  };
}
