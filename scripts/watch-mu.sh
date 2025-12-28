#!/bin/zsh

# 1. Enable job control (essential for 'wait' to track background jobs in scripts)
set -m

if [[ -z "$1" ]]; then
    echo "Usage: $0 <filename.pdf>"
    exit 1
fi

f="$1"

# Start MuPDF
mupdf "$f" &
mu_pid=$!

# Cleanup on exit
cleanup() {
    kill $mu_pid 2>/dev/null
    exit 0
}
trap cleanup SIGINT SIGTERM

echo "Watching $f (PID: $mu_pid). Press Ctrl+C to stop."

while true; do
    # Start inotifywait in the background
    inotifywait -q --event close_write "$f" &
    in_pid=$!

    # Use a simple wait loop instead of 'wait -n' for better compatibility
    # This waits until either the viewer or the file-watcher exits
    while kill -0 $mu_pid 2>/dev/null && kill -0 $in_pid 2>/dev/null; do
        sleep 0.1
    done

    # If MuPDF is gone, exit the script
    if ! kill -0 $mu_pid 2>/dev/null; then
        kill $in_pid 2>/dev/null
        exit 0
    fi

    # If we reached here, inotifywait triggered. Reload MuPDF.
    kill -HUP $mu_pid
done
