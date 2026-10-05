#!/usr/bin/env bash
cd "$(dirname "$0")"

# Function to reassemble termuxDB.bin from chunk parts if missing
reassemble_db() {
    if [ ! -f "termuxDB.bin" ] && [ -d "termuxDB_parts" ]; then
        echo "[termuxDB] Reassembling termuxDB.bin from parts..."
        cat termuxDB_parts/part_* > termuxDB.bin
    fi
}

# Function to split termuxDB.bin into chunks before pushing
split_and_stage_db() {
    if [ -f "termuxDB.bin" ]; then
        echo "[termuxDB] Splitting termuxDB.bin into safe chunks (<50MB)..."
        mkdir -p termuxDB_parts
        rm -f termuxDB_parts/part_*
        split -b 45M termuxDB.bin termuxDB_parts/part_
        git add termuxDB_parts/
        # Ensure the monolithic bin file is ignored/untracked to avoid GitHub limits
        git rm --cached termuxDB.bin 2>/dev/null || true
    fi
}

# Run reassembly on script invocation
reassemble_db

# Command handling
case "${1:-}" in
    init)
        echo "[termuxDB] Initialized database context."
        ls -lh termuxDB.bin 2>/dev/null || echo "[termuxDB] termuxDB.bin not found locally. Run reassembly or check parts."
        ;;
    commit)
        shift
        split_and_stage_db
        git commit -m "$*"
        git push origin main
        ;;
    push)
        split_and_stage_db
        git add .
        git commit -m "chore: auto-sync termuxDB parts and repository updates" || true
        git push origin main
        ;;
    *)
        echo "Usage: ./termuxDB.sh [init|commit 'message'|push]"
        ;;
esac
