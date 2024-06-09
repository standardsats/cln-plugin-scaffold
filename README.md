# CLN Rust Plugin Example

This repository provides the necessary infrastructure to develop dynamic plugins for [CLN](https://github.com/ElementsProject/lightning). It includes a Nix environment and scripts to set up a local regtest instance of CLN.

# How to Use

To begin, enter the Nix shell with `nix-shell` to gain access to `rustup`, `rustc`, and `cargo`. This shell serves as the development environment for the Rust components.

One should follow the following steps to test resulting plugin (these scripts doesn't require calling `nix-shell` before them):
1. Run `./start-cln-regtest` in a separate terminal to start the regtest bitcoind daemon and CLN instance.
2. Execute `./start-plugin` to add the Rust plugin to the node started in the previous step.
3. Use `./stop-plugin` to remove the plugin.
4. Utilize `./cln-cli` and `./btc-cli` as shortcut scripts to execute the corresponding CLI commands.