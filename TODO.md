# todo

- Adapt xuantie-gnu-toolchain patches to build T-Head compatible toolchain
- Adapt xuantie-gnu-toolchain patches to GCC 14 for compatibility with T-Head vector extensions
- Provide package for GCC 14 with T-Head patches
- Build Pioneer image with kernel and packages customized gcc.{arch,tune} for C920
- Upstream sophgo/opensbi recent patches
- PRs for sophgo repos to rebase on upstream repos
- Github actions alerting when upstream is updated with new commits
- Pass unified environment into derivations
- Use mold linker (see `useMoldLinker` stdenv adapter)
- Switch to nixos provided packages
  - Switch to release versions
  - Include patches from milkv-community repos
  - Use stacked git for patches
- Create a separate flake for u-root
- Setup cachix
