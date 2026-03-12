#!/bin/bash

# File containing expected checksums
#CHECKSUM_FILE="sums.csv"
CHECKSUM_FILE="sumtest.txt"

# Verify the file exists
if [[ ! -f "$CHECKSUM_FILE" ]]; then
    echo "Error: $CHECKSUM_FILE not found."
    exit 1
fi

# Read sums.txt line by line
while IFS=',' read -r filename expected_md5; do
    # Skip empty lines
    [[ -z "$filename" || -z "$expected_md5" ]] && continue

    # Check if the file exists
    if [[ ! -f "$filename" ]]; then
        echo "$filename: MISSING"
        continue
    fi

    # Calculate actual md5 sum
    actual_md5=$(md5sum "$filename" | awk '{print $1}')

    # Compare
    if [[ "$actual_md5" == "$expected_md5" ]]; then
        echo "$filename: PASS"
    else
        echo "$filename: FAIL"
    fi
done < "$CHECKSUM_FILE"
