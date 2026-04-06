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

# --- Argument Parsing ---
DRY_RUN=false
LINKS_ONLY=false

for arg in "$@"; do
    case $arg in
        --dry-run|-t)
            DRY_RUN=true
            ;;
        --links-only|-l)
            LINKS_ONLY=true
            ;;
    esac
done

if [ "$DRY_RUN" = true ]; then
    echo "!!! TEST MODE ENABLED - No changes will be made !!!"
fi

if [ "$LINKS_ONLY" = true ]; then
    echo "!!! LINKS ONLY MODE ENABLED - Skipping installations and updates !!!"
fi
echo ""

# Helper function to execute or just echo
run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        echo "[TEST] $@"
    else
        "$@"
    fi
}

# Ensure central backup directory exists
[ "$DRY_RUN" = false ] && mkdir -p "$BACKUP_DIR"

# ==========================================
# SKIP THESE STEPS IF --links-only IS PASSED
# ==========================================
if [ "$LINKS_ONLY" = false ]; then

    # --- 0. System Update ---
    echo "--- Starting System Update ---"
    if [ "$DRY_RUN" = true ]; then
        echo "[TEST] sudo pacman -Syu --noconfirm"
    else
        sudo pacman -Syu --noconfirm || { echo "[ERROR] Update failed"; exit 1; }
    fi

    # --- 1. Install Yay ---
    if ! command -v yay &> /dev/null; then
        echo "[INFO] Installing Yay..."
        run_cmd sudo pacman -S --needed --noconfirm base-devel git
        if [ "$DRY_RUN" = false ]; then
            TEMP_DIR=$(mktemp -d)
            git clone https://aur.archlinux.org/yay.git "$TEMP_DIR/yay"
            cd "$TEMP_DIR/yay" && makepkg -si --noconfirm
            cd "$HOME" && rm -rf "$TEMP_DIR"
        else
            echo "[TEST] (Clone, build, and install yay)"
        fi
    fi

fi

# ==========================================
# ALWAYS RUN THESE (SYMLINKING)
# ==========================================

# --- 2. Symlink Configs ---
echo "--- Linking .config folders ---"
run_cmd mkdir -p "$TARGET_CONFIG"
for folder in "$SOURCE_CONFIG"/*; do
    [ -e "$folder" ] || continue
    name=$(basename "$folder")
    target="$TARGET_CONFIG/$name"
    
    if [ -e "$target" ] && [ "$(readlink "$target")" != "$folder" ]; then
        echo "[BACKUP] Moving existing $name to $BACKUP_DIR"
        run_cmd rm -rf "$BACKUP_DIR/$name"
        run_cmd mv "$target" "$BACKUP_DIR/"
    fi
    run_cmd ln -snf "$folder" "$target"
done

# --- Symlink scripts to local bin ---
echo "--- Linking scripts to ~/.local/bin ---"
run_cmd mkdir -p "$HOME/.local/bin"
SCRIPT_SRC="$DOTFILES_DIR/scripts"

if [ -d "$SCRIPT_SRC" ]; then
    for script in "$SCRIPT_SRC"/*; do
        [ -f "$script" ] || continue  # Only link files, skip directories
        name=$(basename "$script")
        target="$HOME/.local/bin/$name"

        # Check if it's already linked or exists
        if [ -e "$target" ] && [ "$(readlink "$target")" != "$script" ]; then
            echo "[BACKUP] Moving existing bin $name to $BACKUP_DIR"
            run_cmd mv "$target" "$BACKUP_DIR/"
        fi
        
        run_cmd ln -snf "$script" "$target"
    done
fi

# ==========================================
# SKIP THESE STEPS IF --links-only IS PASSED
# ==========================================
if [ "$LINKS_ONLY" = false ]; then

    # --- 3. Install Packages ---
    if [ -f "$PACMAN_LIST" ]; then
        echo "[INFO] Installing packages from list..."
        run_cmd yay -S --needed --noconfirm - < "$PACMAN_LIST"
    fi

    # --- 4. Setup Ly ---
    echo "--- Setting up Ly ---"
    if ! pacman -Qi ly &> /dev/null; then run_cmd yay -S --needed --noconfirm ly; fi
    if [ -L "/etc/systemd/system/display-manager.service" ]; then
        run_cmd sudo systemctl disable $(basename $(readlink /etc/systemd/system/display-manager.service))
    fi
    run_cmd sudo systemctl disable getty@tty2.service
    run_cmd sudo systemctl enable ly@tty2.service

    if [ -f "$LY_CONFIG_DIR/config.ini" ]; then
        if [ -f "$LY_TARGET_CONFIG" ]; then
            run_cmd sudo mv "$LY_TARGET_CONFIG" "$BACKUP_DIR/ly_config.ini.old"
            run_cmd sudo chown $USER:$USER "$BACKUP_DIR/ly_config.ini.old"
        fi
        run_cmd sudo mkdir -p /etc/ly 
        run_cmd sudo cp "$LY_CONFIG_DIR/config.ini" "$LY_TARGET_CONFIG"
    fi

    # --- 5. Zsh Setup ---
    if command -v zsh &> /dev/null; then
        ZSH_BIN=$(which zsh)
        if [ "$SHELL" != "$ZSH_BIN" ]; then
            run_cmd chsh -s "$ZSH_BIN"
        fi
        run_cmd sh -c "echo 'export ZDOTDIR=\"\$HOME/.config/zsh\"' > ~/.zshenv"
    fi

    # --- 6. Neovim Kickstart ---
    echo "--- Customizing nvim config ---"
    NVIM_DIR="$HOME/.config/nvim"
    if [ -e "$NVIM_DIR" ] && [ "$(readlink "$NVIM_DIR")" == "" ]; then
        run_cmd rm -rf "$BACKUP_DIR/nvim"
        run_cmd mv "$NVIM_DIR" "$BACKUP_DIR/"
    fi
    run_cmd git clone https://github.com/kromidka/kromid.kickstart.nvim.git "$NVIM_DIR"

fi

# ==========================================
# ALWAYS RUN THESE (MORE SYMLINKING)
# ==========================================

# --- 7. Extra Links ---
echo "--- Creating extra symlinks ---"
run_cmd mkdir -p ~/Pictures
run_cmd ln -snf "$DOTFILES_DIR/wall" "$HOME/Pictures/wall"
run_cmd ln -snf "$ZEN_CONF_DIR" "$ZEN_TARGET_CONF"

# --- 8. Summary ---
echo ""
if [ "$DRY_RUN" = true ]; then
    echo "--- Test Run Complete. No files were changed. ---"
else
    echo "--- Backup Summary ---"
    ls -F "$BACKUP_DIR"
    if [ "$LINKS_ONLY" = true ]; then
        echo -e "\n--- Symlinking Complete! ---"
    else
        echo -e "\n--- Setup Complete! Reboot to see changes. ---"
    fi
fi
