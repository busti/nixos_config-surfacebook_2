( cd /etc/nixos/ || exit
  git pull origin master

  sources=$(nix-build nix/sources-dir.nix --no-out-link)

  nixos-rebuild switch -I $sources
)