#!/bin/sh
# shipit test runner — validation suite under every available shell.
here="$(cd "$(dirname "$0")" && pwd)"
failed=0; ran=0
for shell in bash zsh dash sh; do
    command -v "$shell" >/dev/null 2>&1 || { printf 'skip: %s not installed\n' "$shell"; continue; }
    ran=$((ran + 1))
    if SHIPIT_TEST_LABEL="$shell" "$shell" "$here/validate.sh"; then :; else
        failed=$((failed + 1)); printf '>>> %s FAILED\n' "$shell" >&2
    fi
    [ "$shell" = "dash" ] && break   # dash covers POSIX; plain sh only as fallback
done
if [ "$failed" -eq 0 ]; then printf 'ALL GREEN (%d shells)\n' "$ran"; else
    printf '%d/%d shell(s) failed\n' "$failed" "$ran" >&2; exit 1; fi
