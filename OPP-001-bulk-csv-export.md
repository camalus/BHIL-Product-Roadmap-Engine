---
id: OPP-001
title: "Bulk CSV export for enterprise data analysts"
status: approved
date: 2026-03-20
author: Barry Hurd
sprint: S-01

source_channels: [CHANNEL-001, CHANNEL-004, CHANNEL-005, CHANNEL-007]
feedback_record_count: 47
date_range_start: 2025-12-01
date_range_end: 2026-03-20

rice_scorecard: RICE-001
prd_stub: PRD-STUB-001
bhil_prd: null

primary_theme: "bulk-export"
secondary_themes: ["data-management", "reporting-analytics"]
urgency_level: high
customer_segments_affected: [enterprise, mid-market]
---

# OPP-001: Bulk CSV Export for Enterprise Data Analysts

## Problem statement

Enterprise data analysts cannot perform their standard monthly reporting workflows because the product's export function fails silently or returns incomplete data for record sets exceeding 5,000 rows, forcing teams to either use manual workarounds or rely on support intervention for every export cycle.

---

## Evidence summary

**Total feedback records:** 47
**Channels represented:** 4 of 7 — Intercom, App Store (G2), NPS (Delighted), Slack (internal)
**Date range:** 2025-12-01 to 2026-03-20
**Sentiment breakdown:** 83% negative / 12% neutral / 5% positive

### Theme frequency by channel

| Channel | Mentions | Sentiment | Urgency signals |
|---|---|---|---|
| Intercom | 28 | Negative | "broken for us", "can't use", "need this fixed now" |
| G2 Reviews | 9 | Negative | "dealbreaker", "frustrating limitation" |
| NPS Survey | 6 | Negative | "this is why I gave a 4" |
| Slack (internal) | 4 | Neutral | CS escalations; "enterprise customer escalated again" |

---

## Verbatim customer evidence

**Quote 1 — Most urgent**
> "The CSV export is completely broken for anything over 5,000 rows. We literally cannot do our monthly board reporting without this. Your team has been 'looking into it' for 6 weeks. We are actively evaluating alternatives."
— *Intercom* | *Enterprise* | *ARR: $50k–100k* | *2026-03-10*

**Quote 2 — Churn signal**
> "I gave you a 6 because the product is great but the data export is still broken. Until I can reliably export my full dataset, I can't recommend you to our other divisions."
— *NPS Survey (score: 6, detractor)* | *Enterprise* | *ARR: $100k+* | *2026-02-28*

**Quote 3 — Feature comparison**
> "Competitor X lets us export unlimited rows with one click. We use a workaround (split exports into batches of 4,999 rows) but it takes our analyst 2 hours every month instead of 5 minutes. This is embarrassing."
— *G2 Review* | *Mid-market* | *ARR: $10k–50k* | *2026-02-15*

**Quote 4 — Repeated escalation**
> "Third ticket this quarter about the CSV export failing for Acme Corp. They're on the $85k plan. They want to know if there's a timeline."
— *Slack #support-escalations (internal CS team)* | *Enterprise* | *ARR: $50k–100k* | *2026-03-15*

**Quote 5 — Workaround burden**
> "I love the product overall but please fix the export. I export 15,000 rows 3x/week and have to split it every time. It's a significant time drain for our data team."
— *Intercom* | *Mid-market* | *ARR: $10k–50k* | *2026-01-22*

**Quote 6 — Competitor mention**
> "We evaluated you and [Competitor] side by side. [Competitor] has unlimited exports. This was the deciding factor for two of our divisions going with them."
— *Intercom (deal-loss follow-up)* | *Enterprise* | *ARR: $100k+* | *2026-02-04*

**Quote 7 — Power user impact**
> "As the data admin, I'm responsible for pulling weekly reports for 8 managers. The export limit means I spend 3 hours every Friday doing what should take 15 minutes. This has been our #1 complaint since we signed."
— *G2 Review* | *Enterprise* | *ARR: $50k–100k* | *2026-01-30*

---

## Customer segment impact

| Segment | Customers affected | ARR represented | Primary signal source |
|---|---|---|---|
| Enterprise | 14 customers | ~$1.4M | Intercom + Slack escalations |
| Mid-market | 23 customers | ~$0.7M | Intercom + G2 |
| SMB | 10 customers | ~$0.1M | G2 + NPS |

**Total ARR represented:** ~$2.1M across 47 customers

**Churn correlation:** Yes — mentioned in 2 churn interviews (Acme Corp in Q4 2025; TechFlow Inc in Q1 2026). Estimated $165k ARR at risk.

**Sales impact:** Yes — mentioned in 3 deal-loss notes as deciding factor. Estimated $245k ACV lost.

---

## Related signals

**Frequently co-mentioned:**
- API rate limit restrictions (15 mentions) — power users attempting API-based data export as workaround
- Scheduled reports / automated exports (12 mentions) — customers want the export to run automatically
- Google Sheets / Excel integration (8 mentions) — customers want direct push to spreadsheets, not CSV download

**Competitor mentions:**
- Competitor A mentioned as having unlimited exports by 9 customers
- Competitor B mentioned as alternative workaround by 4 customers

---

## Strategic alignment

**Primary OKR:** Increase enterprise retention rate from 85% to 92% by Q3 2026
**OKR type:** leading-indicator — removing a cited churn driver directly supports retention improvement

**Strategic rationale:** Enterprise data analysts are power users who are most likely to influence renewal decisions. Removing the export limitation eliminates the most-cited operational complaint from this cohort and reduces the competitive disadvantage mentioned in 3 deal-loss notes.

**Competing opportunities:** OPP-007 (API rate limit increase) addresses the same analyst persona but through a different access method — related but separate solutions.

---

## Proposed solution directions

**Direction A:** Remove the row limit on CSV exports entirely (async processing for large datasets)
*Evidence:* 31 customers described wanting "unlimited exports" or "no size limit"

**Direction B:** Increase the limit to 50,000 rows with a progress indicator for large exports
*Evidence:* 9 customers mentioned the current 5,000-row limit specifically as the pain point; implied a higher limit would be acceptable

**Assumptions to test before committing:**
- [ ] Enterprise customers primarily want unlimited one-time exports, not scheduled recurring exports (test: survey top 5 complainants)
- [ ] Async processing (job queue + email link) is acceptable UX for large exports — customers don't need immediate download
- [ ] Current backend architecture can support async export jobs without major refactoring

---

## RICE input recommendations

**Reach (suggested):** 800 users/quarter
*Basis:* 47 feedback records × 5× dark matter multiplier × adjustment for enterprise segment (lower multiplier) = ~800 unique users impacted per quarter

**Impact (suggested):** 2.0 (High)
*Basis:* Urgency signals in 18 of 47 records (38%), churn correlation confirmed, ARR tier skews enterprise, competitive alternative mentioned — all point to High Impact

**Confidence (suggested):** 80%
*Basis:* 4 channels represented, 47 records, evidence is recent (within 90 days), ARR metadata available for 31 of 47 records; limited by absence of product analytics confirmation

**Effort:** ⚠️ Requires engineering input

---

## Recommended next steps

- [x] **Review and approve** this brief ✓ (approved 2026-03-20)
- [ ] **Get Effort estimate** from engineering for RICE scoring (ping @engineering-lead)
- [x] **Created RICE scorecard:** RICE-001
- [ ] **Consider:** Schedule 3 discovery calls with top enterprise complainants to validate Direction A vs. B assumption
- [ ] **Consider:** Pull churn interview transcripts to confirm $165k ARR-at-risk estimate

---

*Example — BHIL Product Roadmap Engine — [barryhurd.com](https://barryhurd.com)*
