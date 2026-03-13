#!/usr/bin/env bash
set -euo pipefail

usage() {
	cat <<'EOF'
Usage: ./sample_sheet_gen.sh [input_file] [output_file]

Generate a CSV with columns: sample,fq1,fq2,lane

Arguments:
	input_file   Optional. Defaults to sumtest.txt
	output_file  Optional. If provided, write CSV to this file. Otherwise write to stdout.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
	usage
	exit 0
fi

input_file="${1:-sumtest.txt}"
output_file="${2:-}"

if [[ ! -f "$input_file" ]]; then
	echo "Error: input file not found: $input_file" >&2
	exit 1
fi

if [[ ! -s "$input_file" ]]; then
	echo "Error: input file is empty: $input_file" >&2
	exit 1
fi

generate_csv() {
	awk -F',' '
		function trim(s) {
			sub(/^[[:space:]]+/, "", s)
			sub(/[[:space:]]+$/, "", s)
			return s
		}

		BEGIN {
			OFS = ","
			print "sample,fq1,fq2,lane"
		}

		{
			fname = trim($1)
			if (fname == "") {
				next
			}

			n = split(fname, parts, "_")
			if (n < 5) {
				print "Warning: malformed filename, skipping: " fname > "/dev/stderr"
				next
			}

			sample = parts[2]

			lane_token = ""
			for (i = 1; i <= n; i++) {
				if (parts[i] ~ /^L[0-9][0-9][0-9]$/) {
					lane_token = parts[i]
					break
				}
			}

			if (lane_token == "") {
				print "Warning: lane token not found, skipping: " fname > "/dev/stderr"
				next
			}

			lane = lane_token
			sub(/^L0*/, "", lane)
			if (lane == "") {
				lane = 0
			}

			read_dir = ""
			if (fname ~ /_R1_/) {
				read_dir = "R1"
			} else if (fname ~ /_R2_/) {
				read_dir = "R2"
			} else {
				print "Warning: read direction not found (_R1_/_R2_), skipping: " fname > "/dev/stderr"
				next
			}

			key = fname
			gsub(/_R[12]_/, "_R?_", key)

			sample_by_key[key] = sample
			lane_by_key[key] = lane

			if (read_dir == "R1") {
				r1[key] = fname
			} else {
				r2[key] = fname
			}
		}

		END {
			for (k in sample_by_key) {
				if ((k in r1) && (k in r2)) {
					print sample_by_key[k], "/data/" r1[k], "/data/" r2[k], lane_by_key[k]
				} else {
					if (k in r1) {
						print "Warning: missing R2 pair for: " r1[k] > "/dev/stderr"
					} else {
						print "Warning: missing R1 pair for: " r2[k] > "/dev/stderr"
					}
				}
			}
		}
	' "$input_file"
}

if [[ -n "$output_file" ]]; then
	generate_csv > "$output_file"
else
	generate_csv
fi
