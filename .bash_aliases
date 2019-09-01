alias ls='ls -G'
alias la='ls -a'
alias ll='ls -l'
alias l='ls'
alias sl='ls'

abspath() {
	echo "$(cd "$(dirname "$1")"; pwd -P)/$(basename "$1")"
}
