{ buildLinux
, buildPackages
, fetchFromGitHub
, lib
, overrideCC
, stdenv
, ...
}:

let modDirVersion = "6.9.0-rc4"; in

buildLinux {
  stdenv = overrideCC stdenv buildPackages.xthead.gcc14;

  inherit modDirVersion;
  version = "${modDirVersion}-milkv-pioneer";
  src = fetchFromGitHub {
    owner = "milkv-community";
    repo = "linux";
    rev = "766bc51d281bcbd8062b9aff5c47fc685c974085";
    hash = "sha256-cxkG21rF5WuKQCvy9oQNBDmNyZ5pO+pul+xDpBFD678=";
  };

  defconfig = "sophgo_mango_normal_defconfig";
  structuredExtraConfig = let inherit (lib.kernel) module no option yes; in {
    DAMON_DBGFS = lib.mkForce (option no);
    NTFS_FS = lib.mkForce (option no);

    # Enable these explicitly because they are not enabled by the defconfig.
    # The all-hardware profile expects these to be built.
    VIRTIO_MENU = yes;
    VIRTIO_PCI = module;

    # There is an i2c mcu driver (drivers/soc/sophgo/umcu) which is always
    # compiled into the kernel. Hence some of the i2c support also needs to
    # be compiled in instead of being compiled as a module.
    I2C = yes;
    I2C_CHARDEV = yes;
    I2C_DESIGNWARE_PLATFORM = yes;
  };

  extraMakeFlags = [
    "KCFLAGS+=-O3"
    "KCFLAGS+=-march=rv64gc_xtheadvector_zihintpause"
    "KCFLAGS+=-mcpu=thead-c906"
  ];
}
