#!/bin/bash

# --- Configuration ---
DOTFILES_DIR="$HOME/git/my.dotfiles"
SOURCE_CONFIG="$DOTFILES_DIR/.config"
TARGET_CONFIG="$HOME/.config"
PACMAN_LIST="$DOTFILES_DIR/pacman.txt"
LY_CONFIG_DIR="$DOTFILES_DIR/ly"
LY_TARGET_CONFIG="/etc/ly/config.ini"
ZEN_CONF_DIR="$DOTFILES_DIR/.zen"
ZEN_TARGET_CONF="$HOME/.zen"
BACKUP_DIR="$HOME/.bak"

# Ensure central backup directory exists
mkdir -p "$BACKUP_DIR"

# --- 0. System Update ---
echo "--- Starting System Update ---"
sudo pacman -Syu --noconfirm || { echo "[ERROR] Update failed"; exit 1; }

# --- 1. Install Yay ---
if ! command -v yay &> /dev/null; then
    echo "[INFO] Installing Yay..."
    sudo pacman -S --needed --noconfirm base-devel git
    TEMP_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$TEMP_DIR/yay"
    cd "$TEMP_DIR/yay" && makepkg -si --noconfirm
    cd "$HOME" && rm -rf "$TEMP_DIR"
fi

# --- 2. Symlink Configs ---
echo "--- Linking .config folders ---"
mkdir -p "$TARGET_CONFIG"
for folder in "$SOURCE_CONFIG"/*; do
    [ -e "$folder" ] || continue
    name=$(basename "$folder")
    target="$TARGET_CONFIG/$name"
    
    if [ -e "$target" ] && [ "$(readlink "$target")" != "$folder" ]; then
        echo "[BACKUP] Moving existing $name to $BACKUP_DIR"
        rm -rf "$BACKUP_DIR/$name"
        mv "$target" "$BACKUP_DIR/"
    fi
    ln -snf "$folder" "$target"
done

# --- 3. Install Packages ---
if [ -f "$PACMAN_LIST" ]; then
    echo "[INFO] Installing packages from list..."
    yay -S --needed --noconfirm - < "$PACMAN_LIST"
fi

# --- 4. Setup Ly Display Manager ---
echo "--- Setting up Ly ---"
if ! pacman -Qi ly &> /dev/null; then yay -S --needed --noconfirm ly; fi
[ -L "/etc/systemd/system/display-manager.service" ] && sudo systemctl disable $(basename $(readlink /etc/systemd/system/display-manager.service))
sudo systemctl disable getty@tty2.service
sudo systemctl enable ly@tty2.service

if [ -f "$LY_CONFIG_DIR/config.ini" ]; then
    if [ -f "$LY_TARGET_CONFIG" ]; then
        sudo mv "$LY_TARGET_CONFIG" "$BACKUP_DIR/ly_config.ini.old"
        sudo chown $USER:$USER "$BACKUP_DIR/ly_config.ini.old"
    fi
    sudo mkdir -p /etc/ly && sudo cp "$LY_CONFIG_DIR/config.ini" "$LY_TARGET_CONFIG"
fi

# --- 5. Zsh Setup ---
if command -v zsh &> /dev/null; then
    [ "$SHELL" != "$(which zsh)" ] && chsh -s $(which zsh)
    echo 'export ZDOTDIR="$HOME/.config/zsh"' > ~/.zshenv
fi

# --- 6. Neovim Kickstart ---
echo "--- Customizing nvim config ---"
NVIM_DIR="$HOME/.config/nvim"
if [ -e "$NVIM_DIR" ] && [ "$(readlink "$NVIM_DIR")" == "" ]; then
    echo "[INFO] Moving old nvim config to $BACKUP_DIR"
    rm -rf "$BACKUP_DIR/nvim"
    mv "$NVIM_DIR" "$BACKUP_DIR/"
fi
git clone https://github.com/kromidka/kromid.kickstart.nvim.git "$NVIM_DIR"

# --- 7. Extra Links ---
echo "--- Creating final symlinks ---"
mkdir -p ~/Pictures
ln -snf "$DOTFILES_DIR/wall" "$HOME/Pictures/wall"
ln -snf "$ZEN_CONF_DIR" "$ZEN_TARGET_CONF"

# --- 8. Summary & Cleanup ---
echo ""
echo "--- Backup Summary ---"
if [ "$(ls -A $BACKUP_DIR)" ]; then
    echo "The following files/folders were moved to $BACKUP_DIR:"
    ls -F "$BACKUP_DIR"
else
    echo "No backups were necessary."
fi

echo -e "\n--- Setup Complete! Reboot to see changes. ---"
