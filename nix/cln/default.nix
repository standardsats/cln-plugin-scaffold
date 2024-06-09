{ config, lib, pkgs, ... }:
with lib;  # use the functions from lib, such as mkIf
let
  # the values of the options set for the service by the user of the service
  cfg = config.services.clightning;
  cln-cli = pkgs.writeShellScriptBin "cln-mainnet-cli" ''
    ${cfg.package}/bin/lightning-cli --lightning-dir=${cfg.datadir} --rpc-file ${cfg.rpcFile} "$@"
  '';
in {
  ##### interface. here we define the options that users of our service can specify
  options = {
    # the options for our service will be located under services.clightning
    services.clightning = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to enable clightning node by default.
        '';
      };
      package = mkOption {
        type = types.package;
        default = pkgs.clightning;
        defaultText = "pkgs.clightning";
        description = ''
          Which clightning package to use with the service.
        '';
      };
      alias = mkOption {
        type = types.str;
        default = "clightning";
      };
      color = mkOption {
        type = types.str;
        default = "49daaa";
      };
      rpcUser = mkOption {
        type = types.str;
        default = "user";
        description = ''
          Which name of bitcoin RPC user to use.
        '';
      };
      port = mkOption {
        type = types.int;
        default = 9735;
        description = ''
          Which port the cryptonode listens.
        '';
      };
      chain = mkOption {
        type = types.str;
        default = "bitcoin";
        description = ''
          Which blockchain to use: regtest, testnet or bitcoin
        '';
      };
      wallet = mkOption {
        type = types.str;
        default = "clightning";
        description = ''
          Bitcoin Core wallet name
        '';
      };
      datadir = mkOption {
        type = types.str;
        default = "/var/lib/clightning";
        description = ''
          Path to node database on filesystem.
        '';
      };

      btcPasswordFile = mkOption {
        type = types.str;
        default = "/run/keys/clnbtcpassword";
        description = ''
          Location of file with password for RPC.
        '';
      };
      btcPasswordFileService = mkOption {
        type = types.str;
        default = "clnbtcpassword-key.service";
        description = ''
          Service that indicates that passwordFile is ready.
        '';
      };
      rpcFile = mkOption {
        type = types.str; 
        default = "${cfg.datadir}/socket";
      };
      rpcFileMode = mkOption {
        type = types.str; 
        default = "0600";
      };
    };
  };

  ##### implementation
  config = mkIf cfg.enable { # only apply the following settings if enabled
    # User to run the node
    users.users.clightning = {
      name = "clightning";
      group = "clightning";
      extraGroups = [ "tor" ];
      description = "clightning daemon user";
      home = cfg.datadir;
      isSystemUser = true;
    };
    users.groups.clightning = {};
    # GPG setup
    programs.gnupg.agent.enable = true;
    # Write shortcut script to run commands on the node
    environment.systemPackages = [
      cln-cli
    ];
    # Create systemd service
    systemd.services.clightning = {
      enable = true;
      description = "clightning node";
      after = ["network.target" cfg.btcPasswordFileService];
      wants = ["network.target" cfg.btcPasswordFileService];
      path = with pkgs; [ gawk openjdk11 bitcoin];
      script = ''
        export BTC_PASSWORD=$(cat ${cfg.btcPasswordFile} | xargs echo -n)

        ${cfg.package}/bin/lightningd --network=${cfg.chain} \
          --log-level=debug \
          --lightning-dir=${cfg.datadir} \
          --bitcoin-rpcuser=${cfg.rpcUser} \
          --bitcoin-rpcpassword=$BTC_PASSWORD \
          --large-channels \
          --experimental-dual-fund \
          --experimental-onion-messages \
          --experimental-offers \
          --rpc-file=${cfg.rpcFile} \
          --rpc-file-mode=${cfg.rpcFileMode} \
          --rgb ${cfg.color} \
          --alias ${cfg.alias} 
      '';
      serviceConfig = {
          Restart = "always";
          RestartSec = 30;
          User = "clightning";
          WorkingDirectory = "${cfg.datadir}";
        };
      wantedBy = ["multi-user.target"];
    };
    # Init folder for clightning data
    system.activationScripts = {
      intclightning = {
        text = ''
          if [ ! -d "${cfg.datadir}" ]; then
            mkdir -p ${cfg.datadir}
            chown clightning ${cfg.datadir}
          fi
        '';
        deps = [];
      };
    };
  };
}
