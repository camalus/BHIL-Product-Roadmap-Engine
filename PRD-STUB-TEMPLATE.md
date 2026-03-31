---
# === TRACEABILITY METADATA ===
id: PRD-STUB-NNN
title: "[Feature title — matches OPP title, refined for engineering clarity]"
status: draft              # draft | ready-for-handoff | handed-off

date: YYYY-MM-DD
sprint: S-NN

# Upstream references (Roadmap Engine chain)
upstream:
  opportunity: OPP-NNN
  rice_scorecard: RICE-NNN
  rice_score: null         # Populated from RICE-NNN
  priority_tier: null      # P1 / P2 / P3 / P4 / P5

# Cross-toolkit handoff (read by BHIL /new-feature skill)
bhil_handoff:
  target_toolkit: "https://github.com/camalus/BHIL-AI-First-Development-Toolkit"
  suggested_sprint: S-NN
  prd_target: PRD-NNN      # To be assigned by BHIL /new-feature skill
  handoff_date: null       # Populated when status → handed-off
  bhil_prd_assigned: null  # Populated after BHIL assigns PRD-NNN
  
  # For BHIL spec-writer agent
  ears_requirements_count: N
  acceptance_criteria_type: deterministic  # deterministic | probabilistic | mixed
  estimated_effort_tier: M  # XS | S | M | L | XL from RICE scorecard
  
  strategic_alignment:
    okr: "[Active OKR this feature supports]"
    okr_type: leading-indicator  # outcome | leading-indicator

# Evidence summary (for PM context in BHIL PRD)
evidence_summary:
  total_feedback_records: N
  channels_represented: N
  top_customer_segment: enterprise
  affected_arr_estimate: "$[X]M"
  primary_sentiment: negative
  urgency_level: high
  churn_correlation: false  # true | false | unknown
---

# PRD Stub: [Feature Title]

> This is a PRD stub — a structured evidence brief for handoff to the BHIL AI-First Development Toolkit.
> It is NOT a full PRD. The BHIL `/new-feature` skill expands this into PRD-NNN.

---

## Problem statement (evidence-backed)

<!--
Derived directly from OPP-NNN problem statement.
Supported by verbatim customer quotes with attribution.
Do not introduce new framing here — stay faithful to what the data shows.
-->

[Repeat problem statement from OPP-NNN]

**Supporting evidence:**

> "[Most compelling verbatim quote]"
— *[Channel]* | *[Segment]* | *[ARR band]* | *[Date]*

> "[Second compelling quote — different channel preferred]"
— *[Channel]* | *[Segment]* | *[ARR band]* | *[Date]*

**Quantified impact:**
- [N] customers affected, representing $[X]M ARR
- [N]% of NPS detractors cited this as their primary complaint in Q[N] [Year]
- [If churn correlation: mentioned in [N] of last [N] churn interviews]

---

## User stories (EARS format)

<!--
EARS notation — Easy Approach to Requirements Syntax.
Patterns: WHEN [trigger] | WHILE [state] | IF [error] | WHERE [optional feature]
Each story maps to at least one acceptance criterion.
Derived from customer feedback — not invented by PM.
-->

**US-001:**
WHEN [trigger derived from customer feedback], the system SHALL [response solving the pain point].

**US-002:**
WHEN [trigger], the system SHALL [response].

**US-003:**
WHILE [condition state], the system SHALL [behavior].

**US-004:**
IF [error condition described by customers], THEN the system SHALL [graceful response].

**US-005 (optional feature):**
WHERE [feature flag or tier condition], WHEN [trigger], the system SHALL [response].

---

## Acceptance criteria

<!--
For deterministic features: exact, testable conditions.
For AI-native components: probabilistic thresholds.
Every criterion maps to a user story above.
-->

### Functional criteria

- [ ] **AC-001** (US-001): GIVEN [condition], WHEN [action], THEN [exact expected outcome]
- [ ] **AC-002** (US-001): [Error case] GIVEN [error condition], WHEN [action], THEN [system responds with specific behavior]
- [ ] **AC-003** (US-002): GIVEN [condition], WHEN [action], THEN [exact expected outcome]
- [ ] **AC-004** (US-003): GIVEN [condition], WHEN [action], THEN [exact expected outcome]
- [ ] **AC-005** (US-004): GIVEN [error condition], WHEN [action], THEN [fallback behavior]

### Performance criteria

- [ ] **AC-PERF-001:** [Operation] completes in < [X]ms P95 under [N] concurrent users
- [ ] **AC-PERF-002:** [Resource] does not exceed [X] [unit] per [operation]

### For AI-native components (if applicable)

- [ ] **AC-AI-001:** [AI output] achieves ≥[X.XX] [metric] across [N] test runs (eval suite: `evals/[feature].yaml`)
- [ ] **AC-AI-002:** Response latency P95 < [X]ms including [model] generation time

---

## Out of scope

<!--
Explicit exclusions prevent scope creep during implementation.
Derived from OPP-NNN's related signals that are adjacent but not included here.
-->

The following are explicitly NOT part of this feature:
- [Exclusion 1 — adjacent feature that should be a separate OPP-NNN]
- [Exclusion 2 — complexity that would require XL+ effort]
- [Exclusion 3 — nice-to-have not supported by current evidence]

---

## Success metrics

<!--
Derived from OKR alignment in the RICE scorecard.
Leading indicators that will confirm this feature solved the problem.
-->

**Primary metric:** [e.g., "Reduction in support tickets tagged 'bulk-export' by ≥40% within 60 days of launch"]
**Secondary metric:** [e.g., "NPS score improvement among enterprise customers from baseline of [X] to ≥[Y] in next NPS cycle"]
**Baseline:** [Current state of these metrics]
**Measurement method:** [How you will track this]
**Timeline:** [When you will evaluate success — typically 30-60 days post-launch]

---

## Dependencies and constraints

| Dependency | Type | Status | Notes |
|---|---|---|---|
| [Service / ADR / External API] | Internal / External | Available / Unknown | [Detail] |
| [Authentication system] | Internal | Available | Required prerequisite |
| [Data migration needed?] | Internal | TBD | [Scope if applicable] |

**Constraints (from RICE scorecard):**
- Effort ceiling: [M] person-months (from RICE-NNN engineering estimate)
- Engineering assumptions: [List from RICE scorecard — these scope the implementation]

---

## BHIL development handoff notes

<!--
Specific context for the BHIL /new-feature skill and spec-writer agent.
Helps the agent avoid asking clarifying questions.
-->

**For the spec-writer agent:**
- The primary user persona is a [customer segment] customer who [specific context from feedback]
- The integration points are: [existing features/APIs this connects to]
- The data model likely needs: [tables/fields based on customer descriptions in feedback]
- Reference implementation patterns: [existing similar features in the codebase, if known]

**ADRs likely needed for this feature:**
- [ ] [Decision area: e.g., "File format support for export — which formats?"]
- [ ] [Decision area: e.g., "Asynchronous vs. synchronous export for large datasets"]

---

## Handoff readiness checklist

Before setting `status: ready-for-handoff`:
- [ ] `upstream.rice_scorecard` status is `validated`
- [ ] At least 5 EARS user stories present
- [ ] All acceptance criteria are measurable (no "works correctly" criteria)
- [ ] Out of scope section is complete
- [ ] Success metrics are quantified with a baseline
- [ ] `bhil_handoff.okr` references an active OKR
- [ ] `bhil_handoff.estimated_effort_tier` is populated from engineering input in RICE-NNN

---

*Template version 1.0 — BHIL Product Roadmap Engine — [barryhurd.com](https://barryhurd.com)*
