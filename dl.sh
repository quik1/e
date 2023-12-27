#!/bin/bash

# Check if running as root. If root, script will not run
if [[ $EUID -eq 0 ]]; then
    echo "This script should not be executed as root! Exiting..."
    exit 1
fi

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
ORANGE=$(tput setaf 166)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# Set the name of the log file to include the current date and time
LOG="install-$(date +%H%M%S_%d).log"

# Function to create a unique backup directory name with month, day, hours, and minutes
get_backup_dirname() {
  local timestamp
  timestamp=$(date +"%m%d_%H%M")
  echo "back-up_${timestamp}"
}

# Copying dotfiles and wallpapers
copy_dotfiles() {
  printf "${NOTE} - copying dotfiles\n"

  # Back up existing configurations
  backup_dotfiles

  # Copy new configurations
  mkdir -p ~/.config
  cp -r config/* ~/.config/ && { echo "${OK} Copy completed!"; } || { echo "${ERROR} Failed to copy config files."; exit 1; } 2>&1 | tee -a "$LOG"

  # Wallpapers
  mkdir -p ~/Wallpapers
  cp -r wallpapers ~/Pictures/ && { echo "${OK} Copy completed!"; } || { echo "${ERROR} Failed to copy wallpapers."; exit 1; } 2>&1 | tee -a "$LOG"
}

# Backup existing dotfiles
backup_dotfiles() {
  for DIR in btop wofi swww alacritty eww ags mako lsd nvim ranger neofetch spotify spicetify zathura bin bat deadd hyprshotgun xdg-desktop-portal-wlr cava dunst hypr kitty Kvantum qt5ct qt6ct rofi swappy swaylock wal waybar wlogout; do
    DIRPATH=~/.config/"$DIR"
    if [ -d "$DIRPATH" ]; then
      echo -e "${NOTE} - Config for $DIR found, attempting to back up."
      BACKUP_DIR=$(get_backup_dirname)
      mv "$DIRPATH" "$DIRPATH-backup-$BACKUP_DIR" 2>&1 | tee -a "$LOG"
      echo -e "${NOTE} - Backed up $DIR to $DIRPATH-backup-$BACKUP_DIR."
    fi
  done

  for DIRw in wallpapers; do
    DIRPATH=~/Pictures/"$DIRw"
    if [ -d "$DIRPATH" ]; then
      echo -e "${NOTE} - Wallpapers in $DIRw found, attempting to back up."
      BACKUP_DIR=$(get_backup_dirname)
      mv "$DIRPATH" "$DIRPATH-backup-$BACKUP_DIR" 2>&1 | tee -a "$LOG"
      echo -e "${NOTE} - Backed up $DIRw to $DIRPATH-backup-$BACKUP_DIR."
    fi
  done
}

# Set some files as executable
set_executables() {
  printf "\n%.0s" {1..2}
  # Set executable for initial-boot.sh
  # chmod +x ~/.config/hypr/initial-boot.sh 2>&1 | tee -a "$LOG"
}

# Main installation process
main_install() {
  yay -S --noconfirm rustup
  # set default
  rustup default stable
  # if another package needs a different version of rust, temporarily switch and then switch back to default
  yay -S --noconfirm xdg-user-dirs
  xdg-user-dirs-update

  # Uncommenting WLR_RENDERER_ALLOW_SOFTWARE,1 if running in a VM is detected
  if hostnamectl | grep -q 'Chassis: vm'; then
    echo "This script is running in a virtual machine."
    sed -i '/env = WLR_NO_HARDWARE_CURSORS,1/s/^#//' config/hypr/configs/ENVariables.conf
    sed -i '/env = WLR_RENDERER_ALLOW_SOFTWARE,1/s/^#//' config/hypr/configs/ENVariables.conf
    sed -i '/monitor = Virtual-1, 1920x1080@60,auto,1/s/^#//' config/hypr/configs/Monitors.conf
  fi

  # Install required packages
  pacman -S --needed --noconfirm gdb ninja gcc cmake meson libxcb xcb-proto xcb-util xcb-util-keysyms libxfixes libx11 libxcomposite xorg-xinput libxrender pixman wayland-protocols cairo pango seatd libxkbcommon xcb-util-wm xorg-xwayland libinput libliftoff libdisplay-info cpio tomlplusplus \
    aalib gcc wofi plymouth sddm kitty alacritty ranger qt5-wayland qt6-wayland dunst mako pipewire wireplumber polkit-kde-agent xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-desktop-portal-wlr xdg-desktop-portal hyprland wayber nano geany geany-plugins marker notepadqq mpv vlc mpd python \
    nodejs jq go python-pipx python-pip tk npm cliphist python-rich python-pyperclip python=openai python-pyaml python-click wget unzip zip gum rsync ttf-font-awesome neofetch python-opencv python-seaborn python-cfii python-pywayland python-pywall python-bokeh blackbox-terminal pkg geany-plugin-jsonprettifier \
    nvm hyprshotgun chatgpt-desktop-bin xdg-desktop-portal pyinstaller aurutils xdg-desktop-portal-termfilechooser-git \
    autoconf swww gswww-git gtklock \
    automake autoconf-archive python-easygui kitty go alacritty python tk js npm glib glib2 gcc-libs gcc libxml expect python-pywall python-pywalfox python-pywal-spotify-git libnotify aalib jp2a ascii gruvbox-dark-icons-gtk fish zsh gtkmm3 cava aconfmgr-git coreutils augeas diffutils starship gum ranger spotify-wayland wofi neofetch \
    firefox deadd-notification-center plymouth sddm rofi-lbonn-wayland-git waybar-hyprland-cava-git gtk-layer-shell google-chrome shell-color-scripts xdg-ninja neovim neovide yad getoptions geticons jq.sh-git kvantum vlc mplayer mpd mpc nwg-look zenity gtk3 gtk2 gtk4 zenity-gtk4-git geany geany-plugins \
    gtk4-layer-shell swaync mako dunst picom cmus qt5-wayland qt6-wayland kanagawa-gtk-theme-git wxwidgets-gtk3-wayland-perf marker visual-studio-code-bin notepadqq pkgbuild-updater jq jo pacman-contrib reflector reflector-simple

  # Display message for starting pt2
  echo "$ORANGE Starting pt2. Please wait while we get things ready and install."

  # Add your commands based on the resolution choice
  while true; do
    echo "$ORANGE Set monitor resolution for better Rofi appearance:"
    echo "$YELLOW 1. Equal is 1080p"
    read -p "Enter your choice: " resolution

    case $resolution in
    1)
      resolution="1080p"
      break
      ;;
    *)
      echo "Invalid choice. Please enter a valid option."
      ;;
    esac
  done

  # Perform main installation steps
  copy_dotfiles
  set_executables

  # Set some files as executable
  chmod +x ~/.config/hypr/scripts/* 2>&1 | tee -a "$LOG"

  # Set executable for initial-boot.sh
  chmod +x ~/.config/hypr/initial-boot.sh 2>&1 | tee -a "$LOG"

  # Detect machine type and set Waybar configurations accordingly, logging the output
  # if hostnamectl | grep -q 'Chassis: desktop'; then
  # Configurations for a desktop
  #    ln -sf "$HOME/.config/waybar/configs/[TOP] Default" "$HOME/.config/waybar/config" 2>&1 | tee -a "$LOG"
  #    rm -r "$HOME/.config/waybar/configs/[TOP] Default Laptop" "$HOME/.config/waybar/configs/[BOT] Default Laptop" 2>&1 | tee -a "$LOG"
  # else
  # Configurations for a laptop or any system other than desktop
  #    ln -sf "$HOME/.config/waybar/configs/[TOP] Default Laptop" "$HOME/.config/waybar/config" 2>&1 | tee -a "$LOG"
  #    rm -r "$HOME/.config/waybar/configs/[TOP] Default" "$HOME/.config/waybar/configs/[BOT] Default" 2>&1 | tee -a "$LOG"
  # fi

  # initialize pywal to avoid config error on hyprland
  wal -i $wallpaper -s -t 2>&1 | tee -a "$LOG"

  # initial for Pywal Dark and Light for Rofi Themes
  ln -sf "$HOME/.cache/wal/colors-rofi-dark.rasi" "$HOME/.config/rofi/pywal-color/pywal-theme.rasi"

  # initial for Pywal Dark and Light for Rofi Themes
  ln -sf "$HOME/.cache/wal/colors-wofi-dark.rasi" "$HOME/.config/wofi/pywal-color/pywal"

  printf "${ORANGE} YOU NEED to reboot....... System will reboot in 10 seconds. Press Ctrl+C to reboot immediately.\n"
  sleep 10
  reboot
}

# Execute main installation process
main_install
