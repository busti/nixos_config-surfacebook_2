{ config, lib, pkgs, utils,  ... }:

let
  # users = config.users.users;

  home-config = {lib, ...}: {
    options.config = with lib; mkOption {
      description  = "user's home configuration repository";
      default = null;
      type = with types; nullOr (submodule ({config, ...}: {
        options = {
          fetch = mkOption {
            type = str;
            description = "fetch URL for git repository with user configuration";
          };
          push = mkOption {
            type = str;
            description = "push URL for git repository, if it differs";
          };
          branch = mkOption {
            type = str;
            default = "master";
            description = "branch in repository to clone";
          };
          path = mkOption {
            type = str;
            default = ".config";
            description = "clone path for configuration repository, relative to user's $HOME";
          };
          install = mkOption {
            type = str;
            default = "./install";
            description = "installation command";
          };
        };
      }));
    };
  };
in {
  # extend NixOS user configuration module
  options = with lib; with types; {
    users.users = mkOption {
      type = attrsOf (submodule home-config);
    };
  };
  config = with builtins; with lib;
    let
      check = user: "home-config-check-${utils.escapeSystemdPath user.name}";
      initialise = user: "home-config-initialise-${utils.escapeSystemdPath user.name}";
      service = unit: "${unit}.service";
    in {
      # set up user configuration *before* first login
      systemd.services = mkMerge (map (user: mkIf (user.isNormalUser && user.config != null) {
        # skip initialisation early on boot, before waiting for the network, if
        # git repository appears to be in place.
        "${check user}" = {
          description = "check home configuration for ${user.name}";
          wantedBy = [ "multi-user.target" ];
          unitConfig = {
            # path must be absolute!
            # <https://www.freedesktop.org/software/systemd/man/systemd.unit.html#ConditionArchitecture=>
            ConditionPathExists = "!${user.home}/${user.config.path}/.git";
          };
          serviceConfig = {
            User = user.name;
            SyslogIdentifier = check user;
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${pkgs.coreutils}/bin/true";
          };
        };
        "${initialise user}" = {
          description = "initialise home-manager configuration for ${user.name}";
          # do not allow login before setup is finished. after first boot the
          # process takes a long time, and the user would log into a broken
          # environment.
          # let display manager wait in graphical setups.
          wantedBy = [ "multi-user.target" ];
          before = [ "systemd-user-sessions.service" ] ++ optional config.services.xserver.enable "display-manager.service";
          # `nix-daemon` and `network-online` are required under the assumption
          # that installation performs `nix` operations and those usually need to
          # fetch remote data
          after = [ (service (check user)) "nix-daemon.socket" "network-online.target" ];
          bindsTo = [ (service (check user)) "nix-daemon.socket" "network-online.target" ];
          path = with pkgs; [ git nix ];
          environment = {
            NIX_PATH = builtins.concatStringsSep ":" config.nix.nixPath;
          };
          serviceConfig = {
            User = user.name;
            Type = "oneshot";
            SyslogIdentifier = initialise user;
            ExecStart = let
              script = pkgs.writeShellScriptBin (initialise user) ''
                set -e
                mkdir -p ${user.home}/${user.config.path}
                cd ${user.home}/${user.config.path}
                git init
                git remote add origin ${user.config.fetch}
                git remote set-url origin --push ${user.config.push}
                git fetch
                git checkout ${user.config.branch} --force
                ${user.config.install}
              '';
            in "${script}/bin/${(initialise user)}";
          };
        };
      }) (attrValues config.users.users));
    };
}