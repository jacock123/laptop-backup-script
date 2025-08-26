#!/usr/bin/env bash

set -euo pipefail

# ====== Checking arguments ======
if [[ $# -ne 3 ]]; then
    echo "Error: Invalid number of arguments."
    echo "Usage: $0 <Passwort> <Input-Datei> <Output-Datei>"
    exit 1
fi

# ====== Assign arguments ======
ENC_PASS="$1"
INPUT_FILE="$2"
OUTPUT_FILE="$3"

# ====== Check if input file exists ======
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: the input file does not exist: $INPUT_FILE"
    exit 1
fi

# ====== decryption ======
openssl enc -aes-256-cbc -pbkdf2 -iter 600000 -d \
    -k "$ENC_PASS" \
    -in "$INPUT_FILE" \
    -out "$OUTPUT_FILE"

echo "decryption completed: $OUTPUT_FILE"
