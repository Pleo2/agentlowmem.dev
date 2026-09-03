# Agent Lowmem Landing Design

**Status:** Implemented

**Date:** 2026-09-03

**Product:** Agent Lowmem

**Domain:** `agentlowmem.dev`

**Repository:** `Pleo2/agentlowmem.dev`

**Tagline:** More agents. Less RAM.

## 1. Purpose

The first Agent Lowmem website is a public, English-language landing page for developers using coding agents on memory-constrained Macs. It introduces the product, demonstrates its intended command-line experience, and directs visitors to the open-source implementation while the CLI is in early development.

The page must embody the product promise. It is delivered as a static document with no client framework, hydration, third-party runtime, analytics, images, or downloaded fonts.

The visual reference is the restraint and technical clarity of `fx.sh`, not its composition or brand. Agent Lowmem uses its own copy, typographic identity, pressure-state accent, and terminal content.

## 2. Release scope

Version one contains one route, `/`, with this content order:

1. Minimal navigation with the Agent Lowmem wordmark, source link, and status.
2. Hero with the headline “More agents. Less RAM.”
3. A concise explanation of the native CLI and its target user.
4. A primary “Follow the build on GitHub” action.
5. A representative, non-interactive `agent-lowmem doctor` terminal transcript.
6. Four short capability descriptions: global serialization, no-watch execution, bounded time, and owned-process cleanup.
7. An honest release line: `v0.1 · early development · macOS arm64`.
8. Footer links to source and license.

The page must not publish a non-working installation command. Once a real CLI release and installer exist, the primary action will become a copyable installation command without requiring a visual redesign.

## 3. Future scope

Future versions may add `docs`, `lib`, `source`, and `blog`. The initial information architecture must leave room for these destinations, but the first release must not display dead links or empty routes. `source` links directly to `https://github.com/Pleo2/agent-lowmem`.

When multiple content routes become necessary, the project may adopt a static-site generator. That migration must preserve static output, progressive enhancement, and the performance contract unless a reviewed requirement justifies an exception.

## 4. Technical architecture

The deployed product consists of a single hand-authored `index.html`. Its critical CSS is inline, and the initial release contains no JavaScript. Vercel configuration may exist outside the transferred page to define clean URLs, caching, and security headers.

There is no backend, API, database, authentication, cookie, service worker, external asset request, or build-time framework. The HTML remains useful when CSS is unavailable.

The repository initially contains:

```text
index.html
vercel.json
README.md
docs/superpowers/specs/2026-09-03-agent-lowmem-landing-design.md
```

Validation scripts may be added as development-only files when they measurably enforce the contract. They must not become browser dependencies or add production requests.

## 5. Visual system

The interface uses a warm black background, ivory foreground, restrained neutral text, thin borders, small corner radii, and a low-saturation orange pressure-state accent. A light palette is defined with the same hierarchy.

The browser selects the palette with `prefers-color-scheme`. The document declares support for both color schemes. Theme adaptation requires no script, control, local storage, cookie, or initial flash.

Display text, navigation, terminal output, and metrics use this local-first monospace stack:

```css
"JetBrains Mono", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas,
"Liberation Mono", monospace
```

No JetBrains Mono file is downloaded. A device with the font installed uses it; other devices use their native monospace face. Body copy uses `system-ui`, `-apple-system`, `BlinkMacSystemFont`, and platform fallbacks. Typography fidelity never takes priority over first-load cost.

The wordmark is textual: `agent_lowmem`. A short entrance treatment may move a terminal line or cursor once and then stop. The page must perform no continuous animation after its initial presentation. `prefers-reduced-motion: reduce` removes the entrance treatment entirely.

## 6. Interaction and responsive behavior

The first release is primarily a reading surface. The GitHub call to action and source links use ordinary anchors, so core behavior requires no JavaScript.

The layout is a single reading column on small and medium screens. On wider screens, whitespace may increase but line lengths remain bounded. The terminal wraps or horizontally contains long code without forcing document-level horizontal scrolling.

Focus states are always visible. Every interactive element has a clear accessible name and a touch target appropriate to its context. Content order and hierarchy remain unchanged between themes and screen sizes.

## 7. Accessibility

The document uses semantic landmarks, one `h1`, ordered heading levels, descriptive links, and a language declaration. Decorative terminal marks are hidden from accessibility APIs when they add no meaning. Terminal content that communicates product behavior remains readable text.

Both palettes must meet WCAG 2.2 AA contrast for normal text and interactive states. The page must remain navigable by keyboard at 200% zoom and must not rely on color alone to express status.

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
