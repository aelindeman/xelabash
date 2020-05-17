# shellcheck shell=bash source="$HOME"

# load extra profile files
for f in "$HOME/.profile" "$HOME/.bash_aliases"; do
  if [ -f "$f" ]; then
    source "$f"
  fi
done

# only set the rest up if this is an interactive shell
if [ -n "$PS1" ]; then

  # Apple Terminal has some path and session handling tweaks, so don't lose them if we can use them
  if [ "$TERM_PROGRAM" = 'Apple_Terminal' ]; then
    __xelabash_is_apple_terminal=true
  fi

  # set up the prompt
  __xelabash_set_default_prompt() {
    PS1_LAST_EXIT="$?"
    PS1_PREFIX=''
    if [ -z "$__xelabash_is_apple_terminal" ]; then
      PS1_PREFIX='\[\e]0;\w\a\]'
    fi
    PS1_INNER='\[\e[1m\]\w\[\e[0m\]'
    PS1_SUFFIX=' \$ '
  }

  # check if required tools are available
  __xelabash_git_bin="$(command -v git)"
  __xelabash_kubectl_bin="$(command -v kubectl)"

  # configure bash history
  if [ -z "$__xelabash_is_apple_terminal" ]; then
    export HISTCONTROL=ignoreboth:erasedups
    export HISTTIMEFORMAT='[%Y-%m-%d %T] '
    shopt -s histappend
  fi

  # load bash-completion from Homebrew, if it's installed
  if [ -x "$(command -v brew)" ] && [ -f "$(brew --prefix)/etc/bash_completion" ]; then
    source "$(brew --prefix)/etc/bash_completion"
  fi

  # make bash-completion suck less
  bind 'set colored-stats on'
  bind 'set colored-completion-prefix on'
  bind 'set completion-ignore-case on'
  bind 'set completion-map-case on'
  bind 'set expand-tilde on'
  bind 'set mark-directories on'
  bind 'set mark-symlinked-directories on'
  bind 'set show-all-if-ambiguous on'
  bind 'set show-all-if-unmodified on'
  bind 'set skip-completed-text on'

  # make some programs behave better on window resize
  shopt -s checkwinsize

  # display git branch and repo state asterisk after path, if inside of a repository
  __xelabash_add_git_to_prompt() {
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
      PS1_INNER="${PS1_INNER:-} ${__git_prompt}"
    fi
  }

  # append kubernetes context name and namespace
  __xelabash_add_kube_to_prompt() {
    local __kube_context
    local __kube_namespace

    __kube_context="$(kubectl config view -o=jsonpath='{.current-context}')"
    __kube_namespace="$(kubectl config view -o=jsonpath="{.contexts[?(@.name==\"${__kube_context}\")].context.namespace}")"
    if [ -n "$__kube_namespace" ]; then
      __kube_prompt="${__kube_context}:${__kube_namespace}"
    else
      __kube_prompt="${__kube_context}"
    fi
    PS1_INNER="${PS1_INNER:-} \[\e[34m\]${__kube_prompt}\[\e[0m\]"
  }

  # make the prompt suffix red if the previous command failed
  __xelabash_add_exit_code_to_prompt() {
    [ "$PS1_LAST_EXIT" -ne 0 ] && PS1_SUFFIX="\[\e[31m\]${PS1_SUFFIX}\[\e[0m\]"
  }

  # prepend user@hostname to prompt, if connected via ssh
  __xelabash_add_ssh_to_prompt() {
    if [ -n "$SSH_CONNECTION" ]; then
      PS1_PREFIX='\[\e]0;\u@\h \w\a\]'
      PS1_INNER="\[\e[2m\]\u@\h\[\e[0m\] ${PS1_INNER}"
    fi
  }

  # set the prompt
  __xelabash() {
    __xelabash_set_default_prompt
    __xelabash_add_exit_code_to_prompt
    __xelabash_add_ssh_to_prompt
    [ -n "$GIT_PROMPT" ] && [ "$__xelabash_git_bin" ] && __xelabash_add_git_to_prompt
    [ -n "$KUBE_PROMPT" ] && [ -n "$__xelabash_kubectl_bin" ] && __xelabash_add_kube_to_prompt  # disabled by default
    export PS1="${PS1_PREFIX:-}${PS1_INNER:-}${PS1_SUFFIX:-}"
    history -a
  }

  if [ -z "$__xelabash_is_apple_terminal" ]; then
    PROMPT_COMMAND='__xelabash'
  else
    PROMPT_COMMAND="__xelabash${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
  fi
fi
