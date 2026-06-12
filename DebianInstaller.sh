#!/bin/sh
#   ██████╗ ██╗ ██████╗███████╗    ██╗███╗    ██╗███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗
#   ██╔══██╗██║██╔════╝██╔════╝    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗
#   ██████╔╝██║██║     █████╗      ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝
#   ██╔══██╗██║██║     ██╔══╝      ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗
#   ██║  ██║██║╚██████╗███████╗    ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║
#   ╚═╝  ╚═╝╚═╝ ╚═════╝╚══════╝    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
#
#	Author	-	gh0stzk (Adapted for Debian by Gemini)
#	Repo	-	https://github.com/gh0stzk/dotfiles
#
#	RiceInstaller - Script to install gh0stzk dotfiles on DEBIAN TESTING/SID

# Colors
CRE=$(tput setaf 1)    # Red
CYE=$(tput setaf 3)    # Yellow
CGR=$(tput setaf 2)    # Green
CBL=$(tput setaf 4)    # Blue
BLD=$(tput bold)       # Bold
CNC=$(tput sgr0)       # Reset colors

# Logo
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
  %%(**##     ***** ##**
     //##   @@** @@   ##//
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
    # Verificar usuario root
    if [ "$(id -u)" = 0 ]; then
        printf "This script MUST NOT be run as root user."
        exit 1
    fi

    # Verificar directorio HOME
    if [ "$PWD" != "$HOME" ]; then
        printf "The script must be executed from HOME directory."
        exit 1
    fi
}

welcome() {
    clear
    logo "Welcome $USER to Debian"

    printf "%b" "${BLD}${CGR}This script will adapt and install gh0stzk's dotfiles on Debian:${CNC}

  ${BLD}${CGR}[${CYE}i${CGR}]${CNC} Check necessary Debian dependencies and install them via APT
  ${BLD}${CGR}[${CYE}i${CGR}]${CNC} Automatically build custom packages (eww, clipcat, i3lock-color, xwinwrap)
  ${BLD}${CGR}[${CYE}i${CGR}]${CNC} Download dotfiles in ${HOME}/.local/share/gh0stzk
  ${BLD}${CGR}[${CYE}i${CGR}]${CNC} Backup of possible existing configurations
  ${BLD}${CGR}[${CYE}i${CGR}]${CNC} Install configurations and handle Debian paths
  ${BLD}${CGR}[${CYE}i${CGR}]${CNC} Enabling MPD service (Music player daemon) at user level
  ${BLD}${CGR}[${CYE}i${CGR}]${CNC} Change your shell to Zsh

${BLD}${CGR}[${CRE}!${CGR}]${CNC} ${BLD}${CRE}This script will compile some tools in your home directory.${CNC}
${BLD}${CGR}[${CRE}!${CGR}]${CNC} ${BLD}${CRE}Make sure you have an active internet connection.${CNC}

"

    while :; do
        printf " %b" "${BLD}${CGR}Do you wish to continue?${CNC} [y/N]: "
        read -r yn
        case "$yn" in
            [Yy])
                break ;;
            [Nn]|"")
                printf "\n%b\n" "${BLD}${CYE}Operation cancelled${CNC}"
                exit 0 ;;
            *)
                printf "\n%b\n" "${BLD}${CRE}Error:${CNC} Just write '${BLD}${CYE}y${CNC}' or '${BLD}${CYE}n${CNC}'" ;;
        esac
    done
}

install_debian_dependencies() {
    clear
    logo "Installing APT Packages"
    sleep 2

    printf "%b\n" "${BLD}${CYE}Updating package lists...${CNC}"
    sudo apt update

    # Lista adaptada para Debian Testing/Sid (Sem pacman-contrib, nomes corrigidos)
    dependencies="alacritty build-essential bat brightnessctl bspwm dunst eza feh fzf thunar tumbler gvfs-mtp firefox-esr geany git imagemagick jq jgmenu kitty libwebp7 maim mpc mpd mpv neovim xcolor ncmpcpp npm pamixer papirus-icon-theme picom playerctl polybar lxsession python3-gi redshift rofi cargo sxhkd xclip xdg-user-dirs xdo xdotool xsettingsd x11-utils x11-xserver-utils yazi zsh zsh-autosuggestions zsh-syntax-highlighting fonts-inconsolata fonts-jetbrains-mono webp-pixbuf-loader"

    failed_deps=""

    for pkg in $dependencies; do
        sleep 0.20
        printf "%b\n" "${BLD}${CBL}Installing: ${CYE}$pkg${CNC}"
        if ! sudo apt install -y "$pkg"; then
            failed_deps="$failed_deps $pkg"
        fi
    done

    if [ -n "$failed_deps" ]; then
        printf "\n%b\n" "${BLD}${CRE}Some packages failed to install:${CYE}${failed_deps}${CNC}"
        printf "%b\n" "${BLD}${CYE}This is common if a package name slightly shifts in Testing. Continuing...${CNC}"
        sleep 3
    fi
}

compile_debian_packages() {
    clear
    logo "Compiling & Extracting Custom Packages"
    printf "%b\n" "${BLD}${CYE}Preparing local build environment in ~/.local/bin ...${CNC}"
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/debian_builds"
    sleep 2

    # 1. COMPILAR XWINWRAP
    printf "%b\n" "${BLD}${CBL}[1/6] Compiling xwinwrap...${CNC}"
    sudo apt install -y libx11-dev libxext-dev
    if git clone --depth=1 https://github.com/ujjwal96/xwinwrap "$HOME/debian_builds/xwinwrap"; then
        cd "$HOME/debian_builds/xwinwrap" && make
        mv xwinwrap "$HOME/.local/bin/"
        cd "$HOME" # Retorna para a segurança da Home
    fi

    # 2. COMPILAR I3LOCK-COLOR
    printf "%b\n" "${BLD}${CBL}[2/6] Compiling i3lock-color...${CNC}"
    sudo apt install -y autoconf automake cairo-5c libev-dev libjpeg-dev libpam0g-dev libxcb-composite0-dev libxcb-image0-dev libxcb-util-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev libxcb-randr0-dev libxcb-xtest0-dev libxcb-atom0-dev libxcb-xrm-dev
    if git clone --depth=1 https://github.com/Raymo111/i3lock-color.git "$HOME/debian_builds/i3lock-color"; then
        cd "$HOME/debian_builds/i3lock-color"
        autoreconf -i && ./configure && make
        sudo make install
        cd "$HOME" # CORREÇÃO: Garante a saída do diretório antes do próximo passo
    fi

    # 3. BAIXAR CLIPCAT (Binário pré-compilado oficial)
    printf "%b\n" "${BLD}${CBL}[3/6] Fetching Clipcat Binary...${CNC}"
    cd "$HOME/debian_builds"
    wget https://github.com/xrelkd/clipcat/releases/download/v0.16.1/clipcat-v0.16.1-x86_64-unknown-linux-musl.tar.gz
    tar -xf clipcat-v0.16.1-x86_64-unknown-linux-musl.tar.gz
    cd clipcat-v0.16.1-x86_64-unknown-linux-musl && cp clipcatd clipcatctl clipcat-menu "$HOME/.local/bin/"
    cd "$HOME"

    # 4. COMPILAR EWW
    printf "%b\n" "${BLD}${CBL}[4/6] Compiling Eww (Widgets)...${CNC}"
    sudo apt install -y libgtk-3-dev libpango1.0-dev libcairo2-dev libgdk-pixbuf2.0-dev
    if git clone --depth=1 https://github.com/elkowar/eww "$HOME/debian_builds/eww"; then
        cd "$HOME/debian_builds/eww"
        cargo build --release --no-default-features --features x11
        mv target/release/eww "$HOME/.local/bin/"
        cd "$HOME"
    fi

    # 5. EXTRAIR PACOTES EXCLUSIVOS (.pkg.tar.zst) NO DEBIAN
    printf "%b\n" "${BLD}${CBL}[5/6] Downloading and extracting gh0stzk themes/icons...${CNC}"
    sudo apt install -y zstd # Garante o descompressor zstd no Debian
    
    # URL do servidor de pacotes brutos do repositório gh0stzk
    REPO_URL="https://gh0stzk.github.io/pkgs/x86_64"
    
    # Lista de pacotes de mídia necessários para a Rice rodar sem bugs visuais
    pkgs_to_extract="gh0stzk-gtk-themes-2.5-1-any.pkg.tar.zst gh0stzk-icons-beautyline-1.0-1-any.pkg.tar.zst gh0stzk-icons-candy-1.0-1-any.pkg.tar.zst gh0stzk-icons-catppuccin-mocha-1.0-1-any.pkg.tar.zst gh0stzk-icons-dracula-1.0-1-any.pkg.tar.zst gh0stzk-icons-tokyo-night-1.0-1-any.pkg.tar.zst gh0stzk-cursor-qogirr-1.0-1-any.pkg.tar.zst"

    mkdir -p "$HOME/debian_builds/extracted_pkgs"
    cd "$HOME/debian_builds/extracted_pkgs"

    for pkg in $pkgs_to_extract; do
        printf "%b\n" "${BLD}${CYE}Downloading and extracting: $pkg${CNC}"
        wget "$REPO_URL/$pkg"
        # Descompacta o .zst e extrai o tar direto na raiz do sistema de arquivos local
        tar --zstd -xf "$pkg" --strip-components=1 2>/dev/null
    done

    # Mover os temas e ícones extraídos para as pastas locais corretas na sua Home
    printf "%b\n" "${BLD}${CYE}Moving assets to ~/.themes and ~/.icons...${CNC}"
    mkdir -p "$HOME/.themes" "$HOME/.icons"
    
    # Pacotes do Arch estruturam os temas em usr/share/themes e usr/share/icons
    [ -d "usr/share/themes" ] && cp -R usr/share/themes/* "$HOME/.themes/"
    [ -d "usr/share/icons" ] && cp -R usr/share/icons/* "$HOME/.icons/"
    cd "$HOME"

    # 6. LIMPEZA TOTAL
    printf "%b\n" "${BLD}${CBL}[6/6] Cleaning up build files...${CNC}"
    rm -rf "$HOME/debian_builds"
    printf "\n%b\n" "${BLD}${CGR}Custom packages and assets processed successfully!${CNC}"
    sleep 2
}

clone_dotfiles() {
    clear
    logo "Downloading dotfiles"
    repo_url="https://github.com/gh0stzk/dotfiles"
    repo_dir="$HOME/.local/share/gh0stzk"
    timestamp=$(date +"%Y%m%d-%H%M%S")
    sleep 2

    if [ -d "$repo_dir" ]; then
        backup_dir="${repo_dir}_$timestamp"
        printf "%b\n" "${BLD}${CYE}Existing repository found - renaming to: ${CBL}${backup_dir}${CNC}"
        mv "$repo_dir" "$backup_dir"
    fi

    printf "%b\n" "${BLD}${CYE}Cloning dotfiles from: ${CBL}${repo_url}${CNC}"
    git clone --depth=1 "$repo_url" "$repo_dir"
    sleep 3
}

backup_existing_config() {
    clear
    logo "Backup files"
    sleep 2

    printf "%b" "My dotfiles come with a lightweight, simple, and functional Neovim configuration.\nBut if you already have a custom configuration, type 'n'\n"

    while :; do
        printf "%b" "${BLD}${CYE}Do you want to use my Neovim setup? ${CNC}[y/N]: "
        read -r try_nvim
        case "$try_nvim" in
            [Yy]) try_nvim="y"; break ;;
            [Nn]) try_nvim="n"; break ;;
            *) printf " %b%bError:%b write 'y' or 'n'\n" "${BLD}" "${CRE}" "${CNC}" ;;
        esac
    done

    backup_folder="$HOME/.RiceBackup/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_folder"
    
    cfg_dir="bspwm alacritty clipcat picom rofi eww sxhkd dunst kitty polybar geany gtk-3.0 ncmpcpp yazi zsh mpd"
    for cfg in $cfg_dir; do
        [ -d "$HOME/.config/$cfg" ] && mv "$HOME/.config/$cfg" "$backup_folder"
    done

    for f in ".icons" ".zshrc" ".gtkrc-2.0"; do
        [ -e "$HOME/$f" ] && mv "$HOME/$f" "$backup_folder"
    done

    if [ "$try_nvim" = "y" ]; then
        [ -d "$HOME/.config/nvim" ] && mv "$HOME/.config/nvim" "$backup_folder"
    fi

    printf "\n%b\n\n" "${BLD}${CGR}All files moved to:${CNC} ${BLD}${CYE}$backup_folder${CNC}"
    sleep 3
}

install_dotfiles() {
    clear
    logo "Installing dotfiles.."
    sleep 2

    for dir in "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/share" "$HOME/.local/share/fonts"; do
        [ ! -d "$dir" ] && mkdir -p "$dir"
    done

    # Copiar configs principais
    dots_config_dir="alacritty bspwm clipcat geany gtk-3.0 kitty mpd ncmpcpp systemd yazi zsh"
    for dots_cfg in $dots_config_dir; do
        cp -R "$HOME/.local/share/gh0stzk/config/$dots_cfg" "$HOME/.config/"
    done

    [ "$try_nvim" = "y" ] && cp -R "$HOME/.local/share/gh0stzk/config/nvim" "$HOME/.config/"

    dots_misc_dir="applications asciiart"
    for dots_misc in $dots_misc_dir; do
        cp -R "$HOME/.local/share/gh0stzk/misc/$dots_misc" "$HOME/.local/share/"
    done

    # Copiar scripts em bin para .local/bin sem sobrescrever o eww/xwinwrap compilados
    cp -R "$HOME/.local/share/gh0stzk/misc/bin/"* "$HOME/.local/bin/"

    dots_home_dir=".icons .zshrc .gtkrc-2.0"
    for dots_home in $dots_home_dir; do
        cp -R "$HOME/.local/share/gh0stzk/home/$dots_home" "$HOME/"
    done

    # ADAPTAÇÃO NERD FONTS PARA DEBIAN (Baixa os ícones necessários para a polybar)
    printf "%b\n" "${BLD}${CYE}Installing essential Nerd Fonts symbols for Debian...${CNC}"
    wget -P "$HOME/.local/share/fonts/" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    unzip -o "$HOME/.local/share/fonts/JetBrainsMono.zip" -d "$HOME/.local/share/fonts/"
    rm "$HOME/.local/share/fonts/JetBrainsMono.zip"

    # Atualizar cache de fontes
    fc-cache -fv

    # Corrigir scripts que procuram pacman-contrib/checkupdates (Faz o módulo ignorar erro)
    printf "%b\n" "${BLD}${CYE}Patching scripts for Debian APT compatibility...${CNC}"
    find "$HOME/.config/polybar" -type f -exec sed -i 's/checkupdates/apt list --upgradable 2>\/dev\/null | grep -c upgradable/g' {} +

    if [ ! -e "$HOME/.config/user-dirs.dirs" ]; then
        xdg-user-dirs-update
    fi

    printf "\n%s%sDotfiles installed successfully!%s\n" "$BLD" "$CGR" "$CNC"
    sleep 3
}

configure_services() {
    clear
    logo "Configuring Services"
    picom_config="$HOME/.config/bspwm/config/picom.conf"
    sleep 2

    # User-level MPD Service
    printf "%b\n" "${BLD}${CYE}Enabling user MPD service...${CNC}"
    systemctl --user daemon-reload
    systemctl --user enable --now mpd.service

    # Detecção de VM para o Picom
    if systemd-detect-virt --quiet >/dev/null 2>&1; then
        printf "%b\n" "${BLD}${CYE}Virtual machine detected. Adjusting Picom...${CNC}"
        if [ -f "$picom_config" ]; then
            sed -i 's/backend = "glx"/backend = "xrender"/' "$picom_config"
            sed -i 's/vsync = true/vsync = false/' "$picom_config"
        fi
    fi
    sleep 3
}

change_default_shell() {
    clear
    logo "Changing default shell to zsh"
    zsh_path=$(command -v zsh)
    sleep 2

    if [ -n "$zsh_path" ] && [ "$SHELL" != "$zsh_path" ]; then
        printf "%b\n" "${BLD}${CYE}Changing your shell to Zsh...${CNC}"
        chsh -s "$zsh_path"
    else
        printf "%b\n\n" "${BLD}${CGR}Zsh is already your default shell!${CNC}"
    fi
    sleep 3
}

final_prompt() {
    clear
    logo "Installation Complete"
    printf "%b\n" "${BLD}${CGR}Installation completed successfully on Debian!${CNC}"
    printf "%b\n\n" "${BLD}${CRE}You ${CBL}MUST ${CRE}restart your system to apply changes${CNC}"

    while :; do
        printf "%b" "${BLD}${CYE}Reboot now?${CNC} [y/N]: "
        read -r yn
        case "$yn" in
            [Yy]) sudo reboot ;;
            *) printf "\n%b\n\n" "${BLD}${CYE}Please reboot manually when ready. Enjoy!${CNC}" ; break ;;
        esac
    done
}

# --- Main run --- #
initial_checks
welcome
install_debian_dependencies
compile_debian_packages
clone_dotfiles
backup_existing_config
install_dotfiles
configure_services
change_default_shell
final_prompt
