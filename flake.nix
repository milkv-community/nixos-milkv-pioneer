{
  description = "A template that shows all standard flake outputs";


  nixConfig = {
    accept-flake-config = true;
    # FIXME:
    extra-access-tokens = [
      "!include /home/silvanshade/.config/nix-access-tokens/github"
    ];
    extra-experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [
      "https://cache.nixos.org"
      "https://cuda-maintainers.cachix.org"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    flake-compat = {
      url = "github:inclyc/flake-compat";
      flake = false;
    };
    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
      # inputs.nixpkgs.follows = "nixpkgs"; # NOTE: non-existent
    };
    nixos-riscv = {
      url = "github:NickCao/nixos-riscv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      eachSystem = inputs.nixpkgs.lib.genAttrs (import systems);
      eachSystemPkgs = overrides: f: eachSystem (system:
        let
          pkgs = import inputs.nixpkgs ({ inherit system; } // overrides);
        in
        f pkgs);
      treefmtEval = eachSystem (system: inputs.treefmt-nix.lib.evalModule inputs.nixpkgs.legacyPackages.${system} ./treefmt.nix);
    in
    {
      formatter = eachSystemPkgs { } (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      checks = eachSystemPkgs { } (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check inputs.self;
      });
    };
}
