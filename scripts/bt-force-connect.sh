#!/bin/bash

# The MAC address of your speaker
SPEAKER_MAC="08:EB:ED:BD:0E:AF"

# Function to send notifications through Noctalia/Standard system
notify() {
    # We use notify-send, but ensure it's sent to the session bus
    notify-send -a "System" -u normal "Bluetooth" "$1"
}


notify "Connecting to speaker..."

# 2. Hard delay to let PipeWire/WirePlumber settle
sleep 10

# 3. Connection Loop
for i in {1..15}; do
    # Power on the adapter explicitly
    bluetoothctl power on > /dev/null
    
    # Try connecting with a 5-second timeout (prevents hanging)
    if bluetoothctl --timeout 5 connect $SPEAKER_MAC | grep -q "successful"; then
        notify "Speaker Connected!"
        exit 0
    fi
    
    # If it fails, try a 'trust' refresh and wait
    bluetoothctl trust $SPEAKER_MAC > /dev/null
    sleep 5
done

notify "Bluetooth connection timed out."
exit 1
