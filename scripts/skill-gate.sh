#!/bin/bash
# skill-gate.sh — quality gate for OpenClaw skills (adapts aitmpl's skill-judge rubric to OpenClaw).
# Scores each skill /100:  Frontmatter 30 · PDA/structure 30 · Packaging 25 · Hygiene 15.
# Usage:  ./skill-gate.sh [skill-name]      (omit name = audit all)
#         SKILLS_DIR=/path ./skill-gate.sh
set -uo pipefail
SKILLS_DIR="${SKILLS_DIR:-/root/.openclaw/workspace/skills}"
ONLY="${1:-}"

TOT=0; N=0; declare -A GRADES

grade_of() { local s=$1; if   ((s>=85)); then echo A; elif ((s>=70)); then echo B
            elif ((s>=55)); then echo C; elif ((s>=40)); then echo D; else echo F; fi; }

score_skill() {
  local d="$1" name f desc fm pda pkg hyg score lines refs scripts trig notes=""
  name=$(basename "$d"); f="$d/SKILL.md"
  [[ -f "$f" ]] || { printf "  %-22s   —    no SKILL.md\n" "$name"; return; }

  # --- Frontmatter (30) ---
  fm=30
  grep -qE "^name:" "$f"        || { fm=$((fm-5)); notes+="no-name; "; }
  desc=$(grep -m1 "^description:" "$f" || true)
  [[ -n "$desc" ]]             || { fm=$((fm-5)); notes+="no-desc; "; }
  [[ ${#desc} -ge 80 ]]        || { fm=$((fm-3)); notes+="thin-desc; "; }
  echo "$desc" | grep -qiE "use (this|it|when|before|after|for|whenever|on |to )|when (you|the|a|an|setting|installing|debugging|processing|ron)|right after|\bbefore (commit|you|push|deploy)" || { fm=$((fm-4)); notes+="desc-no-when; "; }
  grep -qE "^version:" "$f"     || { fm=$((fm-3)); notes+="no-version; "; }
  trig=$(awk '/^triggers:/{f=1;next}/^[a-zA-Z]/{f=0}f&&/- /{c++}END{print c+0}' "$f")
  [[ ${trig:-0} -ge 3 ]]       || { fm=$((fm-3)); notes+="<3-triggers; "; }
  grep -qE "^author:" "$f"      || { fm=$((fm-3)); notes+="no-author; "; }
  grep -qiE "^lastUpdated:" "$f"|| { fm=$((fm-2)); notes+="no-lastUpdated; "; }
  grep -qiE "^license:" "$f"    || { fm=$((fm-2)); notes+="no-license; "; }
  ((fm<0)) && fm=0

  # --- PDA / structure (30) ---  lean SKILL.md + lazy references/
  lines=$(wc -l < "$f"); refs=$(ls "$d/references/" 2>/dev/null | wc -l)
  if   ((lines<=100)); then pda=20
  elif ((lines<=150)); then pda=14; notes+="body>100ln; "
  elif ((lines<=250)); then pda=7;  notes+="body>150ln; "
  else                      pda=0;  notes+="body>250ln-BLOAT; "; fi
  if   ((refs>=1));    then pda=$((pda+10))
  elif ((lines<=120)); then pda=$((pda+10))           # small + no refs is fine
  else                     notes+="no-refs-split; "; fi

  # --- Packaging (25) ---
  pkg=0; scripts=$(ls "$d/scripts/" 2>/dev/null | wc -l)
  if   ((scripts>=1)); then pkg=$((pkg+10))
  elif ((refs>=1));    then pkg=$((pkg+10))            # reference-pack skills waive scripts
  else                     notes+="no-scripts; "; fi
  [[ -f "$d/README.md" ]] && pkg=$((pkg+8)) || notes+="no-README; "
  { [[ -f "$d/CHANGELOG.md" ]] || grep -qi "changelog" "$f"; } && pkg=$((pkg+7)) || notes+="no-CHANGELOG; "

  # --- Hygiene (15) ---
  hyg=15; local ref miss=0
  while read -r ref; do
    [[ -z "$ref" ]] && continue
    [[ -e "$d/$ref" ]] || miss=$((miss+1))
  done < <(grep -oE "\./scripts/[a-zA-Z0-9_./-]+\.(sh|mjs|py)" "$f" | sed 's#^\./##' | sort -u)
  ((miss>0)) && { hyg=$((hyg-10)); notes+="broken-script-ref($miss); "; }
  { grep -qiE "^(author|homepage):.*(jeffjhunter|jeff j hunter|halthelobster|hal 9001|obviouslynot)" "$f" || grep -qiE "created by[^.]*(hal 9001|jeff j hunter|@halthelobster)|app\.obviouslynot|jeffjhunter\.com|come say hi on x" "$f"; } && { hyg=$((hyg-5)); notes+="external-IP-brand; "; }
  ((hyg<0)) && hyg=0

  # ── ADVISORY (non-scoring): a skill that runs destructive commands should document a safe default
  #    (dry-run / report-first / --apply opt-in). Flags mutators that don't — never changes the score.
  if [[ -d "$d/scripts" ]]; then
    # real destructive commands only — exclude the pattern-STRING case (a security scanner that carries
    # `rm -rf` etc. as a detection RULE, not an actual call): drop lines where it's quoted or on a rule line.
    mut=$(grep -rhnE '\brm[[:space:]]+-[a-zA-Z]*r|[[:space:]]mkfs\b|[[:space:]]dd[[:space:]]+if=|>[[:space:]]*/dev/sd' "$d/scripts/" 2>/dev/null \
          | grep -vE "['\"].*(rm[[:space:]]+-|mkfs|dd[[:space:]]+if)|PATTERN|DESTRUCT|DETECT|_RE=|pattern|detect|scan|flag" )
    if [[ -n "$mut" ]]; then
      grep -qiE 'dry.?run|report.only|preview|--apply|--force|touch(es)? nothing|nothing is (ever )?deleted|default.*(safe|report|preview)|opt-in' "$f" \
        || notes+="⚠mutation-no-safe-default; "
    fi
  fi

  score=$((fm+pda+pkg+hyg)); local g; g=$(grade_of $score)
  TOT=$((TOT+score)); N=$((N+1)); GRADES[$g]=$(( ${GRADES[$g]:-0} + 1 ))
  printf "  %-22s %3d/100  %s  (f%d p%d k%d h%d)  %s\n" "$name" "$score" "$g" "$fm" "$pda" "$pkg" "$hyg" "${notes:-clean ✓}"
}

echo "🛡️  Skill Quality Gate — Frontmatter 30 · PDA 30 · Packaging 25 · Hygiene 15"
echo "    (f=frontmatter p=pda k=packaging h=hygiene)"
echo
if [[ -n "$ONLY" && "$ONLY" != --* ]]; then
  score_skill "$SKILLS_DIR/$ONLY"
else
  for d in "$SKILLS_DIR"/*/; do [[ -d "$d" ]] && score_skill "$d"; done
fi
echo
((N>0)) && printf "  ── %d skills · avg %d/100 · grades:" "$N" "$((TOT/N))" && for g in A B C D F; do [[ -n "${GRADES[$g]:-}" ]] && printf " %s=%d" "$g" "${GRADES[$g]}"; done; echo
