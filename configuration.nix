{ lib, config, pkgs, ... }:

let
  path_nixpkgs-unstable = builtins.fetchTarball "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
in {
  nixpkgs.config.packageOverrides = pkgs: rec {
    unstable = import path_nixpkgs-unstable {
      config = config.nixpkgs.config;
    };
  };

  nix = {
    binaryCaches = [ "https://nixcache.neulandlabor.de" ];
    binaryCachePublicKeys = [ "nixcache.neulandlabor.de:iWPJklU/Tq9NdFWUcO8S7TBHwUjyZMjKIkCIWOei/Tw=" ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 24d";
      persistent = true;
      randomizedDelaySec = "45min";
    };
    buildMachines = [{
      hostName = "builder";
      system = "x86_64-linux";
      maxJobs = 1;
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
    }];
    distributedBuilds = true;
    extraOptions = ''
      builders-use-substitutes = true
      min-free = ${toString (5 * 1024 * 1024 * 1024)}
      max-free = ${toString (10 * 1024 * 1024 * 1024)}
    '';
    trustedUsers = [
      "mbust"
    ];
  };

  environment.systemPackages = with pkgs; [
    # essentials
    wget curl git htop vim

    # nice to have
    pciutils

    # setup specific
    bitwarden-cli

    # sometimes needed, small footprint
    pkg-config bintools-unwrapped
  ];

  imports = [
    ./hardware-configuration.nix
    ./modules/home-config.nix
    ./config/hardware/surfacebook_2.nix
    # ./config/workplaces/home_desk.nix
    ./config/hosts/traal.nix
    ./config/desktop/common.nix
    # ./config/desktop/env/i3wm/i3wm.nix
    # ./config/desktop/env/sway/sway.nix
    ./config/desktop/env/gnome/gnome.nix
    ./config/software/chromium.nix
    ./config/software/vscode.nix
    ./config/software/openssl.nix
  ];

  nixpkgs.config.allowUnfree = true;

  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {
        enable = true;
        version = 2;
        device = "nodev";
        useOSProber = true;
        efiSupport = true;
        enableCryptodisk = true;
      };
    };
    initrd.luks.devices = {
      root = {
        device = (builtins.readFile ./uuid_boot);
        preLVM = true;
      };
    };
    cleanTmpDir = true;
  };

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  networking = {
    networkmanager = {
      enable = true;
    };
    enableIPv6 = false;
    firewall.enable = false;
  };

  environment.pathsToLink = [ "/libexec" ];

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  virtualisation.docker.enable = true;

  users.users.mbust = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "dialout" "bumblebee" "docker" ];
    initialPassword = "changeme"; # fixme: remove for final install
    config = {
      fetch = "https://github.com/busti/dotfiles";
      push = "git@github.com:busti/dotfiles";
      path = ".dotfiles";
      install = "./install.sh";
    };
  };

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint gutenprintBin
      # hdlip # hdlipWithPlugin
      
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}











