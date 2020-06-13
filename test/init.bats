#!/usr/bin/env bats

load test_helpers

setup() {
  export PROMPT_COMMAND_ORIGINAL="$PROMPT_COMMAND"
  export PS1_ORIGINAL="$PS1"
}

teardown() {
  PROMPT_COMMAND="$PROMPT_COMMAND_ORIGINAL"
  unset PROMPT_COMMAND_ORIGINAL
  PS1="$PS1_ORIGINAL"
  unset PS1_ORIGINAL
}

@test "__xelabash_init should set PROMPT_COMMAND to __xelabash_prompt if the terminal is interactive" {
  PROMPT_COMMAND=''
  PS1='\$ ' __xelabash_init
  [[ "$PROMPT_COMMAND" = '__xelabash_prompt' ]]
}

@test "__xelabash_init should prepend __xelabash_prompt to PROMPT_COMMAND if the terminal is interactive" {
  PROMPT_COMMAND='foo'
  PS1='\$ ' __xelabash_init
  [[ "$PROMPT_COMMAND" = '__xelabash_prompt; foo' ]]
}

@test "__xelabash_init should not touch PROMPT_COMMAND if the terminal is non-interactive" {
  PROMPT_COMMAND='foo'
  unset PS1; __xelabash_init
  [[ "$PROMPT_COMMAND" = 'foo' ]]
}
