{ pkgs, ... }:

# This derivation builds the edk2 artifact from the Sophgo SG2042 bsp.
#
# For reference, see the upstream zsbl repositories:
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

pkgs.pkgsCross.riscv64.stdenv.mkDerivation rec {
  pname = "milkv-pioneer-bsp-edk2";
  version = "0.0.0";

  srcs = [
    (pkgs.fetchFromGitHub
      rec {
        owner = "milkv-community";
        repo = "edk2";
        rev = "b17e242";
        hash = "sha256-VFRrIsIfIx0VNhBw2ifvq4l9Yuj808k65dfMXhB/yUY=";
        fetchSubmodules = true;
        name = repo;
      })
    (pkgs.fetchFromGitHub
      rec {
        owner = "milkv-community";
        repo = "edk2-platforms";
        rev = "fc479db";
        hash = "sha256-KDDf0UCoJarCqQwaCqKbogpSl5sRx04TybnZTvn3V7k=";
        fetchSubmodules = true;
        name = repo;
      })
    (pkgs.fetchFromGitHub
      rec {
        owner = "milkv-community";
        repo = "edk2-non-osi";
        rev = "1cfd89b";
        hash = "sha256-oBM1/KHhSIKHPOqNzCEBEmncLNTvPt+74UjKVm43InU=";
        fetchSubmodules = true;
        name = repo;
      })
  ];

  sourceRoot = ".";

  unpackPhase = ''
  '';

  buildPhase = ''
  '';

  installPhase = ''
    mkdir -p $out
  '';
}
