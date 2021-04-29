{ config, lib, pkgs, ... }:

{
  services.xserver = {
    videoDriver = [ "displaylink" ];
    extraConfig = ''
      Section "OutputClass"
        Identifier "DLRot"
        MatchDriver "evdi"
        Option "PageFlip" "off"
      EndSection
    '';
  };
}