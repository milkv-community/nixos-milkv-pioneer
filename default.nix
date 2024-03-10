# https://github.com/nix-community/nixd/blob/main/nixd/docs/user-guide.md#how-to-use-nixd-in-my-flake
let
  flake-lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  flake-compat-tarball = fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/${flake-lock.nodes.flake-compat.locked.rev}.tar.gz";
    sha256 = flake-lock.nodes.flake-compat.locked.narHash;
  };
  flake-compat = import flake-compat-tarball { src = ./.; };
in
flake-compat.defaultNix
