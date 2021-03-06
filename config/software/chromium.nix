{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    chromium
  ];

  programs.chromium = {
    enable = true;
    extensions = [
      # "ocaahdebbfolfmndjeplogmgcagdmblk;https://raw.githubusercontent.com/NeverDecaf/chromium-web-store/master/updates.xml"
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # dark reader
      "nngceckbapebfimnlniiiahkandclblb" # bitwarden
    ];
    extraOpts = {
      "3rdparty" = {
        "extensions" = {
          "cjpalhdlnbpafiamejdnhcphjbkeiagm" = {
            "toolbar_pin" = "force_pinned";
            "adminSettings" = builtins.toJSON {
              "userSettings" = {
                "advancedUserEnabled" = true;
              };
            };
          };
          "eimadpbcbfnmbkopoojfekhnkhdbieeh" = {
            "toolbar_pin" = "force_pinned";
          };
          "nngceckbapebfimnlniiiahkandclblb" = {
            "toolbar_pin" = "force_pinned";
          };
        };
      };
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
