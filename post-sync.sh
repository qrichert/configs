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

# Trim Neovim config on low-powered machines.
nb_cpu_cores=$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 0)
if (( $nb_cpu_cores < 2 )); then
    [[ -n $DEEZ_VERBOSE ]] && echo "Low-powered machine: trimming Neovim \`init.lua\` to minimal config."
    sed '/-- END OF MINIMAL CONFIG --/q' ~/.config/nvim/init.lua > /tmp/init.lua
    mv /tmp/init.lua ~/.config/nvim/init.lua
fi

# Alias SSH terminfo for Ghostty.
if ! grep -qF "SetEnv TERM=xterm-256color" ~/.ssh/config; then
    [[ -n $DEEZ_VERBOSE ]] && echo "Alias SSH terminfo for Ghostty."
    echo "" >> ~/.ssh/config
    cat ./.config/ghostty/ssh.txt >> ~/.ssh/config
fi
