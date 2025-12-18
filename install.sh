#!/bin/bash

# --- Configuration ---
DOTFILES_DIR="$HOME/git/my.dotfiles"
SOURCE_CONFIG="$DOTFILES_DIR/.config"
TARGET_CONFIG="$HOME/.config"
PACMAN_LIST="$DOTFILES_DIR/pacman.txt"
LY_CONFIG_DIR="$DOTFILES_DIR/ly"
LY_TARGET_CONFIG="/etc/ly/config.ini"

# --- 0. System Update ---
echo "--- Starting System Update ---"
# -Syu: Sync, Refresh, Update
sudo pacman -Syu --noconfirm
if [ $? -eq 0 ]; then
    echo "[OK] System update complete."
else
    echo "[ERROR] System update failed. Please resolve errors before proceeding."
    exit 1
fi
echo ""

# --- 1. Install Yay (AUR Helper) ---
echo "--- Checking for Yay ---"

if ! command -v yay &> /dev/null; then
    echo "[INFO] Yay not found. Installing now..."
    
    # Install prerequisites
    sudo pacman -S --needed --noconfirm base-devel git
    
    # Install yay from AUR
    TEMP_DIR="$HOME/yay_temp_install"
    mkdir -p "$TEMP_DIR"
    git clone https://aur.archlinux.org/yay.git "$TEMP_DIR/yay"
    cd "$TEMP_DIR/yay"
    makepkg -si --noconfirm
    
    # Cleanup
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

# --- 3. Install Packages ---
echo "--- Installing Packages ---"

if [ -f "$PACMAN_LIST" ]; then
    echo "[INFO] Installing from pacman.txt..."
    # --noconfirm: automatic yes to all prompts
    yay -S --needed --noconfirm - < "$PACMAN_LIST"
else
    echo "[WARNING] $PACMAN_LIST not found."
fi

echo ""

# --- 4. Setup Ly Display Manager ---
echo "--- Setting up Ly Display Manager ---"

# 4a. Check if ly is installed
if ! pacman -Qi ly &> /dev/null; then
    echo "[INFO] 'ly' package not found. Installing via Yay..."
    yay -S --needed --noconfirm ly
fi

# 4b. Disable current DM (Generic check)
DM_SERVICE_LINK="/etc/systemd/system/display-manager.service"
if [ -L "$DM_SERVICE_LINK" ]; then
    CURRENT_DM=$(basename $(readlink "$DM_SERVICE_LINK"))
    echo "[ACTION] Disabling current active DM: $CURRENT_DM"
    sudo systemctl disable "$CURRENT_DM"
fi

# 4c. Configure Services (Disable getty@tty2, Enable ly@tty2)
echo "[ACTION] Disabling getty@tty2.service..."
sudo systemctl disable getty@tty2.service

echo "[ACTION] Enabling ly@tty2.service..."
sudo systemctl enable ly@tty2.service

# 4d. Config File Backup and Copy
LY_SOURCE_CONFIG="$LY_CONFIG_DIR/config.ini"

if [ -f "$LY_SOURCE_CONFIG" ]; then
    # Check if target config exists and make backup
    if [ -f "$LY_TARGET_CONFIG" ]; then
        echo "[BACKUP] Renaming existing $LY_TARGET_CONFIG to $LY_TARGET_CONFIG.old"
        sudo mv "$LY_TARGET_CONFIG" "$LY_TARGET_CONFIG.old"
    fi

    echo "[CONFIG] Copying new config from $LY_SOURCE_CONFIG..."
    # Ensure directory exists
    sudo mkdir -p /etc/ly
    sudo cp "$LY_SOURCE_CONFIG" "$LY_TARGET_CONFIG"
    echo "[OK] Ly config updated."
else
    echo "[WARNING] Ly source config file not found at $LY_SOURCE_CONFIG. Skipping config copy."
fi

# --- 5. Set Zsh as Default Shell ---
echo "--- Setting Zsh as default shell ---"
if command -v zsh &> /dev/null; then
    # Get the path to zsh
    ZSH_PATH=$(which zsh)
    # Check if current shell is already zsh to avoid unnecessary password prompts
    if [ "$SHELL" != "$ZSH_PATH" ]; then
        echo "[ACTION] Changing default shell to $ZSH_PATH..."
        chsh -s "$ZSH_PATH"
    else
        echo "[SKIP] Zsh is already the default shell."
    fi
else
    echo "[ERROR] Zsh is not installed."
fi

echo "--- Setting path to new config ---"

echo 'export ZDOTDIR="$HOME/.config/zsh"' > ~/.zshenv

# --- 6. getting custum nvim setup ---
echo "--- Custumizing nvim config ---"

git clone https://github.com/kromidka/kromid.kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim

echo "--- nvim setup completed ---"

ln -snf ~/git/my.dotfiles/wall/ ~/Pictures/wall

echo ""
echo "--- Setup Complete! Reboot to see changes. ---"
