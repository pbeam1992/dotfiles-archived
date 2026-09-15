#!/bin/bash
set -euo pipefail

# Appearance: dark mode (takes effect after logout)
defaults write -g AppleInterfaceStyle -string Dark

# Trackpad
defaults write -g com.apple.trackpad.scaling -float 3.0
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool false

# Keyboard: fast key repeat, medium-short initial delay; held keys repeat instead of opening the accent popup
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 30
defaults write -g ApplePressAndHoldEnabled -bool false

# Dock: left, small, auto-hide, no recent apps, Spaces stay in the order they were put
defaults write com.apple.dock orientation -string left
defaults write com.apple.dock tilesize -int 33
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mru-spaces -bool false

# Desktop: clicking the wallpaper reveals it only in Stage Manager
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

# Finder: list view, search the current folder, new windows open home
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv
defaults write com.apple.finder FXDefaultSearchScope -string SCcf
defaults write com.apple.finder NewWindowTarget -string PfHm

# Restart what reads the values above; the script only runs when its content changes
killall Dock Finder || true

# Apply preference changes without logout (private framework binary; guard its existence)
ACTIVATE="/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings"
if [ -x "$ACTIVATE" ]; then "$ACTIVATE" -u; fi
