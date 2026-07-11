# Changelog

## v0.5.1 — 2026-07-11

Installer fix caught by shipit's own Phase 5 install-from-channel gate: the
curl/wget/copy/`--link` paths shipped only `SKILL.md`, so v0.5.0's new
`references/github-pages-playbook.md` (linked from Phase 5¾) was missing on every fresh
install. All install modes now bundle the `references/` dir (copy copies it, download
fetches each ref, `--link` symlinks it, uninstall removes it). Two regression assertions
added (27 × 3 shells green).

## v0.5.0 — 2026-07-11

New **Phase 5¾ — Web presence** (two standing laws) + a battle-tested how-to reference.

- **Favicon, always** on any shipped page: mark-derived `assets/favicon.svg` + 64px PNG
  fallback, transparent, mid-gray/two-tone for light+dark tabs, thickened strokes for
  16px; page carries a "View on GitHub" link.
- **GitHub Pages whenever hostable**: any project with a web page (demo/playground/docs/
  HTML app) ships as a Pages site — `index.html` at root, verify deployed CONTENT (the
  builds API `.commit` lies), then wire the domain.
- New `references/github-pages-playbook.md`: the complete worked HOW from the
  TesseractLogo ship — favicon design rules, `akeyo.io/<Repo>/` (path) vs
  `<name>.akeyo.io` (subdomain) forms, Namecheap DNS table (apex A ×4, www, wildcard,
  verification TXT), GitHub `gh api pages` commands, cert/HTTPS enforcement, and the
  verification battery (authoritative dig, pinned-IP curl, wildcard proof) — plus every
  gotcha that burned the run (parked-domain poisoning, stale local DNS/build sha, ssh
  push fail, "site not secure" stale tab).
- Anti-patterns added: no-favicon ship, unpublished hostable page, trusting builds
  `.commit`/local `dig`, wildcard CNAME without domain verification (subdomain takeover).

## v0.4.1 — 2026-07-06

Docs-only: the playbook took its own Phase 6½ medicine.

- README: full /awesome-readme treatment — eight-gates banner, 7 live badges,
  the phases table deep-linked into SKILL.md (anchors verified against GitHub's
  rendered blob ids, including the Phase 6½ heading), the lineage table with
  version-by-version receipts, mermaid of the gated pipeline, star CTA.
- New `assets/banner.svg` (theme-safe, system fonts only).

## v0.4.0 — 2026-07-06

- New **Phase 6½ — the README gate**: /awesome-readme is now a mandatory last polish
  gate on every run — the 13-element instant-star checklist + live verification battery
  (banner content-type, badge URLs, anchors vs GitHub's rendered ids, links, observed
  numbers, CI) before true completion; skips must be recorded with a reason
- **Close-with-the-links law HARDENED** (user directive, after a run ended without the
  link): zero exceptions; the report ENDS with a repo-link block listing EVERY repo
  created and updated (labeled, a table when multiple); nothing may follow it; /sas
  inherits verbatim
- Two new anti-patterns guarding both (link block omitted/buried · gate skipped silently)
- README: badge row added (release · license · stars)

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
