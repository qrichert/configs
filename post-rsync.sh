#!/usr/bin/env bash

# Unset Git email address.
[[ -n $DEEZ_VERBOSE ]] && echo "Unset Git email address."
git config --file ./.gitconfig user.email '<>'
