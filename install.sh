#!/usr/bin/env bash

# Enhanced Mac Setup Script with proper error handling and logging
# Author: Generated for complete automated Mac setup

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/install.log"
ERROR_LOG="$SCRIPT_DIR/error.log"

# Logging functions
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "$ERROR_LOG" >&2
}

# Error handling
handle_error() {
    local exit_code=$1
    local line_number=$2
    local command="$3"
    error "Command failed with exit code $exit_code at line $line_number: $command"
    error "Installation failed. Check $ERROR_LOG for details."
    exit $exit_code
}

# Set error trap
trap 'handle_error $? $LINENO "$BASH_COMMAND"' ERR

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to retry commands
retry() {
    local retries=$1
    shift
    local count=0
    until "$@"; do
        count=$((count + 1))
        if [ $count -ge $retries ]; then
            error "Command failed after $retries attempts: $*"
            return 1
        fi
        log "Attempt $count failed. Retrying in 5 seconds..."
        sleep 5
    done
}

# Pre-installation checks
pre_install_checks() {
    log "Starting pre-installation checks..."
    
    # Check if running on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        error "This script is designed for macOS only"
        exit 1
    fi
    
    # Check for internet connectivity
    if ! ping -c 1 google.com >/dev/null 2>&1; then
        error "No internet connectivity detected"
        exit 1
    fi
    
    # Check available disk space (minimum 5GB)
    available_space=$(df / | awk 'NR==2 {print $4}')
    if [ "$available_space" -lt 5000000 ]; then
        error "Insufficient disk space. At least 5GB required."
        exit 1
    fi
    
    log "Pre-installation checks passed"
}

# Install Xcode Command Line Tools
install_xcode_tools() {
    log "Checking for Xcode Command Line Tools..."
    
    if ! xcode-select -p >/dev/null 2>&1; then
        log "Installing Xcode Command Line Tools..."
        xcode-select --install
        
        # Wait for installation to complete
        until xcode-select -p >/dev/null 2>&1; do
            log "Waiting for Xcode Command Line Tools installation..."
            sleep 30
        done
        log "Xcode Command Line Tools installed successfully"
    else
        log "Xcode Command Line Tools already installed"
    fi
}

# Install Homebrew
install_homebrew() {
    log "Checking for Homebrew..."
    
    if ! command_exists brew; then
        log "Installing Homebrew..."
        retry 3 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for this session
        if [[ -x "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -x "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        log "Homebrew already installed"
    fi
    
    # Update Homebrew
    log "Updating Homebrew..."
    brew update || error "Failed to update Homebrew"
}

# Install packages from Brewfile
install_brew_packages() {
    log "Installing packages from Brewfile..."
    
    if [[ ! -f "$SCRIPT_DIR/Brewfile" ]]; then
        error "Brewfile not found in $SCRIPT_DIR"
        exit 1
    fi
    
    cd "$SCRIPT_DIR"
    retry 2 brew bundle install || error "Failed to install Homebrew packages"
    log "Homebrew packages installed successfully"
}

# Install Python packages with uv
install_python_packages() {
    log "Installing Python packages with uv..."
    
    if ! command_exists uv; then
        error "uv not found. Make sure it's installed via Homebrew."
        return 1
    fi
    
    local packages=("djlint" "sourcery" "textlsp")
    for package in "${packages[@]}"; do
        log "Installing $package with uv..."
        uv tool install "$package" || error "Failed to install $package"
    done
    
    log "Python packages installed successfully"
}

# Install Go packages
install_go_packages() {
    log "Installing Go development tools..."
    
    if ! command_exists go; then
        error "Go not found. Make sure it's installed via Homebrew."
        return 1
    fi
    
    local packages=(
        "gotest.tools/gotestsum@latest"
        "github.com/josharian/impl@latest"
        "github.com/fatih/gomodifytags@latest"
        "github.com/air-verse/air@latest"
        "mvdan.cc/gofumpt@latest"
        "github.com/kevincobain2000/gobrew/cmd/gobrew@latest"
    )
    
    for package in "${packages[@]}"; do
        log "Installing $package..."
        go install "$package" || error "Failed to install $package"
    done
    
    log "Go packages installed successfully"
}

# Install NPM global packages
install_npm_packages() {
    log "Installing NPM global packages..."
    
    if ! command_exists npm; then
        error "npm not found. Make sure Node.js is installed via Homebrew."
        return 1
    fi
    
    log "Installing svelte-language-server..."
    npm install -g "svelte-language-server" || error "Failed to install svelte-language-server"
    
    log "NPM global packages installed successfully"
}

# Install Rust toolchain
install_rust() {
    log "Installing Rust toolchain..."
    
    if command_exists rustc; then
        log "Rust already installed, updating..."
        rustup update || error "Failed to update Rust"
    else
        log "Installing Rust via rustup..."
        retry 3 curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        
        # Source cargo environment for this session
        if [[ -f "$HOME/.cargo/env" ]]; then
            source "$HOME/.cargo/env"
        fi
    fi
    
    log "Rust toolchain installed successfully"
}

# Install Mac App Store apps
install_mas_apps() {
    log "Installing Mac App Store applications..."
    
    if ! command_exists mas; then
        error "mas not found. Make sure it's installed via Homebrew."
        return 1
    fi
    
    # Check if signed into Mac App Store
    if ! mas account >/dev/null 2>&1; then
        log "⚠️  Please sign into the Mac App Store first, then re-run this script"
        open -a "App Store"
        read -p "Press Enter after signing in to continue..."
    fi
    
    local apps=(
        "1018301773:AdBlock Pro"
        "417375580:BetterSnapTool"
        "897446215:Canva"
        "1477110326:Capital One Shopping"
        "1287239339:ColorSlurp"
        "1524172135:Creator's Best Friend"
        "1438243180:Dark Reader for Safari"
        "672206759:Disk Diag"
        "1462114288:Grammarly for Safari"
        "953040671:hide.me"
        "992115977:Image2Icon"
        "748212890:Memory Diag"
        "409203825:Numbers"
        "1472777122:PayPal Honey"
        "1452228487:Screen-Timelapse-lite"
        "1508706541:Spring"
        "747648890:Telegram"
        "904280696:Things"
        "1255311569:Time Zone Converter and Clock"
        "1200948946:TubeBuddy for YouTube"
        "1537056818:Unzip - RAR ZIP 7Z Unarchiver"
        "533696630:Webcam Settings"
        "1295203466:Windows App"
        "370922777:Oanda"
        "1062022008:LumaFusion"
        "1500855883:CapCut"
        "6473753684:Claude by Anthropic"
    )
    
    for app in "${apps[@]}"; do
        local app_id="${app%%:*}"
        local app_name="${app#*:}"
        log "Installing $app_name..."
        mas install "$app_id" || error "Failed to install $app_name"
    done
    
    log "Mac App Store apps installed successfully"
}

# Setup dotfiles with chezmoi
setup_dotfiles() {
    log "Setting up dotfiles with chezmoi..."
    
    if ! command_exists chezmoi; then
        error "chezmoi not found. Make sure it's installed via Homebrew."
        return 1
    fi
    
    if ! command_exists gh; then
        error "gh not found. Make sure it's installed via Homebrew."
        return 1
    fi
    
    # Check if dotfiles repo exists
    if gh repo view g5becks/dotfiles >/dev/null 2>&1; then
        log "Applying dotfiles from repository..."
        chezmoi init --apply g5becks/dotfiles || error "Failed to apply dotfiles"
        log "Dotfiles applied successfully"
    else
        log "⚠️  Dotfiles repository not found. Manual setup required:"
        log "   1. Create the repository: gh repo create g5becks/dotfiles --private"
        log "   2. Push your dotfiles: chezmoi cd && git add . && git commit -m 'Initial dotfiles' && git push"
        log "   3. Then run: chezmoi init --apply g5becks/dotfiles"
    fi
}

# Setup shell environment
setup_shell() {
    log "Setting up shell environment..."
    
    # Create necessary directories (if not created by chezmoi)
    mkdir -p ~/.config/zsh || true
    
    log "Shell environment setup completed"
}

# Display MCP server setup instructions
show_mcp_instructions() {
    log "Displaying MCP server setup instructions..."
    
    cat << 'EOF'

🔧 MCP Servers Setup Instructions:
⚠️  IMPORTANT: Complete these steps after the script finishes:

1. Set your API keys (if not already in Keychain):
   - GitHub PAT: https://github.com/settings/tokens
   - Context7 Key: https://context7.com/dashboard
   - And others as needed

2. Add MCP servers to default Claude instance:
   claude mcp add-json github '{"command": "github-mcp-server", "args": ["stdio"], "env": {"GITHUB_PERSONAL_ACCESS_TOKEN": "'$GITHUB_PAT'"}}'
   claude mcp add --transport http context7 https://mcp.context7.com/mcp --header "CONTEXT7_API_KEY: $CTX7_KEY"
   claude mcp add brave-search -- npx -y @brave/brave-search-mcp-server --transport stdio --brave-api-key $BRAVE_SEARCH_KEY
   claude mcp add --transport http Ref https://api.ref.tools/mcp --header "x-ref-api-key: ref-20c015e66910720d5356"
   claude mcp add playwright -- npx @playwright/mcp@latest
   claude mcp add exa -e EXA_API_KEY=$EXA_API_KEY -- npx -y exa-mcp-server
   claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project $(pwd)
   claude mcp add memory-bank -e MEMORY_BANK_ROOT=~/.claude_mem_bank -- npx -y @allpepper/memory-bank-mcp@latest
   claude mcp add knowledge-graph -e AIM_DIRECTORY=~/.aim -- npx -y @modelcontextprotocol/server-knowledge-graph

3. Add MCP servers to claudette instance:
   claudette mcp add-json github '{"command": "github-mcp-server", "args": ["stdio"], "env": {"GITHUB_PERSONAL_ACCESS_TOKEN": "'$GITHUB_PAT'"}}'
   [... similar commands with 'claudette' prefix ...]

4. Verify setup:
   claude mcp list
   claudette mcp list

EOF
}

# Restore macOS preferences
restore_macos_preferences() {
    log "Restoring macOS preferences..."
    
    # Finder preferences
    defaults write com.apple.finder AppleShowAllFiles -bool true
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder ShowStatusBar -bool true
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
    
    # Dock preferences
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock orientation -string "bottom"
    defaults write com.apple.dock tilesize -float 48
    defaults write com.apple.dock mineffect -string "scale"
    
    # Keyboard preferences
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    
    # Trackpad preferences
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    
    # Safari preferences
    defaults write com.apple.Safari IncludeDevelopMenu -bool true
    
    # Screenshot preferences
    defaults write com.apple.screencapture location -string "$HOME/Desktop"
    defaults write com.apple.screencapture type -string "png"
    
    # Energy preferences
    sudo pmset -c displaysleep 0 || log "Could not set display sleep settings (requires admin)"
    
    # Development setup
    mkdir -p ~/Dev ~/go ~/.claudette ~/.claude_mem_bank ~/.aim
    
    # Add Dev directory to Finder favorites
    sfltool add-item com.apple.LSSharedFileList.FavoriteItems "file://$HOME/Dev" || true
    
    # Create claude-squad symlink
    if command_exists claude-squad; then
        ln -sf "$(brew --prefix)/bin/claude-squad" "$(brew --prefix)/bin/cs" || true
    fi
    
    # Restart affected services
    killall Finder 2>/dev/null || true
    killall Dock 2>/dev/null || true
    killall SystemUIServer 2>/dev/null || true
    
    log "macOS preferences restored successfully"
}

# Install additional software requiring manual steps
install_additional_software() {
    log "Installing additional software..."
    
    # Install Kensington Konnect Pro
    log "Installing Kensington Konnect Pro..."
    if curl -L -o /tmp/KonnectSetup.pkg "https://accoblobstorageus.blob.core.windows.net/software/version/konnectpro/KonnectSetup.pkg"; then
        sudo installer -pkg /tmp/KonnectSetup.pkg -target / || error "Failed to install Kensington Konnect Pro"
        rm -f /tmp/KonnectSetup.pkg
        log "Kensington Konnect Pro installed successfully"
    else
        error "Failed to download Kensington Konnect Pro"
    fi
    
    # Install Adobe DNG Converter
    log "Installing Adobe DNG Converter..."
    if curl -L -o /tmp/DNGConverter.dmg "https://www.adobe.com/go/dng_converter_mac"; then
        hdiutil attach /tmp/DNGConverter.dmg -nobrowse -quiet
        MOUNT_POINT=$(hdiutil info | grep "Adobe DNG" | awk '{print $3}' | head -1)
        
        if [[ -n "$MOUNT_POINT" ]]; then
            PKG_FILE=$(find "$MOUNT_POINT" -name "*.pkg" | head -1)
            if [[ -n "$PKG_FILE" ]]; then
                sudo installer -pkg "$PKG_FILE" -target / || error "Failed to install Adobe DNG Converter"
            fi
            hdiutil detach "$MOUNT_POINT" -quiet || true
        fi
        
        rm -f /tmp/DNGConverter.dmg
        log "Adobe DNG Converter installation attempted"
    else
        error "Failed to download Adobe DNG Converter"
    fi
}

# Final setup steps
final_setup() {
    log "Performing final setup steps..."
    
    # Setup starship prompt
    if command_exists starship; then
        starship preset nerd-font-symbols -o ~/.config/starship.toml || true
    fi
    
    # Add Homebrew version of bash to shells
    if [[ -x "$(brew --prefix)/bin/bash" ]]; then
        grep -qxF "$(brew --prefix)/bin/bash" /etc/shells || echo "$(brew --prefix)/bin/bash" | sudo tee -a /etc/shells
    fi
    
    log "Final setup completed"
}

# Show manual installation reminders
show_manual_reminders() {
    log "Showing manual installation reminders..."
    
    cat << 'EOF'

==========================================
🚨 MANUAL INSTALLATION REMINDER 🚨
==========================================

📱 RECUT - Video Editor
   This app must be requested from the developer
   Search 'recut' in takinprofit@gmail.com email account for your license key!
   License lookup: https://backend.getrecut.com/lookup/license

✅ All automated installations complete!
Don't forget to install Recut manually!
==========================================

EOF
}

# Main installation function
main() {
    log "Starting Mac Setup Installation"
    log "Script version: Enhanced with error handling"
    log "Log file: $LOG_FILE"
    log "Error log: $ERROR_LOG"
    
    # Create log files
    touch "$LOG_FILE" "$ERROR_LOG"
    
    # Run installation steps in order
    pre_install_checks
    install_xcode_tools
    install_homebrew
    install_brew_packages
    install_python_packages
    install_go_packages
    install_npm_packages
    install_rust
    install_mas_apps
    setup_dotfiles
    setup_shell
    restore_macos_preferences
    install_additional_software
    final_setup
    
    # Display post-installation information
    show_mcp_instructions
    show_manual_reminders
    
    log "Mac Setup Installation completed successfully!"
    log "Please review the instructions above and restart your terminal."
}

# Run main function
main "$@"