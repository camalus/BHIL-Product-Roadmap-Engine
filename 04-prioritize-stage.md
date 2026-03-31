# Guide 04: The Prioritize Stage

**RICE scoring: from Opportunity Brief to defensible priority**

---

## Why RICE

RICE (Reach, Impact, Confidence, Effort) was developed by Sean McBride at Intercom. Its core insight is that one hard estimate is easier to bias than four smaller ones. When you force yourself to separate "how many customers does this affect?" from "how much will it improve their experience?" from "how certain are we?" from "how much will it cost us?" — you expose the assumptions that intuition hides.

The formula: **`(Reach × Impact × Confidence) / Effort`**

The result is a score in units of "impact per person-month per period." Higher is better. The scores are only meaningful in comparison to each other — the absolute number has no inherent meaning.

---

## The four components

### Reach — Number of users affected per quarter

Reach is an estimate of how many unique users will be affected by this change in a 90-day period. It is NOT the number of people who complained about the problem. It is an estimate of how many users would benefit if the problem were solved.

**How the scoring agent estimates Reach:**
1. Count distinct customers who mentioned this theme in the feedback repository over the past 90 days
2. Estimate the "dark matter" — customers who have the pain but haven't reported it. Industry research suggests only 1-in-26 customers complain for every one who silently leaves. Apply a multiplier of 3-10× depending on how passive the channel mix is.
3. If product analytics are available (Amplitude, Mixpanel, Segment): count users who encounter the relevant workflow per quarter. This is the best source of Reach data.

**RICE Reach calibration:**

| Reach Value | Interpretation | Example |
|---|---|---|
| 5,000+ | Affects the majority of the user base | Core onboarding flow |
| 1,000-5,000 | Affects a large segment | Power users, specific plan tier |
| 500-1,000 | Affects a notable minority | Specific integration users |
| 100-500 | Affects a small but important segment | Enterprise admins |
| 10-100 | Affects a niche segment | API users, specific role |

**Always express Reach as a specific number, not a range.** If you are uncertain, use the lower bound of your estimate and reduce Confidence accordingly.

### Impact — Magnitude of improvement per affected user

Impact measures how significantly this change will improve the experience for each affected user. Intercom's original scale:

| Score | Label | Meaning |
|---|---|---|
| 3 | Massive | Core workflow transformation, churn prevention |
| 2 | High | Significant daily friction eliminated |
| 1 | Medium | Noticeable improvement to common task |
| 0.5 | Low | Minor convenience gain |
| 0.25 | Minimal | Polish, cosmetic, edge case |

**This is the most subjective component.** The scoring agent provides a recommended Impact based on sentiment analysis and urgency signal detection, but the PM must review and confirm.

**High-impact signals to look for in feedback:**
- Urgency language: "blocking," "dealbreaker," "can't use," "waiting on this to upgrade"
- Churn correlation: feature mentioned in churn survey verbatims
- Emotional intensity: all-caps, exclamation marks, multiple follow-up messages on same issue
- Enterprise customer flag: any feedback from customers above your ARR median

**Low-impact signals:**
- Single mention with no follow-ups
- "Nice to have" or "not urgent" language from customer
- Mentioned only by trial users or newest cohort

### Confidence — Quality of the evidence

Confidence reflects how certain you are in your Reach and Impact estimates. It is not a measure of whether you believe the feature is a good idea — it is a measure of the data quality underlying your estimates.

| Score | Label | Evidence quality |
|---|---|---|
| 100% | High confidence | Product analytics confirms Reach; multiple churn interviews confirm Impact |
| 80% | Solid | Multi-channel feedback (3+ sources); Impact confirmed by explicit customer statements |
| 60% | Moderate | Two channels; some indirect inference in estimates |
| 50% | Low | Single channel or single customer; significant assumption required |
| Below 50% | Moonshot | Unvalidated hypothesis; treat separately from data-driven items |

**Do not round Confidence up.** If you are at 55%, say 50%. The penalty for overconfidence compounds through the formula.

**How to increase Confidence:**
- Add more channels: an opportunity with Intercom + NPS + App Store evidence is more confident than Intercom alone
- Interview customers directly about the pain point
- Run a targeted survey ("On a scale of 1-10, how much does [X] slow you down?")
- Review product analytics for the relevant workflow

### Effort — Person-months to build and ship

Effort is the total estimated engineering time across all contributors (frontend, backend, design, QA, infrastructure). It is expressed in person-months.

| Effort (person-months) | T-shirt size | Example |
|---|---|---|
| 0.5 | XS | Minor UI change, copy update, flag toggle |
| 1 | S | Small new endpoint, simple UI component |
| 2-3 | M | New feature with API, frontend, and basic testing |
| 4-6 | L | Complex feature with multiple integrations |
| 8-12 | XL | Major system change, significant architecture impact |
| 12+ | XXL | Platform-level change; should be broken down |

**The scoring agent never estimates Effort.** Effort always requires engineering input. The agent will flag `effort_requires_input: true` and block the RICE score from reaching `status: validated` until an engineer provides this estimate.

---

## The RICE formula and score interpretation

```
RICE Score = (Reach × Impact × Confidence%) / Effort
           = (800 × 2 × 0.80) / 3
           = 1,280 / 3
           = 427
```

**Score interpretation (these thresholds are calibrated to your product — adjust in `schemas/scoring-rubric.yaml`):**

| Score | Priority tier | Recommended action |
|---|---|---|
| 800+ | P1 — Build now | Immediate sprint inclusion |
| 400-799 | P2 — Build next | Next 1-2 sprint cycles |
| 200-399 | P3 — Queue | Backlog, review quarterly |
| 100-199 | P4 — Consider | Revisit if scope changes |
| Below 100 | P5 — Defer | Park until evidence strengthens |

---

## AI-assisted versus human scoring

The scoring agent provides first-draft estimates for Reach, Impact, and Confidence based on feedback data. These are inputs — not decisions.

| Component | AI role | Human role |
|---|---|---|
| Reach | Counts feedback records, applies multiplier heuristic | Validate against product analytics; override with usage data |
| Impact | Analyzes urgency signals, suggests 0.25-3.0 score | Confirm or override with strategic context |
| Confidence | Assesses evidence breadth and recency | Override if qualitative context changes confidence level |
| Effort | Flags as "requires engineering input" | Provide after engineering consultation — always |

**The override protocol:**
- Any human override of an AI estimate must include a `override_rationale` field
- Overrides are stored in the RICE-NNN document alongside the original AI estimate
- The override history is visible for calibration — over time, systematic drift between AI estimates and human overrides reveals where the AI model needs recalibration

---

## Sensitivity analysis — required for every RICE scorecard

Before a RICE score reaches `status: validated`, the scoring agent runs a sensitivity analysis showing how the score changes under different assumptions:

```
Base case:       Reach=800, Impact=2, Confidence=80%, Effort=3  → Score: 427
Optimistic:      Reach=1200, Impact=2, Confidence=80%, Effort=2  → Score: 960
Conservative:    Reach=400, Impact=1, Confidence=60%, Effort=4   → Score: 60

Key sensitivity: Score is most sensitive to Reach estimate.
                 A 2× difference in Reach produces a 2× difference in score.
                 Effort estimate from engineering should be confirmed before final scoring.
```

Sensitivity analysis surfaces which assumption deserves the most scrutiny before committing to prioritization. If the score swings from 60 to 960 depending on your Reach estimate, you need more data on Reach — not more time debating Impact.

---

## RICE limitations and when to override

RICE systematically undervalues two types of opportunities:

**Strategic bets:** A new market entry or platform capability may score low on RICE because Reach is currently small (you haven't entered the market yet) and Confidence is low (unvalidated hypothesis). These should be tracked separately as "Strategic Initiatives" and evaluated against OKRs rather than RICE score alone.

**Churn-prevention fixes:** High-urgency pain points from your highest-ARR customers may have low Reach (few customers hit this) but catastrophic Impact if not fixed. Weight these separately using a "Revenue at Risk" flag in the RICE scorecard.

**The fail-safe:** No RICE score creates an obligation to build. A PM can always override the backlog ordering with documented reasoning. The value of RICE is not that it decides — it is that it surfaces assumptions that would otherwise be implicit.

---

## The force-ranked backlog

Once a sprint cycle's RICE scores are validated, the output is a force-ranked backlog in `project/.sdlc/context/product-context.md`. The backlog is sorted by RICE score, annotated with status, strategic tier, and PRD stub linkage:

```markdown
## Force-Ranked Opportunity Backlog (Sprint S-03)

| Rank | OPP | Title | RICE | Status | PRD Stub |
|---|---|---|---|---|---|
| 1 | OPP-001 | Bulk CSV Export | 640 | PRD stub created | PRD-STUB-001 |
| 2 | OPP-007 | API Rate Limit Increase | 512 | Validated | — |
| 3 | OPP-003 | SSO / SAML Integration | 480 | Validated | — |
| 4 | OPP-012 | Mobile Push Notifications | 320 | In review | — |
...
```

---

*Next: Read `guides/05-communicate-stage.md` for roadmap board creation and PRD stub generation.*

*BHIL Product Roadmap Engine — [barryhurd.com](https://barryhurd.com)*
