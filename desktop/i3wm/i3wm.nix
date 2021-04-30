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
      #extraSessionCommands = ''
      #  if [ ! -f /home/$USER/.config/i3/config ]; then
      #    mkdir -p /home/$USER/.config/i3/config
      #    cp /etc/i3/config /home/$USER/.config/i3/config
      #  fi
      #'';
      extraPackages = with pkgs; [
        dmenu i3status i3lock
      ];
    };
  };

  #environment.etc."i3/config".source = ./common.conf;
}