---
# === TRACEABILITY METADATA ===
id: RICE-NNN
title: "RICE Score: [OPP title]"
status: draft              # draft | ai-scored | human-reviewed | validated | disputed
date: YYYY-MM-DD
sprint: S-NN

# Upstream
opportunity: OPP-NNN

# Downstream
prd_stub: null             # PRD-STUB-NNN (populated when stub created)

# Score summary (populated by scoring agent, confirmed by PM)
rice_score: null           # Calculated value
priority_tier: null        # P1 / P2 / P3 / P4 / P5
recommendation: null       # build-now | build-next | queue | defer
---

# RICE-NNN: RICE Score for [Opportunity Title]

## Linked opportunity

**OPP-NNN:** [Opportunity title]
**OPP status:** [approved]
**Feedback records:** [N] records across [N] channels
**Top customer segment:** [Enterprise / Mid-market / SMB]
**ARR represented:** $[X]M

---

## RICE Components

### Reach — Users affected per quarter

**AI estimate:** [N] users/quarter
**Human-validated:** [N] users/quarter ← *Update this after review*

**Estimation methodology:**
1. Feedback record count: [N] distinct customers mentioned this theme in the past 90 days
2. Dark matter multiplier applied: [X]× (only ~1-in-[X] customers who experience the pain report it)
3. Raw estimate from feedback: [N × multiplier = N] customers
4. Adjustment: [e.g., "Product analytics shows [N] users engage with the related workflow monthly; quarterly estimate is [N]"]
5. **Final Reach:** [N] users/quarter

**Reach confidence note:** [e.g., "Moderate confidence — product analytics not yet integrated. Estimate based on feedback record extrapolation. Upgrade confidence after Mixpanel integration."]

```
Override (if applicable):
  original_ai_estimate: N
  human_override: N
  override_rationale: "[Why you changed it]"
  override_date: YYYY-MM-DD
  overridden_by: [Name]
```

---

### Impact — Magnitude of improvement per user

**Scale:** 3.0 = Massive | 2.0 = High | 1.0 = Medium | 0.5 = Low | 0.25 = Minimal

**AI recommended:** [X.X]
**Human-validated:** [X.X] ← *Update this after review*

**Rationale:**
- Urgency signals detected: [N] records contain high-urgency language ("blocking", "can't use", etc.)
- Churn correlation: [Yes — mentioned in N churn interviews / No / Unknown]
- ARR tier: [N]% of reporters are enterprise tier (strongest Impact signal)
- Workaround exists: [Yes — customers describe using [workaround] / No workaround found]
- Emotional intensity: [Low / Medium / High] based on language analysis

**Impact score selection:**
- Chose [X.X] because: [explicit reasoning]
- Considered [X.X] but rejected because: [reasoning]

```
Override (if applicable):
  original_ai_estimate: X.X
  human_override: X.X
  override_rationale: "[Why you changed it]"
```

---

### Confidence — Evidence quality score

**Scale:** 100% = High (analytics-confirmed) | 80% = Solid (multi-channel) | 60% = Moderate | 50% = Low | <50% = Moonshot

**AI assessed:** [N]%
**Human-validated:** [N]% ← *Update this after review*

**Evidence quality assessment:**

| Factor | Quality | Notes |
|---|---|---|
| Channel breadth | [High/Med/Low] | [N] of 7 channels represented |
| Record volume | [High/Med/Low] | [N] records (threshold: >20 = high) |
| Recency | [High/Med/Low] | Most recent record: [date] |
| ARR metadata | [High/Med/Low] | [N]% of records have ARR band data |
| Product analytics | [Available/Not available] | [If available: confirms/contradicts estimate] |
| Customer interviews | [Done/Not done] | [N] interviews conducted |

**Confidence ceiling:** If product analytics are unavailable, maximum confidence is 80% regardless of feedback volume.

```
Override (if applicable):
  original_ai_estimate: N%
  human_override: N%
  override_rationale: "[e.g., 'Conducted 3 customer discovery calls this week that directly validated Impact and Reach estimates. Raising to 90%.']"
```

---

### Effort — Engineering person-months

⚠️ **This component MUST be provided by engineering.** The scoring agent does not estimate Effort.

**Status:** [Awaiting engineering input / Provided by: [Name] on [Date]]

**Engineering estimate:** [N] person-months
**T-shirt size:** [XS / S / M / L / XL / XXL]

**Breakdown (if provided):**
| Work area | Estimate | Notes |
|---|---|---|
| Backend | [N] weeks | [Key technical considerations] |
| Frontend | [N] weeks | [Key UI/UX considerations] |
| Design | [N] weeks | [Design complexity] |
| QA / Testing | [N] weeks | [Test scope] |
| Infrastructure | [N] weeks | [If applicable] |
| **Total** | **[N] weeks = [N] person-months** | |

**Engineering assumptions:**
- [ ] [Assumption 1 from engineering: e.g., "Assumes existing data model can accommodate export fields without migration"]
- [ ] [Assumption 2: e.g., "Assumes 3rd party export library is usable — needs license review"]

**Note:** If the T-shirt size is XL or XXL, flag this opportunity for decomposition before RICE scoring. Large efforts should be broken into smaller OPP-NNN items.

---

## RICE Calculation

```
RICE Score = (Reach × Impact × Confidence) / Effort

           = ([Reach] × [Impact] × [Confidence]%) / [Effort]
           
           = ([N] × [X.X] × [X.XX]) / [N]
           
           = [numerator] / [denominator]
           
           = [SCORE]
```

**RICE Score: [SCORE]**

| Score | Priority tier | Action |
|---|---|---|
| 800+ | P1 — Build now | Immediate sprint |
| 400-799 | **P2 — Build next** ← *this score* | Next 1-2 sprints |
| 200-399 | P3 — Queue | Review quarterly |
| 100-199 | P4 — Consider | Revisit |
| <100 | P5 — Defer | Park |

**This opportunity is:** [P1 / P2 / P3 / P4 / P5]

---

## Sensitivity analysis

*Required before `status: validated`. Shows how the score changes if key assumptions shift.*

| Scenario | Reach | Impact | Confidence | Effort | Score |
|---|---|---|---|---|---|
| Base case | [N] | [X] | [X]% | [N] | **[S]** |
| Optimistic (Reach 2×, Effort −20%) | [N×2] | [X] | [X]% | [N×0.8] | [S] |
| Conservative (Reach ÷2, Confidence −20%) | [N÷2] | [X] | [X−20]% | [N] | [S] |
| Engineering overrun (+50% Effort) | [N] | [X] | [X]% | [N×1.5] | [S] |

**Key sensitivity insight:** [e.g., "Score is most sensitive to the Reach estimate. A 2× change in Reach produces a 2× change in score. Engineering overrun of 50% would drop score from [S] to [S], keeping it in the same priority tier."]

**Most uncertain assumption:** [e.g., "Reach — dark matter multiplier of [X]× has not been validated against churn cohort analysis"]

**Recommended next action to reduce uncertainty:** [e.g., "Pull churn interview transcripts from the last 6 months and search for mentions of this theme. If confirmed in >20% of churns, upgrade Confidence to 90%."]

---

## Revenue at risk flag

*Complete this section if any enterprise customers mentioned this in churn context.*

- [ ] Not applicable — no churn correlation detected
- [ ] **Revenue at risk** — [N] customers representing $[X]K ARR mentioned this in churn context

If Revenue at Risk is flagged, this opportunity should be escalated regardless of RICE score. Attach to a "Revenue Protection" strategic initiative in the roadmap board.

---

## Validation checklist

Before setting `status: validated`:
- [ ] Engineering has provided Effort estimate (not estimated by AI)
- [ ] Reach estimate has been reviewed against product analytics (if available)
- [ ] Impact score has been confirmed by PM
- [ ] Confidence score reflects actual evidence quality (not wishful thinking)
- [ ] Sensitivity analysis is complete
- [ ] Revenue at risk flag has been assessed

---

## Override log

*Append any overrides to AI estimates here with date and reasoning.*

| Date | Component | AI estimate | Human override | Rationale | Overrider |
|---|---|---|---|---|---|
| YYYY-MM-DD | [Reach/Impact/Confidence] | [value] | [value] | [reason] | [name] |

---

*Template version 1.0 — BHIL Product Roadmap Engine — [barryhurd.com](https://barryhurd.com)*
