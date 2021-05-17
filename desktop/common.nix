{ config, lib, pkgs, ... }:

{
  environment.etc."xdg/user-dirs.default".source = ./user-dirs.defaults;
}