#!/bin/bash
set -euo pipefail

# Trackpad
defaults write -g com.apple.trackpad.scaling -float 3.0
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool false

# Keyboard: fast key repeat, medium-short initial delay
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 30

# Held keys repeat instead of opening the accent popup (needed for the fast KeyRepeat above)
defaults write -g ApplePressAndHoldEnabled -bool false

# Dock: auto-hide; restart it only when the value actually changes
if [ "$(defaults read com.apple.dock autohide 2>/dev/null || true)" != "1" ]; then
  defaults write com.apple.dock autohide -bool true
  killall Dock
fi

# Apply preference changes without logout (private framework binary; guard its existence)
ACTIVATE="/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings"
[ -x "$ACTIVATE" ] && "$ACTIVATE" -u
