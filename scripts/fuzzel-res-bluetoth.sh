#!/bin/bash

# 1. Ask for the password using fuzzel
pass=$(fuzzel --dmenu --password --prompt "Sudo Password (Restart BT): " --lines 0)

# 2. If the user hits Esc or enters nothing, exit quietly
[ -z "$pass" ] && exit 1

# 3. Pipe the password into sudo to restart the service
if echo "$pass" | sudo -S systemctl restart bluetooth.service 2>/dev/null; then
    notify-send -u low "System" "Bluetooth service restarted successfully."
else
    notify-send -u critical "System" "Failed to restart Bluetooth. Check password."
    exit 1
fi
