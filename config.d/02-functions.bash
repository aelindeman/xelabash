# shellcheck shell=bash source="$HOME"

exportfile() {
  # shellcheck disable=SC2046
  export $(grep -v '^#' "${1:-.env}" | xargs)
}
