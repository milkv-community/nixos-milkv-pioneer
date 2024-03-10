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
      url = "github:silvanshade/nixpkgs/nixpkgs-unstable";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xthead-toolchains = {
      url = "github:milkv-community/nixpkgs-xthead-toolchains";
    };
  };

  outputs = { self, nixpkgs, systems, treefmt-nix, xthead-toolchains, ... }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems ++ [ "riscv64-linux" ]);
      eachSystemPkgs = overrides: f: eachSystem (system:
        let
          pkgs = import nixpkgs ({ inherit system; } // overrides);
        in
        f pkgs);
      treefmtEval = eachSystem (system: treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt.nix);
    in
    {
      formatter = eachSystemPkgs { } (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      checks = eachSystemPkgs { } (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });

      overlays = {
        default = nixpkgs.lib.composeManyExtensions [
          xthead-toolchains.overlays.default
          (final: prev: {
            sophgo = {
              riscv = {
                sg2042 = {
                  linux = prev.callPackage ./packages/sophgo/riscv/sg2042/linux { };
                  linuxPackages = prev.linuxPackagesFor final.sophgo.riscv.sg2042.linux;
                  opensbi = prev.callPackage ./packages/sophgo/riscv/sg2042/opensbi { };
                  zsbl = prev.callPackage ./packages/sophgo/riscv/sg2042/zsbl { };
                };
              };
            };
          })
        ];
      };

      devShells = eachSystemPkgs
        {
          overlays = [
            self.overlays.default
          ];
        }
        (pkgs: {
          default = pkgs.mkShell {
            nativeBuildInputs = with pkgs.pkgsCross.riscv64; [
              sophgo.riscv.sg2042.linuxPackages.kernel
              sophgo.riscv.sg2042.opensbi
              sophgo.riscv.sg2042.zsbl
            ];
          };
        });

      flake = {
        config = {
          ccache =
            let
              common = ''
                export CCACHE_MAXSIZE=0
                export CCACHE_COMPILERCHECK=content
                export CCACHE_NOHASHDIR=1
                export CCACHE_SLOPPINESS=include_file_ctime,include_file_mtime,locale,modules,pch_defines,random_seed,system_headers,time_macros
              '';
            in
            {
              dev = ''
                ${common}
                export CCACHE_DIR="''${XDG_CACHE_DIR:-$HOME/.cache}/ccache"
              '';
              nix = ''
                ${common}
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
            };
        };
      };
    };
}
