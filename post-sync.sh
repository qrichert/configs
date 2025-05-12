#!/usr/bin/env bash

# Source machine-specific values (home, work, server, etc.).
[[ -f ~/.deezenv ]] && . ~/.deezenv

# Set global Git email address.
[[ -n $DEEZ_VERBOSE ]] && echo "Set global Git email address."
git config --global user.email ${EMAIL:-quentin@richert.co}

# Add local fish config.
if [[ -f ~/.deezfish.fish ]]; then
    [[ -n $DEEZ_VERBOSE ]] && echo "Add local fish config."
    echo -e "\n# <deez>\n" >> ~/.config/fish/config.fish
    cat ~/.deezfish.fish >> ~/.config/fish/config.fish
fi

# Alias SSH terminfo for Ghostty.
if ! grep -qF "SetEnv TERM=xterm-256color" ~/.ssh/config; then
    [[ -n $DEEZ_VERBOSE ]] && echo "Alias SSH terminfo for Ghostty."
    echo "" >> ~/.ssh/config
    cat ./.config/ghostty/ssh.txt >> ~/.ssh/config
fi

# Install essential software if `$DEEZ_INSTALL_ESSENTIALS` is set.
# Additional software can be installed in desktop environments with
# `$DEEZ_INSTALL_DESKTOP`.
if [[ -n $DEEZ_INSTALL_ESSENTIALS ]]; then
    echo  "Installing essential software..."

    . ./software.sh

    # Some programs are only available through `cargo install`.
    if ! command -v cargo > /dev/null 2>&1; then
        read -p "Some tools require Rust to build. Install Rust? " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        fi
    fi

    # Install for macOS.
    if [[ $DEEZ_OS == "macos" ]]; then
        brew install $MACOS_BREW

        if [[ -n $DEEZ_INSTALL_DESKTOP ]]; then
            brew install --cask $MACOS_BREW_DESKTOP
        fi

        if command -v cargo > /dev/null 2>&1; then
            cargo install --locked $MACOS_CARGO
        fi

    # Install for Linux.
    elif [[ $DEEZ_OS == "linux" ]]; then
        sudo snap install $LINUX_SNAP

        if [[ -n $DEEZ_INSTALL_DESKTOP ]]; then
            sudo snap install --classic $LINUX_SNAP_DESKTOP
        fi

        sudo apt install -y $LINUX_APT
        sudo ln -sf $(which fdfind) $(dirname $(which fdfind))/fd

        if command -v cargo > /dev/null 2>&1; then
            cargo install --locked $LINUX_CARGO
        fi
    fi
fi
