# GitHub Pages + favicon playbook (battle-tested on TesseractLogo, 2026-07-11)

The complete HOW for Phase 5¾: every command below was actually run and verified while
shipping https://github.com/fire17/TesseractLogo → https://tesseract.akeyo.io/.
fire17's domain: **akeyo.io** (Namecheap, BasicDNS). User site repo:
`fire17/fire17.github.io` (branch `master`) carries the apex custom domain.

## 1) Repo layout for a Pages site

- The page entry point is **`index.html` at repo root** — Pages serves it over README.md.
  A self-contained single-file app (inline CSS/JS, zero deps) is the ideal shape.
- Keep README.md beside it: GitHub shows README on the repo page, Pages serves index.html.

## 2) Favicon (ALWAYS — every shipped page)

- Generate from the project's own mark. Two files: `assets/favicon.svg` (primary) +
  `assets/favicon.png` 64px (fallback, RGBA):
  ```bash
  rsvg-convert -w 64 -h 64 assets/favicon.svg -o assets/favicon.png
  ```
- Design rules learned: **transparent background**; a **mid-gray** (`#7a7a7a`-ish) or
  two-tone mark stays legible on BOTH light and dark browser tabs (pure white or pure
  black vanishes on one of them); **thicken strokes** — detail that reads at 1000px is
  mush at 16px (TesseractLogo bars went 15 → 34/1000 viewBox units).
- Wire into `<head>`:
  ```html
  <link rel="icon" type="image/svg+xml" href="assets/favicon.svg">
  <link rel="alternate icon" type="image/png" href="assets/favicon.png">
  ```
- Also add a **"View on GitHub" button/link on the page itself** — the site and the repo
  must point at each other (the README already links the site; close the loop).

## 3) Enable Pages on the repo

```bash
gh api repos/<owner>/<repo>/pages -X POST --input - <<'EOF'
{"source":{"branch":"main","path":"/"}}
EOF
```

Wait for deploy — poll, don't sleep blind:
```bash
gh api repos/<owner>/<repo>/pages --jq .status           # "building" → "built"
gh api repos/<owner>/<repo>/pages/builds/latest --jq '.status + " " + .commit'
```
**Gotcha:** the legacy builds API can keep reporting an OLD commit sha after a second
push has actually deployed. Never trust `.commit` alone — verify the *content*:
```bash
curl -fsSL "https://<owner>.github.io/<repo>/?v=2" | grep -c 'favicon.svg\|View on GitHub'
```

## 4) The two URL forms (path vs subdomain)

**Path form — `akeyo.io/<Repo>/` — is automatic.** When the USER-SITE repo
(`fire17/fire17.github.io`) has custom domain `akeyo.io`, GitHub serves EVERY project
site at `akeyo.io/<Repo>/` and 301s `fire17.github.io/<Repo>/` there. Zero per-project
config. (Corollary: a dead/parked custom domain on the user site breaks EVERY project
page at once — that exact incident happened 2026-07-11; see §7.)

**Subdomain form — `<name>.akeyo.io` — one command per repo** (needs the wildcard DNS
record from §5):
```bash
gh api -X PUT repos/<owner>/<repo>/pages -f cname=<name>.akeyo.io
```
- **Naming:** short, lowercase, memorable — `tesseract.akeyo.io`, not
  `tesseractlogo.akeyo.io`; the repo keeps its TitleCase name independently.
- Setting cname makes GitHub **commit a `CNAME` file into the repo** — run
  `git pull --rebase` locally before your next push or it gets rejected
  (and `.DS_Store` etc. must be clean/ignored or the rebase refuses).
- After the domain works, repoint the README's live-app links to the canonical
  subdomain URL.

## 5) DNS at Namecheap (Advanced DNS tab of the domain)

Delete any parking records first (`URL Redirect Record`, CNAME to
`parkingpage.namecheap.com`, stray `A` like 192.64.119.237). Then the full record set:

| Type  | Host | Value               | Purpose |
|-------|------|---------------------|---------|
| A     | @    | 185.199.108.153     | apex → GitHub Pages |
| A     | @    | 185.199.109.153     | (all four required) |
| A     | @    | 185.199.110.153     | |
| A     | @    | 185.199.111.153     | |
| CNAME | www  | fire17.github.io.   | www variant |
| CNAME | *    | fire17.github.io.   | wildcard — enables any `<name>.akeyo.io` |
| TXT   | _github-pages-challenge-fire17 | (from GitHub verified-domains UI) | anti-takeover, see §8 |

GitHub side, apex (only on the user-site repo — NOT per project):
```bash
gh api -X PUT repos/fire17/fire17.github.io/pages --input - <<'EOF'
{"cname":"akeyo.io","source":{"branch":"master","path":"/"}}
EOF
```

## 6) Verification battery (local DNS cache LIES — every check below was needed)

```bash
# authoritative truth, bypassing every cache (registrar's own NS):
dig +short akeyo.io A @dns1.registrar-servers.com          # want: 4× 185.199.x
dig +short <name>.akeyo.io @dns1.registrar-servers.com     # want: fire17.github.io.
dig +short test123.akeyo.io | head -2                      # wildcard proof → 185.199.x

# serve check that ignores stale local cache — pin the IP:
curl -s --resolve <name>.akeyo.io:443:185.199.108.153 https://<name>.akeyo.io/ | grep -o "<title>.*</title>"

# HTTPS: cert poll → enforce → prove the redirect
gh api repos/<owner>/<repo>/pages --jq '.https_certificate.state'   # pending → approved/issued
# enforce (MUST resend cname+source in the same PUT or they reset):
gh api -X PUT repos/<owner>/<repo>/pages --input - <<'EOF'
{"https_enforced":true,"cname":"<name>.akeyo.io","source":{"branch":"main","path":"/"}}
EOF
curl -s -o /dev/null -w "%{http_code} %{redirect_url}\n" http://<name>.akeyo.io/   # want: 301 → https
echo | openssl s_client -connect <name>.akeyo.io:443 -servername <name>.akeyo.io 2>/dev/null | openssl x509 -noout -subject -enddate
```

Cert is Let's Encrypt, auto-issued in ~1–3 min once DNS resolves, auto-renews.

## 7) Gotchas that actually burned this run

- **Parked custom domain poisons everything**: akeyo.io was Namecheap-parked while set as
  the user-site domain → every `fire17.github.io/*` URL 301'd to a parking page. Fix
  order matters: remove the custom domain first (`"cname": null` via the PUT above —
  GitHub auto-deletes the repo's CNAME file too), ship on github.io URLs, re-add the
  domain ONLY after authoritative DNS shows 185.199.x.
- **`ssh -T git@github.com` can fail in sandboxes** — push with
  `git -c credential.helper='!gh auth git-credential' push` over an https remote.
- **User's browser shows "site not secure" after everything is green**: stale tab/DNS
  from before cert issuance. Hard reload / incognito / `sudo dscacheutil -flushcache;
  sudo killall -HUP mDNSResponder`. Verify server-side with the pinned-IP curl before
  debugging anything else.
- **Local `dig` kept returning the parked IP long after the fix** (TTL ~30 min) — always
  check `@dns1.registrar-servers.com` for truth.

## 8) Security: verify the domain on GitHub (do once per domain)

A wildcard CNAME pointing at GitHub Pages means ANYONE could bind an unused
`<something>.akeyo.io` to their repo (subdomain takeover) — unless the domain is
verified: GitHub → Settings → Pages → "Add a verified domain" → akeyo.io → add the
offered `TXT _github-pages-challenge-<user>` record at Namecheap. After verification,
only fire17's repos can use `*.akeyo.io`. Status as of 2026-07-11: recommended, not yet
confirmed done — check before assuming.
