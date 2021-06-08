{ config, lib, pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome = {
        enable = true;
        extraGSettingsOverrides = ''
          [org.gnome.mutter]
          experimental-features=['scale-monitor-framebuffer']
        '';
      };
    };
  };

  programs.chromium.extensions = [
    "gphhapmejobijbbhgpjhcjognlahblep" # gnome shell integration
  ];

  environment.gnome.excludePackages = with pkgs.gnome; [
    baobab      # disk usage analyzer
    cheese      # photo booth
    eog         # image viewer
    epiphany    # web browser
    gedit       # text editor
    simple-scan # document scanner
    totem       # video player
    yelp        # help viewer
    evince      # document viewer
    file-roller # archive manager
    geary       # email client
    seahorse    # password manager
    gnome-calculator gnome-calendar gnome-characters gnome-clocks gnome-contacts
    gnome-font-viewer gnome-logs gnome-maps gnome-music gnome-photos gnome-screenshot
    gnome-system-monitor gnome-weather gnome-disk-utility pkgs.gnome-connections
  ];

  environment.systemPackages = with pkgs.gnomeExtensions; [
    appindicator pixel-saver remove-rounded-corners coverflow-alt-tab arrange-windows sound-output-device-chooser
    autohide-battery bluetooth-quick-connect
  ];
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
}