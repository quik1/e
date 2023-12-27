#!/bin/bash

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
WARN="$(tput setaf 166)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
ORANGE=$(tput setaf 166)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# Check if running as root. If root, script will not run
if [[ $EUID -eq 0 ]]; then
    echo "This script should not be executed as root! Exiting..." >> "$HOME/Documents/InstallError.txt"
    exit 1
fi

yay -S --noconfirm rustup
# set default
rustup default stable
# if another package needs a different version of rust, temporarily switch and then switch back to default
yay -S --noconfirm xdg-user-dirs
xdg-user-dirs-update

# Set the name of the log file to include the current date and time
LOG="install-$(date -%H%M%S +%d )_dotfiles.log"

# update home folders
xdg-user-dirs-update 2>&1 | tee -a "$LOG" || true

yay -S --noconfirm gdb ninja gcc cmake meson libxcb xcb-proto xcb-util xcb-util-keysyms libxfixes libx11 libxcomposite xorg-xinput libxrender pixman wayland-protocols cairo pango seatd libxkbcommon xcb-util-wm xorg-xwayland libinput libliftoff libdisplay-info cpio tomlplusplus
# Add the rest of your package list here...

# Display a message starting pt2, please wait while we get things ready and install
echo "Starting pt2. Please wait while we get things ready and install..."

# Add more commands or scripts after this line

# Add a loop for better rofi appearance
while true; do
    echo "$ORANGE Set monitor resolution for better Rofi appearance:"
    echo "$YELLOW 1. Equal is 1080p"

    resolution="1080p"
    break
done

# Add your commands based on the resolution choice
if [ "$resolution" == "1080p" ]; then
    cp -r config/rofi/resolution/1080p/* config/rofi/
fi

# Add more commands or scripts after this line

# Add the missing loop for copying config files
for DIR in btop wofi swww alacritty eww ags mako lsd nvim ranger neofetch spotify spicetify zathura bin bat deadd hyprshotgun xdg-desktop-portal-wlr cava dunst hypr kitty Kvantum qt5ct qt6ct rofi swappy swaylock wal waybar wlogout; do
    DIRPATH=~/.config/"$DIR"
    if [ -d "$DIRPATH" ]; then
        echo -e "${NOTE} - Config for $DIR found, attempting to back up."
        # Assuming you have a get_backup_dirname function defined
        BACKUP_DIR=$(get_backup_dirname)
        mv "$DIRPATH" "$DIRPATH-backup-$BACKUP_DIR" 2>&1 | tee -a "$LOG"
        echo -e "${NOTE} - Backed up $DIR to $DIRPATH-backup-$BACKUP_DIR."
    fi
done

# Add more commands or scripts after this line

# Copying config files
cp -r config/* ~/.config/ && { echo "${OK} Copy completed!"; } || { echo "${ERROR} Failed to copy config files." >> "$LOG"; }

# Wallpapers
mkdir -p ~/Wallpapers

# Set some files as executable
# chmod +x ~/.config/hypr/scripts/* 2>&1 | tee -a "$LOG"

# Set executable for initial-boot.sh
# chmod +x ~/.config/hypr/initial-boot.sh 2>&1 | tee -a "$LOG"

# Add more commands or scripts after this line

# Detect machine type and set Waybar configurations accordingly, logging the output
# if hostnamectl | grep -q 'Chassis: desktop'; then
# Configurations for a desktop
# ln -sf "$HOME/.config/waybar/configs/[TOP] Default" "$HOME/.config/waybar/config" 2>&1 | tee -a "$LOG"
# rm -r "$HOME/.config/waybar/configs/[TOP] Default Laptop" "$HOME/.config/waybar/configs/[BOT] Default Laptop" 2>&1 | tee -a "$LOG"
# else
# Configurations for a laptop or any system other than desktop
# ln -sf "$HOME/.config/waybar/configs/[TOP] Default Laptop" "$HOME/.config/waybar/config" 2>&1 | tee -a "$LOG"
# rm -r "$HOME/.config/waybar/configs/[TOP] Default" "$HOME/.config/waybar/configs/[BOT] Default" 2>&1 | tee -a "$LOG"
# fi

# Add more commands or scripts after this line

# initialize pywal to avoid config error on hyprland
wal -i $wallpaper -s -t 2>&1 | tee -a "$LOG"

# initial for Pywal Dark and Light for Rofi Themes
ln -sf "$HOME/.cache/wal/colors-rofi-dark.rasi" "$HOME/.config/rofi/pywal-color/pywal-theme.rasi"

# initial for Pywal Dark and Light for Wofi Themes
ln -sf "$HOME/.cache/wal/colors-wofi-dark." "$HOME/.config/wofi/pywal-color/pywal"

printf "${ORANGE} YOU NEED to reboot....... sytsem rebooting count down from 10 and reboot user can reboot before timer runs out\n"
