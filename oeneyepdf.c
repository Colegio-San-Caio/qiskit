#!/usr/bin/env python3
# oeneyepdf.c — set by oeneye.c — raw PDF engine — PL:36883
import os, sys
title = os.environ.get("TITLE","")
body = os.environ.get("BODY","")
eq = os.environ.get("EQ","")
doc = os.environ.get("DOC","jc_sigma")
out = os.environ.get("PDF","./MOSFETQexchange/output/jc_sigma.pdf")
author = "oeneye.c + oeneyepdf.c"

def esc(s):
    # safe escape for PDF parentheses — no backslash hell
    return s.replace(chr(92), chr(92)+chr(92)).replace("(", r"\(").replace(")", r"\)")

lines = [
    f"FAX by oeneyeFAX — set by {author}",
    f"Title: {title}",
    f"Author: {author} PL:36883",
    f"Doc: {doc}",
    "",
    "Analysis:",
    body[:1500],
    "",
    f"Equation: {eq}",
    "",
    "UNITY: 1+0=1 0 has jc",
    "Evergreen (0)b — 'N' AH (0)b jc 'N' = solved",
    "g=0 V(f-F)=0 U->U07->Uinf->U0",
]

y = 780
stream = ""
for l in lines:
    txt = l if l else " "
    for i in range(0, max(1,len(txt)), 90):
        chunk = txt[i:i+90]
        stream += f"BT /F1 10 Tf 50 {y} Td ({esc(chunk)}) Tj ET\n"
        y -= 14
        if y < 40:
            stream += "showpage\n"
            y = 780

sb = stream.encode()
objs = []
objs.append(b"1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj\n")
objs.append(b"2 0 obj << /Type /Pages /Kids [3 0 R] /Count 1 >> endobj\n")
objs.append(b"3 0 obj << /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 << /Type /Font /Subtype /Type1 /BaseFont /Helvetica >> >> >> /Contents 4 0 R >> endobj\n")
objs.append(f"4 0 obj << /Length {len(sb)} >> stream\n".encode() + sb + b"\nendstream endobj\n")

pdf = b"%PDF-1.4\n"
offs = []
for o in objs:
    offs.append(len(pdf))
    pdf += o
xref = len(pdf)
pdf += f"xref\n0 {len(objs)+1}\n0000000000 65535 f \n".encode()
for off in offs:
    pdf += f"{off:010d} 00000 n \n".encode()
pdf += f"trailer << /Size {len(objs)+1} /Root 1 0 R /Info << /Title ({esc(title)}) /Author ({esc(author)}) /Creator (oeneyepdf.c) >> >>\nstartxref\n{xref}\n%%EOF".encode()
open(out,"wb").write(pdf)
print(f"[+] wrote {out} by {author} len={len(pdf)}")
