#!/bin/bash
# scaffold-skill.sh — scaffold a gate-passing OpenClaw skill skeleton.
# Creates skills/<name>/ with a SKILL.md template (all gate frontmatter + lean body),
# empty scripts/ + references/, and a placeholder reference so the skeleton itself scores well.
# Usage: ./scaffold-skill.sh <skill-name> [SKILLS_DIR]
#        (skill-name = kebab-case; must match the folder name)
set -uo pipefail

NAME="${1:-}"
DIR="${2:-${SKILLS_DIR:-/root/.openclaw/workspace/skills}}"

if [[ -z "$NAME" ]]; then
  echo "usage: ./scaffold-skill.sh <skill-name>  (kebab-case)" >&2
  exit 2
fi
if ! [[ "$NAME" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "❌ name must be kebab-case (lowercase, hyphen-separated): got '$NAME'" >&2
  exit 2
fi

TARGET="$DIR/$NAME"
if [[ -e "$TARGET" ]]; then
  echo "❌ $TARGET already exists — refusing to overwrite" >&2
  exit 1
fi

TODAY=$(date +%F)
mkdir -p "$TARGET/scripts" "$TARGET/references"

# --- SKILL.md (gate-passing skeleton: full frontmatter + body ≤100 lines + refs pointer) ---
cat > "$TARGET/SKILL.md" <<EOF
---
name: $NAME
description: TODO one-line of what it does, then a "use when" phrase so the agent knows when to invoke. Use this when TODO-the-triggering-situation. Make every word work — this single field decides whether the skill fires.
version: 1.0.0
metadata:
  openclaw:
    emoji: "🧩"
    requires:
      bins: ["bash"]
triggers:
  - "TODO natural-language phrase 1"
  - "TODO paraphrase 2"
  - "TODO another way a user asks"
author: Rin
license: UNLICENSED
lastUpdated: $TODAY
---

# ${NAME}

One-paragraph summary of what this skill does and the value it returns.

## 🚀 Quick Start

\`\`\`bash
./scripts/TODO.sh            # the minimum command that delivers value
\`\`\`

## Usage

Each major operation, with an example invocation. Keep this body **≤100 lines** —
push depth into \`references/\` and link by path so the agent loads it lazily.

## When to Use

- DO invoke when TODO.
- Do NOT invoke when TODO (point at the better-fit skill).

→ Full reference (deep material, examples, tables): [\`references/guide.md\`](references/guide.md).

---
*By Rin 🧩*
EOF

# --- references/ placeholder (so the PDA axis credits a lazy reference) ---
cat > "$TARGET/references/guide.md" <<EOF
# ${NAME} — Reference

Deep material for the \`${NAME}\` skill — loaded on demand, kept out of SKILL.md to keep the body lean.

## TODO
Move long-form context, example libraries, and tables here.
EOF

# --- scripts/ placeholder (so the Packaging axis credits a shipped script) ---
cat > "$TARGET/scripts/TODO.sh" <<'EOF'
#!/bin/bash
# TODO.sh — replace with the skill's real helper.
# Take input as args/stdin, print parseable output, exit non-zero on failure.
set -uo pipefail
echo "TODO: implement $0"
EOF
chmod +x "$TARGET/scripts/TODO.sh"

echo "✓ scaffolded $TARGET"
echo "  ├── SKILL.md            (fill the TODOs: description, triggers, body)"
echo "  ├── scripts/TODO.sh     (rename + implement; chmod +x already set)"
echo "  └── references/guide.md (move deep material here)"
echo
echo "Next: fill it in, then gate it →  ./scripts/skill-gate.sh $NAME"
