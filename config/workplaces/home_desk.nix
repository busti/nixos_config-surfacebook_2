{ config, lib, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "displaylink" ];
}