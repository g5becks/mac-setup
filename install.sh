#!/usr/bin/env bash

xcode-select --install

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
    install_with_pipx djlint
    install_with_pipx sourcery
    install_with_pipx textlsp
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

install_with_npm() {
    echo "attempting to install $1 with npm"
    npm i -g "$1"
    echo "$1 installed successfully"
}

install_npm_globals() {
    install_with_npm "svelte-language-server"
}

installApp() {
    echo "installing app $1"
    mas install "$2"
    echo "$1 installed successfully"
}

installApps() {
    installApp "canva" 89744621
    installApp "Creator's Best Friend" 1524172135
    installApp "Things 3" 904280696
    installApp "Spring for Twitter" 1508706541
    installApp "Screen Timelapse" 1452228487
    installApp "Adblock pro" 1018301773
    installApp "Honey safari" 1472777122
    installApp "ColorSlurp" 1287239339
    installApp "Color2Icon" 992115977
    installApp "Disk Diag" 672206759
    installApp "Better Snap Tool" 417375580
    installApp "Windows App" 1295203466
    installApp "Oanda" 370922777
    installApp "LumaFusion" 1062022008

}

setup_zsh() {
    mkdir -p ~/.config/zsh && touch ~/.config/zsh/zimrc
    echo "installing zim"
    curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
}

install_homebrew
install_lit
install_python_stuff
install_go_stuff
install_npm_globals
setup_zsh

echo 'eval "$(uv generate-shell-completion zsh)"' >>~/.zshrc
echo 'eval "$(uvx --generate-shell-completion zsh)"' >>~/.zshrc
eval "$(task --completion zsh)"

# setup starship
starship preset nerd-font-symbols -o ~/.config/starship.toml

# this will add the homebrew version of bash to the /etc/shells
which bash | sudo tee -a /etc/shells
# add fish to /etc/shells
which fish | sudo tee -a /etc/shells
