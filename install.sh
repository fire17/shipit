#!/bin/sh
# shipit installer — https://github.com/fire17/shipit
#
# Installs the `shipit` Claude Code skill (+ its `sota` alias) into your
# skills directory. Zero dependencies, no prompts, nothing clobbered:
#   - an existing shipit SKILL.md that differs is backed up first (*.bak.<ts>)
#   - an existing `sota` skill that isn't our alias is left alone (warned)
#
# Usage:
#   sh install.sh              copy mode (from local checkout, else downloads)
#   sh install.sh --link       symlink mode: skills dir tracks this checkout
#   sh install.sh --uninstall  remove only what this installer owns
#
# env: SHIPIT_SKILLS_DIR  override the skills dir (default ~/.claude/skills)

set -e

SKILLS_DIR="${SHIPIT_SKILLS_DIR:-$HOME/.claude/skills}"
RAW_URL="https://raw.githubusercontent.com/fire17/shipit/main/SKILL.md"
skill_dir="$SKILLS_DIR/shipit"
alias_dir="$SKILLS_DIR/sota"

say() { printf '%s\n' "$*" >&2; }
here="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
src="$here/SKILL.md"

is_our_alias() {
    [ -L "$alias_dir/SKILL.md" ] || return 1
    case "$(readlink "$alias_dir/SKILL.md")" in
        ../shipit/SKILL.md|"$skill_dir/SKILL.md") return 0 ;;
        *) return 1 ;;
    esac
}

if [ "${1-}" = "--uninstall" ]; then
    if [ -f "$skill_dir/SKILL.md" ] || [ -L "$skill_dir/SKILL.md" ]; then
        if grep -q '^name: shipit$' "$skill_dir/SKILL.md" 2>/dev/null || [ -L "$skill_dir/SKILL.md" ]; then
            rm -f "$skill_dir/SKILL.md"; rmdir "$skill_dir" 2>/dev/null || true
            say "shipit: removed $skill_dir"
        else
            say "shipit: $skill_dir/SKILL.md doesn't look like ours — left in place"
        fi
    fi
    if is_our_alias; then
        rm -f "$alias_dir/SKILL.md"; rmdir "$alias_dir" 2>/dev/null || true
        say "shipit: removed alias $alias_dir"
    elif [ -e "$alias_dir" ]; then
        say "shipit: $alias_dir is not our alias — left in place"
    fi
    say "shipit: uninstalled. (backups, if any, were left as $skill_dir/SKILL.md.bak.*)"
    exit 0
fi

mode="copy"
[ "${1-}" = "--link" ] && mode="link"

mkdir -p "$skill_dir"

# back up an existing, different SKILL.md before touching it
if [ -e "$skill_dir/SKILL.md" ] && [ ! -L "$skill_dir/SKILL.md" ]; then
    if [ -f "$src" ] && cmp -s "$src" "$skill_dir/SKILL.md"; then
        : # identical — nothing to back up
    else
        bak="$skill_dir/SKILL.md.bak.$(date +%Y%m%d-%H%M%S)"
        cp "$skill_dir/SKILL.md" "$bak"
        say "shipit: existing skill backed up → $bak"
    fi
fi

if [ "$mode" = "link" ]; then
    [ -f "$src" ] || { say "shipit: --link needs a local checkout (SKILL.md next to install.sh)"; exit 1; }
    ln -sf "$src" "$skill_dir/SKILL.md"
    say "shipit: linked $skill_dir/SKILL.md → $src (edits in the checkout propagate)"
elif [ -f "$src" ]; then
    rm -f "$skill_dir/SKILL.md"   # may be a stale symlink from a prior --link install
    cp "$src" "$skill_dir/SKILL.md"
    say "shipit: installed from local checkout → $skill_dir/SKILL.md"
elif command -v curl >/dev/null 2>&1; then
    rm -f "$skill_dir/SKILL.md"
    curl -fsSL "$RAW_URL" -o "$skill_dir/SKILL.md"
    say "shipit: downloaded → $skill_dir/SKILL.md"
elif command -v wget >/dev/null 2>&1; then
    rm -f "$skill_dir/SKILL.md"
    wget -q "$RAW_URL" -O "$skill_dir/SKILL.md"
    say "shipit: downloaded → $skill_dir/SKILL.md"
else
    say "shipit: need curl or wget (or run install.sh from a cloned repo)"; exit 1
fi

# the /sota alias: a real dir whose SKILL.md symlinks the canonical one
if [ -e "$alias_dir/SKILL.md" ] || [ -L "$alias_dir/SKILL.md" ]; then
    if is_our_alias; then
        say "shipit: alias /sota already in place"
    else
        say "shipit: $alias_dir exists and is not our alias — left untouched (compose, never clobber)"
    fi
else
    mkdir -p "$alias_dir"
    ln -s ../shipit/SKILL.md "$alias_dir/SKILL.md"
    say "shipit: alias /sota created"
fi

say ""
say "done. restart your Claude Code session (skills load at start), then type /shipit or /sota."
say "undo: sh install.sh --uninstall    (or: rm -rf $skill_dir $alias_dir)"
