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
  };
}