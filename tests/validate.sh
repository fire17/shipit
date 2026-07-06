#!/bin/sh
# shellcheck disable=SC1090,SC2319,SC2181
#   inspecting $? after test conditions is the suite's assertion pattern.
# shipit validation suite — pure POSIX sh, runs under bash/zsh/dash.
# Usage: <shell> tests/validate.sh   (from anywhere)

here="$(cd "$(dirname "$0")" && pwd)"
repo="$(dirname "$here")"

TMP="$(mktemp -d)" || exit 1
SHIPIT_SKILLS_DIR="$TMP/skills"; export SHIPIT_SKILLS_DIR

PASS=0; FAIL=0
check() { if [ "$2" -eq 0 ]; then PASS=$((PASS + 1)); else FAIL=$((FAIL + 1)); printf 'FAIL: %s\n' "$1" >&2; fi; }

# --- structural checks on the skill itself -----------------------------------
grep -q '^name: shipit$' "$repo/SKILL.md"; check "frontmatter has name: shipit" $?
grep -q '^description: .\{100,\}' "$repo/SKILL.md"; check "description is substantial (triggering surface)" $?
grep -q '^argument-hint: "' "$repo/SKILL.md"; check "argument-hint present and quoted" $?
for phase in "Phase 0" "Phase 1" "Phase 2" "Phase 3" "Phase 4" "Phase 5" "Phase 6" "Phase 7"; do
    grep -q "## $phase" "$repo/SKILL.md" || { check "skill contains $phase" 1; continue; }
done
grep -q "## Anti-patterns" "$repo/SKILL.md"; check "skill contains anti-patterns section" $?

# --- copy-mode install --------------------------------------------------------
sh "$repo/install.sh" >/dev/null 2>&1; check "copy install runs" $?
[ -f "$SHIPIT_SKILLS_DIR/shipit/SKILL.md" ]; check "skill installed" $?
grep -q '^name: shipit$' "$SHIPIT_SKILLS_DIR/sota/SKILL.md" 2>/dev/null
check "sota alias resolves through symlink" $?
[ -L "$SHIPIT_SKILLS_DIR/sota/SKILL.md" ]; check "alias is a symlink (one source of truth)" $?

# --- idempotency: second run, no backup churn on identical content ------------
sh "$repo/install.sh" >/dev/null 2>&1; check "second install run exits 0" $?
n_bak="$(find "$SHIPIT_SKILLS_DIR/shipit" -name 'SKILL.md.bak.*' | wc -l | tr -d ' ')"
[ "$n_bak" -eq 0 ]; check "identical reinstall creates no backup" $?

# --- divergent installed copy gets backed up, never lost ----------------------
printf '\n# local user edit\n' >> "$SHIPIT_SKILLS_DIR/shipit/SKILL.md"
sh "$repo/install.sh" >/dev/null 2>&1
n_bak="$(find "$SHIPIT_SKILLS_DIR/shipit" -name 'SKILL.md.bak.*' | wc -l | tr -d ' ')"
[ "$n_bak" -eq 1 ] && grep -q "local user edit" "$SHIPIT_SKILLS_DIR/shipit"/SKILL.md.bak.*
check "divergent copy backed up before overwrite" $?

# --- link mode -----------------------------------------------------------------
sh "$repo/install.sh" --link >/dev/null 2>&1; check "--link install runs" $?
[ -L "$SHIPIT_SKILLS_DIR/shipit/SKILL.md" ]; check "--link makes SKILL.md a symlink to checkout" $?

# --- foreign sota skill is never clobbered ------------------------------------
TMP2="$(mktemp -d)"
SHIPIT_SKILLS_DIR="$TMP2/skills"; export SHIPIT_SKILLS_DIR
mkdir -p "$SHIPIT_SKILLS_DIR/sota"
printf -- '---\nname: sota\ndescription: user own skill\n---\n' > "$SHIPIT_SKILLS_DIR/sota/SKILL.md"
sh "$repo/install.sh" >/dev/null 2>&1
grep -q '^name: sota$' "$SHIPIT_SKILLS_DIR/sota/SKILL.md"
check "pre-existing foreign sota skill preserved" $?

# --- uninstall removes only what we own ----------------------------------------
sh "$repo/install.sh" --uninstall >/dev/null 2>&1; check "uninstall runs" $?
[ ! -e "$SHIPIT_SKILLS_DIR/shipit/SKILL.md" ]; check "uninstall removed our skill" $?
grep -q '^name: sota$' "$SHIPIT_SKILLS_DIR/sota/SKILL.md" 2>/dev/null
check "uninstall left foreign sota untouched" $?

printf '%s: %d passed, %d failed\n' "${SHIPIT_TEST_LABEL:-validate}" "$PASS" "$FAIL"
rm -rf "$TMP" "$TMP2"
[ "$FAIL" -eq 0 ]
