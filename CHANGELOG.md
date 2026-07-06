# Changelog

## v0.1.0 — 2026-07-06

Initial release — the skill shipped itself (its first fresh invocation was this repo).

- `SKILL.md`: the 8-phase idea→state-of-the-art-release playbook (+ anti-pattern list),
  distilled from the bettercd v0.1.0→v0.1.1 ship earlier the same day
- `install.sh`: copy / `--link` / `--uninstall` modes, `sota` alias, backup-on-divergence,
  never clobbers a foreign skill, `SHIPIT_SKILLS_DIR` override
- 18-assertion validation suite × bash/zsh/dash, shellcheck-clean, CI on ubuntu+macos
