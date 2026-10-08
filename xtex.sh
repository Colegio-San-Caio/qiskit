#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="./MOSFETQexchange"
OUTPUT_DIR="${BASE_DIR}/output"
SPOOL_DIR="${BASE_DIR}/spool/fax"
mkdir -p "$OUTPUT_DIR" "$SPOOL_DIR"
echo "================================================================Cache Cleared"
echo "[*] Touch *.*"; find . -maxdepth 2 -type f -exec touch {} + 2>/dev/null || true

for XTEX_FILE in *.xtex; do
  [ -f "$XTEX_FILE" ] || continue
  DOC="${XTEX_FILE%.xtex}"
  TEX="${DOC}.tex"
  PDF="${DOC}.pdf"
  
  TITLE=$(grep "^@title" "$XTEX_FILE" | cut -c7-)
  AUTHOR=$(grep "^@author" "$XTEX_FILE" | cut -c9-)
  EQ=$(grep "^@equation" "$XTEX_FILE" | cut -c11-)
  BODY=$(grep "^@body" "$XTEX_FILE" | cut -c7-)

  # expand to .tex for git
  cat > "$TEX" <<TEXEOF
\\documentclass{article}
\\title{$TITLE}
\\author{$AUTHOR}
\\begin{document}
\\maketitle
$BODY
\\begin{equation}$EQ\\end{equation}
\\end{document}
TEXEOF

  # BYPASS LOGIC FOR GITS
  if command -v xelatex >/dev/null 2>&1; then
    echo "[*] xelatex found — compiling $TEX"
    xelatex -interaction=nonstopmode "$TEX" >/dev/null
    mv "$PDF" "$OUTPUT_DIR/" 2>/dev/null || true
  else
    echo "[!] xelatex not found. .xtex expanded to $TEX successfully."
    echo "[!] bypass: .xtex -> python -> $OUTPUT_DIR/$PDF"
    python3 - <<PY
import fitz
t="""$TITLE"""; a="""$AUTHOR"""; e="""$EQ"""; b="""$BODY"""; n="$DOC"
doc=fitz.open();p=doc.new_page(width=595,height=842);y=40
def w(txt,sz=11):
 global y; p.insert_text((50,y),txt[:108],fontsize=sz); y+=sz*1.6
w(t,14); w(a,8); w(f"Evergreen (0)b — 'N' AH (0)b jc 'N' = solved",8); y+=8; w("Analysis:",11)
for i in range(0,len(b),90): w(b[i:i+90],10)
w(f"Eq: {e}",11)
doc.save(f"$OUTPUT_DIR/{n}.pdf")
PY
    cp "$OUTPUT_DIR/$PDF" "./sigma_0b_jc.pdf" 2>/dev/null || cp "$OUTPUT_DIR/$PDF" "./${DOC}.pdf"
    echo "[+] Success: $OUTPUT_DIR/$PDF generated (bypass)"
  fi
done
echo "================================================================Pipeline Complete"
