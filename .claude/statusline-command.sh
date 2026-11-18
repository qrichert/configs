#!/usr/bin/env bash

# TODO: Add daily API quota usage % once exposed in statusLine JSON.
# See: https://github.com/anthropics/claude-code/issues/5621
# See: https://github.com/anthropics/claude-code/issues/28999

# --- Data extraction ---
# One line per field; `// ""` keeps absent fields as empty lines so the
# reads stay aligned.
{
    read -r cwd
    read -r model
    read -r used_pct
} <<<"$(jq -r '
    .workspace.current_dir // .cwd // "",
    .model.display_name // "",
    .context_window.used_percentage // ""
')"

# --- Current directory (shorten $HOME to ~) ---
home="$HOME"
display_dir="${cwd/#$home/\~}"

# --- Git branch, or short commit when detached (skip lock, best-effort) ---
git_branch=""
if [ -n "$cwd" ]; then
    git_branch=$(
        export GIT_OPTIONAL_LOCKS=0
        git -C "$cwd" symbolic-ref --short -q HEAD 2>/dev/null ||
            git -C "$cwd" rev-parse --short HEAD 2>/dev/null
    )
fi

# --- Token usage bar ---
token_info=""
if [ -n "$used_pct" ]; then
    # Round to integer
    printf -v used_int "%.0f" "$used_pct"
    token_info="${used_int}% used"
fi

# --- Assembly ---
# Colors (ANSI; terminal will dim them further)
RESET=$'\e[0m'
CYAN=$'\e[36m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
MAGENTA=$'\e[35m'
BLUE=$'\e[34m'
RED=$'\e[31m'

parts=()

# Current directory
if [ -n "$display_dir" ]; then
    parts+=("${CYAN}${display_dir}${RESET}")
fi

# Git branch
if [ -n "$git_branch" ]; then
    parts+=("${MAGENTA}(${git_branch})${RESET}")
fi

# Model
if [ -n "$model" ]; then
    parts+=("${BLUE}${model}${RESET}")
fi

# Token usage
if [ -n "$token_info" ]; then
    # Color based on usage level
    if [ "$used_int" -ge 80 ]; then
        parts+=("${RED}${token_info}${RESET}")
    elif [ "$used_int" -ge 50 ]; then
        parts+=("${YELLOW}${token_info}${RESET}")
    else
        parts+=("${GREEN}${token_info}${RESET}")
    fi
fi

# Join with separator
sep=" | "
result=""
for part in "${parts[@]}"; do
    if [ -z "$result" ]; then
        result="$part"
    else
        result="${result}${sep}${part}"
    fi
done

printf "%s\n" "$result"
