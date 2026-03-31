#!/usr/bin/env bash
# validate-pipeline.sh — Validate the full Roadmap Engine pipeline traceability and quality
# Usage: ./tools/scripts/validate-pipeline.sh [OPP-NNN | --check-orphans | --all]
# BHIL Product Roadmap Engine — barryhurd.com

set -euo pipefail

TARGET="${1:---all}"
ERRORS=0
WARNINGS=0

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

error() { echo -e "${RED}❌ ERROR:${NC} $1"; ((ERRORS++)) || true; }
warn()  { echo -e "${YELLOW}⚠️  WARN:${NC} $1"; ((WARNINGS++)) || true; }
info()  { echo -e "${BLUE}ℹ️  INFO:${NC} $1"; }
ok()    { echo -e "${GREEN}✅${NC} $1"; }

get_field() {
  local file="$1" field="$2"
  grep "^${field}:" "$file" 2>/dev/null | head -1 | sed "s/^${field}: *//" | tr -d '"'
}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "BHIL Product Roadmap Engine — Pipeline Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Target: ${TARGET}"
echo ""

# ─── Validate a single OPP-NNN ────────────────────────────────────────────────
validate_opp() {
  local file="$1"
  local id=$(get_field "$file" "id")
  local status=$(get_field "$file" "status")
  local rice=$(get_field "$file" "rice_scorecard")
  local prd_stub=$(get_field "$file" "prd_stub")
  local channels=$(grep "source_channels:" "$file" | head -1)
  local record_count=$(get_field "$file" "feedback_record_count")

  echo "  Checking ${id}..."

  # Required frontmatter
  [ -z "$id" ]     && error "${file}: Missing 'id' in frontmatter"
  [ -z "$status" ] && error "${file}: Missing 'status' in frontmatter"

  # Minimum evidence standard
  if [ -n "$record_count" ] && [ "$record_count" -lt 5 ] 2>/dev/null; then
    warn "${id}: Only ${record_count} feedback records — minimum is 5 for a robust OPP"
  fi

  # Check for verbatim quotes section
  if ! grep -q "^## Verbatim customer evidence" "$file" 2>/dev/null; then
    error "${id}: Missing '## Verbatim customer evidence' section"
  fi

  # Check minimum quote count (look for **Quote N** patterns)
  QUOTE_COUNT=$(grep -c "^\*\*Quote [0-9]" "$file" 2>/dev/null || echo "0")
  if [ "$QUOTE_COUNT" -lt 5 ]; then
    warn "${id}: Only ${QUOTE_COUNT} verbatim quotes found — minimum is 5"
  fi

  # Check RICE scorecard link validity
  if [ -n "$rice" ] && [ "$rice" != "null" ]; then
    RICE_FILE=$(find docs/adr/ examples/ project/ -name "${rice}*.md" 2>/dev/null | head -1)
    if [ -z "$RICE_FILE" ]; then
      error "${id}: rice_scorecard references ${rice} but file not found"
    fi
  fi

  # Check PRD stub link validity
  if [ -n "$prd_stub" ] && [ "$prd_stub" != "null" ]; then
    STUB_FILE=$(find project/ examples/ -name "${prd_stub}*.md" 2>/dev/null | head -1)
    if [ -z "$STUB_FILE" ]; then
      error "${id}: prd_stub references ${prd_stub} but file not found"
    fi
  fi

  # Check for unfilled placeholders in approved/scored status
  if [ "$status" = "approved" ] || [ "$status" = "scored" ]; then
    if grep -qE '\[.*\]' "$file" 2>/dev/null; then
      warn "${id}: Unfilled placeholders found in file with status: ${status}"
    fi
  fi

  # Check strategic alignment section exists
  if ! grep -q "^## Strategic alignment" "$file" 2>/dev/null; then
    warn "${id}: Missing '## Strategic alignment' section"
  fi
}

# ─── Validate a single RICE-NNN ───────────────────────────────────────────────
validate_rice() {
  local file="$1"
  local id=$(get_field "$file" "id")
  local status=$(get_field "$file" "status")
  local opp=$(get_field "$file" "opportunity")
  local score=$(get_field "$file" "rice_score")

  echo "  Checking ${id}..."

  [ -z "$id" ]     && error "${file}: Missing 'id' in frontmatter"
  [ -z "$status" ] && error "${file}: Missing 'status' in frontmatter"

  # Validate parent OPP exists
  if [ -n "$opp" ] && [ "$opp" != "null" ]; then
    OPP_FILE=$(find project/ examples/ -name "${opp}*.md" 2>/dev/null | head -1)
    if [ -z "$OPP_FILE" ]; then
      error "${id}: opportunity references ${opp} but file not found"
    else
      OPP_STATUS=$(get_field "$OPP_FILE" "status")
      if [ "$OPP_STATUS" != "approved" ] && [ "$OPP_STATUS" != "scored" ] && \
         [ "$OPP_STATUS" != "roadmapped" ] && [ "$OPP_STATUS" != "complete" ]; then
        warn "${id}: Parent ${opp} has status '${OPP_STATUS}' — RICE should only be created for approved OPPs"
      fi
    fi
  else
    error "${id}: Missing 'opportunity' (parent OPP-NNN reference)"
  fi

  # Check sensitivity analysis exists (required for validated status)
  if [ "$status" = "validated" ]; then
    if ! grep -q "## Sensitivity analysis" "$file" 2>/dev/null; then
      error "${id}: status is 'validated' but '## Sensitivity analysis' section is missing"
    fi
    # Check effort was not AI-estimated (must have engineering note)
    if grep -q "⚠️ Requires engineering input" "$file" 2>/dev/null; then
      error "${id}: status is 'validated' but Effort is still marked as 'requires engineering input'"
    fi
  fi

  # RICE formula validation (if score is populated)
  if [ -n "$score" ] && [ "$score" != "null" ]; then
    ok "${id}: RICE score present: ${score}"
  else
    if [ "$status" = "validated" ]; then
      error "${id}: status is 'validated' but rice_score is null"
    fi
  fi
}

# ─── Validate a single PRD-STUB-NNN ───────────────────────────────────────────
validate_prd_stub() {
  local file="$1"
  local id=$(get_field "$file" "id")
  local status=$(get_field "$file" "status")
  local opp=$(grep "  opportunity:" "$file" | head -1 | awk '{print $2}')
  local rice=$(grep "  rice_scorecard:" "$file" | head -1 | awk '{print $2}')

  echo "  Checking ${id}..."

  [ -z "$id" ]     && error "${file}: Missing 'id' in frontmatter"
  [ -z "$status" ] && error "${file}: Missing 'status' in frontmatter"

  # Validate upstream OPP reference
  if [ -n "$opp" ] && [ "$opp" != "null" ]; then
    OPP_FILE=$(find project/ examples/ -name "${opp}*.md" 2>/dev/null | head -1)
    [ -z "$OPP_FILE" ] && error "${id}: upstream.opportunity references ${opp} but file not found"
  else
    error "${id}: Missing 'upstream.opportunity' in frontmatter"
  fi

  # Validate upstream RICE reference
  if [ -n "$rice" ] && [ "$rice" != "null" ]; then
    RICE_FILE=$(find project/ examples/ docs/ -name "${rice}*.md" 2>/dev/null | head -1)
    [ -z "$RICE_FILE" ] && error "${id}: upstream.rice_scorecard references ${rice} but file not found"
  else
    error "${id}: Missing 'upstream.rice_scorecard' in frontmatter"
  fi

  # Check EARS requirements
  EARS_COUNT=$(grep -cE "^(WHEN|WHILE|IF|WHERE)" "$file" 2>/dev/null || echo "0")
  if [ "$EARS_COUNT" -lt 3 ]; then
    warn "${id}: Only ${EARS_COUNT} EARS-format user stories found — minimum is 3 for handoff"
  fi

  # Check bhil_handoff block
  if ! grep -q "bhil_handoff:" "$file" 2>/dev/null; then
    error "${id}: Missing 'bhil_handoff' frontmatter block — required for BHIL toolkit handoff"
  fi

  # Check OKR reference
  if ! grep -q "okr:" "$file" 2>/dev/null; then
    warn "${id}: No OKR reference in bhil_handoff.strategic_alignment — add before handoff"
  fi

  # Readiness gate
  if [ "$status" = "ready-for-handoff" ]; then
    if grep -qE '\[.*\]' "$file" 2>/dev/null; then
      error "${id}: status is 'ready-for-handoff' but unfilled placeholders found"
    fi
  fi
}

# ─── Orphan check ─────────────────────────────────────────────────────────────
check_orphans() {
  echo ""
  echo "Checking for orphaned artifacts..."

  # RICE files without a valid OPP
  for rice_file in project/.sdlc/opportunities/RICE-*.md 2>/dev/null; do
    [ -f "$rice_file" ] || continue
    opp=$(grep "^opportunity:" "$rice_file" | awk '{print $2}')
    if [ -n "$opp" ] && [ "$opp" != "null" ]; then
      opp_file=$(find project/ examples/ -name "${opp}*.md" 2>/dev/null | head -1)
      [ -z "$opp_file" ] && warn "ORPHAN: $(basename $rice_file) references ${opp} which doesn't exist"
    fi
  done

  # PRD stubs without a valid RICE
  for stub_file in project/.sdlc/opportunities/PRD-STUB-*.md 2>/dev/null; do
    [ -f "$stub_file" ] || continue
    rice=$(grep "rice_scorecard:" "$stub_file" | head -1 | awk '{print $2}')
    if [ -n "$rice" ] && [ "$rice" != "null" ]; then
      rice_file=$(find project/ examples/ docs/ -name "${rice}*.md" 2>/dev/null | head -1)
      [ -z "$rice_file" ] && warn "ORPHAN: $(basename $stub_file) references ${rice} which doesn't exist"
    fi
  done

  ok "Orphan check complete"
}

# ─── Main execution ────────────────────────────────────────────────────────────

if [[ "$TARGET" == "--check-orphans" ]]; then
  check_orphans
elif [[ "$TARGET" == "--all" ]]; then
  echo "📄 Validating Opportunity Briefs..."
  for f in project/.sdlc/opportunities/OPP-*.md 2>/dev/null; do
    [ -f "$f" ] && validate_opp "$f"
  done
  for f in examples/full-chain/OPP-*.md 2>/dev/null; do
    [ -f "$f" ] && validate_opp "$f"
  done

  echo ""
  echo "📊 Validating RICE Scorecards..."
  for f in project/.sdlc/opportunities/RICE-*.md 2>/dev/null; do
    [ -f "$f" ] && validate_rice "$f"
  done
  for f in examples/full-chain/RICE-*.md 2>/dev/null; do
    [ -f "$f" ] && validate_rice "$f"
  done

  echo ""
  echo "📝 Validating PRD Stubs..."
  for f in project/.sdlc/opportunities/PRD-STUB-*.md 2>/dev/null; do
    [ -f "$f" ] && validate_prd_stub "$f"
  done
  for f in examples/full-chain/PRD-STUB-*.md 2>/dev/null; do
    [ -f "$f" ] && validate_prd_stub "$f"
  done

  check_orphans
else
  # Validate a specific artifact by ID prefix
  FILE=$(find project/ examples/ -name "${TARGET}*.md" 2>/dev/null | head -1)
  if [ -z "$FILE" ]; then
    error "No file found for ${TARGET}"
    exit 1
  fi

  case "$TARGET" in
    OPP-*)      validate_opp "$FILE" ;;
    RICE-*)     validate_rice "$FILE" ;;
    PRD-STUB-*) validate_prd_stub "$FILE" ;;
    *)          error "Unknown artifact type: ${TARGET}" ;;
  esac
fi

# ─── Summary ─────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Errors:   ${ERRORS}"
echo "  Warnings: ${WARNINGS}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$ERRORS" -gt 0 ]; then
  echo -e "${RED}❌ FAILED — ${ERRORS} error(s) must be fixed${NC}"
  exit 1
else
  echo -e "${GREEN}✅ PASSED${NC}"
  exit 0
fi
