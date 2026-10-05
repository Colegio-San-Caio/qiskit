#!/usr/bin/env bash
# upload-all.sh
# usage: ./upload-all.sh oeneye-00x00.img [dry]
set -uo pipefail

OWNER=clevjhon
SOURCE_REPO=qiskit        # pushed first; the workflow compares against it
SKIP=""                   # space-separated repos to exclude, e.g. "repoA repoB"
F="${1:?usage: $0 <file> [dry]}"
DRY="${2:-}"

# --- preflight ---
command -v gh >/dev/null || { echo "gh CLI not installed"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "run: gh auth login"; exit 1; }
[ -f "$F" ] || { echo "$F not found"; exit 1; }
SIZE=$(stat -c%s "$F" 2>/dev/null || stat -f%z "$F")
[ "$SIZE" -lt 100000000 ] || { echo "File is over 100 MB: GitHub needs Git LFS for this"; exit 1; }

WORK=$(mktemp -d); trap 'rm -rf "$WORK"' EXIT
sha256sum "$F" > "$WORK/$F.sha256"
WANT=$(cut -d' ' -f1 "$WORK/$F.sha256")

# --- embedded workflow (written verbatim into every repo) ---
cat > "$WORK/verify-oeneye-img.yml" <<'EOF'
name: verify-oeneye-img
on:
  push:
  schedule:
    - cron: "0 6 * * *"
  workflow_dispatch:

permissions:
  contents: read

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Verify
        run: |
          F=oeneye-00x00.img
          PIN=$(cut -d' ' -f1 $F.sha256)
          MINE=$(sha256sum $F | cut -d' ' -f1)
          SRC=$(curl -fsSL https://github.com/clevjhon/qiskit/raw/main/$F | sha256sum | cut -d' ' -f1)
          echo "pin=$PIN mine=$MINE source=$SRC"
          [ "$MINE" = "$PIN" ] || { echo "Local copy differs from pin"; exit 1; }
          [ "$MINE" = "$SRC" ] || { echo "Local copy differs from qiskit source"; exit 1; }
EOF

# --- repo list: source first, then the rest ---
mapfile -t ALL < <(gh repo list "$OWNER" --limit 1000 --no-archived --source \
  --json name,defaultBranchRef -q '.[]|select(.defaultBranchRef!=null)|.name')
REPOS=("$SOURCE_REPO")
for R in "${ALL[@]}"; do [ "$R" = "$SOURCE_REPO" ] || REPOS+=("$R"); done

FAILED=()
for R in "${REPOS[@]}"; do
  case " $SKIP " in *" $R "*) echo "skip $R"; continue;; esac
  echo "== $R"
  [ "$DRY" = "dry" ] && continue

  D="$WORK/repo-$R"
  gh repo clone "$OWNER/$R" "$D" -- --depth 1 -q || { FAILED+=("$R: clone"); continue; }

  mkdir -p "$D/.github/workflows"
  cp "$F" "$WORK/$F.sha256" "$D/"
  cp "$WORK/verify-oeneye-img.yml" "$D/.github/workflows/"

  (
    cd "$D"
    git add "$(basename "$F")" "$(basename "$F").sha256" .github/workflows/verify-oeneye-img.yml
    git diff --cached --quiet && { echo "in sync"; exit 0; }
    git commit -qm "Update $(basename "$F") + verify workflow" && git push -q
  ) || { FAILED+=("$R: push"); continue; }

  # verify what actually landed (works for private repos too)
  V="$WORK/check-$R"
  gh repo clone "$OWNER/$R" "$V" -- --depth 1 -q 2>/dev/null
  GOT=$(sha256sum "$V/$(basename "$F")" 2>/dev/null | cut -d' ' -f1)
  [ "$GOT" = "$WANT" ] || FAILED+=("$R: hash mismatch")
  rm -rf "$D" "$V"
done

if [ ${#FAILED[@]} -eq 0 ]; then echo "All OK"
else printf 'FAILED: %s\n' "${FAILED[@]}"; exit 1; fi
