#!/usr/bin/env bash
# Appends one verdict to the local timeout log. Usage:
#   log.sh <verdict> <class> <level 0-7> <target> <status>
# Every field is limited to a fixed list, so session text cannot reach the log.
# Any target other than a known config file is stored as "other".
set -eu
[ "$#" -eq 5 ] || { echo "usage: log.sh verdict class level target status" >&2; exit 2; }
verdict="$1"; class="$2"; level="$3"; target="$4"; status="$5"

case "$verdict" in MODEL|SETUP|PROMPT|MIXED|NO_ERROR|UNDETERMINED) ;; *) echo "bad verdict" >&2; exit 2;; esac
case "$class" in
  phantom-verification|gamed-check|partial-report|scope-creep|ignored-instruction|\
  fabrication|unauthorized-destruction|control-evasion|retry-loop|context-loss|\
  sycophantic-capitulation|unchecked-assumption|none) ;;
  *) echo "bad class" >&2; exit 2;;
esac
case "$level" in [0-7]) ;; *) echo "bad level" >&2; exit 2;; esac
case "$status" in proposed|applied|declined|none) ;; *) echo "bad status" >&2; exit 2;; esac
case "${target##*/}" in
  CLAUDE.md|settings.json|settings.local.json|none) target="${target##*/}" ;;
  *) target="other" ;;
esac

project="$("$(dirname "${BASH_SOURCE[0]}")/../../../scripts/project-hash.sh")"
state="${XDG_STATE_HOME:-$HOME/.local/state}/timeout-chair"
mkdir -p "$state"
chmod 700 "$state"
printf '{"date":"%s","project":"%s","verdict":"%s","class":"%s","level":%s,"target":"%s","status":"%s"}\n' \
  "$(date -u +%Y-%m-%d)" "$project" "$verdict" "$class" "$level" "$target" "$status" >> "$state/log.jsonl"
echo "logged"
