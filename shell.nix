with import ./nix/pkgs.nix {};
let 
  merged-openssl = symlinkJoin { name = "merged-openssl"; paths = [ openssl.out openssl.dev ]; };
in stdenv.mkDerivation rec {
  name = "rust-env";
  env = buildEnv { name = name; paths = buildInputs; };

  buildInputs = [
    rustup
    clang
    cmake
    llvm
    llvmPackages.libclang
    openssl
    cacert
    pkg-config
    bitcoind
    clightning
  ];
  LIBCLANG_PATH="${llvmPackages.libclang}/lib";
  OPENSSL_DIR="${merged-openssl}";
}
