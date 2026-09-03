# Agent Lowmem Landing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish a one-request, zero-JavaScript Agent Lowmem landing page at `agentlowmem.dev` that introduces the early-development CLI and directs visitors to its GitHub repository.

**Architecture:** Serve one hand-authored `index.html` containing semantic content and inline CSS. Enforce the transfer and dependency contract with a dependency-free shell verifier and GitHub Actions, then deploy the static repository through Vercel with restrictive response headers.

**Tech Stack:** HTML5, CSS, POSIX shell, gzip, GitHub Actions, Vercel static hosting

**Spec:** `docs/superpowers/specs/2026-09-03-agent-lowmem-landing-design.md`

## Global Constraints

- Work directly on `main` until the first Agent Lowmem release, as requested by the repository owner.
- Use Conventional Commit messages and push each independently verified task.
- The production page is a single `index.html` with inline CSS and zero JavaScript.
- The cold page load makes one HTTP request and transfers less than 15 KiB after gzip compression.
- Download no fonts, images, stylesheets, scripts, or other third-party resources.
- Use system-selected light and dark themes with no theme script or stored preference.
- Use no continuous animation; disable entrance motion under `prefers-reduced-motion: reduce`.
- Do not publish an installation command until an actual installer exists.
- The initial public status is `v0.1 · early development · macOS arm64`.
- The active source link is `https://github.com/Pleo2/agent-lowmem`; do not expose empty `docs`, `lib`, or `blog` routes.
- Keep user-facing copy in English.

---

## File Map

- `index.html` — complete production page, metadata, semantic content, responsive layout, adaptive color tokens, and one-shot motion.
- `scripts/verify-site.sh` — deterministic production-contract verifier for a supplied HTML file.
- `tests/verify-site.sh` — isolated fixtures proving the verifier accepts a compliant page and rejects scripts, external subresources, and oversized output.
- `.github/workflows/verify.yml` — runs the verifier tests and validates the real page on pushes and pull requests.
- `vercel.json` — static response headers and clean deployment behavior.
- `README.md` — product, local preview, validation, deployment, and future-scope guidance.
- `LICENSE` — MIT terms for the website source, providing the footer's stable license destination.
- `.gitignore` — excludes Vercel's local project linkage and macOS metadata.

---

### Task 1: Dependency-free site contract verifier

**Files:**
- Create: `scripts/verify-site.sh`
- Create: `tests/verify-site.sh`
- Create: `.github/workflows/verify.yml`

**Interfaces:**
- Consumes: an optional HTML path as `$1`, defaulting to `index.html`
- Produces: exit code `0` plus one size line for compliant input; non-zero with a specific diagnostic for a violated contract

- [ ] **Step 1: Write the failing verifier tests**

Create `tests/verify-site.sh`:

```sh
#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP=$(mktemp -d "${TMPDIR:-/tmp}/agent-lowmem-site.XXXXXX")
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

write_valid() {
  cat > "$1" <<'HTML'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="color-scheme" content="dark light">
  <link rel="icon" href="data:,">
  <style>
    @media (prefers-color-scheme: light) { :root { color: #111; } }
    @media (prefers-reduced-motion: reduce) { * { animation: none; } }
  </style>
</head>
<body><nav>nav</nav><main><h1>More agents. Less RAM.</h1></main><footer>footer</footer></body>
</html>
HTML
}

expect_failure() {
  name=$1
  file=$2
  if "$ROOT/scripts/verify-site.sh" "$file" >"$TMP/$name.out" 2>"$TMP/$name.err"; then
    echo "expected failure: $name" >&2
    exit 1
  fi
}

write_valid "$TMP/valid.html"
"$ROOT/scripts/verify-site.sh" "$TMP/valid.html"

cp "$TMP/valid.html" "$TMP/script.html"
sed -i.bak 's#</body>#<script>0</script></body>#' "$TMP/script.html"
expect_failure script "$TMP/script.html"

cp "$TMP/valid.html" "$TMP/remote.html"
sed -i.bak 's#</head>#<link rel="stylesheet" href="https://example.com/site.css"></head>#' "$TMP/remote.html"
expect_failure remote "$TMP/remote.html"

cp "$TMP/valid.html" "$TMP/image.html"
sed -i.bak 's#</body>#<img src="logo.png" alt=""></body>#' "$TMP/image.html"
expect_failure image "$TMP/image.html"

cp "$TMP/valid.html" "$TMP/oversized.html"
awk 'BEGIN { srand(1); for (i = 0; i < 60000; i++) printf "%c", 33 + int(rand() * 90) }' >> "$TMP/oversized.html"
expect_failure oversized "$TMP/oversized.html"

echo "verifier tests passed"
```

- [ ] **Step 2: Run the test to verify it fails**

Run:

```bash
chmod +x tests/verify-site.sh
./tests/verify-site.sh
```

Expected: FAIL because `scripts/verify-site.sh` does not exist.

- [ ] **Step 3: Implement the minimal verifier**

Create `scripts/verify-site.sh`:

```sh
#!/bin/sh
set -eu

FILE=${1:-index.html}
LIMIT=15360

fail() {
  echo "site contract: $1" >&2
  exit 1
}

[ -f "$FILE" ] || fail "missing $FILE"

require() {
  pattern=$1
  message=$2
  grep -Eiq "$pattern" "$FILE" || fail "$message"
}

reject() {
  pattern=$1
  message=$2
  if grep -Eiq "$pattern" "$FILE"; then
    fail "$message"
  fi
}

require '<!doctype html>' 'missing HTML5 doctype'
require '<html[^>]+lang="en"' 'missing English language declaration'
require '<meta[^>]+charset="utf-8"' 'missing UTF-8 declaration'
require '<meta[^>]+name="viewport"' 'missing viewport metadata'
require '<meta[^>]+name="color-scheme"[^>]+content="dark light"' 'missing adaptive color-scheme metadata'
require '<link[^>]+rel="icon"[^>]+href="data:,' 'missing request-free favicon declaration'
require '<nav([[:space:]>])' 'missing navigation landmark'
require '<main([[:space:]>])' 'missing main landmark'
require '<h1([[:space:]>])' 'missing primary heading'
require '<footer([[:space:]>])' 'missing footer landmark'
require 'prefers-color-scheme:[[:space:]]*light' 'missing light theme adaptation'
require 'prefers-reduced-motion:[[:space:]]*reduce' 'missing reduced-motion override'

reject '<script([[:space:]>])' 'production JavaScript is forbidden'
reject '<img([[:space:]>])' 'image requests are forbidden'
reject '<iframe([[:space:]>])' 'embedded documents are forbidden'
reject '@font-face' 'downloadable fonts are forbidden'
reject '<link[^>]+rel="(stylesheet|preload|modulepreload)"' 'linked subresources are forbidden'
reject '<link[^>]+rel="icon"[^>]+href="(https?:)?//' 'remote icons are forbidden'
reject '(src|poster)="[^"]+"' 'source subresources are forbidden'
reject 'url\([^)]*//' 'remote CSS resources are forbidden'

SIZE=$(gzip -9 -c "$FILE" | wc -c | tr -d '[:space:]')
[ "$SIZE" -lt "$LIMIT" ] || fail "gzip size ${SIZE} bytes exceeds ${LIMIT}-byte limit"

echo "site contract: ${SIZE} gzip bytes; no production subresources"
```

- [ ] **Step 4: Make both scripts executable and run the tests**

Run:

```bash
chmod +x scripts/verify-site.sh tests/verify-site.sh
./tests/verify-site.sh
```

Expected: both the valid-fixture size line and `verifier tests passed`; exit code `0`.

- [ ] **Step 5: Add continuous verification**

Create `.github/workflows/verify.yml`:

```yaml
name: Verify site

on:
  push:
    branches: [main]
  pull_request:

permissions:
  contents: read

jobs:
  contract:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Test verifier
        run: ./tests/verify-site.sh
      - name: Verify production page
        if: ${{ hashFiles('index.html') != '' }}
        run: ./scripts/verify-site.sh index.html
```

- [ ] **Step 6: Verify and commit**

Run:

```bash
./tests/verify-site.sh
git diff --check
git add scripts/verify-site.sh tests/verify-site.sh .github/workflows/verify.yml
git commit -m "test: enforce landing performance contract"
git push origin main
```

Expected: tests pass, the commit is created, and `main` is synchronized.

---

### Task 2: Semantic adaptive landing page

**Files:**
- Create: `index.html`
- Test: `scripts/verify-site.sh`

**Interfaces:**
- Consumes: direct browser navigation to `/` and system color/motion preferences
- Produces: one self-contained English HTML response with links to `https://github.com/Pleo2/agent-lowmem`

- [ ] **Step 1: Verify the missing production artifact**

Run:

```bash
./scripts/verify-site.sh index.html
```

Expected: FAIL with `site contract: missing index.html`.

- [ ] **Step 2: Create the complete landing page**

Create `index.html` with this structure and copy. Keep all CSS inline and add no resource-bearing elements:

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="color-scheme" content="dark light">
  <link rel="icon" href="data:,">
  <title>Agent Lowmem — More agents. Less RAM.</title>
  <meta name="description" content="A native policy runner for predictable agent-launched validation on memory-constrained Apple Silicon Macs.">
  <link rel="canonical" href="https://agentlowmem.dev/">
  <meta property="og:type" content="website">
  <meta property="og:title" content="Agent Lowmem — More agents. Less RAM.">
  <meta property="og:description" content="Keep agent-launched validation predictable on memory-constrained Macs.">
  <meta property="og:url" content="https://agentlowmem.dev/">
  <meta name="twitter:card" content="summary">
  <meta name="twitter:title" content="Agent Lowmem — More agents. Less RAM.">
  <meta name="twitter:description" content="Keep agent-launched validation predictable on memory-constrained Macs.">
  <style>
    :root {
      --bg: #0b0a09;
      --surface: #11100e;
      --text: #f1eee8;
      --muted: #aaa49a;
      --faint: #777168;
      --line: #292622;
      --accent: #d76b4b;
      --accent-soft: #362019;
      --mono: "JetBrains Mono", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", monospace;
      --sans: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      color-scheme: dark;
    }
    * { box-sizing: border-box; }
    html { background: var(--bg); scroll-behavior: smooth; }
    body {
      margin: 0;
      background: var(--bg);
      color: var(--muted);
      font: 400 1rem/1.7 var(--sans);
      text-rendering: optimizeLegibility;
    }
    a { color: inherit; text-underline-offset: .25em; }
    a:hover { color: var(--text); }
    a:focus-visible { outline: 2px solid var(--accent); outline-offset: 5px; border-radius: 2px; }
    .shell { width: min(100% - 2.5rem, 72rem); margin-inline: auto; }
    .nav {
      min-height: 4.5rem;
      display: flex;
      align-items: center;
      justify-content: space-between;
      border-bottom: 1px solid var(--line);
      font: 500 .78rem/1 var(--mono);
    }
    .brand { color: var(--text); text-decoration: none; letter-spacing: -.03em; }
    .brand::after { content: "_"; color: var(--accent); }
    .nav-meta { display: flex; align-items: center; gap: 1.25rem; }
    .status { color: var(--faint); }
    .status::before { content: ""; display: inline-block; width: .45rem; height: .45rem; margin-right: .45rem; border-radius: 50%; background: var(--accent); }
    main { padding: clamp(4.5rem, 11vw, 8rem) 0 6rem; }
    .hero { max-width: 49rem; }
    .eyebrow { margin: 0 0 1.25rem; color: var(--accent); font: 600 .72rem/1.4 var(--mono); letter-spacing: .12em; text-transform: uppercase; }
    h1 { margin: 0; color: var(--text); font: 600 clamp(2.8rem, 8vw, 6.6rem)/.94 var(--mono); letter-spacing: -.075em; }
    .lede { max-width: 42rem; margin: 2rem 0 0; font-size: clamp(1.05rem, 2vw, 1.28rem); color: var(--muted); }
    .actions { margin-top: 2rem; display: flex; flex-wrap: wrap; align-items: center; gap: 1.15rem; }
    .primary { display: inline-flex; min-height: 2.9rem; align-items: center; padding: 0 1rem; border: 1px solid var(--accent); color: var(--text); background: var(--accent-soft); font: 600 .78rem/1 var(--mono); text-decoration: none; }
    .primary::after { content: " ↗"; margin-left: .6rem; color: var(--accent); }
    .release { color: var(--faint); font: 400 .72rem/1.5 var(--mono); }
    .terminal { max-width: 49rem; margin-top: clamp(4rem, 9vw, 7rem); border: 1px solid var(--line); background: var(--surface); }
    .terminal-bar { display: flex; align-items: center; justify-content: space-between; min-height: 2.75rem; padding: 0 1rem; border-bottom: 1px solid var(--line); color: var(--faint); font: 400 .7rem/1 var(--mono); }
    .lights { letter-spacing: .28em; color: var(--line); }
    pre { margin: 0; padding: clamp(1.25rem, 4vw, 2rem); overflow-x: auto; color: var(--muted); font: 400 clamp(.72rem, 2vw, .84rem)/1.85 var(--mono); }
    .prompt, .ok { color: var(--accent); }
    .bright { color: var(--text); }
    .terminal { animation: arrive .65s cubic-bezier(.2,.7,.2,1) both; }
    @keyframes arrive { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: none; } }
    .features { max-width: 49rem; margin-top: clamp(5rem, 10vw, 8rem); border-top: 1px solid var(--line); }
    .feature { display: grid; grid-template-columns: minmax(8rem, 13rem) 1fr; gap: 2rem; padding: 2rem 0; border-bottom: 1px solid var(--line); }
    h2 { margin: 0; color: var(--text); font: 600 .8rem/1.5 var(--mono); }
    .feature p { margin: 0; }
    footer { display: flex; flex-wrap: wrap; justify-content: space-between; gap: 1rem; padding: 2rem 0 3rem; border-top: 1px solid var(--line); color: var(--faint); font: 400 .7rem/1.5 var(--mono); }
    footer nav { display: flex; gap: 1.2rem; }
    @media (max-width: 38rem) {
      .shell { width: min(100% - 1.5rem, 72rem); }
      .nav-meta { gap: .85rem; }
      .status { font-size: 0; }
      .status::before { margin: 0; }
      .feature { grid-template-columns: 1fr; gap: .65rem; }
    }
    @media (prefers-color-scheme: light) {
      :root {
        --bg: #f5f2ec;
        --surface: #ece8e0;
        --text: #171410;
        --muted: #5f5a52;
        --faint: #777168;
        --line: #d5cfc5;
        --accent: #a84227;
        --accent-soft: #eddbd3;
        color-scheme: light;
      }
    }
    @media (prefers-reduced-motion: reduce) {
      html { scroll-behavior: auto; }
      *, *::before, *::after { animation: none !important; }
    }
  </style>
</head>
<body>
  <header class="shell">
    <nav class="nav" aria-label="Primary navigation">
      <a class="brand" href="/" aria-label="Agent Lowmem home">agent_lowmem</a>
      <div class="nav-meta">
        <span class="status">early development</span>
        <a href="https://github.com/Pleo2/agent-lowmem">source</a>
      </div>
    </nav>
  </header>
  <main class="shell">
    <section class="hero" aria-labelledby="hero-title">
      <p class="eyebrow">Native policy runner for macOS</p>
      <h1 id="hero-title">More agents.<br>Less RAM.</h1>
      <p class="lede">Agent Lowmem keeps agent-launched validation predictable on memory-constrained Apple Silicon Macs—one managed heavy operation at a time.</p>
      <div class="actions">
        <a class="primary" href="https://github.com/Pleo2/agent-lowmem">Follow the build on GitHub</a>
        <span class="release">v0.1 · early development · macOS arm64</span>
      </div>
    </section>

    <section class="terminal" aria-label="Agent Lowmem doctor example">
      <div class="terminal-bar"><span class="lights" aria-hidden="true">● ● ●</span><span>agent-lowmem</span></div>
      <pre><span class="prompt">$</span> <span class="bright">agent-lowmem doctor</span>

host       macOS arm64
profile    Apple M2 · 8 GiB
repository JavaScript / TypeScript
policy     one heavy operation
watch      denied
cleanup    owned process group

<span class="ok">ready</span>      focused validation recommended</pre>
    </section>

    <section class="features" aria-label="Core capabilities">
      <article class="feature"><h2>Global serialization</h2><p>One Agent Lowmem-managed heavy operation across repositories, so cooperating agents do not pile work onto the same Mac.</p></article>
      <article class="feature"><h2>No watch mode</h2><p>Recognized watch and background execution are rejected before they can become forgotten memory consumers.</p></article>
      <article class="feature"><h2>Bounded execution</h2><p>Every supported operation has a visible deadline and a warning before Agent Lowmem ends it.</p></article>
      <article class="feature"><h2>Owned cleanup</h2><p>Timeouts and interruptions target only the process group Agent Lowmem created—never unrelated work by name or guesswork.</p></article>
    </section>
  </main>
  <footer class="shell">
    <span>Built for constrained machines.</span>
    <nav aria-label="Footer navigation"><a href="https://github.com/Pleo2/agent-lowmem">source</a><a href="https://github.com/Pleo2/agentlowmem.dev/blob/main/LICENSE">MIT license</a></nav>
  </footer>
</body>
</html>
```

- [ ] **Step 3: Run the contract verifier**

Run:

```bash
./scripts/verify-site.sh index.html
```

Expected: PASS with a gzip size below `15360` bytes and `no production subresources`.

- [ ] **Step 4: Serve and perform the first meaningful preview**

Run:

```bash
python3 -m http.server 4173 --bind 127.0.0.1
```

In another terminal, run:

```bash
curl --fail --silent --show-error http://127.0.0.1:4173/ > /dev/null
```

Expected: HTTP success. Open this exact local URL once for the first meaningful preview. Do not start a second server.

- [ ] **Step 5: Verify the page and commit**

Run:

```bash
./tests/verify-site.sh
./scripts/verify-site.sh index.html
git diff --check
git add index.html
git commit -m "feat: add minimal adaptive landing"
git push origin main
```

Expected: all checks pass and the page commit is on `origin/main`.

---

### Task 3: Static deployment contract and repository guidance

**Files:**
- Create: `vercel.json`
- Create: `README.md`
- Create: `LICENSE`
- Create: `.gitignore`
- Modify: `docs/superpowers/specs/2026-09-03-agent-lowmem-landing-design.md`

**Interfaces:**
- Consumes: Vercel static deployment of the repository root
- Produces: security and caching headers for `/`; contributor commands that invoke the Task 1 verifier

- [ ] **Step 1: Add static response headers**

Create `vercel.json`:

```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "cleanUrls": true,
  "trailingSlash": false,
  "headers": [
    {
      "source": "/",
      "headers": [
        { "key": "Content-Type", "value": "text/html; charset=utf-8" },
        { "key": "Cache-Control", "value": "public, max-age=0, must-revalidate" },
        { "key": "Content-Security-Policy", "value": "default-src 'none'; style-src 'unsafe-inline'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'; upgrade-insecure-requests" },
        { "key": "Referrer-Policy", "value": "no-referrer" },
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "Permissions-Policy", "value": "accelerometer=(), camera=(), geolocation=(), gyroscope=(), microphone=(), payment=(), usb=()" }
      ]
    }
  ]
}
```

- [ ] **Step 2: Document the repository**

Create `README.md`:

````markdown
# agentlowmem.dev

The public website for [Agent Lowmem](https://github.com/Pleo2/agent-lowmem): a native policy runner for predictable agent-launched validation on memory-constrained Apple Silicon Macs.

## Principles

- one production HTML response;
- zero production JavaScript;
- zero downloaded fonts or images;
- less than 15 KiB after gzip compression;
- system-adaptive light and dark themes;
- no continuous animation.

## Preview

```sh
python3 -m http.server 4173 --bind 127.0.0.1
```

Open `http://127.0.0.1:4173/`.

## Verify

```sh
./tests/verify-site.sh
./scripts/verify-site.sh index.html
```

## Roadmap

The initial release is one landing page. Documentation, library reference, source navigation, and a blog may follow while preserving static output and measurable performance budgets.
````

- [ ] **Step 3: Add the website source license**

Create `LICENSE` with the standard MIT License text, using `2026 Jose Moreno` as the copyright line:

```text
MIT License

Copyright (c) 2026 Jose Moreno

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

- [ ] **Step 4: Exclude local deployment state**

Create `.gitignore`:

```gitignore
.DS_Store
.vercel/
```

- [ ] **Step 5: Mark the implemented specification status**

Change the spec header from:

```markdown
**Status:** Approved design candidate
```

to:

```markdown
**Status:** Implemented
```

Do this only after Tasks 1 and 2 have passed their checks.

- [ ] **Step 6: Validate configuration and all source artifacts**

Run:

```bash
./tests/verify-site.sh
./scripts/verify-site.sh index.html
python3 -m json.tool vercel.json > /dev/null
git diff --check
```

Expected: every command exits `0`.

- [ ] **Step 7: Commit and push**

Run:

```bash
git add .gitignore README.md LICENSE vercel.json docs/superpowers/specs/2026-09-03-agent-lowmem-landing-design.md
git commit -m "chore: configure static landing deployment"
git push origin main
```

Expected: the deployment contract is recorded atomically on `main`.

---

### Task 4: Production publication and evidence

**Files:**
- Create: `docs/evidence/2026-09-03-initial-release.md`

**Interfaces:**
- Consumes: verified `main`, authenticated Vercel account, and the owned `agentlowmem.dev` domain
- Produces: public HTTPS landing, attached production domain, and reproducible release evidence

- [ ] **Step 1: Re-run the complete local gate**

Run:

```bash
./tests/verify-site.sh
./scripts/verify-site.sh index.html
python3 -m json.tool vercel.json > /dev/null
git status --short --branch
```

Expected: all checks pass and the worktree is clean and synchronized with `origin/main`.

- [ ] **Step 2: Deploy the repository root to Vercel production**

Use the explicitly pinned Vercel CLI version so deployment does not depend on a moving package tag:

```bash
npx --yes vercel@59.11.2 --version
npx --yes vercel@59.11.2 --prod --yes --scope pleo2s-projects
```

Expected: a successful HTTPS production deployment. Preserve the returned deployment URL for validation. The non-interactive deployment links this directory to the `pleo2s-projects` team and uses `agentlowmem.dev` as the project name; do not add a framework preset or build command.

- [ ] **Step 3: Attach and verify the owned domain**

Attach the owned apex domain to the linked Vercel project and inspect the provider-reported configuration:

```bash
npx --yes vercel@59.11.2 domains add agentlowmem.dev agentlowmem.dev --scope pleo2s-projects
npx --yes vercel@59.11.2 domains inspect agentlowmem.dev --scope pleo2s-projects
```

If inspection reports a DNS requirement, apply exactly the record it reports in the domain's Vercel settings; do not substitute a remembered address.

Run:

```bash
curl --fail --silent --show-error --head https://agentlowmem.dev/
curl --fail --silent --show-error https://agentlowmem.dev/ | gzip -9 -c | wc -c
```

Expected: HTTPS success, the configured security headers, and compressed HTML below `15360` bytes.

- [ ] **Step 4: Run browser and Lighthouse release checks**

Against `https://agentlowmem.dev/`, verify desktop and mobile widths, keyboard focus, 200% zoom, system light/dark themes, and reduced motion. Then run Lighthouse with the four required categories against the deployed origin.

Run:

```bash
npx --yes lighthouse@13.4.1 https://agentlowmem.dev/ \
  --only-categories=performance,accessibility,best-practices,seo \
  --output=json \
  --output-path=/tmp/agent-lowmem-lighthouse.json \
  --chrome-flags="--headless"
node -e 'const r=require("/tmp/agent-lowmem-lighthouse.json"); for (const [k,v] of Object.entries(r.categories)) console.log(`${k}: ${Math.round(v.score*100)}`)'
```

Expected: no horizontal document scroll, visible focus, correct adaptive palettes, no motion under reduced-motion, no third-party requests, and scores of 100 for Performance, Accessibility, Best Practices, and SEO. Fix factual failures and repeat the relevant check; do not weaken the contract to make a score pass.

- [ ] **Step 5: Record reproducible release evidence**

Create `docs/evidence/2026-09-03-initial-release.md` with the exact deployment URL, apex URL, UTC verification time, commit SHA, compressed byte count, response-header summary, request count, Lighthouse scores, and any honest environmental caveat. Use observed values only.

- [ ] **Step 6: Commit the evidence and verify final state**

Run:

```bash
git add docs/evidence/2026-09-03-initial-release.md
git commit -m "docs: record initial landing release evidence"
git push origin main
git status --short --branch
```

Expected: clean `main`, synchronized with `origin/main`, with the public landing and its evidence tied to the same final commit history.
