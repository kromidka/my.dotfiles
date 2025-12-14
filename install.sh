#!/bin/bash

# --- Configuration ---
DOTFILES_DIR="$HOME/git/my.dotfiles"
SOURCE_CONFIG="$DOTFILES_DIR/.config"
TARGET_CONFIG="$HOME/.config"
PACMAN_LIST="$DOTFILES_DIR/pacman.txt"
YAY_LIST="$DOTFILES_DIR/yay-pac.txt"

# --- 0. System Update ---
echo "--- Starting System Update ---"
# -Syu: Sync, Refresh the package list, and Update the system
sudo pacman -Syu --noconfirm
if [ $? -eq 0 ]; then
    echo "[OK] System update complete."
else
    echo "[ERROR] System update failed. Check the error above and resolve it before proceeding."
    exit 1
fi
echo ""

# --- 1. Install Yay (AUR Helper) ---
echo "--- Checking for Yay ---"

if ! command -v yay &> /dev/null; then
    echo "[INFO] Yay not found. Installing now..."
    
    # 1. Install prerequisites (needed for building)
    sudo pacman -S --needed --noconfirm base-devel git
    
    # 2. Clone yay repo to a temporary directory
    # Note: Using a safe temporary directory in $HOME instead of /opt
    TEMP_DIR="$HOME/yay_temp_install"
    mkdir -p "$TEMP_DIR"
    git clone https://aur.archlinux.org/yay.git "$TEMP_DIR/yay"
    cd "$TEMP_DIR/yay"
    
    # 3. Build and install
    makepkg -si --noconfirm
    
    # 4. Cleanup
    cd "$HOME"
    rm -rf "$TEMP_DIR"
    echo "[OK] Yay installed successfully."
else
    echo "[SKIP] Yay is already installed."
fi

echo ""

# --- 2. Symlink Folders with Backup ---
echo "--- Setting up Symlinks ---"

mkdir -p "$TARGET_CONFIG"

if [ -d "$SOURCE_CONFIG" ]; then
    for folder in "$SOURCE_CONFIG"/*; do
        folder_name=$(basename "$folder")
        target_path="$TARGET_CONFIG/$folder_name"
        backup_path="$TARGET_CONFIG/$folder_name.old"

        # Check if the target exists (and is not already the correct symlink)
        if [ -e "$target_path" ]; then
            current_link=$(readlink "$target_path")
            if [ "$current_link" == "$folder" ]; then
                echo "[SKIP] $folder_name is already correctly linked."
                continue
            fi

            if [ -e "$backup_path" ]; then
                echo "[WARN] Removing old backup: $backup_path"
                rm -rf "$backup_path"
            fi
            
            echo "[BACKUP] Renaming existing $folder_name to $folder_name.old"
            mv "$target_path" "$backup_path"
        fi

        echo "[LINK] Linking $folder_name..."
        ln -s "$folder" "$target_path"
    done
else
    echo "[ERROR] Source config directory $SOURCE_CONFIG not found! Skipping symlinks."
fi

echo ""

# --- 3. Install Pacman Packages ---
echo "--- Installing Pacman Packages ---"

if [ -f "$PACMAN_LIST" ]; then
    # -S: Sync/Install, --needed: Skip if already installed, -: Read from stdin
    yay -S --needed - < "$PACMAN_LIST"
else
    echo "[WARNING] $PACMAN_LIST not found. Skipping pacman installation."
fi

echo ""

# --- 4. Install Yay Packages ---
echo "--- Installing Yay Packages ---"

# Check if yay is installed before attempting to use it
if command -v yay &> /dev/null; then
    if [ -f "$YAY_LIST" ]; then
        yay -S --needed - < "$YAY_LIST"
    else
        echo "[WARNING] $YAY_LIST not found. Skipping yay package installation."
    fi
else
    echo "[SKIP] Yay is not installed. Cannot install AUR packages."
fi

echo ""
echo "--- Setup Complete! ---"
