#!/bin/bash
# gen-skill-changelog.sh — create a baseline CHANGELOG.md per skill if missing.
# Usage: ./gen-skill-changelog.sh
set -uo pipefail
DIR="${SKILLS_DIR:-/root/.openclaw/workspace/skills}"
fmval(){ awk -v k="$1" 'BEGIN{inf=0}/^---[[:space:]]*$/{inf++;next} inf==1&&index($0,k": ")==1{sub("^"k": *","");print;exit}' "$2"; }
made=0
for d in "$DIR"/*/; do
  n=$(basename "$d"); f="$d/SKILL.md"; c="$d/CHANGELOG.md"
  [[ -f "$f" ]] || continue
  [[ -f "$c" ]] && continue
  ver=$(fmval version "$f")
  cat > "$c" <<EOF
# Changelog — ${n}

## ${ver:-1.0.0} (2026-06-15)
- Packaging pass: README added, frontmatter standardized (license / lastUpdated), structure/PDA hygiene.
- Baseline entry — track future changes here going forward. The authoritative contract is SKILL.md.
EOF
  echo "  ✓ ${n}/CHANGELOG.md"; made=$((made+1))
done
echo "  → ${made} CHANGELOG(s)"
