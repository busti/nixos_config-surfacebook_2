{ config, lib, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    exportConfiguration = true;
    libinput.enable = true;
    desktopManager = {
      xterm.enable = false;
    };
    displayManager = {
      defaultSession = "none+i3";
    };
    windowManager.i3 = {
      enable = true;
      configFile = /etc/i3/config;
      extraPackages = with pkgs; [
        dmenu i3status i3lock
      ];
    };
  };

  environment.etc."i3/config".source = ./common.conf;
}