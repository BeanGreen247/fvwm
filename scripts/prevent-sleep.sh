#!/bin/bash

# Disable HDD spindown
hdparm -S 0 /dev/sda

# Prevent system sleep and screen blanking
systemd-inhibit --what=idle:sleep:handle-lid-switch --why="Keep system awake" \
bash -c '
    while true; do
        # Touch activity to reset idle timer
        xset s off           # Disable screen saver
        xset -dpms           # Disable DPMS (display power management)
        xset s noblank       # Don’t blank the screen
        xset s reset         # Reset the screen saver timer
        sleep 50
    done
'
