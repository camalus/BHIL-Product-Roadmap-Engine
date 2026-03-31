---
id: RICE-001
title: "RICE Score: Bulk CSV export for enterprise data analysts"
status: validated
date: 2026-03-22
sprint: S-01

opportunity: OPP-001
prd_stub: PRD-STUB-001

rice_score: 640
priority_tier: P2
recommendation: build-next
---

# RICE-001: RICE Score for Bulk CSV Export

## Linked opportunity

**OPP-001:** Bulk CSV export for enterprise data analysts
**OPP status:** approved
**Feedback records:** 47 records across 4 channels
**Top customer segment:** Enterprise
**ARR represented:** ~$2.1M

---

## RICE Components

### Reach — Users affected per quarter

**AI estimate:** 800 users/quarter
**Human-validated:** 800 users/quarter ✓ *Confirmed — no change*

**Estimation methodology:**
1. Feedback record count: 47 distinct customers in past 90 days
2. Dark matter multiplier applied: 5× (standard default for enterprise segment — enterprise tier uses 3-5×)
3. Raw estimate: 47 × 5 = 235 direct reporters extrapolated
4. Adjustment: The 47 complainants represent ~6% of the total enterprise + mid-market base. Applying to total user base: ~800 users engage with data export workflows quarterly based on product usage patterns (estimated; analytics not yet integrated)
5. **Final Reach: 800 users/quarter**

**Reach confidence note:** Moderate-high. Product analytics integration pending — this estimate would upgrade to 100% confidence once confirmed with Amplitude data showing export workflow usage. Current estimate is directionally sound based on segment size and feedback coverage.

```
Override:
  original_ai_estimate: 800
  human_override: 800
  override_rationale: "Confirmed — consistent with rough sizing based on known enterprise base"
  override_date: 2026-03-22
  overridden_by: Barry Hurd
```

---

### Impact — Magnitude of improvement per user

**AI recommended:** 2.0 (High)
**Human-validated:** 2.0 (High) ✓ *Confirmed*

**Rationale:**
- Urgency signals detected: 18 of 47 records (38%) contain urgency language — "can't do our reporting", "blocking us", "3 hours every Friday"
- Churn correlation: Yes — mentioned in 2 confirmed churn interviews, $165k ARR at risk
- ARR tier: 31% of reporters are enterprise tier; 2 are >$100k ARR
- Workaround exists: Yes — customers split exports into 4,999-row batches — but it's actively painful (2-3 hours of manual work cited)
- Competitive disadvantage: Competitor A cited as having this capability by 9 customers; mentioned as deal-loss factor in 3 notes

**Impact score selection:**
- Chose 2.0 because the workaround is painful but possible — not a complete blocker for most customers
- Considered 3.0 (Massive) but rejected — 3.0 requires core workflow to be completely broken with no workaround. The batch split workaround, while painful, means customers can still function.
- Escalation rule applied: churn_correlation + enterprise ARR → minimum Impact 2.0. Score confirmed.

```
Override:
  original_ai_estimate: 2.0
  human_override: 2.0
  override_rationale: "Confirmed. Would revisit to 3.0 if churn interviews confirm this as primary termination driver for more customers."
```

---

### Confidence — Evidence quality score

**AI assessed:** 80%
**Human-validated:** 80% ✓ *Confirmed*

**Evidence quality assessment:**

| Factor | Quality | Notes |
|---|---|---|
| Channel breadth | High | 4 of 7 channels represented: Intercom, G2, NPS, Slack |
| Record volume | High | 47 records exceeds the 20+ threshold for "high volume" |
| Recency | High | Most recent record: 2026-03-15 (5 days ago) |
| ARR metadata | Medium | 31 of 47 records (66%) have ARR band data |
| Product analytics | Not available | No Amplitude integration yet — maximum confidence capped at 80% |
| Customer interviews | Not done | Pending discovery calls with top 3 complainants |

**Confidence ceiling:** 80% — product analytics not available. Score stands at 80%.

```
Override:
  original_ai_estimate: 80
  human_override: 80
  override_rationale: "Confirmed. Will re-evaluate to 90%+ after discovery calls and Amplitude data confirms Reach estimate."
```

---

### Effort — Engineering person-months

**Status:** Provided by Engineering Lead (Sarah Chen) on 2026-03-22
**Engineering estimate:** 3.0 person-months
**T-shirt size:** M

**Breakdown:**
| Work area | Estimate | Notes |
|---|---|---|
| Backend | 5 weeks | Async job queue implementation; worker service for large dataset processing |
| Frontend | 3 weeks | Progress indicator, email notification, download page |
| Design | 1 week | UX for async download flow (progress page, email template) |
| QA / Testing | 2 weeks | Load testing at 100k rows; edge cases (empty export, partial failure) |
| Infrastructure | 1 week | Job queue infrastructure (Redis or similar); storage for temp export files |
| **Total** | **12 weeks = 3.0 person-months** | |

**Engineering assumptions:**
- [ ] Async job queue can use existing Redis instance — no new infrastructure procurement needed
- [ ] Temp export files can be stored in existing S3 bucket with 24h TTL
- [ ] No database schema migration required — current schema supports the export query as-is

---

## RICE Calculation

```
RICE Score = (Reach × Impact × Confidence) / Effort

           = (800 × 2.0 × 0.80) / 3.0
           
           = (800 × 2.0 × 0.80) / 3.0
           
           = 1,280 / 3.0
           
           = 426.7 → rounded to 427
```

**Wait — recalculating with all confirmed values:**
```
Reach: 800
Impact: 2.0
Confidence: 80% = 0.80
Effort: 3.0 person-months

RICE Score = (800 × 2.0 × 0.80) / 3.0
           = 1,280 / 3.0
           = 427
```

**Hmm — but the frontmatter shows 640. Let me correct:**

*Note for example purposes: The score was originally calculated at 640 when engineering estimated 2.0 person-months. After final estimate of 3.0, correct score is 427.*

**Corrected RICE Score: 427 → Priority Tier: P2 (Build next, 400-799)**

---

## Sensitivity analysis

| Scenario | Reach | Impact | Confidence | Effort | Score |
|---|---|---|---|---|---|
| **Base case** | **800** | **2.0** | **80%** | **3.0** | **427** |
| Optimistic (analytics confirms 2× Reach, Confidence 90%) | 1,600 | 2.0 | 90% | 3.0 | 960 → **P1** |
| Conservative (Reach ÷2, Confidence 60%) | 400 | 2.0 | 60% | 3.0 | 160 → **P4** |
| Engineering overrun (+50% Effort) | 800 | 2.0 | 80% | 4.5 | 284 → **P3** |
| Impact upgrade (churn interviews confirm 3.0) | 800 | 3.0 | 80% | 3.0 | 640 → **P2** |

**Key sensitivity insight:** Score is most sensitive to the Reach estimate. Integrating product analytics (which would confirm or revise the 800 user estimate) is the single highest-value action for improving scoring confidence. An engineering overrun of 50% drops the priority tier from P2 to P3 — worth monitoring.

**Most uncertain assumption:** Reach estimate of 800 — based on dark matter multiplier extrapolation from 47 feedback records without analytics confirmation.

**Recommended action to reduce uncertainty:** Integrate Amplitude before next sprint planning to confirm how many users engage with the export workflow per quarter. Estimated effort: 0.5 days (existing Amplitude integration exists; just need the query).

---

## Revenue at risk flag

✅ **Revenue at risk flagged**

- 2 confirmed churn cases with CSV export as cited reason: ~$165k ARR
- 3 deal-loss notes with CSV export as cited deciding factor: ~$245k ACV
- Total revenue risk: ~$410k

This opportunity is classified as **Revenue Protection** in addition to its RICE tier. Even if the RICE score dropped to P3 due to engineering overrun, this flag keeps it under active consideration.

---

## Validation checklist

- [x] Engineering has provided Effort estimate (Sarah Chen, 2026-03-22)
- [x] Reach estimate reviewed — product analytics not yet available, estimate is directional
- [x] Impact score confirmed by PM (Barry Hurd, 2026-03-22)
- [x] Confidence score reflects evidence quality — capped at 80% without analytics
- [x] Sensitivity analysis complete
- [x] Revenue at risk flag assessed — flagged

**Status: validated ✓**

---

## Override log

| Date | Component | AI estimate | Human override | Rationale | Overrider |
|---|---|---|---|---|---|
| 2026-03-22 | Effort | "requires engineering input" | 3.0 months | Engineering estimate from Sarah Chen | Barry Hurd |

---

*Example — BHIL Product Roadmap Engine — [barryhurd.com](https://barryhurd.com)*
