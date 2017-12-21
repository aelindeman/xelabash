#!/bin/bash

export HISTSIZE=
export HISTFILESIZE=
export HISTTIMEFORMAT='[%y-%m-%d %T] '
export HISTCONTROL=ignoreboth:erasedups

[ -f "$HOME/.profile" ] && source "$HOME/.profile"
[ -x "$(command -v brew)" ] && [ -f "$(brew --prefix)/etc/bash_completion" ] && source "$(brew --prefix)/etc/bash_completion"
[ -f "$HOME/.bash_aliases" ] && source "$HOME/.bash_aliases"

function __set_default_prompt {
  PS1_LAST_EXIT="$?"
  PS1_PREFIX='\[\e]0;\w\a\]'
  PS1_INNER='\[\e[1m\]\w\[\e[0m\]'
  PS1_SUFFIX=' \$ '
}

function __add_git_to_prompt {
  [ -x "$(command -v git)" ] || return 0
  local __git_prompt
  local __git_prompt_branch
  local __git_prompt_status_count

  if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = 'true' ] || [ "$(git rev-parse --is-inside-git-dir 2>/dev/null)" = 'true' ]; then
    __git_prompt_branch="$(git rev-parse --abbrev-ref HEAD)"
    [ -z "$__git_prompt_branch" ] && __git_prompt_branch='(no branch)'
    if [ "$(git rev-parse --is-inside-git-dir 2>/dev/null)" != 'true' ]; then
      __git_prompt_status_count="$(git status --porcelain | wc -l)"
    fi
  elif [ "$(git rev-parse --is-bare-repository 2>/dev/null)" = 'true' ]; then
    __git_prompt_branch='(bare repo)'
  fi

  if [ ! -z "$__git_prompt_branch" ]; then
    if [ "${__git_prompt_status_count:-0}" -gt 0 ]; then
      __git_prompt="\[\e[1;33m\]${__git_prompt_branch}*\[\e[0m\]"
    else
      __git_prompt="\[\e[36m\]${__git_prompt_branch}\[\e[0m\]"
    fi
    PS1_INNER="${PS1_INNER} ${__git_prompt}"
  fi
}

function __add_exit_code_to_prompt {
  [ "$PS1_LAST_EXIT" != '0' ] && PS1_SUFFIX="\[\e[31m\]${PS1_SUFFIX}\[\e[0m\]"
}

function __add_ssh_to_prompt {
  if [ ! -z "$SSH_CONNECTION" ]; then
    PS1_PREFIX='\[\e]0;\u@\h \w\a\]'
    PS1_INNER="\[\e[2m\]\u@\h\[\e[0m\] ${PS1_INNER}"
  fi
}

function __set_prompt {
  history -a
  __set_default_prompt
  __add_exit_code_to_prompt
  __add_ssh_to_prompt
  __add_git_to_prompt
  export PS1="${PS1_PREFIX}${PS1_INNER}${PS1_SUFFIX}"
}

PROMPT_COMMAND='__set_prompt'
