#!/usr/bin/env bash
# Tests the plugin's shell scripts. No model calls.
set -u
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"; export XDG_STATE_HOME="$tmp/state"
log="$repo/skills/timeout/scripts/log.sh"; prep="$repo/skills/investigate/scripts/prepare.sh"
fail=0
check() { if eval "$2"; then echo "PASS $1"; else echo "FAIL $1"; fail=1; fi; }

mkdir -p "$tmp/p/sub" "$tmp/other" "$tmp/cfg/projects/x"
git -C "$tmp/p" init -q
cd "$tmp/p" || exit 1
check "rejects bad verdict" "! '$log' NOPE none 0 none none 2>/dev/null"
check "rejects bad class" "! '$log' MODEL nope 0 none none 2>/dev/null"
check "rejects bad level" "! '$log' MODEL none 9 none none 2>/dev/null"
check "rejects bad status" "! '$log' MODEL none 0 none nope 2>/dev/null"
"$log" MODEL scope-creep 3 ~/.claude/settings.json proposed >/dev/null
"$log" MODEL scope-creep 3 "sk-secret-token" proposed >/dev/null
check "keeps known target" "grep -q '\"target\":\"settings.json\"' '$XDG_STATE_HOME/timeout-chair/log.jsonl'"
check "drops unknown target" "! grep -q secret '$XDG_STATE_HOME/timeout-chair/log.jsonl'"
rows="$(wc -l < "$XDG_STATE_HOME/timeout-chair/log.jsonl")"
check "rejects shell text in a field" "! '$log' MODEL \"x'; touch pwned; '\" 0 none none 2>/dev/null"
check "rejected call writes nothing" "[ \"\$(wc -l < '$XDG_STATE_HOME/timeout-chair/log.jsonl')\" -eq $rows ] && [ ! -e pwned ]"
# shellcheck disable=SC2016
"$log" MODEL scope-creep 3 '$(touch pwned)' proposed >/dev/null
check "shell text in target stored as other" "tail -n 1 '$XDG_STATE_HOME/timeout-chair/log.jsonl' | grep -q '\"target\":\"other\"' && [ ! -e pwned ]"
cd sub || exit 1
check "history found from a subfolder" "'$prep' | grep -q scope-creep"
cd "$tmp/other" || exit 1
check "history kept per project" "! '$prep' | grep -q scope-creep"
check "missing session id is its own case" "env -u CLAUDE_CODE_SESSION_ID '$prep' | grep -q SESSION_ID_MISSING"
check "unknown session is not found" "CLAUDE_CODE_SESSION_ID=nope '$prep' | grep -q 'TRANSCRIPT: NOT_FOUND'"
touch "$tmp/cfg/projects/x/abc.jsonl"
check "finds the transcript" "CLAUDE_CONFIG_DIR='$tmp/cfg' CLAUDE_CODE_SESSION_ID=abc '$prep' | grep -q 'x/abc.jsonl'"
check "chair script prints the chair" "'$repo/skills/timeout/scripts/chair.sh' | grep -q 'T I M E O U T'"
check "prints the chair" "'$prep' | grep -q 'T I M E O U T'"
rm -rf "$tmp"
exit "$fail"
