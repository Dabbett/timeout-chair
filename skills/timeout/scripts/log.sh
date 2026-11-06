#!/usr/bin/env bash
# Appends one verdict to the local timeout log. Usage:
#   log.sh <verdict> <class> <level 0-7> <target> <status>
# Fields are validated so transcript text can never reach the log. No quotes
# from the session are stored.
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
target="$(printf '%s' "$target" | tr -cd 'A-Za-z0-9._/~-' | cut -c1-120)"

hash_cmd() { if command -v shasum >/dev/null 2>&1; then shasum; else sha1sum; fi; }
project="$(pwd | hash_cmd | cut -c1-12)"
state="${XDG_STATE_HOME:-$HOME/.local/state}/timeout-chair"
mkdir -p "$state"
chmod 700 "$state"
printf '{"date":"%s","project":"%s","verdict":"%s","class":"%s","level":%s,"target":"%s","status":"%s"}\n' \
  "$(date -u +%Y-%m-%d)" "$project" "$verdict" "$class" "$level" "$target" "$status" >> "$state/log.jsonl"
echo "logged"
