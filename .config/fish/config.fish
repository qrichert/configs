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

alias vim="nvim"
alias git="LANG=en_US.UTF-8 $(which git)"
alias gti="git"
alias pra="pre-commit run --all-files"
alias pr=":"
alias prettier="prettier --prose-wrap=always --print-width=72 --write"

export EDITOR=nvim
export PRE_COMMIT_ALLOW_NO_CONFIG=1

function history
    builtin history --show-time='%h/%d - %H:%M:%S ' | tail -r
end
