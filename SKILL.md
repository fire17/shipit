---
name: shipit
description: Take a simple project idea (or an existing small project) and ship it STATE OF THE ART — designed against edge cases, tested across runtimes, packaged, published (GitHub + a package manager), with launch media prepared. Also handles UPDATE runs — re-shipping an already-published project (version bump, channel bumps, re-verified install) — so checkpoint skills like /sas can chain into it safely. Use whenever the user wants to "ship", "release", "publish", "re-publish", "package", "open-source" a project, "bump the version", "make it state of the art", "take this from idea to released", or asks for the full build→test→publish→announce pipeline — even if they only name one phase, this skill covers the whole arc. Distilled from the bettercd v0.1 release (2026-07-06); battle-tested same day on itself, claude-queue, and my-skills.
argument-hint: "project idea or path to ship, e.g. a better cd / ~/Creations/bettercd"
---

# shipit — idea → state-of-the-art release, end to end

Ship small tools the way the best OSS maintainers do. The phases below are ordered;
each has a gate you must actually pass (not claim). The core creed: **verify by running
the real thing from the published channel** — a release you didn't install-test is a claim,
not a release.

## Phase 0 — Ground truth first

- Toolchain + auth: `gh auth status` (which account?), package managers present, runtimes
  installed. Check name collisions NOW (`gh repo list`, `brew search`, registry search) —
  renaming after publish is expensive. A collision with the user's OWN repo isn't a
  collision — it means this is an **update run** (see "Update runs" below).
- Other agents may share this machine and these surfaces (registries, taps, rc files,
  even this repo): before writing anything shared, check it's quiescent (mtimes) and
  re-read what changed since you last looked; `git fetch` before you push.
- Users' existing paradigm: if your tool wraps/replaces something people already configure
  (their shell, editor, prompt), inspect how the current user has it set up — you'll design
  for composition, and their machine is your first integration test.
- Outward actions (repo creation, pushes, posts) need explicit user authorization. If the
  request already grants it, proceed; otherwise prepare everything and ask once, batched.

## Phase 1 — Design against the failure modes

Before code: write the edge-case ladder. For every "magic" behavior ask (a) what does a typo
do, (b) what does a script/CI invocation do, (c) how do I undo it, (d) what user setup could
it clobber? Rules that generalize:

- **Compose, never clobber**: detect what the user had (function/config/tool), delegate to
  it; never silently change semantics they chose.
- **Destructive-safe undo**: prefer operations that can't destroy content (`rmdir` not
  `rm -rf`); print the undo command at the moment of the side effect.
- **Interactive-only prompts**: guard every prompt with a tty check; scripts get plain
  old behavior, never hangs or surprises.
- **Escape hatches**: an env var to disable each magic behavior; document `builtin`/native
  bypasses.
- Deliver the edge-case brief to the user — the unknown-unknowns list is part of the product.

## Phase 2 — Build minimal

Single file if possible, zero dependencies, hot path measured (a real benchmark number for
the README: overhead vs baseline). Optional integrations (fzf, zoxide, …) degrade gracefully
and get a `doctor` subcommand that checks/installs them — after backing up the user's
current setup with written RESTORE instructions.

## Phase 3 — Verify like an adversary

- Dependency-free test harness in-repo (plain sh/py — no framework users must install).
- **Matrix across runtimes, not just your shell** — portability bugs live in the deltas
  (real example: zsh's `command cd` runs the external no-op `/usr/bin/cd`; POSIX shells run
  the builtin — every zsh test failed until delegates used `builtin`).
- Stub external tools in tests for determinism; never depend on the machine's real state/db.
- Beyond the suite: one live end-to-end run on the real machine with the user's real
  config — in a real fresh interactive shell, not the agent-harness shell (harness shells
  lie: different rc processing, cosmetic noise, missing modules).
- Lint clean (shellcheck/ruff/eslint); annotate intentional violations rather than ignoring.
- **Honest numbers**: every count you publish (assertions, benchmarks) must match observed
  output. Test counters that only count failures silently under-report — count passes too
  (real example: a suite claimed 18, printed 17, and actually ran 25 once the pass branch
  was counted).

## Phase 4 — Package

- README that leads with the outcome (demo block first), a safety-design table, honest
  benchmark, install matrix (package manager / curl / manual / plugin manager), uninstall +
  restore section, FAQ that answers the skeptic.
- LICENSE, CHANGELOG, `.github/workflows/ci.yml` (lint + test matrix on ubuntu+macos).
- Installer script: backs up rc/config, appends an idempotent marked block
  (`# >>> name >>>` … `# <<< name <<<`), prints exact next steps.

## Phase 5 — Publish (each step verified)

1. `git init -b main`, commit, `gh repo create --public --source . --push`
   (if ssh push fails: `gh auth setup-git` + https remote).
2. Tag + `gh release create` with real notes. Add repo topics for discoverability.
3. Package managers that don't need new credentials: own Homebrew tap
   (`Formula/<name>.rb` via `gh api PUT contents`, sha256 of the release tarball) and the
   curl installer. Registries needing logins (npm, PyPI): prepare, ask user to run the
   final push. For non-binary artifacts (skills, dotfiles, configs) the curl installer /
   git clone IS the package channel — don't force them into brew.
4. **Gate**: install from the published channel on a clean-ish path (`brew install
   user/tap/name` + `brew test`) and watch the FIRST CI run — it usually fails on runner
   env deltas (e.g. XDG_CONFIG_HOME being globally set). Fix, push, see green.
5. **Birth the `.project` marker (ripple gate)** — a FIRST ship creates
   `<project-root>/.project/` (DIR form with a `status` file inside — the default for
   anything pushed to GitHub, so richer state stores naturally as sibling files; a
   plain `.project` file is fine for local-only work): `#project v1` header, flat
   `key: value` state block (slug, status, version, repo, channels, first_shipped,
   last_shipped, refs-out…), a `---` separator, freeform verbatim below. From this
   moment the project is under the ripple law: every future change to it — or to
   anything it's referenced by — must update all references and stage republishing of
   affected published projects. Tool:
   `python3 ~/.claude/skills/ripple/scripts/ripple_graph.py ensure-project <slug>
   status=published repo=<url> version=<vX.Y.Z>`; full spec in
   `~/.claude/skills/ripple/references/project-file.md`.

## Phase 5¾ — Web presence: favicon always, GitHub Pages whenever hostable

Two standing laws for every ship (full worked HOW — every command, DNS table, and gotcha
from the TesseractLogo ship — in `references/github-pages-playbook.md`; read it before
executing this phase):

1. **Favicon, always.** Any shipped page (Pages site, docs site, bundled HTML app) gets a
   favicon generated from the project's own mark: `assets/favicon.svg` + 64px PNG
   fallback, transparent background, mid-gray/two-tone so it reads on light AND dark
   tabs, strokes thickened for 16px legibility. Wire `<link rel="icon" ...>` (svg) +
   `<link rel="alternate icon" ...>` (png). Plus a "View on GitHub" link on the page
   itself — site and repo must point at each other.
2. **If the project has (or can trivially have) a web page — a demo, playground, docs,
   or the app itself is HTML — ALWAYS ship it as a GitHub Pages site.** `index.html` at
   repo root, enable via `gh api repos/<o>/<r>/pages -X POST` (branch main, path `/`),
   verify the deployed CONTENT with curl (the builds API's `.commit` field lies after
   second pushes).

Domain wiring (fire17-specific): apex `akeyo.io` lives on `fire17/fire17.github.io`, so
every project auto-serves at `akeyo.io/<Repo>/`. For a memorable subdomain —
short + lowercase, e.g. `tesseract.akeyo.io` — one command:
`gh api -X PUT repos/fire17/<repo>/pages -f cname=<name>.akeyo.io` (wildcard
`* CNAME fire17.github.io.` already exists at Namecheap; GitHub then commits a CNAME
file — `git pull --rebase` before your next push). Always finish with the playbook's
verification battery: authoritative dig via `@dns1.registrar-servers.com` (local cache
lies), pinned-IP curl (`--resolve <host>:443:185.199.108.153`), cert-state poll, then
PUT `https_enforced=true` (resending cname+source), and prove http→https 301. Wildcard
proof: `dig +short test123.akeyo.io` → 185.199.x. Report the live URL in the final
repo-link block.

## Phase 6 — Media (prepare, never auto-post)

- `posts/hackernews.md`: Show HN title + body that invites critique of the design
  (HN rewards honest engineering discussion, not marketing), link to repo + X placeholder.
- `posts/x.md`: short thread — hook, safety/design ladder, perf numbers, install one-liner,
  HN link placeholder. Posts cross-reference each other; include posting notes (order,
  timing, first-comment).
- Posting itself is an outward action: hand the drafts to the user.

## Phase 6½ — The README gate (/awesome-readme) — mandatory last polish gate

The moment a shipit run starts, add this to the run's todo list; it blocks true completion.
Before closing — fresh ship or update — load the **awesome-readme** skill and hold the
repo's README to its bar: the 13-element completeness checklist (hero SVG banner, live
badges, killer hook section, mermaid, ≤30s quickstart, linked core table, collapsible
depth, making-of/provenance, safety table, trust section, star CTA, cross-links, license)
plus its live verification battery — banner serves `image/svg+xml`, every badge URL
resolves, anchors matched against GitHub's ACTUAL rendered `user-content-*` ids, relative
links exist, every number observed, CI green. Fresh ships get the full build; updates
re-run the battery and fill whatever the README is missing. Skip ONLY when the run
produced no public repo surface — and record that reason in the report.

## Phase 7 — Retrospect BEFORE announcing

Use the fresh-eyes window between "released" and "announced": run the tool again in a fresh
environment, read the README as a stranger. Fix warts as a patch release now (real example:
zoxide's doctor printed a false-positive warning on every shell start with the tool
installed — caught in this window, fixed as v0.1.1, formula bumped, before any post went
out). Then deliver: a report (what shipped, where, how it was verified — honestly, including
what was NOT verified), the edge-case brief, and the prepared posts.

**Close with the links — HARD LAW, zero exceptions, every run.** Every shipit run's
closing report — fresh ship or update, complete or partial — ENDS with a repo-link
block: EVERY repo CREATED and EVERY repo UPDATED by the run, each labeled
(`🆕 created:` / `🔄 updated:`) with release/tap/docs links beside it where they exist.
Multi-repo runs list ALL of them — use a table when more than one. NOTHING may follow
the link block; it is the report's last content. A report that omits or buries the
links is an UNFINISHED run — the user must never have to ask "where is it?" (this law
was hardened 2026-07-06 because a run ended without the link and the user had to ask).
Checkpoint skills that chain into shipit (e.g. /sas) inherit this law verbatim and must
end their own final report the same way.

## Update runs — re-shipping an already-published project

`/shipit` on something already released (directly, or chained from a checkpoint skill's
delta gate) is an UPDATE, not a fresh ship — never re-init, never re-create:

1. `git fetch` first — a parallel session may have pushed since you last looked.
2. Version-bump discipline, all surfaces in one pass: version string in the artifact →
   CHANGELOG → commit → tag `vX.Y.Z` → release with notes that match reality (edit old
   notes if a published number turned out wrong). Patch = fixes; minor = new capability.
3. Bump every package channel: a formula update via `gh api PUT contents` needs the
   current file's `sha` (fetch it first or the PUT 409s); recompute the tarball sha256.
4. Re-run the Phase 5 gate: upgrade/reinstall from the published channel and re-test.
5. Deltas of an already-authorized publication inherit its authorization; a NEW outward
   surface (new registry, first-ever post) still needs the user.
6. Bookkeeping in the same pass: if the machine keeps a project registry or skill vault,
   sync its entry (status/updated/changelog) alongside the release; refresh the
   project's `.project` marker (`version`, `last_shipped`).
7. **Ripple the update (default-on — the user never has to ask):**
   `python3 ~/.claude/skills/ripple/scripts/ripple_graph.py check <changed paths>` —
   the cycle-safe dependency graph lists every node referencing what just shipped.
   Update every stale reference (vault copies, aliases, snapshots, doc-mentions,
   registry entries) in this same pass, and STAGE the republish of every affected
   published project as one batch behind ONE user confirmation. Load the `ripple`
   skill (alias /rpl) for the full law.

## Anti-patterns (each one burned someone)

- Claiming "published" without installing from the published channel.
- Shipping an update and walking away with dependents stale — the user had to say
  "remember to update all the references and republish related projects" many times a
  day before the ripple law (/ripple + `.project` markers) made it default-on.
- Testing only in your own shell/runtime/OS.
- Prompts or auto-magic reachable from non-interactive contexts.
- Clobbering user config without a backup + written restore path.
- Announcing before the first CI run is green.
- Skipping the retrospective window and shipping the wart to the front page.
- Re-initializing / re-creating on an update run instead of fetching and bumping.
- Publishing a number (assertion count, benchmark) you didn't see printed.
- Writing shared surfaces (registry, tap, rc) blind to the other agents on the machine.
- Ending the closing report without the repo-link block, or with anything after it —
  the links are the report's mandatory last content (hardened 2026-07-06; it happened).
- Declaring true completion without the Phase 6½ /awesome-readme gate — or without
  recording, in the report, why it didn't apply.
- Shipping an HTML/web project with no favicon, or leaving a hostable web page
  unpublished when GitHub Pages was one command away (Phase 5¾).
- Trusting the Pages builds API `.commit` or your own local `dig` — both lie (stale
  build sha, stale DNS cache); verify deployed CONTENT by curl and DNS via the
  registrar's authoritative nameserver.
- A wildcard `*.<domain>` CNAME at GitHub Pages WITHOUT verifying the domain on the
  GitHub account — that is an open subdomain-takeover door.
