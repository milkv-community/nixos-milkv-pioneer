{
  description = "A Nix flake for building the Milk-V Pioneer BSP";

  inputs = {
    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixos-hardware = {
    #   url = "github:nixos/nixos-hardware";
    #   # inputs.nixpkgs.follows = "nixpkgs"; # NOTE: non-existent
    # };
    # nixos-riscv = {
    #   url = "github:NickCao/nixos-riscv";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ systems, ... }:
    let
      eachSystem = inputs.nixpkgs.lib.genAttrs (import systems ++ [ "riscv64-linux" ]);
      eachSystemPkgs = overrides: f: eachSystem (system:
        let
          pkgs = import inputs.nixpkgs ({ inherit system; } // overrides);
        in
        f pkgs);
      recurseIntoAttrs = attrs: attrs // { recurseForDerivations = true; };
      treefmtEval = eachSystem (system: inputs.treefmt-nix.lib.evalModule inputs.nixpkgs.legacyPackages.${system} ./treefmt.nix);
    in
    rec {
      flake = eachSystemPkgs { } (pkgs: {
        ccache = rec {
          extraConfig = ''
            export CCACHE_MAXSIZE=20G
            export CCACHE_COMPILERCHECK=content
            export CCACHE_NOHASHDIR=1
            export CCACHE_SLOPPINESS=include_file_ctime,include_file_mtime,locale,modules,pch_defines,random_seed,system_headers,time_macros
            export CCACHE_DIR="/var/cache/ccache"
            export CCACHE_UMASK=007
            if [ ! -d "$CCACHE_DIR" ]; then
              echo "====="
              echo "Directory '$CCACHE_DIR' does not exist"
              echo "Please create it with:"
              echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
              echo "  sudo chown root:nixbld '$CCACHE_DIR'"
              echo "====="
              exit 1
            fi
            if [ ! -w "$CCACHE_DIR" ]; then
              echo "====="
              echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
              echo "Please verify its access permissions"
              echo "====="
              exit 1
            fi
          '';
          stdenv = pkgs.ccacheStdenv.override {
            inherit extraConfig;
          };
          stdenv-riscv64 = pkgs.pkgsCross.riscv64.ccacheStdenv.override {
            inherit extraConfig;
          };
          stdenv-riscv64-embedded = pkgs.pkgsCross.riscv64-embedded.ccacheStdenv.override {
            inherit extraConfig;
          };
        };
      });

      formatter = eachSystemPkgs { } (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      checks = eachSystemPkgs { } (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check inputs.self;
      });

      scopedPackages = eachSystemPkgs
        {
          overlays = [
            inputs.gomod2nix.overlays.default
          ];
        }
        (pkgs:
          let systemFlake = flake.${pkgs.system}; in
          {
            milkv = recurseIntoAttrs (pkgs.callPackage ./packages/milkv { flake = systemFlake; });
            toolchain = recurseIntoAttrs (pkgs.callPackage ./packages/toolchain { flake = systemFlake; });
          });

      packages = eachSystemPkgs { }
        (pkgs: with scopedPackages.${pkgs.system}; {
          milkv-pioneer-bsp-edk2 = milkv.pioneer.bsp.edk2;
          milkv-pioneer-bsp-bootloader = milkv.pioneer.bsp.bootloader;
          milkv-pioneer-bsp-linux = milkv.pioneer.bsp.linux;
          milkv-pioneer-bsp-opensbi = milkv.pioneer.bsp.opensbi;
          milkv-pioneer-bsp-uroot-initrd = milkv.pioneer.bsp.uroot-initrd;
          milkv-pioneer-bsp-zsbl = milkv.pioneer.bsp.zsbl;
        });

      devShells = eachSystemPkgs { } (pkgs: with packages.${pkgs.system};
        let
          bsp-edk2 = milkv-pioneer-bsp-edk2;
          bsp-bootloader = milkv-pioneer-bsp-bootloader;
          bsp-linux = milkv-pioneer-bsp-linux;
          bsp-opensbi = milkv-pioneer-bsp-opensbi;
          bsp-uroot-initrd = milkv-pioneer-bsp-uroot-initrd;
          bsp-zsbl = milkv-pioneer-bsp-zsbl;
        in
        {
          default = pkgs.mkShell {
            BSP_EDK2_BIN = bsp-edk2;
            BSP_EDK2_SRC = bsp-edk2.src-edk2;
            BSP_EDK2_PLATFORMS_SRC = bsp-edk2.src-edk2-platforms;
            BSP_EDK2_NON_OSI_SRC = bsp-edk2.src-edk2-non-osi;
            BSP_BOOTLOADER_BIN = bsp-bootloader;
            BSP_LINUX_BIN = bsp-linux;
            BSP_LINUX_SRC = bsp-linux.src;
            BSP_OPENSBI_BIN = bsp-opensbi;
            BSP_OPENSBI_SRC = bsp-opensbi.src;
            BSP_UROOT_INITRD_BIN = bsp-uroot-initrd;
            BSP_UROOT_INITRD_SRC = bsp-uroot-initrd.src;
            BSP_ZSBL_BIN = bsp-zsbl;
            BSP_ZSBL_SRC = bsp-zsbl.src;
            nativeBuildInputs = with pkgs; lib.filter
              (p: ! lib.elem p [
                # NOTE: The user will likely not have permissions to write to `/var/cache/ccache`
                # so just remove the ccache stdenvs from the shell environment.
                flake.${system}.ccache.stdenv.cc
                flake.${system}.ccache.stdenv-riscv64.cc
                flake.${system}.ccache.stdenv-riscv64-embedded.cc
              ])
              ([
                # NOTE: Replace the removed ccache stdenvs with non-caching variants.
                stdenv.cc
                pkgsCross.riscv64.stdenv.cc
                pkgsCross.riscv64-embedded.stdenv.cc
              ]
              ++ bsp-edk2.nativeBuildInputs
              ++ bsp-bootloader.nativeBuildInputs
              ++ bsp-linux.nativeBuildInputs
              ++ bsp-opensbi.nativeBuildInputs
              ++ bsp-uroot-initrd.nativeBuildInputs
              ++ bsp-zsbl.nativeBuildInputs);
          };
        });
    };
}
