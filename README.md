# shipit

**A Claude Code skill that takes a project from idea to state-of-the-art release — designed against edge cases, tested across runtimes, packaged, published, with launch media prepared. Alias: `/sota`.**

```console
$ claude
> /shipit a better cd

  Phase 0  ground truth      gh auth ✓ · name free ✓ · user's shell paradigm read
  Phase 1  edge-case ladder  compose-never-clobber · destructive-safe undo · tty-guarded
  Phase 2  build minimal     one file · zero deps · hot path measured (~25µs)
  Phase 3  verify            67 assertions × bash+zsh+dash · stubbed externals · live run
  Phase 4  package           README · CI · installer with backups + markers
  Phase 5  publish           repo + release + brew tap — install-tested from the channel
  Phase 6  media             Show HN + X thread prepared, never auto-posted
  Phase 7  retrospect        fresh-eyes run BEFORE announcing → v0.1.1 wart fix
```

That transcript is real: this skill is distilled from shipping [bettercd](https://github.com/fire17/bettercd) v0.1.0→v0.1.1 in one session — every rule in it is a lesson that actually burned. Then the skill **shipped itself** (this repo) as its first fresh run.

## What it is

A [Claude Code skill](https://docs.anthropic.com/en/docs/claude-code) — a `SKILL.md` playbook Claude loads and executes. Eight ordered phases, each with a gate you must *pass, not claim*. The core creed:

> **Verify by running the real thing from the published channel** — a release you didn't install-test is a claim, not a release.

What makes releases state-of-the-art in practice:

- **Ground truth before code** — auth, name collisions, and the user's existing setup (their machine is your first integration test).
- **The edge-case ladder is the product** — typo behavior, script/CI behavior, undo, clobber-risk: designed before building.
- **Adversarial verification** — dependency-free test harness, runtime *matrix* (portability bugs live in the deltas between shells/runtimes), stubbed externals, plus one live run on real config.
- **Publishing gates** — first CI runs usually fail on runner env deltas; installs are tested from the published channel, not the working tree.
- **Media prepared, never auto-posted** — posting is the human's call.
- **The retrospective window** — the gap between "released" and "announced" is where you catch the wart before it hits the front page.

## Install

**One-liner** (inspect [install.sh](install.sh) first if you like — it backs up anything it would overwrite and never clobbers a foreign skill):

```sh
curl -fsSL https://raw.githubusercontent.com/fire17/shipit/main/install.sh | sh
```

**From a clone** (contributors: `--link` makes your skills dir track the checkout):

```sh
git clone https://github.com/fire17/shipit && sh shipit/install.sh          # copy
sh shipit/install.sh --link                                                 # symlink
```

Restart your Claude Code session (skills load at start), then:

```
/shipit <project idea or path>     — or —     /sota <...>
```

Uninstall: `sh install.sh --uninstall` (removes only what it owns; backups are kept).

## Safety design

| Concern | Behavior |
|---|---|
| Existing `shipit` skill with local edits | backed up to `SKILL.md.bak.<ts>` before overwrite; identical content → no churn |
| You already have a `sota` skill | left untouched, warned (compose, never clobber) |
| Scripts / CI | no prompts anywhere; `set -e`; deterministic |
| Undo | `--uninstall` removes only owned files; exact undo commands printed at install |
| Custom skills dir | `SHIPIT_SKILLS_DIR` env override |

## Verification

`tests/run.sh` — 18 assertions (skill structure, copy/link/uninstall modes, idempotency, backup-on-divergence, foreign-skill preservation) under bash, zsh, and dash; shellcheck-clean; CI on ubuntu + macos.

## FAQ

**Is this just a checklist?** It's a playbook with *gates* — the difference is each phase ends in something observable (a green matrix, a successful install from the published channel, a fresh-eyes run). Claude executes it; the phases keep it honest.

**Why phases instead of "just be careful"?** Because every anti-pattern in the skill's final section burned someone during a real release. Encoding the lesson beats remembering it.

**Does it work for things that aren't shell tools?** Yes — the phases are language-agnostic (the verify matrix becomes node LTS versions, python versions, etc.). For non-binary artifacts, the curl installer / git clone *is* the package channel.

## License

[MIT](LICENSE) © [fire17](https://github.com/fire17)
