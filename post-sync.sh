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
