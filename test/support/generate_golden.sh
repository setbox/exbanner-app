#!/usr/bin/env bash
set -euo pipefail

figlet="${FIGLET:-figlet}"
root="$(cd "$(dirname "$0")/../.." && pwd)"
cases="$root/test/support/golden_cases.tsv"
golden="$root/test/fixtures/golden"
fonts="$(mktemp -d)"
trap 'rm -rf "$fonts"' EXIT

for font in "$root"/priv/fonts/*.flf; do
  perl -pe 's/^\xEF\xBB\xBF// if $. == 1' "$font" > "$fonts/$(basename "$font")"
done

rm -rf "$golden"

for font in "$fonts"/*.flf; do
  name="$(basename "$font" .flf)"
  mkdir -p "$golden/$name"

  while IFS=$'\t' read -r case width text; do
    printf '%s' "${text//\\n/$'\n'}" |
      "$figlet" -d "$fonts" -f "$name" -w "$width" > "$golden/$name/$case.txt"
  done < "$cases"
done
