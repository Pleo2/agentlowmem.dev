# Agent Lowmem Landing Design

**Status:** Implemented

**Date:** 2026-09-03

**Product:** Agent Lowmem

**Domain:** `agentlowmem.dev`

**Repository:** `Pleo2/agentlowmem.dev`

**Tagline:** More agents. Less RAM.

## 1. Purpose

The first Agent Lowmem website is a public, English-language landing page for developers using coding agents on memory-constrained Macs. It introduces the product, demonstrates its intended command-line experience, and directs visitors to the open-source implementation while the CLI is in early development.

The page must embody the product promise. It is delivered as a static document with no client framework, hydration, third-party runtime, analytics, downloaded images, or downloaded fonts. Its only image payload is a request-free SVG favicon embedded in the document URL.

The visual reference is the restraint and technical clarity of `fx.sh`, not its composition or brand. Agent Lowmem uses its own copy, typographic identity, pressure-state accent, and terminal content.

## 2. Release scope

Version one contains one route, `/`, with this content order:

1. Minimal navigation with the Agent Lowmem wordmark, source link, and status.
2. Hero with the headline “More agents. Less RAM.” and the eyebrow “Native Rust policy runner for macOS”.
3. A concise explanation of the native CLI and its target user.
4. A primary “Follow the build on GitHub” action.
5. A representative terminal session combining `agent-lowmem doctor` with a non-interactive managed run.
6. A compact trace inside that window showing inspection, policy, lock, launch, supervision, owned cleanup, and the final result.
7. A concise managed-runner definition and `without / with` comparison.
8. Four short capability descriptions: global serialization, no-watch execution, bounded time, and owned-process cleanup.
9. An honest release line: `v0.1 · early development · macOS arm64`.
10. Footer links to source and license.

The page must not publish a non-working installation command. Once a real CLI release and installer exist, the primary action will become a copyable installation command without requiring a visual redesign.

## 3. Future scope

Future versions may add `docs`, `lib`, `source`, and `blog`. The initial information architecture must leave room for these destinations, but the first release must not display dead links or empty routes. `source` links directly to `https://github.com/Pleo2/agent-lowmem`.

When multiple content routes become necessary, the project may adopt a static-site generator. That migration must preserve static output, progressive enhancement, and the performance contract unless a reviewed requirement justifies an exception.

## 4. Technical architecture

The deployed product consists of a single hand-authored `index.html`. Its critical CSS is inline, and the initial release contains no JavaScript. Vercel configuration may exist outside the transferred page to define clean URLs, caching, and security headers.

There is no backend, API, database, authentication, cookie, service worker, external asset request, or build-time framework. A compact `ag_` SVG favicon is embedded as a `data:` URL so browsers do not make a fallback favicon request. The HTML remains useful when CSS is unavailable.

The repository initially contains:

```text
index.html
vercel.json
README.md
docs/superpowers/specs/2026-09-03-agent-lowmem-landing-design.md
```

Validation scripts may be added as development-only files when they measurably enforce the contract. They must not become browser dependencies or add production requests.

## 5. Visual system

The interface uses a warm black background, ivory foreground, restrained neutral text, thin borders, and a narrow vertical reading column. A CSS-only lavender-to-indigo-to-cyan gradient accents only the wordmark cursor, status dot, primary-link underline, terminal prompt, and ready state. A light palette uses darker stops with the same hierarchy.

The terminal session uses a restrained macOS window treatment: rounder corners, a compact three-zone title bar, decorative traffic-light controls, a centered `agent-lowmem — doctor` title, and shallow border-and-shadow depth. The terminal surface uses 45% opacity and its title bar 55%, integrating the window with the page instead of presenting it as an opaque card. One second after the terminal arrives, the managed-run command appears and its seven states resolve sequentially from a finite loader to a checkmark. The final state clearly reads `result completed`; the sequence never loops. Its title bar suggests the current macOS material hierarchy with a CSS gradient, but avoids `backdrop-filter`, images, scripts, and runtime dependencies so the terminal remains inexpensive to render.

The browser selects the palette with `prefers-color-scheme`. The document declares support for both color schemes. Theme adaptation requires no script, control, local storage, cookie, or initial flash.

All landing-page text uses this local-first monospace stack:

```css
"JetBrains Mono", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas,
"Liberation Mono", monospace
```

No JetBrains Mono file is downloaded. A device with the font installed uses it; other devices use their native monospace face. A system sans stack is reserved for future long-form documentation or blog content and is not used by the initial landing. Typography fidelity never takes priority over first-load cost.

The wordmark is textual: `agent_lowmem`. The primary action is an underlined text link rather than a bordered or filled button. A short entrance treatment may move the terminal once and then stop. The managed-run sequence may reveal each state once and must settle completely. The page performs no continuous animation after its initial presentation. `prefers-reduced-motion: reduce` removes the entrance treatment and shows the completed sequence immediately.

## 6. Interaction and responsive behavior

The first release is primarily a reading surface. The GitHub call to action and source links use ordinary anchors, so core behavior requires no JavaScript.

The layout is a single reading column on small and medium screens. On wider screens, whitespace may increase but line lengths remain bounded. The terminal wraps or horizontally contains long code without forcing document-level horizontal scrolling.

Focus states are always visible. Every interactive element has a clear accessible name and a touch target appropriate to its context. Content order and hierarchy remain unchanged between themes and screen sizes.

## 7. Accessibility

The document uses semantic landmarks, one `h1`, ordered heading levels, descriptive links, and a language declaration. Decorative terminal marks are hidden from accessibility APIs when they add no meaning. Terminal content that communicates product behavior remains readable text.

Both palettes must meet WCAG 2.2 AA contrast for normal text and interactive states. The page must remain navigable by keyboard at 200% zoom and must not rely on color alone to express status.

All visible auxiliary labels use at least 12 CSS pixels at the default root size. The textual home link uses its visible `agent_lowmem` content as its accessible name rather than overriding it with a divergent ARIA label.

## 8. Performance contract

The initial landing targets all of the following on a cold load:

- one HTTP request for the rendered page;
- less than 15 KiB transferred after HTTP compression;
- zero downloaded fonts;
- zero production JavaScript;
- zero hydration;
- zero third-party requests;
- zero continuous animation or intentional background work after entrance;
- no layout shift caused by remote assets;
- Lighthouse targets of 100 for Performance, Accessibility, Best Practices, and SEO under its applicable desktop audit.

The product will describe itself as exceptionally small and fast, but it will not claim to be “the fastest page in the world” without a reproducible comparison protocol and evidence.

The repository must include a deterministic check that fails when the compressed `index.html` exceeds 15 KiB. Validation must also confirm that the document references no remote stylesheet, script, image, or font resource.

## 9. Metadata and discoverability

The page title, description, canonical URL, Open Graph text, and X card text describe Agent Lowmem accurately. Because images are excluded from the first release, metadata must not reference a generic or missing preview image.

The page includes minimal structured data for an open-source developer tool only when every declared property is already factual. It must not advertise an installer, stable release, measured memory savings, or platform support beyond current repository evidence.

## 10. Deployment

The public GitHub repository is `Pleo2/agentlowmem.dev`. The site deploys as static content on Vercel and is attached to `agentlowmem.dev`.

Deployment configuration sets an explicit UTF-8 content type, a restrictive content security policy compatible with inline CSS and no script, referrer policy, MIME-sniffing protection, and frame restrictions. The HTML uses revalidation-friendly caching so status and copy updates can propagate promptly.

Publishing must not require introducing a client framework. The GitHub repository remains the source of truth for deployed content.

## 11. Verification

Before the first public handoff:

1. Validate HTML structure and all local links.
2. Confirm the compressed transfer budget deterministically.
3. Confirm there are no production script elements or external subresources.
4. Verify both system-selected themes and reduced-motion behavior.
5. Verify keyboard navigation, visible focus, zoom, and mobile-width layout.
6. Run a production Lighthouse audit against the deployed page.
7. Confirm headers on the public domain.
8. Confirm the GitHub source action resolves to `Pleo2/agent-lowmem`.

Visual browser testing is a release check, not a runtime dependency.

## 12. Explicit non-goals

The first release does not include documentation routes, a blog, a library reference, an interactive terminal, a waitlist, analytics, telemetry, a theme toggle, an installation script, a package download, a CMS, user accounts, comments, search, or localization.

These exclusions keep the first public artifact consistent with Agent Lowmem’s simplicity and resource-efficiency goals.
