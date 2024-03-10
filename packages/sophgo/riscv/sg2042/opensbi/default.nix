{ buildPackages
, fetchFromGitHub
, opensbi
, overrideCC
, stdenv
, withCFlags
, ...
}:

# TODO: make compiling with GCC 14 + xthead optional

# This derivation builds the opensbi artifact from the Sophgo SG2042 bsp.
#
# For reference, see the upstream opensbi repositories:
#   https://github.com/sophgo/opensbi
#   https://github.com/riscv-software-src/opensbi
#
# For reference, see the `build_rv_sbi` function in `scripts/envsetup.sh`:
#   https://github.com/sophgo/bootloader-riscv

(opensbi.override {
  stdenv = withCFlags [
    "-O3"
    "-march=rv64gc_xtheadvector_zihintpause"
    "-mcpu=thead-c906"
  ]
    (overrideCC stdenv buildPackages.xthead.gcc14);
}).overrideAttrs (attrs: rec {
  # Based on the vendor's sg2042-master branch.
  version = "1.4-git-${src.rev}";
  src = fetchFromGitHub {
    owner = "milkv-community";
    repo = "opensbi";
    rev = "c59d9c7";
    hash = "sha256-zdOR8Ewv4UEsf6c83FXD4cqUlTnTVDhNvRaK17zjJvs=";
  };

  patches = (attrs.patches or [ ]) ++ [
    ./patches/000-fix-maybe-uninitialized-warnings.patch
  ];

  makeFlags =
    # Based on the vendor options:
    # https://github.com/sophgo/bootloader-riscv/blob/01dc52ce10e7cf489c93e4f24b6bfe1bf6e55919/scripts/envsetup.sh#L299
    attrs.makeFlags ++ [
      "PLATFORM=generic"
      "FW_PIC=y"
      "BUILD_INFO=y"
      "DEBUG=1"
    ];
})
