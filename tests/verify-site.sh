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
