#!/usr/bin/env bash
set -euo pipefail

# Build a sample sheet CSV (sample,fq1,fq2,lane) from a list of FASTQ paths.
# Usage: ./build_sample_sheet.sh [input_list_file] [output_csv]
# Defaults: input_list_file="data" relative to repo root, output_csv="config/samples.csv".

infile=${1:-data}
outfile=${2:-config/samples.csv}

if [[ ! -f "$infile" ]]; then
  echo "[ERROR] Input list not found: $infile" >&2
  exit 1
fi

mkdir -p "$(dirname "$outfile")"

awk -v outfile="$outfile" '
  BEGIN {
    FS="\n"
  }
  {
    line=$0
    if (line == "" || line ~ /^#/) next

    # Strip directory to get basename.
    n=split(line, parts, "/")
    fname=parts[n]

    # Sample: extract text after "25091Aru_" and up to the next "_".
    if (match(fname, /25091Aru_/)) {
      rest=substr(fname, RSTART+9)
      idx=index(rest, "_")
      if (idx > 0) {
        sample=substr(rest, 1, idx-1)
      } else {
        sample=rest
      }
    } else {
      printf "[WARN] Skipping entry without 25091Aru_ prefix: %s\n", line > "/dev/stderr"
      next
    }

    lane=""
    if (match(fname, /L00[0-9][0-9]*/)) {
      lane=substr(fname, RSTART+3, RLENGTH-3)
    }

    if (lane !~ /^(1|2|3|4|5|7|8)$/) {
      printf "[WARN] Skipping entry with unsupported lane format: %s\n", line > "/dev/stderr"
      next
    }

    key=sample "|" lane

    if (index(fname, "_R1_")) {
      r1[key]=fname
      keys[key]=1
    } else if (index(fname, "_R2_")) {
      r2[key]=fname
      keys[key]=1
    } else {
      printf "[WARN] Skipping entry without R1/R2 marker: %s\n", line > "/dev/stderr"
      next
    }
  }
  END {
    print "sample,fq1,fq2,lane" > outfile
    missing=0
    for (key in keys) {
      split(key, kp, "|")
      sample=kp[1]
      lane=kp[2]
      fq1=r1[key]
      fq2=r2[key]
      if (fq1 == "" || fq2 == "") {
        missing=1
        printf "[WARN] Missing R1/R2 pairs for: sample=%s, lane=%s\n", sample, lane > "/dev/stderr"
        continue
      }
      row=sample "," fq1 "," fq2 "," lane
      if (!(row in seen)) {
        print row >> outfile
        seen[row]=1
      }
    }
    if (missing) exit 2
    printf "[INFO] Wrote %s\n", outfile > "/dev/stderr"
  }
' "$infile"
