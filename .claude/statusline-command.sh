#!/usr/bin/env bash

# --- Data extraction ---
# One line per field; `// ""` keeps absent fields as empty lines so the
# reads stay aligned. Percentages arrive rounded.
{
    read -r cwd
    read -r model
    read -r effort
    read -r context_pct
    read -r five_hour_pct
    read -r seven_day_pct
} <<<"$(jq -r '
    .workspace.current_dir // .cwd // "",
    .model.display_name // "",
    .effort.level // "",
    (.context_window.used_percentage | numbers | round) // "",
    (.rate_limits.five_hour.used_percentage | numbers | round) // "",
    (.rate_limits.seven_day.used_percentage | numbers | round) // ""
')"

# --- Git branch, or short commit when detached (skip lock, best-effort) ---
git_branch=""
if [ -n "$cwd" ]; then
    git_branch=$(
        export GIT_OPTIONAL_LOCKS=0
        git -C "$cwd" symbolic-ref --short -q HEAD 2>/dev/null ||
            git -C "$cwd" rev-parse --short HEAD 2>/dev/null
    )
fi

# --- Model, with reasoning effort when the model supports it ---
model="${model}${effort:+ $effort}"

# --- Usage: context window, then 5-hour and 7-day rate limits ---
# Entries are "<percentage>|<text>". Rate limits exist only on Pro, Max and
# Ultra plans, from the session's first response on.
usage=()
[ -n "$context_pct" ] && usage+=("$context_pct|ctx ${context_pct}%")
[ -n "$five_hour_pct" ] && usage+=("$five_hour_pct|5h ${five_hour_pct}%")
[ -n "$seven_day_pct" ] && usage+=("$seven_day_pct|7d ${seven_day_pct}%")

# --- Current directory (shorten $HOME to ~, then fit to terminal width) ---
home="$HOME"
display_dir="${cwd/#$home/\~}"

# Width of the segments after the directory, " | " separators included.
rest_width=0
[ -n "$git_branch" ] && rest_width=$((rest_width + ${#git_branch} + 2 + 3))
[ -n "$model" ] && rest_width=$((rest_width + ${#model} + 3))
for entry in "${usage[@]}"; do
    text=${entry#*|}
    rest_width=$((rest_width + ${#text} + 3))
done

# Too wide: abbreviate parent directories fish-style (one letter, two for
# dot directories), then fall back to the last directory alone. The 2-column
# margin is a guess at Claude Code's own indent.
max_width=$((${COLUMNS:-0} - 2))
if [ -n "$COLUMNS" ] && ((${#display_dir} + rest_width > max_width)); then
    parent_dir=${display_dir%/*}
    if [[ $display_dir == */* && -n $parent_dir ]]; then
        abbreviated=""
        IFS=/ read -ra parents <<<"$parent_dir"
        for parent in "${parents[@]}"; do
            if [[ $parent == .* ]]; then
                abbreviated+="${parent:0:2}/"
            else
                abbreviated+="${parent:0:1}/"
            fi
        done
        display_dir="${abbreviated}${display_dir##*/}"
    fi
    if ((${#display_dir} + rest_width > max_width)) && [ -n "${display_dir##*/}" ]; then
        display_dir=${display_dir##*/}
    fi
fi

# Too wide with the shortest directory: cut the end of the branch to fit,
# keeping at least 8 characters so it stays recognizable.
line_width=$((${#display_dir} + rest_width))
if [ -n "$COLUMNS" ] && [ -n "$git_branch" ] && ((line_width > max_width)); then
    branch_room=$((${#git_branch} - (line_width - max_width) - 1))
    ((branch_room < 8)) && branch_room=8
    if ((branch_room < ${#git_branch})); then
        git_branch="${git_branch:0:branch_room}…"
    fi
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

# Usage, colored by level
for entry in "${usage[@]}"; do
    pct=${entry%%|*}
    if [ "$pct" -ge 80 ]; then
        color=$RED
    elif [ "$pct" -ge 50 ]; then
        color=$YELLOW
    else
        color=$GREEN
    fi
    parts+=("${color}${entry#*|}${RESET}")
done

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
