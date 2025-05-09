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
if [[ -n $DEEZ_INSTALL_ESSENTIALS ]]; then
    echo  "Installing essential software..."

    # Install for macOS.
    if [[ $DEEZ_OS == "macos" ]]; then
        echo "mac"

    # Install for Linux.
    elif [[ $DEEZ_OS == "linux" ]]; then
        sudo snap install \
            httpie \
            nvim \
            ;
        if [[ -n $DEEZ_INSTALL_DESKTOP ]]; then
            sudo snap install \
                ghostty \
                ;
        fi
        sudo apt install -y \
            bat \
            exa \
            fd-find \
            htop \
            ncdu \
            ripgrep \
            ;
        sudo ln -sf $(which fdfind) $(dirname $(which fdfind))/fd
    fi

    # The following programs are not available in package managers, and
    # thus need to be built.
    if ! command -v cargo > /dev/null 2>&1; then
        read -p "Some tools require Rust to build. Install Rust? " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        fi
    fi
    if command -v cargo > /dev/null 2>&1; then
        cargo install --locked \
            cronrunner \
            ports \
            tealdeer \
            ;
    fi
fi
