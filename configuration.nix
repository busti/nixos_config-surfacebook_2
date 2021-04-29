{ lib, config, pkgs, ... }:

let
  path_nixpkgs-unstable = builtins.fetchTarball "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";

  path_home-manager = builtins.fetchGit {
    url = "https://github.com/nix-community/home-manager.git";
    rev = "fedfd430f96695997b3eaf8d7e82ca79406afa23";
  };
in
{
  nixpkgs.config.packageOverrides = pkgs: {
    unstable = import path_nixpkgs-unstable {
      config = config.nixpkgs.config;
    };
  };

  nix = {
    binaryCaches = [ "https://nixcache.neulandlabor.de" ];
    binaryCachePublicKeys = [ "nixcache.neulandlabor.de:iWPJklU/Tq9NdFWUcO8S7TBHwUjyZMjKIkCIWOei/Tw=" ];
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
    '';

  };

  environment.systemPackages = with pkgs; [
    wget curl git htop vim
    firefox ungoogled-chromium
    jetbrains.idea-community
  ];

  imports =
    [
      ./hardware-configuration.nix
      ( import "${path_home-manager}/nixos" )
      # ./sway.nix
      ./hardware/surfacebook_2.nix
      ./workplaces/home_desk.nix
      ./hosts/traal.nix
      ./desktop/i3wm/i3wm.nix
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
  };

  environment.pathsToLink = [ "/libexec" ];

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users.users.mbust = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    initialPassword = "changeme"; # fixme: remove for final install
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
  system.stateVersion = "20.09"; # Did you read the comment?

}











