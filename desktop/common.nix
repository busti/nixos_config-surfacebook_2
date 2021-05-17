{ config, lib, pkgs, ... }:

{
  environment.etc."xdg/user-dirs.defaults".source = ./user-dirs.defaults;
}