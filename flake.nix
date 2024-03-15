{
  description = "A Nix flake for building the Milk-V Pioneer BSP";

  inputs = {
    flake-compat = {
      url = "github:inclyc/flake-compat";
      flake = false;
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
      formatter = eachSystemPkgs { } (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      checks = eachSystemPkgs { } (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check inputs.self;
      });

      scopedPackages = eachSystemPkgs { } (pkgs: {
        milkv = recurseIntoAttrs (pkgs.callPackage ./packages/milkv { });
        toolchain = recurseIntoAttrs (pkgs.callPackage ./packages/toolchain { });
      });

      packages = eachSystemPkgs { } (pkgs: {
        milkv-pioneer-bsp-edk2 = scopedPackages.${pkgs.system}.milkv.pioneer.bsp.edk2;
        milkv-pioneer-bsp-linux = scopedPackages.${pkgs.system}.milkv.pioneer.bsp.linux;
        milkv-pioneer-bsp-opensbi = scopedPackages.${pkgs.system}.milkv.pioneer.bsp.opensbi;
        milkv-pioneer-bsp-zsbl = scopedPackages.${pkgs.system}.milkv.pioneer.bsp.zsbl;
      });

      devShells = eachSystemPkgs { } (pkgs:
        let
          bsp-edk2 = packages.${pkgs.system}.milkv-pioneer-bsp-edk2;
          # bsp-src-linux = packages.${pkgs.system}.milkv-pioneer-bsp-linux.src;
          bsp-opensbi = packages.${pkgs.system}.milkv-pioneer-bsp-opensbi;
          bsp-zsbl = packages.${pkgs.system}.milkv-pioneer-bsp-zsbl;
        in
        {
          default = pkgs.pkgsCross.riscv64.mkShell {
            BSP_EDK2 = bsp-edk2;
            # BSP_SRC_LINUX = bsp-src-linux;
            BSP_OPENSBI = bsp-opensbi;
            BSP_ZSBL = bsp-zsbl;
            nativeBuildInputs = with pkgs; [
              bison
              flex
              go
            ];
          };
        });
    };
}
