#!/usr/bin/env bash
set -euo pipefail

# Sort a sample sheet (CSV with header) by the first column and keep header.
infile=${1:-}
outfile=${2:-$infile}

if [[ -z "$infile" ]]; then
  echo "Usage: $0 <input_csv> [output_csv]" >&2
  exit 1
fi

if [[ ! -f "$infile" ]]; then
  echo "[ERROR] Input file not found: $infile" >&2
  exit 1
fi

if [[ -z "$outfile" ]]; then
  echo "[ERROR] Output path not specified" >&2
  exit 1
fi

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

header=$(head -n 1 "$infile")
printf '%s\n' "$header" > "$tmp"

tail -n +2 "$infile" | LC_ALL=C sort -t',' -k1,1 -s >> "$tmp"

mv "$tmp" "$outfile"
trap - EXIT

echo "[INFO] Wrote sorted sheet to $outfile" >&2
