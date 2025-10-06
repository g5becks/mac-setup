#!/usr/bin/env bash

# Clean macOS preferences restoration script
# Focused on commonly changed settings

restore_macos_preferences() {
    echo 'Restoring macOS preferences...'

    # === FINDER PREFERENCES ===
    # Show hidden files
    defaults write com.apple.finder AppleShowAllFiles -bool true
    
    # Show file extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    
    # Show path bar
    defaults write com.apple.finder ShowPathbar -bool true
    
    # Show status bar
    defaults write com.apple.finder ShowStatusBar -bool true
    
    # Default to list view
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

    # === DOCK PREFERENCES ===
    # Auto-hide dock
    defaults write com.apple.dock autohide -bool true
    
    # Dock position
    defaults write com.apple.dock orientation -string "bottom"
    
    # Dock size
    defaults write com.apple.dock tilesize -float 48
    
    # Minimize windows using scale effect
    defaults write com.apple.dock mineffect -string "scale"

    # === KEYBOARD PREFERENCES ===
    # Fast key repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    
    # === TRACKPAD PREFERENCES ===
    # Tap to click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    
    # === SAFARI PREFERENCES ===
    # Show develop menu
    defaults write com.apple.Safari IncludeDevelopMenu -bool true
    
    # === SCREENSHOT PREFERENCES ===
    # Save screenshots to Desktop
    defaults write com.apple.screencapture location -string "$HOME/Desktop"
    
    # Screenshot format
    defaults write com.apple.screencapture type -string "png"

    # === ENERGY PREFERENCES ===
    # Never put display to sleep when charging
    sudo pmset -c displaysleep 0

    # Restart affected services
    killall Finder 2>/dev/null || true
    killall Dock 2>/dev/null || true
    killall SystemUIServer 2>/dev/null || true

    echo 'macOS preferences restored. Some changes may require logout/restart.'
}