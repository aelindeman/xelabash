#!/usr/bin/env bats

load test_helpers

setup() {
  export TERM_PROGRAM_ORIGINAL="$TERM_PROGRAM"
}

teardown() {
  TERM_PROGRAM="$TERM_PROGRAM_ORIGINAL"
  unset TERM_PROGRAM_ORIGINAL
}

@test "__xelabash_is_apple_terminal should return 0 if TERM_PROGRAM is set to 'Apple_Terminal'" {
  TERM_PROGRAM='Apple_Terminal'
  if __xelabash_is_apple_terminal; then result='ok'; fi
  [ "$result" = 'ok' ]

}

@test "__xelabash_is_apple_terminal should return 1 TERM_PROGRAM is set to 'Apple_Terminal'" {
  TERM_PROGRAM='nope'
  if ! __xelabash_is_apple_terminal; then result='ok'; fi
  [ "$result" = 'ok' ]
}
