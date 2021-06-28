{ config, lib, pkgs, ... }:

{
  networking.hostName = "traal";

  hardware.bluetooth.disabledPlugins = [ avrcp ];
}