# To update nix-prefetch-git https://github.com/NixOS/nixpkgs
import ((import <nixpkgs> {}).fetchFromGitHub {
  owner = "NixOS";
  repo = "nixpkgs";
  rev = "7bc2869094ce99fe7531e82fa9353fe646808990";
  sha256  = "0lkv4xs7c1mcflvmnrcm4kx01hakhm6ybv1i4jv7ggwh1q7ldjf2";
})
