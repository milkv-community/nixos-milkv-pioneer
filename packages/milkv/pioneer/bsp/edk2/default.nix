{ flake, pkgs, ... }:

# This derivation builds the edk2 artifact from the Sophgo SG2042 bsp.
#
# For reference, see the upstream edk2 repositories:
#   https://github.com/sophgo/sophgo-edk2
#   https://github.com/sophgo/edk2
#   https://github.com/sophgo/edk2-platforms
#   https://github.com/sophgo/edk2-non-osi
#   https://github.com/tianocore/edk2
#   https://github.com/tianocore/edk2-platforms
#   https://github.com/tianocore/edk2-non-osi
#
# For reference, see the `build_rv_edk2` function in `scripts/envsetup.sh`:
#   https://github.com/sophgo/bootloader-riscv

# NOTE: This derivation needs the default `gcc` to target the build host's native architecture, but
# we also need the riscv64-embedded targetting `gcc` installed as a nativeBuildInput. The edk2 build
# system will invoke this riscv64-embedded cross-toolchain on its own; we only need to set the
# `GCC5_RISCV64_PREFIX`.

flake.ccache.stdenv.mkDerivation rec {
  pname = "milkv-pioneer-bsp-edk2";
  version = "0.0.0";

  nativeBuildInputs = with pkgs; [
    # breakpointHook
    flake.ccache.stdenv-riscv64-embedded.cc
    libuuid
    python3
  ];

  src-edk2 = pkgs.fetchFromGitHub
    rec {
      owner = "milkv-community";
      repo = "edk2";
      rev = "b17e242";
      hash = "sha256-VFRrIsIfIx0VNhBw2ifvq4l9Yuj808k65dfMXhB/yUY=";
      fetchSubmodules = true;
      name = repo;
    };
  src-edk2-platforms = pkgs.fetchFromGitHub
    rec {
      owner = "milkv-community";
      repo = "edk2-platforms";
      rev = "fc479db";
      hash = "sha256-KDDf0UCoJarCqQwaCqKbogpSl5sRx04TybnZTvn3V7k=";
      fetchSubmodules = true;
      name = repo;
    };
  src-edk2-non-osi = pkgs.fetchFromGitHub
    rec {
      owner = "milkv-community";
      repo = "edk2-non-osi";
      rev = "1cfd89b";
      hash = "sha256-oBM1/KHhSIKHPOqNzCEBEmncLNTvPt+74UjKVm43InU=";
      fetchSubmodules = true;
      name = repo;
    };

  srcs = [
    src-edk2
    src-edk2-platforms
    src-edk2-non-osi
  ];

  sourceRoot = "sg2042-edk2";

  SG2042_BSP_EDKII_SRC_DIR = "/build/${sourceRoot}";
  TARGET = "RELEASE";

  unpackPhase = ''
    runHook preUnpack

    mkdir $sourceRoot

    cp -a ${src-edk2} $SG2042_BSP_EDKII_SRC_DIR/edk2
    chmod -R u+w $SG2042_BSP_EDKII_SRC_DIR/edk2

    cp -a ${src-edk2-platforms} $SG2042_BSP_EDKII_SRC_DIR/edk2-platforms
    chmod -R u+w $SG2042_BSP_EDKII_SRC_DIR/edk2-platforms

    cp -a ${src-edk2-non-osi} $SG2042_BSP_EDKII_SRC_DIR/edk2-non-osi
    chmod -R u+w $SG2042_BSP_EDKII_SRC_DIR/edk2-non-osi

    runHook postUnpack
  '';

  patchPhase = ''
    runHook prePatch

    patchShebangs $SG2042_BSP_EDKII_SRC_DIR/edk2/BaseTools/BinWrappers/PosixLike

    runHook postPatch
  '';

  buildPhase = ''
    runHook preBuild

    export WORKSPACE=$SG2042_BSP_EDKII_SRC_DIR
    export PACKAGES_PATH=$WORKSPACE/edk2:$WORKSPACE/edk2-platforms:$WORKSPACE/edk2-non-osi
    export EDK_TOOLS_PATH=$WORKSPACE/edk2/BaseTools
    export GCC5_RISCV64_PREFIX=${flake.ccache.stdenv-riscv64-embedded.cc.targetPrefix}

    # NOTE: We must first clear the positional args inherited from Nix environment so that
    # "buildPhase" is not passed as a positional argument when sourcing `edk2/edksetup.sh` below,
    # otherwise sourcing it will fail with a generic help message.
    set -- # clear the positional args
    source edk2/edksetup.sh

    make -j$NIX_BUILD_CORES -C edk2/BaseTools

    build -n $NIX_BUILD_CORES --arch=RISCV64 --tagname=GCC5 --buildtarget=$TARGET --define=X64EMU_ENABLE --platform=Platform/Sophgo/SG2042_EVB_Board/SG2042.dsc

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -a $SG2042_BSP_EDKII_SRC_DIR/Build/SG2042_EVB/$TARGET\_GCC5/FV/SG2042.fd $out

    runHook postInstall
  '';
}
