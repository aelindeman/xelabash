# shellcheck shell=bash source="$HOME"

case "$(uname | tr '[:upper:]' '[:lower:]')" in
  *bsd|bsd*|darwin*)
    alias ls='ls -G'
    ;;
  linux*)
    alias ls='ls --color=if-tty'
    alias grep=''
    alias egrep=''
    ;;
esac

alias la='ls -a'
alias ll='ls -lah'
alias l='ls'
alias sl='ls'

exportfile() {
  # shellcheck disable=SC2046
  export $(grep -v '^#' "${1:-.env}" | xargs)
}
