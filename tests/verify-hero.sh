#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
FILE="$ROOT/index.html"
HERO=$(sed -n '/<section class="hero"/,/<\/section>/p' "$FILE")
FOOTER=$(sed -n '/<footer[ >]/,/<\/footer>/p' "$FILE")

fail() {
  echo "hero contract: $1" >&2
  exit 1
}

printf '%s' "$HERO" | grep -Fq '<h1 id="hero-title">Native policy runner for memory-constrained Macs.</h1>' || fail 'hero must lead with the direct product definition'
printf '%s' "$HERO" | grep -Fq '<p class="lede">Agent Lowmem keeps agent-launched validation predictable on Apple Silicon—one managed heavy operation at a time. Written in Rust.</p>' || fail 'lede must explain the product without repeating the headline'
if printf '%s' "$HERO" | grep -Fq 'More agents.'; then
  fail 'tagline must not compete with the product definition in the hero'
fi
printf '%s' "$FOOTER" | grep -Fq '<span>More agents. Less RAM.</span>' || fail 'tagline must close the page as a footer signature'
grep -Eq 'h1[[:space:]]*\{[^}]*font:[^;]*clamp\(1\.5rem,[[:space:]]*4vw,[[:space:]]*2rem\)[^;]*var\(--mono\)' "$FILE" || fail 'headline must use the compact product-definition scale'
grep -Eq 'h1[[:space:]]*\{[^}]*font:[[:space:]]*500[[:space:]]' "$FILE" || fail 'headline must use the lighter 500 weight'
grep -Eq '\.section-label[[:space:]]*\{[^}]*font-weight:[[:space:]]*500' "$FILE" || fail 'section label must use the lighter 500 weight'
grep -Eq 'h2[[:space:]]*\{[^}]*font:[[:space:]]*500[[:space:]]' "$FILE" || fail 'section titles must use the lighter 500 weight'

echo "hero contract passed"
