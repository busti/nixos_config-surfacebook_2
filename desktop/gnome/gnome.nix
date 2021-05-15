{ config, lib, pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome3.enable = true;
    };
  };

  environment.gnome3.excludePackages = with pkgs.gnome3; [
    baobab cheese eog epiphany gedit simple-scan totem yelp evince file-roller geary seahorse
    gnome-calculator gnome-calendar gnome-characters gnome-clocks gnome-contacts
    gnome-font-viewer gnome-logs gnome-maps gnome-music gnome-photos gnome-screenshot
    gnome-system-monitor gnome-weather gnome-disks
  ];

  environment.systemPackages = with pkgs; [ gnomeExtensions.appindicator ];
  services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];
}