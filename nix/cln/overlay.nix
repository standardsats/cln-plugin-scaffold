self: super: {
  python3 = super.python3.override {
    packageOverrides = python-self: python-super: {
      mistune = python-super.mistune.overrideAttrs (oldAttrs: {
        src = super.python3Packages.fetchPypi {
          pname = "mistune";
          version = "0.8.4";
          sha256 = "sha256-WaNCnbU8ULXGvMigf4hIywDX3IvbQxpKtBkg0gHUdW4=";
          extension = "tar.gz";
        };
      });
    };
  };
}