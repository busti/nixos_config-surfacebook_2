{ config, lib, pkgs, ... }:

{
  networking.hostName = "traal";

  hardware.bluetooth.disabledPlugins = [ "avrcp" ];

  hardware.pulseaudio.extraModules = [ pkgs.pulseaudio-modules-bt ];
}