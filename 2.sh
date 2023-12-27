#!/bin/bash

# Check if running as root. If root, script will not run
if [[ $EUID -eq 0 ]]; then
    echo "This script should not be executed as root! STUPID......."
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
        echo "$ORANGE Installing $package_name..."
        yay -S --needed --noconfirm "$package_name" || log_error "Failed to install $package_name"
    fi
}

# Install necessary packages
install_package rustup
rustup default stable
install_package xdg-user-dirs
xdg-user-dirs-update

# List of packages to install
packages_to_install=(
    gdb
    ninja
    gcc
    cmake
    meson
    libxcb
    # Add more packages as needed
)

# Loop through and install each package
for package in "${packages_to_install[@]}"; do
    install_package "$package"
done

# Additional installation steps...

# Reboot into the installed system
echo "$ORANGE Rebooting in 10 seconds. Press Ctrl+C to interrupt."
sleep 10
reboot
