{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ungoogled-chromium
  ];

  programs.chromium = {
    enable = true;
    extensions = [
      # "ocaahdebbfolfmndjeplogmgcagdmblk;https://raw.githubusercontent.com/NeverDecaf/chromium-web-store/master/updates.xml"
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
    ];
    extraOpts = {
      "BrowserSignin" = 0;
      "SyncDisabled" = true;
      "PasswordManagerEnabled" = false;
      "SpellcheckEnabled" = true;
      "SpellcheckLanguage" = [
        "de" "en-US"
      ];
      "DefaultCookieSettings" = 1;
    };
  };
}