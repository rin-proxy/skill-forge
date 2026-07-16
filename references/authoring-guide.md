# Skill Authoring Guide — PDA discipline + the /100 gate

Deep reference for the `skill-forge` skill — loaded on demand so `SKILL.md` stays lean. Full theory lives in `tower/openclaw-skills-authoring.md`.

---

## PDA discipline (Progressive Disclosure Architecture)

A skill should reveal itself in layers, cheapest first, so the agent pays tokens only for what it needs:

1. **Frontmatter** — the contract. The agent reads `description` + `triggers` to decide *whether to invoke at all*. This is always loaded; make every word work.
2. **Body (`SKILL.md` prose) ≤100 lines** — the instruction sheet, loaded on every invocation. Quick Start, the core workflow, a rubric/usage table, when-to-use. If it grows past 100 lines, you're paying that overhead every single call — move material down a layer.
3. **`references/*.md`** — long-form context, example libraries, big tables. Linked *by path* from the body and pulled in only when the task needs them ("→ see references/guide.md").
4. **`scripts/*`** — executed, not read into context. The agent runs them; their output (not their source) enters the conversation. This is where logic and heavy lifting belong.

**Rule of thumb:** if it's a decision the agent makes every time → body. If it's depth consulted occasionally → `references/`. If it's *work* → `scripts/`.

---

## The /100 gate rubric (what `skill-gate.sh` scores)

`Frontmatter 30 · PDA/structure 30 · Packaging 25 · Hygiene 15`. Grades: A ≥85 · B ≥70 · C ≥55 · D ≥40 · F below.

### Frontmatter — 30 pts
| Field | Deduction if missing/weak |
|---|---|
| `name:` (kebab, matches folder) | −5 |
| `description:` present | −5 |
| `description` ≥80 chars | −3 (thin-desc) |
| `description` contains a **use-when** phrase | −4 (desc-no-when) |
| `version:` (semver) | −3 |
| ≥3 `triggers:` (natural-language, paraphrased) | −3 (<3-triggers) |
| `author:` | −3 |
| `lastUpdated:` | −2 |
| `license:` | −2 |

The **use-when** trip-wire: the description must match a phrase like `use this when…`, `use it before…`, `when you…`, `right after…`, `before commit/push/deploy`. Easiest fix: append a sentence starting `Use this when …`.

### PDA / structure — 30 pts
- Body **≤100 lines** → 20 · ≤150 → 14 (`body>100ln`) · ≤250 → 7 · else 0 (`body>250ln-BLOAT`).
- `references/` has ≥1 file → **+10**. (A small skill ≤120 lines with no refs still gets the +10; anything larger without refs gets `no-refs-split` and loses it.)
- Net: keep body ≤100 **and** ship one `references/*.md` → full 30.

### Packaging — 25 pts
- ≥1 file in `scripts/` → +10 (a references-only skill waives this and takes the +10 from refs instead).
- `README.md` present → +8 (else `no-README`).
- `CHANGELOG.md` present (or "changelog" mentioned in SKILL.md) → +7 (else `no-CHANGELOG`).

### Hygiene — 15 pts
- Every `./scripts/<file>.{sh,mjs,py}` mentioned in `SKILL.md` must resolve to a real file in the folder → else −10 (`broken-script-ref(N)`). **This is the most common 100→90 miss:** if you name a script in the body, it must exist in `scripts/`.
- No third-party-IP branding in `author`/`homepage`/body (e.g. external authors or "come say hi on X") → else −5 (`external-IP-brand`). Keep credit honest and first-party ("Derived from … Tower book").

---

## Common deductions → fixes

| Gate note | Cause | Fix |
|---|---|---|
| `desc-no-when` | description has no trigger phrase | add `Use this when …` |
| `thin-desc` | description < 80 chars | expand: what + when + what it ships |
| `<3-triggers` | fewer than 3 trigger lines | add paraphrases of how users actually ask |
| `no-license` / `no-lastUpdated` | field missing | add `license:` and `lastUpdated:` (ISO date) |
| `body>100ln` | SKILL.md too long | move depth into `references/`, link by path |
| `no-refs-split` | large body, no `references/` | create `references/<topic>.md` and point at it |
| `no-README` / `no-CHANGELOG` | packaging files absent | run `gen-skill-readme.sh` + `gen-skill-changelog.sh` |
| `broken-script-ref(N)` | body names a script that isn't in `scripts/` | create the file (or fix the path) so every `./scripts/…` resolves |
| `external-IP-brand` | third-party author/branding | strip it; credit the source book honestly, author = your own handle |

---

## Bundled scripts (this skill is self-contained)

| Script | What it does |
|---|---|
| `scripts/scaffold-skill.sh <name>` | Creates `skills/<name>/` with a gate-passing skeleton: SKILL.md (all frontmatter fields + lean body + references pointer), an empty-but-seeded `scripts/` and `references/`. |
| `scripts/skill-gate.sh [name]` | Scores a skill (or all skills) `/100` against the rubric above; prints per-axis breakdown + deduction notes. |
| `scripts/gen-skill-readme.sh [--force]` | Generates `README.md` from SKILL.md frontmatter for skills missing one. |
| `scripts/gen-skill-changelog.sh` | Writes a baseline `CHANGELOG.md` for skills missing one. |

These were built first-party in this workspace (`scripts/`) and copied in-folder so the skill travels standalone. Keep the in-folder copies in sync with the canonical `scripts/` versions if you edit either.

---

*Reference for the skill-forge skill. The authoritative contract is SKILL.md. Derived from the `openclaw-skills-authoring` Tower book — by Rin 🔨.*
