{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ungoogled-chromium
  ];

  programs.chromium = {
    enable = true;
    extensions = [
      "ocaahdebbfolfmndjeplogmgcagdmblk;https://raw.githubusercontent.com/NeverDecaf/chromium-web-store/master/updates.xml"
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
    ];
  };
}