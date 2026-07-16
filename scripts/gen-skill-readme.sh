#!/bin/bash
# gen-skill-readme.sh — generate a README.md per skill from its SKILL.md frontmatter.
# Only fills in skills MISSING a README (use --force to overwrite). Usage: ./gen-skill-readme.sh [--force]
set -uo pipefail
DIR="${SKILLS_DIR:-/root/.openclaw/workspace/skills}"
FORCE="${1:-}"

fmval() {  # first value of a top-level frontmatter key
  awk -v k="$1" 'BEGIN{inf=0} /^---[[:space:]]*$/{inf++; next} inf==1 && index($0,k": ")==1 {sub("^"k": *",""); print; exit}' "$2"
}

made=0
for d in "$DIR"/*/; do
  n=$(basename "$d"); f="$d/SKILL.md"; r="$d/README.md"
  [[ -f "$f" ]] || continue
  [[ -f "$r" && "$FORCE" != "--force" ]] && continue
  desc=$(fmval description "$f"); ver=$(fmval version "$f")
  emoji=$(awk -F'"' '/emoji:/{print $2; exit}' "$f")
  trig=$(awk '/^triggers:/{t=1;next} /^[a-zA-Z]/{t=0} t&&/^[[:space:]]*-/{gsub(/^[[:space:]]*-[[:space:]]*|"/,""); printf "%s, ", $0}' "$f" | sed 's/, $//')
  cat > "$r" <<EOF
# ${emoji} ${n}

${desc}

**Version:** ${ver:-1.0.0} · **Triggers:** ${trig:-—}

## Usage
Full guide and procedure: see **SKILL.md**. Bundled scripts (if any) live in **scripts/**; deep reference material in **references/** (loaded on demand).

## Install
    openclaw skills install git:OWNER/${n}

Or copy this folder into your OpenClaw workspace/skills/ directory.

---
*README for the ${n} skill. The authoritative contract is SKILL.md.*
EOF
  echo "  ✓ generated ${n}/README.md"; made=$((made+1))
done
echo "  → ${made} README(s) generated"
