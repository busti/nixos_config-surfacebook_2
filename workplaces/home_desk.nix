{ config, lib, pkgs, ... }:

{
  services.xserver = {
    videoDrivers = [ "displaylink" ];
    extraConfig = ''
      Section "OutputClass"
        Identifier "DLRot"
        MatchDriver "evdi"
        Option "PageFlip" "off"
      EndSection
    '';
    displayManager.sessionCommands = let xrandr = "${lib.getBin pkgs.xorg.xrandr}/bin/xrandr"; in ''
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
}