#!/usr/bin/env bash

install_homebrew() {
    if ! command -v brew &>/dev/null; then
        echo "homebrew not found, attempting to install..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "homebrew is already installed, skipping..."
    fi
}

brew bundle

install_with_uv() {
    echo "installing $1 with uv"
    uv tool install "$1"
    echo "$1 installed"
}

install_python_stuff() {
    install_with_uv djlint
    install_with_uv sourcery
    install_with_uv textlsp
}

install_with_go() {
    echo "installing $1 with go"
    go install "$1"
    echo "$1 installed susseccfully"
}

install_go_stuff() {
    echo "installing go dev tools"
    install_with_go "gotest.tools/gotestsum@latest"
    install_with_go "github.com/josharian/impl@latest"
    install_with_go "github.com/fatih/gomodifytags@latest"
    install_with_go "github.com/air-verse/air@latest"
    install_with_go "mvdan.cc/gofumpt@latest"
    install_with_go "github.com/kevincobain2000/gobrew/cmd/gobrew@latest"
}

install_npm_globals() {
    npm i -g "svelte-language-server"
}

install_kensington_konnect() {
    echo "Installing Kensington Konnect Pro..."
    
    # Download the installer
    curl -L -o /tmp/KonnectSetup.pkg "https://accoblobstorageus.blob.core.windows.net/software/version/konnectpro/KonnectSetup.pkg"
    
    # Install the package
    sudo installer -pkg /tmp/KonnectSetup.pkg -target /
    
    # Clean up
    rm /tmp/KonnectSetup.pkg
    
    echo "Kensington Konnect Pro installed successfully"
}

install_adobe_dng_converter() {
    echo "Installing Adobe DNG Converter..."
    
    # Download the installer
    curl -L -o /tmp/DNGConverter.dmg "https://www.adobe.com/go/dng_converter_mac"
    
    # Mount the DMG
    hdiutil attach /tmp/DNGConverter.dmg -nobrowse -quiet
    
    # Find the mounted volume (Adobe DNG converters usually mount as something like "Adobe DNG Converter")
    MOUNT_POINT=$(hdiutil info | grep "Adobe DNG" | awk '{print $3}' | head -1)
    
    # Install the package (assuming it contains a .pkg file)
    PKG_FILE=$(find "$MOUNT_POINT" -name "*.pkg" | head -1)
    if [ -n "$PKG_FILE" ]; then
        sudo installer -pkg "$PKG_FILE" -target /
    fi
    
    # Unmount and clean up
    hdiutil detach "$MOUNT_POINT" -quiet
    rm /tmp/DNGConverter.dmg
    
    echo "Adobe DNG Converter installed successfully"
}

setup_mcp_servers() {
    echo "Setting up MCP servers for Claude Code..."
    
    # Add claudette alias to shell configs
    echo "alias claudette='CLAUDE_CONFIG_DIR=~/.claudette claude'" >> ~/.zshrc
    echo "alias claudette='CLAUDE_CONFIG_DIR=~/.claudette claude'" >> ~/.bash_profile
    
    # Add reminder to set environment variables
    echo "" >> ~/.zshrc
    echo "# GitHub Personal Access Token for MCP server" >> ~/.zshrc
    echo "# export GITHUB_PAT=your_token_here" >> ~/.zshrc
    echo "# Context7 API Key for MCP server" >> ~/.zshrc
    echo "# export CTX7_KEY=your_context7_key_here" >> ~/.zshrc
    
    echo "" >> ~/.bash_profile
    echo "# GitHub Personal Access Token for MCP server" >> ~/.bash_profile
    echo "# export GITHUB_PAT=your_token_here" >> ~/.bash_profile
    echo "# Context7 API Key for MCP server" >> ~/.bash_profile
    echo "# export CTX7_KEY=your_context7_key_here" >> ~/.bash_profile
    
    echo ""
    echo "🔧 MCP Servers Setup Instructions:"
    echo ""
    echo "⚠️  IMPORTANT: Complete these steps after the script finishes:"
    echo ""
    echo "1. Set your API keys:"
    echo "   - GitHub PAT: https://github.com/settings/tokens (create token with 'repo' scope)"
    echo "   - Context7 Key: https://context7.com/dashboard (optional, for higher rate limits)"
    echo "   - Add to your ~/.zshrc:"
    echo "     export GITHUB_PAT=your_token_here"
    echo "     export CTX7_KEY=your_context7_key_here"
    echo "   - Run: source ~/.zshrc"
    echo ""
    echo "2. Add GitHub MCP server to default Claude instance (local stdio - fastest):"
    echo "   claude mcp add-json github '{\"command\": \"github-mcp-server\", \"args\": [\"stdio\"], \"env\": {\"GITHUB_PERSONAL_ACCESS_TOKEN\": \"'\$GITHUB_PAT'\"}}'"
    echo ""
    echo "3. Add Context7 MCP server to default Claude instance (remote HTTP):"
    echo "   claude mcp add --transport http context7 https://mcp.context7.com/mcp --header \"CONTEXT7_API_KEY: \$CTX7_KEY\""
    echo ""
    echo "4. Add Brave Search MCP server to default Claude instance (NPX stdio - fastest):"
    echo "   claude mcp add brave-search -- npx -y @brave/brave-search-mcp-server --transport stdio --brave-api-key \$BRAVE_SEARCH_KEY"
    echo ""
    echo "5. Add Ref.tools MCP server to default Claude instance (remote HTTP):"
    echo "   claude mcp add --transport http Ref https://api.ref.tools/mcp --header \"x-ref-api-key: ref-20c015e66910720d5356\""
    echo ""
    echo "6. Add Playwright MCP server to default Claude instance (NPX stdio):"
    echo "   claude mcp add playwright -- npx @playwright/mcp@latest"
    echo ""
    echo "7. Add Exa MCP server to default Claude instance (NPX stdio - code search & web search):"
    echo "   claude mcp add exa -e EXA_API_KEY=\$EXA_API_KEY -- npx -y exa-mcp-server"
    echo ""
    echo "8. Add Serena MCP server to default Claude instance (uvx - semantic code agent):"
    echo "   claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project \$(pwd)"
    echo ""
    echo "9. Add GitHub MCP server to claudette instance:"
    echo "   claudette mcp add-json github '{\"command\": \"github-mcp-server\", \"args\": [\"stdio\"], \"env\": {\"GITHUB_PERSONAL_ACCESS_TOKEN\": \"'\$GITHUB_PAT'\"}}'"
    echo ""
    echo "10. Add Context7 MCP server to claudette instance:"
    echo "   claudette mcp add --transport http context7 https://mcp.context7.com/mcp --header \"CONTEXT7_API_KEY: \$CTX7_KEY\""
    echo ""
    echo "11. Add Brave Search MCP server to claudette instance:"
    echo "   claudette mcp add brave-search -- npx -y @brave/brave-search-mcp-server --transport stdio --brave-api-key \$BRAVE_SEARCH_KEY"
    echo ""
    echo "12. Add Ref.tools MCP server to claudette instance:"
    echo "   claudette mcp add --transport http Ref https://api.ref.tools/mcp --header \"x-ref-api-key: ref-20c015e66910720d5356\""
    echo ""
    echo "13. Add Playwright MCP server to claudette instance:"
    echo "   claudette mcp add playwright -- npx @playwright/mcp@latest"
    echo ""
    echo "14. Add Exa MCP server to claudette instance:"
    echo "   claudette mcp add exa -e EXA_API_KEY=\$EXA_API_KEY -- npx -y exa-mcp-server"
    echo ""
    echo "15. Add Serena MCP server to claudette instance:"
    echo "   claudette mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project \$(pwd)"
    echo ""
    echo "16. Add Memory Bank MCP server to default Claude instance:"
    echo "   claude mcp add memory-bank -e MEMORY_BANK_ROOT=~/.claude_mem_bank -- npx -y @allpepper/memory-bank-mcp@latest"
    echo ""
    echo "17. Add Memory Bank MCP server to claudette instance:"
    echo "   claudette mcp add memory-bank -e MEMORY_BANK_ROOT=~/.claude_mem_bank -- npx -y @allpepper/memory-bank-mcp@latest"
    echo ""
    echo "18. Add MCP Knowledge Graph server to default Claude instance:"
    echo "   claude mcp add knowledge-graph -e AIM_DIRECTORY=~/.aim -- npx -y @modelcontextprotocol/server-knowledge-graph"
    echo ""
    echo "19. Add MCP Knowledge Graph server to claudette instance:"
    echo "   claudette mcp add knowledge-graph -e AIM_DIRECTORY=~/.aim -- npx -y @modelcontextprotocol/server-knowledge-graph"
    echo ""
    echo "20. Verify setup:"
    echo "   claude mcp list"
    echo "   claudette mcp list"
    echo ""
}

installApp() {
    echo "installing app $1"
    mas install "$2"
    echo "$1 installed successfully"
}

installApps() {
    # NOTE: You must be signed into the Mac App Store before running this script
    # Open the App Store app and sign in with your Apple ID first
    installApp "AdBlock Pro" 1018301773
    installApp "BetterSnapTool" 417375580
    installApp "Canva" 897446215
    installApp "Capital One Shopping" 1477110326
    installApp "ColorSlurp" 1287239339
    installApp "Creator's Best Friend" 1524172135
    installApp "Dark Reader for Safari" 1438243180
    installApp "Disk Diag" 672206759
    installApp "Grammarly for Safari" 1462114288
    installApp "hide.me" 953040671
    installApp "Image2Icon" 992115977
    installApp "Memory Diag" 748212890
    installApp "Numbers" 409203825
    installApp "PayPal Honey" 1472777122
    installApp "Screen-Timelapse-lite" 1452228487
    installApp "Spring" 1508706541
    installApp "Telegram" 747648890
    installApp "Things" 904280696
    installApp "Time Zone Converter and Clock" 1255311569
    installApp "TubeBuddy for YouTube" 1200948946
    installApp "Unzip - RAR ZIP 7Z Unarchiver" 1537056818
    installApp "Webcam Settings" 533696630
    installApp "Windows App" 1295203466
    installApp "Oanda" 370922777
    installApp "LumaFusion" 1062022008
    installApp "CapCut" 1500855883
    installApp "Claude by Anthropic" 6473753684
}

setup_zsh() {
    mkdir -p ~/.config/zsh && touch ~/.config/zsh/zimrc
    echo "installing zim"
    curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
}

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

    # === DEVELOPMENT SETUP ===
    # Create development directories
    mkdir -p ~/Dev
    mkdir -p ~/go
    mkdir -p ~/.claudette
    mkdir -p ~/.claude_mem_bank
    mkdir -p ~/.aim
    
    # Add Dev directory to Finder favorites
    sfltool add-item com.apple.LSSharedFileList.FavoriteItems file:///$HOME/Dev

    # Create claude-squad symlink for shorter command
    ln -sf "$(brew --prefix)/bin/claude-squad" "$(brew --prefix)/bin/cs"

    # Restart affected services
    killall Finder 2>/dev/null || true
    killall Dock 2>/dev/null || true
    killall SystemUIServer 2>/dev/null || true

    echo 'macOS preferences restored. Some changes may require logout/restart.'
}

xcode-select --install
install_homebrew
echo "Installing packages from Brewfile..."
brew bundle install
install_python_stuff
install_go_stuff
installApps
setup_zsh
setup_mcp_servers
restore_macos_preferences

# Configure PATH to prioritize Homebrew binaries
echo 'export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"' >>~/.zshrc
echo 'export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"' >>~/.bash_profile

echo 'eval "$(uv generate-shell-completion zsh)"' >>~/.zshrc
echo 'eval "$(uvx --generate-shell-completion zsh)"' >>~/.zshrc
echo 'eval "$(task --completion zsh)"' >>~/.zshrc

# setup starship
starship preset nerd-font-symbols -o ~/.config/starship.toml

# this will add the homebrew version of bash to the /etc/shells
which bash | sudo tee -a /etc/shells

install_kensington_konnect
install_adobe_dng_converter

echo ""
echo "=========================================="
echo "🚨 MANUAL INSTALLATION REMINDER 🚨"
echo "=========================================="
echo ""
echo "📱 RECUT - Video Editor"
echo "   This app must be requested from the developer"
echo "   Search 'recut' in takinprofit@gmail.com email account for your license key!"
echo "   License lookup: https://backend.getrecut.com/lookup/license"
echo ""
echo "✅ All automated installations complete!"
echo "Don't forget to install Recut manually!"
echo "=========================================="
echo ""
