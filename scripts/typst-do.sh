#!/bin/zsh

# 1. No 'set -m' here; it fails in background jobs
if [[ -z "$1" ]]; then
    exit 1
fi

typ_file="$1"
pdf_file="${typ_file:r}.pdf"

# 2. Start Typst watch
# Redirect everything to a log or null to prevent buffer pipe issues
typst watch "$typ_file" >/dev/null 2>&1 &
typ_pid=$!

# 3. Wait for PDF to exist
while [[ ! -f "$pdf_file" ]]; do
    sleep 0.2
done

# 4. Start MuPDF
mupdf "$pdf_file" >/dev/null 2>&1 &
mu_pid=$!

# Cleanup on exit
cleanup() {
    kill $typ_pid $mu_pid 2>/dev/null
}
trap cleanup EXIT INT TERM

# 5. Background-safe Loop
# We check if the processes exist using kill -0
while kill -0 $mu_pid 2>/dev/null && kill -0 $typ_pid 2>/dev/null; do
    # Use inotifywait in a way that doesn't require job control
    # We block here until the file changes
    inotifywait -q -e close_write "$pdf_file" >/dev/null 2>&1
    
    # Reload MuPDF
    kill -HUP $mu_pid 2>/dev/null
done
