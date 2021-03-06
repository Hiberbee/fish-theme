#!/bin/bash

cyan='\033[0;36m'
yellow='\033[0;33m'
green='\033[0;32m'
transparent='\033[0m'

platform=""
case $(uname) in
"Darwin") platform="darwin" ;;
*) platform="linux" ;;
esac

architecture=""
case $(uname -m) in
i386) architecture="386" ;;
i686) architecture="386" ;;
x86_64) architecture="amd64" ;;
arm) dpkg --print-architecture | grep -q "arm64" && architecture="arm64" || architecture="arm" ;;
esac


fisher_version=3.2.11
fisher_download_url="https://raw.githubusercontent.com/jorgebucaran/fisher/$fisher_version/fisher.fish"
starship_download_url="https://starship.rs/install.sh"
fzf_version=0.21.1
fzf_dowload_url="https://github.com/junegunn/fzf-bin/releases/download/$fzf_version/fzf-$fzf_version-${platform}_$architecture.tgz"
fish_addons_url="https://raw.githubusercontent.com/Hiberbee/fish-theme/master/.config"
xxh_url="https://github.com/xxh/xxh-portable/raw/master/result/xxh-portable-musl-alpine-Linux-x86_64.tar.gz"

config_dir=${XDG_CONFIG_HOME:-"$HOME/.config"}
fish_functions_dir="$config_dir/fish/functions"
bin_dir=${BIN_DIR:-$HOME/bin}

echo -e "${green}Detected OS: ${cyan}$platform & $architecture${transparent}"

if [ ! -d "$bin_dir" ]; then
  echo -e "${yellow}Directory '$bin_dir' directory is not exist, creating...${transparent}"
  mkdir "$bin_dir"
fi

export PATH="$bin_dir:$PATH"

if [ ! -d "$fish_functions_dir" ]; then
  echo -e "${yellow}Fish's ${cyan}$fish_functions_dir${yellow} directory is not exist, creating...${transparent}"
  mkdir -p "$fish_functions_dir"
fi


echo -e "${yellow}Installing Fish Shell addons pack:${transparent}"
if [ ! "$(command -v xxh)" ]; then
  echo -e "${cyan}xxh${yellow} binary was not found in PATH $bin_dir, installing...${transparent}"
  wget $xxh_url -qO- | tar -xzv -C "$bin_dir"
else
  echo -e "${cyan}xxh${green} already installed.${transparent}"
fi

if [ ! -f "$fish_functions_dir/fisher.fish" ]; then
  echo -e "${yellow}Downloading fisher...${transparent}"
  wget "$fisher_download_url" -qO "$fish_functions_dir/fisher.fish"
else
  echo -e "${cyan}fisher${green} already installed.${transparent}"
fi
echo -e "${yellow}Don't forget to update fish plugins running ${cyan}fisher${yellow} command in your fish shell!${transparent}"
wget "$fish_addons_url/fish/fishfile" -qO "$config_dir/fish/fishfile"

echo -e "${yellow}Configuring Fish Shell color theme...${transparent}"
wget "$fish_addons_url/fish/functions/fish_greeting.fish" -qO "$config_dir/fish/functions/fish_greeting.fish"
wget "$fish_addons_url/fish/functions/fish_prompt.fish" -qO "$config_dir/fish/functions/fish_prompt.fish"


if [ ! "$(command -v starship)" ]; then
  echo -e "${yellow}Installing Starship shell prompt...${transparent}"
  wget "$starship_download_url" -qO- | FORCE=1 BIN_DIR=$bin_dir bash
else
  echo -e "${cyan}starship${green} already installed.${transparent}"
fi
echo -e "${green}Creating ${cyan}starship${green} prompt configuration...${transparent}"
wget "$fish_addons_url/starship.toml" -qO "$config_dir/starship.toml"

if [ ! "$(command -v fzf)" ]; then
  echo -e "${yellow}Downloading ${cyan}fzf v${fzf_version}${yellow}...${transparent}"
  wget "$fzf_dowload_url" -qO- | tar -xzv -C "$bin_dir"
else
  echo -e "${green}fzf already installed.${transparent}"
fi

chmod -R +x "$bin_dir"

echo -e "${cyan}Fish Shell${green} is updated and configured!${transparent}"
