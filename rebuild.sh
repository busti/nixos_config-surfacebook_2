( cd /etc/nixos/ || exit
  git pull origin master
  nixos-rebuild switch
)