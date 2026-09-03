#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
INDEX="$ROOT/index.html"
ROBOTS="$ROOT/robots.txt"
SITEMAP="$ROOT/sitemap.xml"
VERCEL="$ROOT/vercel.json"

fail() {
  echo "prerelease public contract: $1" >&2
  exit 1
}

[ -f "$ROBOTS" ] || fail 'missing robots.txt'
[ -f "$SITEMAP" ] || fail 'missing sitemap.xml'

grep -Eq '^User-agent:[[:space:]]*\*$' "$ROBOTS" || fail 'robots.txt must address every crawler'
grep -Eq '^Allow:[[:space:]]*/$' "$ROBOTS" || fail 'robots.txt must allow the public landing'
grep -Eq '^Sitemap:[[:space:]]*https://agentlowmem\.dev/sitemap\.xml$' "$ROBOTS" || fail 'robots.txt must advertise the canonical sitemap'
grep -Eq '<loc>https://agentlowmem\.dev/</loc>' "$SITEMAP" || fail 'sitemap must contain the canonical landing URL'
grep -Eq "connect-src 'self'" "$VERCEL" || fail 'CSP must permit same-origin robots discovery'

if grep -Eq 'href="https://github\.com/Pleo2/agent-lowmem(["/#?])' "$INDEX"; then
  fail 'public page must not link to the private CLI repository'
fi

LINKS=$(grep -Eo 'href="https://github\.com/[^" ]+' "$INDEX" | cut -d '"' -f 2 | sort -u)
[ -n "$LINKS" ] || fail 'missing public GitHub destinations'

printf '%s\n' "$LINKS" | while IFS= read -r url; do
  status=$(curl -sS -L --max-time 15 -A 'agentlowmem.dev-link-check' -o /dev/null -w '%{http_code}' "$url") || fail "unreachable link: $url"
  case "$status" in
    2??|3??) ;;
    *) fail "link returned HTTP $status: $url" ;;
  esac
done

echo "prerelease public contract passed"
