#!/bin/bash

# export HISTSIZE=1000000
# export HISTTIMEFORMAT="%y-%m-%d %T "
# export HISTCONTROL=ignoreboth:erasedups

[ -f "$HOME/.profile" ] && . "$HOME/.profile"
[ -x '$(command -v brew)' ] && [ -f "$(brew --prefix)/etc/bash_completion" ] && . "$(brew --prefix)/etc/bash_completion"
[ -f "$HOME/.bash_aliases" ] && . "$HOME/.bash_aliases"

function __set_default_prompt {
  PS1_LAST_EXIT="$?"
  PS1_PREFIX='\[\e]0;\w\a\]'
  PS1_INNER='\[\e[1m\]\w\[\e[0m\]'
  PS1_SUFFIX=' \$ '
}

function __add_git_to_prompt {
  local __git_prompt_branch
  local __git_prompt_status
  __git_prompt_branch="$(git branch | grep '\*' | cut -d ' ' -f2-)"
  [ -z "$__git_prompt_branch" ] && __git_prompt_branch='(no branch)'

  __git_prompt_status="$(git status --porcelain | awk '{print $1}' | sort -u | paste -sd ',' -)"
  if [ ! -z "$__git_prompt_status" ]; then
    __git_prompt_branch="\[\e[1;33m\]${__git_prompt_branch}*\[\e[0m\]"
  else
    __git_prompt_branch="\[\e[36m\]${__git_prompt_branch}\[\e[0m\]"
  fi

  PS1_INNER+=" ${__git_prompt_branch}"
}

function __add_exit_code_to_prompt {
  [ "$PS1_LAST_EXIT" != '0' ] && PS1_SUFFIX="\[\e[31m\]${PS1_SUFFIX}\[\e[0m\]"
}

function __add_ssh_to_prompt {
  PS1_PREFIX='\[\e]0;\u@\h \w\a\]'
  PS1_INNER="\[\e[2m\]\u@\h\[\e[0m\] ${PS1_INNER}"
}

function __set_prompt {
  __set_default_prompt
  __add_exit_code_to_prompt
  [ ! -z "$SSH_CONNECTION" ] && __add_ssh_to_prompt
  [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" ] && __add_git_to_prompt
  export PS1="${PS1_PREFIX}${PS1_INNER}${PS1_SUFFIX}"
}

PROMPT_COMMAND='__set_prompt'
