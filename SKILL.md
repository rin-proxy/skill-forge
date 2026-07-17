---
name: skill-forge
description: Scaffold, quality-gate, and ship installable OpenClaw skills. Bundles a /100 quality gate plus scaffold/README/CHANGELOG generators so a new skill goes from empty folder to a gate-passing, drop-in package. Use this when authoring a new OpenClaw skill or before publishing one.
version: 1.1.0
metadata:
  openclaw:
    emoji: "🔨"
    requires:
      bins: ["bash", "node"]
triggers:
  - "create a skill"
  - "scaffold a skill"
  - "gate my skill"
  - "score this skill"
  - "author an openclaw skill"
  - "is my skill ready to ship"
author: Rin
license: UNLICENSED
lastUpdated: 2026-07-17
---

# Skill Forge

A meta-skill that forges OpenClaw skills: scaffold a gate-passing skeleton, fill it in, score it `/100`, and package it for ship — all self-contained in this folder's `scripts/`.

## 🚀 Quick Start

```bash
./scripts/scaffold-skill.sh my-skill     # → skills/my-skill/ skeleton (SKILL.md + scripts/ + references/)
# ...fill in the TODOs: description, ≥3 triggers, ≤100-line body, real script...
./scripts/skill-gate.sh my-skill         # score it /100 — iterate until "100/100 A … clean ✓"
./scripts/gen-skill-readme.sh            # generate README.md from frontmatter (skills missing one)
./scripts/gen-skill-changelog.sh         # generate a baseline CHANGELOG.md
```

## 🔁 The forge workflow

1. **Scaffold** — `scaffold-skill.sh <name>` writes a skeleton whose frontmatter already carries every field the gate wants and whose body is lean.
2. **Fill** — replace the TODOs: sharpen the description (lead with *what*, then a *use-when* phrase), list ≥3 paraphrased triggers, write the body, drop deep material into `references/`, put real logic in `scripts/`.
3. **Gate** — run `skill-gate.sh <name>`; fix each deduction it prints.
4. **Ship** — generate README + CHANGELOG, then copy/install the folder.

## 📊 The /100 rubric at a glance

| Axis | Pts | How to max it |
|---|---|---|
| **Frontmatter** | 30 | `name` · `description` ≥80 chars **with a "use when" phrase** · `version` · ≥3 `triggers` · `author` · `lastUpdated` · `license` |
| **PDA / structure** | 30 | **body ≤100 lines** (the magic rule → full 20) + ≥1 file in `references/` (+10) |
| **Packaging** | 25 | ≥1 file in `scripts/` (10) + `README.md` (8) + `CHANGELOG.md` (7) |
| **Hygiene** | 15 | every `./scripts/…` mention points at a real file; no third-party-IP branding |

**The magic rule:** keep `SKILL.md` body **≤100 lines** — that alone unlocks the full PDA score; everything else moves to `references/`.

## ✅ When to Use

- DO invoke when authoring a new OpenClaw skill, refactoring one to pass the gate, or pre-flighting one for publish.
- Do NOT invoke for cron jobs (use `cron-automation`) or for non-skill docs.

→ Full PDA discipline, per-axis tactics, and the common-deduction → fix table: [`references/authoring-guide.md`](references/authoring-guide.md).
→ Deep theory: `tower/openclaw-skills-authoring.md`.

---
*Derived from the `openclaw-skills-authoring` Tower book. By Rin 🔨*
