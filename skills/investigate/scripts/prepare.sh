#!/usr/bin/env bash
# Prints the chair, the current session's transcript location and past timeouts for this
# project. Always exits 0: a non-zero exit would abort the
# skill, and a missing transcript is a case the skill handles.
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
state="${XDG_STATE_HOME:-$HOME/.local/state}/timeout-chair"
session="${CLAUDE_CODE_SESSION_ID:-}"

project="$("$dir/../../scripts/project-hash.sh")"

echo "CHAIR:"
cat "$dir/art/chair.txt"
echo "END_CHAIR"

transcript=""
if [ -n "$session" ]; then
  for f in "$config"/projects/*/"$session".jsonl; do
    [ -f "$f" ] && transcript="$f" && break
  done
fi

echo "SESSION_ID: ${session:-UNKNOWN}"
if [ -n "$transcript" ]; then
  echo "TRANSCRIPT: $transcript"
  sidecar="${transcript%.jsonl}"
  [ -d "$sidecar" ] && echo "SIDECAR_DIR: $sidecar"
elif [ -z "$session" ]; then
  echo "TRANSCRIPT: SESSION_ID_MISSING"
else
  echo "TRANSCRIPT: NOT_FOUND"
fi
echo "WORKING_DIR: $(pwd)"

echo "PAST_TIMEOUTS:"
if [ -f "$state/log.jsonl" ]; then
  grep -F "\"project\":\"$project\"" "$state/log.jsonl" | tail -n 20
fi
echo "END_PAST_TIMEOUTS"
exit 0
