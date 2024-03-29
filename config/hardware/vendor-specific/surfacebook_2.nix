{ config, lib, pkgs, modulesPath, ... }: let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      exec -a "$0" "$@"
    '';
in {
  imports = [
    "${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }}/microsoft/surface"
  ];

  services.xserver.videoDrivers = [ "nvidia" "displaylink" ];

  hardware = {
    opengl = {
      enable = true;
      driSupport32Bit = true;
      driSupport = true;
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
    nvidia = {
      prime = {
        offload.enable = true;
        # sync.allowExternalGpu = true;
        intelBusId = "PCI:00:02:0";
        nvidiaBusId = "PCI:02:00:0";
      };
      modesetting.enable = true;
      nvidiaPersistenced = false;
    };
    bumblebee = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [ nvidia-offload nvtop ];

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
}