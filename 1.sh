#!/bin/bash

# Check if running as root. If root, script will not run
if [[ $EUID -eq 0 ]]; then
    echo "This script should not be executed as root! Exiting..." >> "$HOME/Documents/InstallError.txt"
    exit 1
fi

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
ORANGE="$(tput setaf 166)"
RESET="$(tput sgr0)"

# Set the name of the log file to include the current date and time
LOG="$HOME/Documents/InstallError_$(date +%Y%m%d%H%M%S).txt"

# Function to log errors
log_error() {
    echo "[ERROR] $1" >> "$LOG"
}

# Function to install packages using yay
install_package() {
    package_name="$1"
    if yay -Qi "$package_name" &> /dev/null; then
        echo "$NOTE $package_name is already installed. Skipping..."
    else
        yay -S --needed --noconfirm "$package_name" || log_error "Failed to install $package_name"
    fi
}

# Install yay if not already installed
if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git
    cd yay || { log_error "Failed to clone yay repository. Exiting..."; exit 1; }
    makepkg -si --noconfirm || { log_error "Failed to install yay. Exiting..."; exit 1; }
    cd .. && rm -rf yay
fi

# Install necessary packages
install_package rustup
rustup default stable
install_package xdg-user-dirs
xdg-user-dirs-update

# Uncommenting WLR_RENDERER_ALLOW_SOFTWARE,1 if running in a VM is detected
if hostnamectl | grep -q 'Chassis: vm'; then
    echo "This script is running in a virtual machine."
    sed -i '/env = WLR_NO_HARDWARE_CURSORS,1/s/^#//' config/hypr/configs/ENVariables.conf
    sed -i '/env = WLR_RENDERER_ALLOW_SOFTWARE,1/s/^#//' config/hypr/configs/ENVariables.conf
    sed -i '/monitor = Virtual-1, 1920x1080@60,auto,1/s/^#//' config/hypr/configs/Monitors.conf
fi

# Install required packages
yay -S --noconfirm gdb ninja gcc cmake meson libxcb xcb-proto xcb-util xcb-util-keysyms libxfixes libx11 libxcomposite xorg-xinput libxrender pixman wayland-protocols cairo pango seatd libxkbcommon xcb-util-wm xorg-xwayland libinput libliftoff libdisplay-info cpio tomlplusplus \
    aalib gcc wofi plymouth sddm kitty alacritty ranger qt5-wayland qt6-wayland dunst mako pipewire wireplumber polkit-kde-agent xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-desktop-portal-wlr xdg-desktop-portal hyprland wayber nano geany geany-plugins marker notepadqq mpv vlc mpd python \
    nodejs jq go python-pipx python-pip tk npm cliphist python-rich python-pyperclip python=openai python-pyaml python-click wget unzip zip gum rsync ttf-font-awesome neofetch python-opencv python-seaborn python-cfii python-pywayland python-pywall python-bokeh blackbox-terminal pkg geany-plugin-jsonprettifier \
    nvm hyprshotgun chatgpt-desktop-bin xdg-desktop-portal pyinstaller aurutils xdg-desktop-portal-termfilechooser-git \
    autoconf swww gswww-git gtklock \
    automake autoconf-archive python-easygui kitty go alacritty python tk js npm glib glib2 gcc-libs gcc libxml expect python-pywall python-pywalfox python-pywal-spotify-git libnotify aalib jp2a ascii gruvbox-dark-icons-gtk fish zsh gtkmm3 cava aconfmgr-git coreutils augeas diffutils starship gum ranger spotify-wayland wofi neofetch \
    firefox deadd-notification-center plymouth sddm rofi-lbonn-wayland-git waybar-hyprland-cava-git gtk-layer-shell google-chrome shell-color-scripts xdg-ninja neovim neovide yad getoptions geticons jq.sh-git kvantum vlc mplayer mpd mpc nwg-look zenity gtk3 gtk2 gtk4 zenity-gtk4-git geany geany-plugins \
    gtk4-layer-shell swaync mako dunst picom cmus qt5-wayland qt6-wayland kanagawa-gtk-theme-git wxwidgets-gtk3-wayland-perf marker visual-studio-code-bin notepadqq pkgbuild-updater jq jo pacman-contrib reflector reflector-simple

# Create partition layout (Assuming /dev/sda is a 500GB drive)
echo -e "n\n\n\n+2G\nn\n\n\n\nw" | fdisk /dev/sda
echo -e "n\n\n\n\n\nw" | fdisk /dev/sda

# Format partitions
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2

# Mount partitions
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

# Continue with the installation...
# Add your installation steps here

# Reboot into the installed system
echo "$ORANGE Rebooting in 10 seconds. Press Ctrl+C to interrupt."
sleep 10
reboot
