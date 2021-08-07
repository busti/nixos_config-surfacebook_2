{ config, lib, pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [ openssl ];
    variables = with pkgs; {
      OPENSSL_DIR = "${openssl.dev}";
      OPENSSL_LIB_DIR = "${openssl.out}/lib";
    };
  };
}