#!/usr/bin/env bash
# Prints a short hash identifying the current project: the git root if there is
# one, else the current directory. Shared so the log writer and reader agree.
root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
if command -v shasum >/dev/null 2>&1; then
  printf '%s\n' "$root" | shasum | cut -c1-12
else
  printf '%s\n' "$root" | sha1sum | cut -c1-12
fi
