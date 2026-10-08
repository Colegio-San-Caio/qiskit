#!/usr/bin/env bash
set -euo pipefail
DOC_NAME="jc_theta_assumptions"
TEX_FILE="${DOC_NAME}.tex"
PDF_FILE="${DOC_NAME}.pdf"
echo "================================================================Cache Cleared"
echo "[*] Initializing: ${TEX_FILE}"
command -v xelatex >/dev/null || { echo "install texlive: pkg install texlive"; exit 1; }
echo "[*] Pass 1..."
xelatex -interaction=nonstopmode "${TEX_FILE}" > /dev/null
[ -f "${DOC_NAME}.aux" ] && echo "[*] Pass 2..." && xelatex -interaction=nonstopmode "${TEX_FILE}" > /dev/null
[ -f "${PDF_FILE}" ] && echo "[+] Success: ${PDF_FILE} ($(du -h ${PDF_FILE}|cut -f1))" && sha256sum "${PDF_FILE}" > "${PDF_FILE}.sha256" || { echo "fail"; exit 1; }
echo "================================================================Pipeline Complete"
