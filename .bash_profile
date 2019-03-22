# load extra profile files
for f in "$HOME/.profile" "$HOME/.bash_aliases"; do
  if [ -f "$f" ]; then
    source "$f"
  fi
done

# check if required tools are available
__git_bin="$(command -v git)"
__kubectl_bin="$(command -v kubectl)"

# only set the rest up if this is an interactive shell
if [ -n "$PS1" ]; then

  # configure bash history
  export HISTSIZE=
  export HISTFILESIZE=
  export HISTTIMEFORMAT='[%y-%m-%d %T] '
  export HISTCONTROL=ignoreboth:erasedups
  shopt -s histappend

  # load bash-completion from Homebrew, if it's installed
  if [ -x "$(command -v brew)" ] && [ -f "$(brew --prefix)/etc/bash_completion" ]; then
    source "$(brew --prefix)/etc/bash_completion"
  fi

  # make bash-completion suck less
  bind 'set colored-stats on'
  bind 'set completion-ignore-case on'
  bind 'set expand-tilde on'
  bind 'set mark-directories on'
  bind 'set mark-symlinked-directories on'
  bind 'set show-all-if-ambiguous on'
  bind 'set show-all-if-unmodified on'
  bind 'set skip-completed-text on'

  # make some programs behave better on window resize
  shopt -s checkwinsize

  # set up the prompt
  __set_default_prompt() {
    PS1_LAST_EXIT="$?"
    PS1_PREFIX='\[\e]0;\w\a\]'
    PS1_INNER='\[\e[1m\]\w\[\e[0m\]'
    PS1_SUFFIX=' \$ '
  }

  # display git branch and repo state asterisk after path, if inside of a repository
  __add_git_to_prompt() {
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

    if [ -n "$__git_prompt_branch" ]; then
      if [ "${__git_prompt_status_count:-0}" -gt 0 ]; then
        __git_prompt="\[\e[1;33m\]${__git_prompt_branch}*\[\e[0m\]"
      else
        __git_prompt="\[\e[36m\]${__git_prompt_branch}\[\e[0m\]"
      fi
      PS1_INNER="${PS1_INNER} ${__git_prompt}"
    fi
  }

  # append kubernetes context name and namespace
  __add_kube_to_prompt() {
    local __kube_context
    local __kube_namespace

    __kube_context="$(kubectl config view -o=jsonpath='{.current-context}')"
    __kube_namespace="$(kubectl config view -o=jsonpath="{.contexts[?(@.name==\"${__kube_context}\")].context.namespace}")"
    if [ -n "$__kube_namespace" ]; then
      __kube_prompt="${__kube_context}:${__kube_namespace}"
    else
      __kube_prompt="${__kube_context}"
    fi
    PS1_INNER="${PS1_INNER} \[\e[34m\]${__kube_prompt}\[\e[0m\]"
  }

  # make the prompt suffix red if the previous command failed
  __add_exit_code_to_prompt() {
    [ "$PS1_LAST_EXIT" != '0' ] && PS1_SUFFIX="\[\e[31m\]${PS1_SUFFIX}\[\e[0m\]"
  }

  # prepend user@hostname to prompt, if connected via ssh
  __add_ssh_to_prompt() {
    if [ -n "$SSH_CONNECTION" ]; then
      PS1_PREFIX='\[\e]0;\u@\h \w\a\]'
      PS1_INNER="\[\e[2m\]\u@\h\[\e[0m\] ${PS1_INNER}"
    fi
  }

  # set the prompt
  __set_prompt() {
    history -a
    __set_default_prompt
    __add_exit_code_to_prompt
    __add_ssh_to_prompt
    [ -n "$__git_bin" ] && __add_git_to_prompt
    [ -n "$__kubectl_bin" ] && __add_kube_to_prompt
    export PS1="${PS1_PREFIX}${PS1_INNER}${PS1_SUFFIX}"
  }

  PROMPT_COMMAND='__set_prompt'
fi
