#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
FILE="$ROOT/index.html"
HERO=$(sed -n '/<section class="hero"/,/<\/section>/p' "$FILE")

fail() {
  echo "hero contract: $1" >&2
  exit 1
}

if printf '%s' "$HERO" | grep -Eq 'class="eyebrow"'; then
  fail 'Rust positioning must not appear as a detached eyebrow'
fi

printf '%s' "$HERO" | grep -Eq '<p class="lede">[^<]*<strong>Native Rust policy runner for macOS\.</strong></p>' || fail 'Rust positioning must close the lede in bold'
grep -Eq 'h1[[:space:]]*\{[^}]*font:[^;]*clamp\(2\.35rem,[[:space:]]*6vw,[[:space:]]*3\.75rem\)[^;]*var\(--mono\)' "$FILE" || fail 'headline must use the restrained 60px mono scale'

echo "hero contract passed"
