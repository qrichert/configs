if status is-interactive
    # Commands to run in interactive sessions can go here.

    # Remove login message.
    set -U fish_greeting

    # Vim mode.
    set -g fish_key_bindings fish_vi_key_bindings
    set fish_cursor_default block
    set fish_cursor_insert line
    set fish_cursor_replace_one underscore
    set fish_cursor_replace underscore
    set fish_cursor_external line
    set fish_cursor_visual block
    bind -M insert \cf forward-char # Re-enable <C-f> in Vim mode.
end

if command -v eza > /dev/null
    alias ls="eza"
end

if command -v bat > /dev/null
    alias cat="bat"
end

alias vim="nvim"
alias git="LANG=en_US.UTF-8 $(which git)"
alias gti="git"
alias pra="pre-commit run --all-files"
alias pr=":"
alias prettier="prettier --write --prose-wrap=always --print-width=72"

alias gs="git status"
alias gl="git ll"

export EDITOR=nvim
export LESSCHARSET="UTF-8"
export LESS="-R -F -X"
export PRE_COMMIT_ALLOW_NO_CONFIG=1
export CRONRUNNER_ENV="$HOME/.cron.env"

function history
    builtin history --show-time='%h/%d - %H:%M:%S ' | tail -r
end

fish_add_path "$HOME/.local/bin"
