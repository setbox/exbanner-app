#!/usr/bin/env bash
set -euo pipefail

figlet="${FIGLET:-figlet}"
root="$(cd "$(dirname "$0")/../.." && pwd)"
cases="$root/test/support/golden_cases.tsv"
golden="$root/test/fixtures/golden"
fonts="$(mktemp -d)"
trap 'rm -rf "$fonts"' EXIT

for font in "$root"/priv/fonts/*.flf "$root"/priv/fonts/*.tlf; do
  perl -pe 's/^\xEF\xBB\xBF// if $. == 1' "$font" > "$fonts/$(basename "$font")"
done

rm -rf "$golden"
failed=()

for font in "$fonts"/*.flf "$fonts"/*.tlf; do
  file="$(basename "$font")"
  name="${file%.*}"
  mkdir -p "$golden/$name"

  while IFS=$'\t' read -r case width text; do
    if ! printf '%s' "${text//\\n/$'\n'}" |
      "$figlet" -d "$fonts" -f "$name" -w "$width" > "$golden/$name/$case.txt" 2> /dev/null; then
      rm -rf "$golden/$name"
      failed+=("$name")
      break
    fi
  done < "$cases"
done

if [ "${#failed[@]}" -gt 0 ]; then
  echo "figlet could not render: ${failed[*]}" >&2
fi
