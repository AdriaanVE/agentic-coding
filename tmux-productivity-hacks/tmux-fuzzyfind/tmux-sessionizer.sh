#!/usr/bin/env -S TERMINFO=/usr/share/terminfo TERM=xterm-256color bash

PROJECT_DIRS=(
    "$HOME/Code"
    "$HOME/projects"
)

tmux_cmd() {
    TERM="xterm-256color" command tmux "$@"
}

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find "${PROJECT_DIRS[@]}" -mindepth 1 -maxdepth 1 -type d | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=${selected##*/}
selected_name=${selected_name:0:20}
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux_cmd new-session -s $selected_name -c $selected
    exit 0
fi
if ! tmux_cmd has-session -t=$selected_name 2> /dev/null; then
    tmux_cmd new-session -ds $selected_name -c $selected
fi
if [[ -z $TMUX ]]; then
    tmux_cmd attach -t $selected_name \; run-shell "printf '\\033]0;$selected_name\\007'"
else
    tmux_cmd switch-client -t $selected_name
    printf '\033]0;%s\007' "$selected_name"
fi
