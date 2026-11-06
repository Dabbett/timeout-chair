#!/usr/bin/env bash
# Prints the chair for the main session, so it can show the chair even if the
# investigator's report leaves it out.
cat "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/investigate/art/chair.txt" 2>/dev/null || echo "(chair art missing)"
exit 0
