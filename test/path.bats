#!/usr/bin/env bats

load test_helpers

@test "__xelabash_path should be the correct path" {
  [ "$(__xelabash_path)" = "$PWD/xela.bash" ]
}
