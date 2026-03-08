#!/usr/bin/env bash

# TODO: Add daily API quota usage % once exposed in statusLine JSON.
# See: https://github.com/anthropics/claude-code/issues/5621
# See: https://github.com/anthropics/claude-code/issues/28999

input=$(cat)

# --- Data extraction ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
remaining_pct=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# --- Current directory (shorten $HOME to ~) ---
home="$HOME"
display_dir="${cwd/#$home/~}"

# --- Git branch (skip lock, best-effort) ---
git_branch=""
if [ -n "$cwd" ] && [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    git_branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
fi

# --- Token usage bar ---
token_info=""
if [ -n "$used_pct" ]; then
    # Round to integer
    used_int=$(printf "%.0f" "$used_pct")
    remaining_int=$(printf "%.0f" "${remaining_pct:-0}")
    token_info="${used_int}% used (${remaining_int}% left)"
fi

# --- Assembly ---
# Colors (ANSI; terminal will dim them further)
RESET="\033[0m"
CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[33m"
MAGENTA="\033[35m"
BLUE="\033[34m"
RED="\033[31m"

parts=()

# Current directory
if [ -n "$display_dir" ]; then
    parts+=("$(printf "${CYAN}%s${RESET}" "$display_dir")")
fi

# Git branch
if [ -n "$git_branch" ]; then
    parts+=("$(printf "${MAGENTA}(%s)${RESET}" "$git_branch")")
fi

# Model
if [ -n "$model" ]; then
    parts+=("$(printf "${BLUE}%s${RESET}" "$model")")
fi

# Token usage
if [ -n "$token_info" ]; then
    # Color based on usage level
    if [ "$used_int" -ge 80 ]; then
        parts+=("$(printf "${RED}%s${RESET}" "$token_info")")
    elif [ "$used_int" -ge 50 ]; then
        parts+=("$(printf "${YELLOW}%s${RESET}" "$token_info")")
    else
        parts+=("$(printf "${GREEN}%s${RESET}" "$token_info")")
    fi
fi

# Join with separator
sep="$(printf "${RESET} | ")"
result=""
for part in "${parts[@]}"; do
    if [ -z "$result" ]; then
        result="$part"
    else
        result="${result}${sep}${part}"
    fi
done

printf "%b\n" "$result"
