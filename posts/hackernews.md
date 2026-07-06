# Show HN post (prepared — not yet submitted)

Submit at: https://news.ycombinator.com/submit
URL field: https://github.com/fire17/shipit

## Title

Show HN: Shipit – a Claude Code skill that ships projects, and shipped itself

## Text

shipit is a SKILL.md playbook for Claude Code: eight ordered phases from idea to release — ground truth (auth/collisions/user's existing setup), an edge-case ladder designed before code, a dependency-free test matrix across runtimes, packaging with backup-everything installers, publishing gated on installing from the published channel, launch posts that are prepared but never auto-posted, and a mandatory retrospective in the window between "released" and "announced".

It was distilled from a real release earlier the same day (bettercd — https://github.com/fire17/bettercd), where each rule was learned the hard way: zsh's `command cd` silently runs an external no-op binary, the first CI run failed on a runner env delta, and a zoxide false-positive warning was caught and patched in the retrospective window before any announcement.

Then the skill ran on itself: this repo (installer with copy/link/uninstall modes that never clobber a foreign skill, an 18-assertion suite across bash/zsh/dash, CI) is its own first output.

Interested in HN's take on encoding release discipline as executable playbooks for coding agents — what gates would you add?

X/Twitter announcement: <X_POST_URL — fill in after posting>

## Posting notes

- Works standalone or as a follow-up to the bettercd Show HN.
- First comment: paste the 8 phase names + the anti-pattern list as text.
