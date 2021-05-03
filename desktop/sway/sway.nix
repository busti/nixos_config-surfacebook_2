{ config, lib, pkgs, modulesPath, ... }:

{
  services.xserver = {
    videoDrivers = [ "intel" "nouveau" "displaylink" ];
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      mesa
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.mesa
    ];
  };

  environment.systemPackages = with pkgs; [
    glxinfo
  ];

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly
    extraPackages = with pkgs; [
      swaylock
      swayidle
      # wl-clipboard
      # mako # notification daemon
      alacritty # Alacritty is the default terminal in the config
      dmenu # Dmenu is the default in the config but i recommend wofi since its wayland native
    ];
  };
}