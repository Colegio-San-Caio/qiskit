#!/data/data/com.termux/files/usr/bin/bash
# termuxDB manager for qiskit repo
DB="./termuxDB.bin"
QISKIT_FILE="./quantum_test.py"

case "$1" in
  init)
    echo "[termuxDB] init db at $DB"
    echo "qiskit-bell-db-v1 $(date)" > "$DB"
    ls -lh "$DB"
    ;;
  info)
    echo "=== TermuxDB Info ==="
    ls -lh "$DB" 2>/dev/null || echo "no DB yet, run:./termuxDB.sh init"
    echo "=== Qiskit Repo ==="
    ls -lh
    python $QISKIT_FILE 2>/dev/null || python3 $QISKIT_FILE
    ;;
  backup)
    git add -f "$DB"
    git commit -m "db: backup termuxDB $(date +%F_%H:%M)"
    git push origin main
    ;;
  clean)
    rm -f "$DB"
    echo "cleaned"
    ;;
  *)
    echo "Usage: $0 {init|info|backup|clean}"
    ;;
esac
