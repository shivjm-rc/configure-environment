#!/usr/bin/env zsh

# Loosely based on https://github.com/olets/zsh-window-title/blob/0253f338b3ef74f3e3c2e833b906c602c94552a7/zsh-window-title.zsh

local WINDOW_TITLE_CWD_DEPTH=0

function shivjm:update_window_title_precmd(){
    local title=$(print -P "%$WINDOW_TITLE_CWD_DEPTH~")
    echo -ne "\033]0;$title\007"
}

precmd_functions+=(shivjm:update_window_title_precmd)

function shivjm:update_window_title_preexec(){
    local current_command="${1[(w)1]}"

    if [[ $current_command == "sudo" ]]; then
        current_command+=" ${1[(w)2]}"
    fi

    local title=$(print -P "%$WINDOW_TITLE_CWD_DEPTH~ - $current_command")
    echo -ne "\033]0;$title\007"
}

preexec_functions+=(shivjm:update_window_title_preexec)
