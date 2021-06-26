{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    "${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }}/microsoft/surface"
  ];

  services.xserver.videoDrivers = [ "nvidia" "displaylink" ];

  hardware = {
    opengl.driSupport32Bit = true;
    nvidia = {
      prime = {
        offload.enable = true;
        intelBusId = "PCI:00:02:0";
        nvidiaBusId = "PCI:02:00:0";
      };
      modesetting.enable = true;
    };
  };


  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  #hardware.opengl = {
  #  enable = true;
  #  extraPackages = with pkgs; [
  #    intel-media-driver # LIBVA_DRIVER_NAME=iHD
  #    vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
  #    vaapiVdpau
  #    libvdpau-va-gl
  #  ];
  #};

  boot.kernelParams = [ "i915.enable_psr=0" ];

  # audio
  sound.enable = true;
  hardware.pulseaudio.enable = true;
}