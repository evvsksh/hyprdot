#!/bin/bash
# ~/.config/hypr/scripts/screenshot-region-clipboard.sh

# Take a region screenshot and pipe to clipboard
grim -g "$(slurp)" - | wl-copy

# Optional notification
notify-send "Screenshot copied to clipboard!"
