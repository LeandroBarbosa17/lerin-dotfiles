#!/bin/sh
# Debian Adapted Installer

# Colors
CRE=$(tput setaf 1)
CYE=$(tput setaf 3)
CGR=$(tput setaf 2)
CBL=$(tput setaf 4)
BLD=$(tput bold)
CNC=$(tput sgr0)

logo() {
    text="$1"

    printf "%b" "
               %%%
        %%%%%//%%%%%
      %%************%%%
  (%%//############*****%%
 %%%%**###&&&&&&&&&###**//
 %%(**##&&&#########&&&##**
 %%(**##*****#####*****##**%%%
 %%(**##     *****     ##**
   //##   @@**   @@   ##//
     ##     **###     ##
     #######     #####//
       ###**&&&&&**###
       &&&         &&&
       &&&////   &&
          &&//@@@**
            ..***

   ${BLD}${CRE}[ ${CYE}${text} ${CRE}]${CNC}\n\n"
}

initial_checks() {
    if [ "$(id -u)" = 0 ]; then
        printf "This script MUST NOT be run as root user.\n"
        exit 1
    fi

    if [ "$PWD" != "$HOME" ]; then
        printf "The script must be executed from HOME directory.\n"
        exit 1
    fi
}

welcome() {
    clear
    logo "Welcome $USER"

    printf "%b" "${BLD}${CGR}This script will install my dotfiles on Debian.${CNC}

${BLD}${CGR}[${CYE}i${CGR}]${CNC} Install dependencies using apt
${BLD}${CGR}[${CYE}i${CGR}]${CNC} Save missing packages to missing_apps.txt
${BLD}${CGR}[${CYE}i${CGR}]${CNC} Clone dotfiles repository
${BLD}${CGR}[${CYE}i${CGR}]${CNC} Backup existing configs
${BLD}${CGR}[${CYE}i${CGR}]${CNC} Install dotfiles
${BLD}${CGR}[${CYE}i${CGR}]${CNC} Enable MPD service
${BLD}${CGR}[${CYE}i${CGR}]${CNC} Change default shell to zsh

"

    while :; do
        printf " %b" "${BLD}${CGR}Do you wish to continue?${CNC} [y/N]: "
        read -r yn

        case "$yn" in
            [Yy]) break ;;
            [Nn]|"")
                printf "\n%b\n" "${BLD}${CYE}Operation cancelled${CNC}"
                exit 0 ;;
            *)
                printf "\n%b\n" "${BLD}${CRE}Please type y or n${CNC}" ;;
        esac
    done
}

install_dependencies() {
    clear
    logo "Installing Debian packages..."
    sleep 2

    sudo apt update

dependencies="\
alacritty
build-essential
bat
brightnessctl
bspwm
clipcat
dunst
eza
feh
fzf
thunar
tumbler
gvfs-backends
firefox-esr
geany
git
imagemagick
jq
jgmenu
kitty
libwebp-dev
maim
mpc
mpd
mpv
neovim
xcolor
ncmpcpp
npm
pamixer
papirus-icon-theme
picom
playerctl
polybar
lxsession
python3-gi
redshift
rofi
rustup
sxhkd
xclip
xdg-user-dirs
xdo
xdotool
xsettingsd
x11-utils
yazi
zsh
zsh-autosuggestions
zsh-syntax-highlighting
fonts-inconsolata
fonts-jetbrains-mono
fonts-terminus
fonts-ubuntu
fastfetch
btop
os-prober
helix

# AUR / Chaotic / Custom
eww-git
xwinwrap-0.9-bin
i3lock-color
simple-mtpfs
fzf-tab-git
brave-bin

# gh0stzk repo
st-gh0stzk
gh0stzk-gtk-themes
gh0stzk-cursor-qogirr
gh0stzk-icons-beautyline
gh0stzk-icons-candy
gh0stzk-icons-catppuccin-mocha
gh0stzk-icons-dracula
gh0stzk-icons-glassy
gh0stzk-icons-gruvbox-plus-dark
gh0stzk-icons-hack
gh0stzk-icons-luv
gh0stzk-icons-sweet-rainbow
gh0stzk-icons-tokyo-night
gh0stzk-icons-vimix-white
gh0stzk-icons-zafiro
gh0stzk-icons-zafiro-purple"

    failed_deps=""
    retry_failed=""

    for pkg in $dependencies; do
        sleep 0.3

        if ! sudo apt install -y "$pkg"; then
            failed_deps="$failed_deps $pkg"
        fi
    done

    if [ -n "$failed_deps" ]; then
        printf "\n%b\n" "${BLD}${CRE}Retrying failed packages...${CNC}"

        for pkg in $failed_deps; do
            sleep 0.3

            if ! sudo apt install -y "$pkg"; then
                retry_failed="$retry_failed $pkg"
            fi
        done
    fi

    if [ -n "$retry_failed" ]; then
        printf "\nPackages to compile manually:\n%s\n" "$retry_failed" > "$HOME/missing_apps.txt"

        printf "\n%b\n" "${BLD}${CYE}Some packages could not be installed.${CNC}"
        printf "%b\n" "${BLD}${CBL}missing_apps.txt${CNC} created in HOME."
    else
        printf "\n%b\n" "${BLD}${CGR}All packages installed successfully.${CNC}"
    fi

    sleep 3
}

clone_dotfiles() {
    clear
    logo "Downloading dotfiles"

    repo_url="https://github.com/LeandroBarbosa17/lerin-dotfiles"
    repo_dir="$HOME/.local/share/gh0stzk"

    timestamp=$(date +"%Y%m%d-%H%M%S")

    sleep 2

    if [ -d "$repo_dir" ]; then
        backup_dir="${repo_dir}_$timestamp"

        printf "%b\n" "${BLD}${CYE}Existing repository found.${CNC}"
        mv -v "$repo_dir" "$backup_dir"
    fi

    git clone --depth=1 "$repo_url" "$repo_dir"

    sleep 2
}

backup_existing_config() {
    clear
    logo "Backup files"

    sleep 2

    while :; do
        printf "%b" "${BLD}${CYE}Use included Neovim config?${CNC} [y/N]: "
        read -r try_nvim

        case "$try_nvim" in
            [Yy]) try_nvim="y"; break ;;
            [Nn]|"") try_nvim="n"; break ;;
            *) printf "Please type y or n\n" ;;
        esac
    done

    backup_folder="$HOME/.RiceBackup/$(date +%Y%m%d-%H%M%S)"

    mkdir -p "$backup_folder"

    cfg_dir="\
bspwm
alacritty
clipcat
picom
rofi
eww
sxhkd
dunst
kitty
polybar
geany
gtk-3.0
ncmpcpp
yazi
zsh
mpd"

    for cfg in $cfg_dir; do
        [ -d "$HOME/.config/$cfg" ] && \
        mv "$HOME/.config/$cfg" "$backup_folder"
    done

    for f in ".icons" ".zshrc" ".gtkrc-2.0"; do
        [ -e "$HOME/$f" ] && \
        mv "$HOME/$f" "$backup_folder"
    done

    if [ "$try_nvim" = "y" ]; then
        [ -d "$HOME/.config/nvim" ] && \
        mv "$HOME/.config/nvim" "$backup_folder"
    fi

    printf "\n%b\n" "${BLD}${CGR}Backup completed.${CNC}"

    sleep 2
}

install_dotfiles() {
    clear
    logo "Installing dotfiles"

    sleep 2

    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.local/share"

    dots_config_dir="\
alacritty
bspwm
clipcat
geany
gtk-3.0
kitty
mpd
ncmpcpp
systemd
yazi
zsh"

    for dots_cfg in $dots_config_dir; do
        cp -R "$HOME/.local/share/gh0stzk/config/$dots_cfg" \
        "$HOME/.config/"
    done

    [ "$try_nvim" = "y" ] && \
    cp -R "$HOME/.local/share/gh0stzk/config/nvim" \
    "$HOME/.config/"

    dots_misc_dir="applications asciiart fonts"

    for dots_misc in $dots_misc_dir; do
        cp -R "$HOME/.local/share/gh0stzk/misc/$dots_misc" \
        "$HOME/.local/share/"
    done

    cp -R "$HOME/.local/share/gh0stzk/misc/bin" \
    "$HOME/.local/"

    dots_home_dir=".icons .zshrc .gtkrc-2.0"

    for dots_home in $dots_home_dir; do
        cp -R "$HOME/.local/share/gh0stzk/home/$dots_home" \
        "$HOME/"
    done

    fc-cache -r

    if [ ! -e "$HOME/.config/user-dirs.dirs" ]; then
        xdg-user-dirs-update
    fi

    printf "\n%b\n" "${BLD}${CGR}Dotfiles installed successfully.${CNC}"

    sleep 2
}

configure_services() {
    clear
    logo "Configuring services"

    sleep 2

    if systemctl is-enabled --quiet mpd.service; then
        sudo systemctl disable --now mpd.service
    fi

    systemctl --user enable --now mpd.service

    sleep 2
}

change_default_shell() {
    clear
    logo "Changing shell to zsh"

    zsh_path=$(command -v zsh)

    sleep 2

    if [ -z "$zsh_path" ]; then
        printf "%b\n" "${BLD}${CRE}zsh is not installed.${CNC}"
        return
    fi

    if [ "$SHELL" != "$zsh_path" ]; then
        chsh -s "$zsh_path"
    fi

    sleep 2
}

final_prompt() {
    clear
    logo "Installation Complete"

    printf "%b\n" "${BLD}${CGR}Installation completed.${CNC}"

    if [ -f "$HOME/missing_apps.txt" ]; then
        printf "%b\n" "${BLD}${CYE}Some packages must be compiled manually.${CNC}"
    fi

    printf "%b\n\n" "${BLD}${CRE}You should reboot your system.${CNC}"

    while :; do
        printf "%b" "${BLD}${CYE}Reboot now?${CNC} [y/N]: "

        read -r yn

        case "$yn" in
            [Yy])
                sudo reboot
                break ;;
            [Nn]|"")
                break ;;
            *)
                printf "Please type y or n\n" ;;
        esac
    done
}

# Main
initial_checks
welcome
install_dependencies
clone_dotfiles
backup_existing_config
install_dotfiles
configure_services
change_default_shell
final_prompt
