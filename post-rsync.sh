#!/usr/bin/env bash

# Portable version of `sed`.
sed_inplace() {
    sed -i.bak "$@" && rm "${@: -1}.bak"
}

# Unset Git email address.
[[ -n $DEEZ_VERBOSE ]] && echo "Unset Git email address."
git config --file ./.gitconfig user.email '<>'

# Remove local fish config.
[[ -n $DEEZ_VERBOSE ]] && echo "Remove local fish config."
sed_inplace '/^# <deez>$/,$d' ./.config/fish/config.fish
sed_inplace '${/^$/d;}' ./.config/fish/config.fish
