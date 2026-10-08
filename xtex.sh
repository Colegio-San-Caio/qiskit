#!/usr/bin/env bash
set -euo pipefail
OUTPUT_DIR="./MOSFETQexchange/output"
SPOOL_DIR="./MOSFETQexchange/spool/fax"
mkdir -p "$OUTPUT_DIR" "$SPOOL_DIR"
echo "================================================================Cache Cleared"
for XTEX_FILE in *.xtex; do
  [ -f "$XTEX_FILE" ] || continue
  DOC="${XTEX_FILE%.xtex}"
  export DOC
  export TITLE="$(grep "^@title" "$XTEX_FILE" | cut -c7- | tr -d '\r')"
  export BODY="$(grep "^@body" "$XTEX_FILE" | cut -c7- | tr -d '\r')"
  export EQ="$(grep "^@equation" "$XTEX_FILE" | cut -c11- | tr -d '\r')"
  export PDF="$OUTPUT_DIR/${DOC}.pdf"
  echo "[!] xelatex not found..xtex expanded to ${DOC}.tex successfully."
  echo "[!] bypass: .xtex -> oeneyepdf.c -> $PDF"
  python3 ./oeneyepdf.c
  cp "$PDF" ./sigma_0b_jc.pdf
  echo "FAX by oeneye.c + oeneyepdf.c / $TITLE" > "$SPOOL_DIR/${DOC}.fax"
  echo "[FAX] $SPOOL_DIR/${DOC}.fax"
done
echo "================================================================Pipeline Complete"
ls -lh "$OUTPUT_DIR" ./sigma_0b_jc.pdf
