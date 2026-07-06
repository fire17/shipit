# Changelog

## v0.3.0 — 2026-07-06

- New default law (user directive): **close with the link** — the FINAL line of every
  shipit run's report (fresh or update) is the git repo URL, with release/tap links
  beside it when they exist; chaining checkpoint skills (/sas) inherit the law and end
  their own reports the same way

## v0.2.0 — 2026-07-06

Learnings folded back from the skill's first day in production (this repo, bettercd,
claude-queue, my-skills, and the /sas checkpoint skill that chains into it):

- New **Update runs** section: re-shipping an already-published project — fetch-first,
  version-bump discipline across all surfaces, package-channel sha bumps, re-verified
  install, authorization inheritance, registry/vault bookkeeping
- Phase 0: own-repo "collision" = update run; multi-agent cohabitation rules
  (quiescence checks, fetch-before-push)
- Phase 3: honest-numbers rule (counters must count passes; published counts must match
  observed output) + verify in a real interactive shell, not the agent-harness shell
- Three new anti-patterns; description now covers update/re-publish triggering

## v0.1.0 — 2026-07-06

Initial release — the skill shipped itself (its first fresh invocation was this repo).

- `SKILL.md`: the 8-phase idea→state-of-the-art-release playbook (+ anti-pattern list),
  distilled from the bettercd v0.1.0→v0.1.1 ship earlier the same day
- `install.sh`: copy / `--link` / `--uninstall` modes, `sota` alias, backup-on-divergence,
  never clobbers a foreign skill, `SHIPIT_SKILLS_DIR` override
- 25-assertion validation suite × bash/zsh/dash, shellcheck-clean, CI on ubuntu+macos
