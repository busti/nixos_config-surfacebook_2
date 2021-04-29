{ lib, config, pkgs, ... }:

let
  path_nixpkgs-unstable = builtins.fetchTarball "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";

  path_home-manager = builtins.fetchGit {
    url = "https://github.com/nix-community/home-manager.git";
    rev = "fedfd430f96695997b3eaf8d7e82ca79406afa23";
  };
in
{
  nixpkgs.overlays = [
    (self: super: {
      ungoogled-chromium = super.ungoogled-chromium.override { libvaSupport = true; };
    })
  ];

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
    firefox chromium # (ungoogled-chromium.override { libvaSupport = true; })
    jetbrains.idea-community
  ];

  imports =
    [
      "${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }}/microsoft/surface"
      ./hardware-configuration.nix
      ( import "${path_home-manager}/nixos" )
      # ./sway.nix
      ./surface.nix
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
    hostName = "traal";
    networkmanager = {
      enable = true;
      # wifi.backend = "iwd";
      # unmanaged = [ "type:gsm" ];
    };
    # wireless = {
    #  enable = true;
    #  iwd.enable = true;
    #  networks = {
    #    "hannover.freifunk.net" = {};
    #  };
    #};
  };

  environment.pathsToLink = [ "/libexec" ];

  services.xserver = {
    enable = true;
    exportConfiguration = true;
    videoDrivers = [ "displaylink" "intel" "nvidia" ];
    deviceSection = ''
      Option "DRI" "3"
      Option "TearFree" "true"
      Option "PageFlip" "off"
      Option "RandRRotation" "True"
    '';
    extraConfig = ''
      Section "OutputClass"
        Identifier "DLRot"
        MatchDriver "evdi"
        Option "PageFlip" "off"
      EndSection
    '';
    #extraConfig = ''
    #  Section "Monitor"
    #    Identifier "eDP1"
    #  EndSection
    #
    #  Section "Monitor"
    #    Identifier "DVI-I-2-1"
    #    Option "LeftOf" "eDP1"
    #    Option "PreferredMode" "1680x1050"
    #  EndSection
    #
    #  Section "Monitor"
    #    Identifier "DP1-1"
    #    Modeline "lggarbage" 138.50 1920 1968 2000 2080 1080 1083 1088 1111 +hsync -vsync
    #    Option "PreferredMode" "lggarbage"
    #    Option "LeftOf" "DVI-I-2-1"
    #  EndSection
    #
    #  Section "Monitor"
    #    Identifier "DP1-2"
    #    Option "Above" "DP1-1"
    #  EndSection
    #
    #  Section "Monitor"
    #    Identifier "DVI-I-3-2"
    #    Option "LeftOf" "DP1-1"
    #    Option "PreferredMode" "1600x1200"
    #  EndSection
    #'';
    desktopManager = {
      xterm.enable = false;
    };
    displayManager = {
      defaultSession = "none+i3";
      sessionCommands = let xrandr = "${lib.getBin pkgs.xorg.xrandr}/bin/xrandr"; in ''
        ${xrandr} --setprovideroutputsource 1 0
        ${xrandr} --setprovideroutputsource 2 0
        ${xrandr} --output DVI-I-2-1 --right-of eDP1 --mode 1680x1050
        ${xrandr} --newmode "lggarbage" 138.50 1920 1968 2000 2080  1080 1083 1088 1111 +hsync -vsync
        ${xrandr} --addmode DP1-1 lggarbage
        ${xrandr} --output DP1-1 --mode lggarbage --right-of DVI-I-2-1
        ${xrandr} --output DP1-2 --above DP1-1
        ${xrandr} --output DVI-I-3-2 --right-of DP1-1 --mode 1600x1200
      '';
    };
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu i3status i3lock
      ];
    };
  };

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











