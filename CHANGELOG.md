# Changelog — skill-forge

## 1.1.0 (2026-07-17)
- skill-gate.sh: NON-SCORING mutation-safety advisory — flags a skill whose scripts run destructive commands (rm -rf / mkfs / dd) but whose SKILL.md documents no safe default (dry-run / report-first / --apply opt-in). Never changes the score (existing 100/100 skills unaffected); surfaces a reversibility risk at author time.

## 1.0.0 (2026-06-15)
- Packaging pass: README added, frontmatter standardized (license / lastUpdated), structure/PDA hygiene.
- Baseline entry — track future changes here going forward. The authoritative contract is SKILL.md.
