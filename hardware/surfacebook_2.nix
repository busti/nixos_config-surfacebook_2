{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    "${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }}/microsoft/surface"
  ];

  services.xserver = {
    videoDrivers = [ "intel" "nvidia" ];
    deviceSection = ''
      Option "DRI" "3"
      Option "TearFree" "true"
      Option "PageFlip" "off"
      Option "RandRRotation" "True"
    '';
  };

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  boot.kernelParams = [ "i915.enable_psr=0" ];
}