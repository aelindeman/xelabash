# shellcheck shell=bash source="$HOME"

case "$(__xelabash_os)" in
  *bsd|bsd*|darwin*)
    alias ls='ls -G'
    ;;
  linux*)
    alias ls='ls --color=if-tty'
    ;;
esac

alias la='ls -a'
alias ll='ls -lah'
alias l='ls'
alias sl='ls'
