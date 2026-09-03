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

printf '%s' "$HERO" | grep -Fq '<h1 id="hero-title">More agents. Less RAM.</h1>' || fail 'tagline must open the hero'
printf '%s' "$HERO" | grep -Fq '<p class="lede"><strong>Native policy runner for memory-constrained Macs.</strong> Agent Lowmem keeps agent-launched validation predictable on Apple Silicon—one managed heavy operation at a time. Written in Rust.</p>' || fail 'lede must lead with the direct product definition'
printf '%s' "$FOOTER" | grep -Fq '<span>Built for constrained machines.</span>' || fail 'footer must not duplicate the hero tagline'
grep -Eq 'h1[[:space:]]*\{[^}]*font:[^;]*clamp\(\.95rem,[[:space:]]*2vw,[[:space:]]*1\.125rem\)[^;]*var\(--mono\)' "$FILE" || fail 'tagline must use the small terminal-like title scale'
grep -Eq 'h1[[:space:]]*\{[^}]*font:[[:space:]]*500[[:space:]]' "$FILE" || fail 'headline must use the lighter 500 weight'
grep -Eq '\.section-label[[:space:]]*\{[^}]*font-weight:[[:space:]]*500' "$FILE" || fail 'section label must use the lighter 500 weight'
grep -Eq 'h2[[:space:]]*\{[^}]*font:[[:space:]]*500[[:space:]]' "$FILE" || fail 'section titles must use the lighter 500 weight'

echo "hero contract passed"
