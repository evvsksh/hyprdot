#!/usr/bin/env bash

# config
required_pkgs="hyprland wayland wayland-protocols polkit-gnome xorg-xwayland waybar rofi
               zip unzip pipewire wireplumber networkmanager pamixer fastfetch vim nano
               noto-fonts kitty fish"

# colors
black="\033[30m"
dark_blue="\033[34m"
dark_green="\033[32m"
dark_aqua="\033[36m"
dark_red="\033[31m"
dark_purple="\033[35m"
gold="\033[33m"
gray="\033[37m"
dark_gray="\033[90m"
blue="\033[94m"
green="\033[92m"
aqua="\033[96m"
red="\033[91m"
light_purple="\033[95m"
yellow="\033[93m"
white="\033[97m"
reset="\033[0m"

# installation folder
tmp_path="/tmp/$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c16)"

# wrapper
echo() {
    command echo -e "$@${reset}"
}

# cleanup function
cleanup() {
    echo "${yellow}Cleaning up..."
    if [ -f "$tmp_path/mirrorlist.bak" ]; then
        sudo cp "$tmp_path/mirrorlist.bak" /etc/pacman.d/mirrorlist
    fi
    rm -rf $tmp_path
}

# trap exit signals
trap cleanup EXIT

# allow only arch-based distros
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    if [[ "$ID" != "arch" && "$ID_LIKE" != *arch* ]]; then
        echo "${red}This script can run only on Arch Linux or Arch-based distros.${reset}"
        exit 1
    fi
else
    echo "${red}This script can run only on Arch Linux or Arch-based distros.${reset}"
    exit 1
fi

# prevent script from running if sudo and no dedicated arg
if [[ $EUID -eq 0 && "$1" != "--root" ]]; then
    echo "${red}To prevent damages, please don't run this script as root.${reset}"
    echo "${red}To bypass this block, re-run the script with the --root arg."
    exit 1
fi

# check if hyprland is running
if pgrep -x "Hyprland" > /dev/null; then
    echo "${red}Hyprland must not be running for the script to work properly."
    exit 1
fi

# backup original mirrorlist
mkdir -p "$tmp_path"
cp /etc/pacman.d/mirrorlist "$tmp_path/mirrorlist.bak"

# setup
setup() {
    # root one-time password
    clear
    echo "${green}Root access is required, please fill in your password."
    echo "${yellow}NOTE: This will be only asked once!"
    sudo -v

    echo "${aqua}Waiting for lock file..."
    while [ -f /var/lib/pacman/db.lck ]; do
        sleep 1
    done

    # overwrite mirrorlist with good mirror using sudo
    sudo bash -c 'echo "Server = https://fastly.mirror.pkgbuild.com/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist'

    # install required packages
    sudo pacman -Syu --needed --noconfirm $required_pkgs
}

clear


# install prompt
echo "${green}Welcome to the setup script for ${yellow}evvsk's Hyprland Dotfiles"

sleep 1

read -rp "Would you like to start the setup? (Y/n): " response </dev/tty
response=${response:-Y}

case "$response" in
    [Yy]* )
        setup
        ;;
    * )
        echo "${red}Aborted."
        exit 0
        ;;
esac
