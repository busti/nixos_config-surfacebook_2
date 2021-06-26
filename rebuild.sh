( cd /etc/nixos/ || exit
  git pull origin master
  nixos-rebuild switch -p "$(git log -1 --pretty=format:'%s' | head)"
)