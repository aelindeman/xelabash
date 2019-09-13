alias ls='ls -G'
alias la='ls -a'
alias ll='ls -lah'
alias l='ls'
alias sl='ls'

abspath() {
	echo "$(cd "$(dirname "$1")"; pwd -P)/$(basename "$1")"
}

mkpw() {
        LC_CTYPE=C tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "${1:-24}"; echo
}
