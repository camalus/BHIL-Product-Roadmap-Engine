# Guide 06: Cross-Toolkit Handoff

**Connecting the Product Roadmap Engine to the BHIL AI-First Development Toolkit**

---

## The complete chain

These two toolkits form a continuous pipeline from customer voice to shipped code:

```
PRODUCT ROADMAP ENGINE                BHIL AI-FIRST DEV TOOLKIT
─────────────────────────             ──────────────────────────

Customer Feedback (7 channels)
         ↓
Normalized Feedback Records (FB-NNN)
         ↓
Opportunity Brief (OPP-NNN)
         ↓
RICE Scorecard (RICE-NNN)
         ↓
PRD Stub (PRD-STUB-NNN)   ──────────→   PRD-NNN  (/new-feature skill)
                                                   ↓
                                         SPEC-NNN  (spec-writer agent)
                                                   ↓
                                         ADR-NNN   (/new-adr skill)
                                                   ↓
                                         TASK-NNN  (task decomposition)
                                                   ↓
                                         CODE → REVIEW → DEPLOY
```

The handoff point is the **PRD Stub**. When a RICE-validated opportunity is ready for development, the `/generate-prd-from-feedback` skill creates a PRD stub with `bhil_handoff` frontmatter fields. BHIL's `/new-feature` skill reads those fields directly — no context re-entry required.

---

## The PRD stub as handoff artifact

A PRD stub is not a full PRD. It is a structured brief that contains:
1. The evidence foundation (verbatim quotes, channel attribution, segment data)
2. EARS-format requirements derived from the feedback
3. Acceptance criteria (probabilistic for AI components)
4. RICE score summary with strategic rationale
5. Handoff metadata that BHIL's toolkit needs to create a full PRD-NNN

What the PRD stub does NOT contain:
- Technical implementation details (that belongs in SPEC-NNN)
- Architectural decisions (that belongs in ADR-NNN)
- Task breakdown (that belongs in TASK-NNN)
- Acceptance test code (that belongs alongside the task)

---

## The `bhil_handoff` frontmatter block

Every PRD stub includes this block, which BHIL's `/new-feature` skill reads:

```yaml
---
id: PRD-STUB-001
title: "Bulk CSV Export for enterprise data analysts"
status: ready-for-handoff
date: 2026-03-26

# Upstream references (Roadmap Engine chain)
upstream:
  opportunity: OPP-001
  rice_scorecard: RICE-001
  rice_score: 640
  priority_tier: P2

# Cross-toolkit handoff fields (read by BHIL /new-feature skill)
bhil_handoff:
  target_toolkit: "https://github.com/camalus/BHIL-AI-First-Development-Toolkit"
  suggested_sprint: S-04
  prd_target: PRD-NNN          # To be assigned by /new-feature skill
  ears_requirements_count: 7
  acceptance_criteria_type: deterministic
  estimated_effort_tier: M     # From RICE scorecard
  strategic_alignment:
    okr: "Increase enterprise retention by 15% in H1 2026"
    okr_type: leading-indicator
  
# Evidence summary (for PM context in BHIL PRD)
evidence_summary:
  total_feedback_records: 47
  channels_represented: 4
  top_customer_segment: enterprise
  affected_arr_estimate: "$2.1M"
  primary_sentiment: negative
  urgency_level: high
---
```

---

## Step-by-step handoff process

### Step 1: Create the PRD stub

When an opportunity reaches `RICE-NNN status: validated` and the RICE score meets the P1 or P2 threshold, use the skill:

```
In Claude Code: "Use the generate-prd-from-feedback skill to create a PRD stub for OPP-001"
```

Or via script:
```bash
# Generates PRD-STUB-NNN from OPP-NNN + RICE-NNN
./tools/scripts/new-prd-stub.sh OPP-001
```

Review the generated stub. Verify that:
- [ ] All customer quotes are verbatim (not paraphrased)
- [ ] EARS requirements map to real customer needs from the feedback
- [ ] Acceptance criteria are measurable
- [ ] Strategic alignment field references a current active OKR
- [ ] `bhil_handoff.suggested_sprint` is realistic given current sprint planning

Set `status: ready-for-handoff` when satisfied.

### Step 2: Hand off to BHIL AI-First Dev Toolkit

In your BHIL toolkit project, reference the stub path during sprint planning:

```
In Claude Code (BHIL project): 
"Use the new-feature skill to create PRD-[NNN] from 
 [path/to/product-roadmap-engine]/project/.sdlc/opportunities/PRD-STUB-001-bulk-csv-export.md"
```

BHIL's `/new-feature` skill reads the `bhil_handoff` block and:
1. Auto-populates the PRD frontmatter with upstream references
2. Carries the EARS requirements into the PRD's user stories section
3. Flags the acceptance criteria type so the spec-writer agent knows whether to generate probabilistic criteria
4. References the RICE score as the justification for the feature's priority

### Step 3: Update traceability in both toolkits

After BHIL assigns a PRD number, update the PRD stub:

```yaml
bhil_handoff:
  prd_target: PRD-012     # Updated from PRD-NNN
  handoff_date: 2026-03-28
  status: handed-off
```

The PRD-012 frontmatter in the BHIL toolkit should carry:
```yaml
upstream_source: PRD-STUB-001
roadmap_engine_opp: OPP-001
roadmap_engine_rice: RICE-001
rice_score: 640
```

This creates the bidirectional link. Six months from now, when you ask "why did we build the CSV export?", you can follow the chain from PRD-012 → PRD-STUB-001 → RICE-001 → OPP-001 → 47 feedback records with verbatim customer quotes.

---

## Traceability ID cross-reference

| Roadmap Engine | BHIL AI-First Dev Toolkit | Direction |
|---|---|---|
| `OPP-NNN` | — | Roadmap Engine only |
| `RICE-NNN` | — | Roadmap Engine only |
| `PRD-STUB-NNN` | Referenced in `PRD-NNN` frontmatter | Cross-toolkit |
| — | `PRD-NNN` | BHIL only |
| — | `SPEC-NNN`, `ADR-NNN`, `TASK-NNN` | BHIL only |

---

## What the BHIL /new-feature skill needs from the PRD stub

BHIL's spec-writer agent reads these fields to avoid asking clarifying questions:

| PRD stub field | Used by BHIL to |
|---|---|
| `title` | Name the PRD and SPEC |
| `bhil_handoff.estimated_effort_tier` | Skip the effort estimation question during task decomposition |
| `bhil_handoff.acceptance_criteria_type` | Set the AC format in the SPEC template (deterministic vs. probabilistic) |
| `bhil_handoff.strategic_alignment.okr` | Pre-populate the "Success metrics" section of the PRD |
| `evidence_summary.top_customer_segment` | Inform user story personas in the PRD |
| EARS requirements in stub body | Seed the PRD's user stories section |
| Verbatim customer quotes | Populate the "Problem statement" section of the PRD with cited evidence |

The goal: a BHIL `/new-feature` session that opens a PRD stub should need zero human clarification questions from the agent before drafting the full PRD.

---

## When the handoff is NOT ready

Do not hand off to BHIL if:

- `RICE-NNN status` is not `validated` — scoring may still change
- Engineering has not provided Effort input — the effort estimate in the stub will be unreliable
- The PRD stub has fewer than 3 EARS requirements — the stub is too thin for spec-writing
- `evidence_summary.total_feedback_records` is below 5 — insufficient evidence base
- The cited OKR is from a previous quarter and no longer active

---

## Shared taxonomy and conventions

Both toolkits use the same conventions to ensure smooth handoff:

| Convention | Both toolkits use |
|---|---|
| Requirements format | EARS notation (WHEN/WHILE/IF/WHERE patterns) |
| Acceptance criteria | Probabilistic bands for AI components (`≥X.XX on N runs`) |
| Frontmatter schema | Same YAML structure: `id`, `status`, `date`, `upstream`, `downstream` |
| Status vocabulary | `draft → in-review → approved → complete` |
| ID zero-padding | 3 digits: `OPP-001`, `PRD-NNN`, `SPEC-NNN` |

---

*Next: Read `guides/07-storage-architecture.md` for database setup options.*

*BHIL Product Roadmap Engine — [barryhurd.com](https://barryhurd.com)*
