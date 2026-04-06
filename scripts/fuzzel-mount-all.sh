#!/bin/bash

# 1. Get the password
pass=$(fuzzel --dmenu --password --prompt "Sudo Password: " --lines 0)

# 2. Exit if the user pressed Esc (empty string)
[ -z "$pass" ] && exit 1

# 3. Try to mount and capture the result
if echo "$pass" | sudo -S mount -a 2>/dev/null; then
    notify-send -u low "Disk Utility" "All drives mounted successfully."
else
    notify-send -u critical "Disk Utility" "Mount failed! Check password or fstab."
    exit 1
fi
