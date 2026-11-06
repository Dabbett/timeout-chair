---
name: investigate
description: "Internal step of the timeout skill: reviews this session's log independently. Only use when the timeout skill calls it."
user-invocable: false
context: fork
agent: timeout-chair:investigator
background: false
allowed-tools: Bash("${CLAUDE_SKILL_DIR}/scripts/prepare.sh")
---

Investigate this session and write your report.

!`"${CLAUDE_SKILL_DIR}/scripts/prepare.sh"`

Complaint: $ARGUMENTS

If `TRANSCRIPT` is `NOT_FOUND`, reply only: `LOG NOT FOUND`.
If `TRANSCRIPT` is `SESSION_ID_MISSING`, reply only: `SESSION ID MISSING`.
