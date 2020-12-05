cd $(dirname $0)

function replaceDir {
	dir=~/.config/$2

	if [[ -h $dir ]]; then
		rm $dir
	fi

	ln -rs $1 $dir
}

# bash
ln -frs bash/.bashrc ~/

# git
ln -frs git/.gitconfig ~/
replaceDir git git

# i3
replaceDir i3/i3 i3
replaceDir i3/i3status i3status

# neovim
replaceDir neovim/config nvim

# nix
ln -f nix/configuration.nix /etc/nixos/
ln -f nix/flake.nix /etc/nixos/
ln -f nix/flake.lock /etc/nixos/
