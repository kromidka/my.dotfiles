#!/bin/bash

# Define your directories
CONFIG_DIR="$HOME/.config"
KDE_DIR="$CONFIG_DIR/kde-settings"

# 1. Create the target directory
mkdir -p "$KDE_DIR"

# 2. Comprehensive list based on your specific .config layout
KDE_FILES=(
    "libinput-gestures.conf"
    "dolphinrc"
    "kdeglobals"
    "baloofilerc"
    "baloofileinformationrc"
    "bluedevilglobalrc"
    "darklyrc"
    "filetypesrc"
    "harunarc"
    "kactivitymanagerdrc"
    "kate-externaltoolspluginrc"
    "katerc"
    "katevirc"
    "kcminputrc"
    "kconf_updaterc"
    "kded5rc"
    "kded6rc"
    "kglobalshortcutsrc"
    "kiorc"
    "krunnerrc"
    "ksmserverrc"
    "ksplashrc"
    "ktimezonedrc"
    "kwalletrc"
    "kwinoutputconfig.json"
    "kwinrc"
    "partitionmanagerrc"
    "plasma-localerc"
    "plasma-org.kde.plasma.desktop-appletsrc"
    "plasmaparc"
    "plasmarc"
    "plasmashellrc"
    "powermanagementprofilesrc"
    "spectaclerc"
    "trashrc"
    "QtProject.conf"
    "Trolltech.conf"
)

echo "Starting deep KDE/Plasma config sweep..."

# 3. Loop through the list and process each file
for file in "${KDE_FILES[@]}"; do
    SOURCE_FILE="$CONFIG_DIR/$file"
    TARGET_FILE="$KDE_DIR/$file"

    # Check if the file exists in ~/.config AND is NOT already a symlink
    if [ -f "$SOURCE_FILE" ] && [ ! -L "$SOURCE_FILE" ]; then
        echo " -> Moving $file to $KDE_DIR..."
        mv "$SOURCE_FILE" "$TARGET_FILE"
        
        echo " -> Creating symlink for $file..."
        ln -s "$TARGET_FILE" "$SOURCE_FILE"
        
    elif [ -L "$SOURCE_FILE" ]; then
        # Already a symlink, skip it
        continue
    fi
done

echo "Sweep complete! Your ~/.config should look much cleaner now."
