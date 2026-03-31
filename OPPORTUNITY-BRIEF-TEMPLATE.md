---
# === TRACEABILITY METADATA ===
id: OPP-NNN
title: "[Opportunity title — 5-8 words describing the customer need]"
status: draft              # draft | in-review | approved | scored | roadmapped | complete
date: YYYY-MM-DD
author: [Name]
sprint: S-NN

# Upstream: channels that contributed evidence
source_channels: [CHANNEL-NNN, CHANNEL-NNN]
feedback_record_count: N
date_range_start: YYYY-MM-DD
date_range_end: YYYY-MM-DD

# Downstream: artifacts this opportunity feeds
rice_scorecard: null        # RICE-NNN (populated when scored)
prd_stub: null              # PRD-STUB-NNN (populated when PRD stub created)
bhil_prd: null              # PRD-NNN (populated after BHIL handoff)

# Tagging
primary_theme: "[theme from tagging taxonomy]"
secondary_themes: []
urgency_level: medium       # critical | high | medium | low
customer_segments_affected: []
---

# OPP-NNN: [Opportunity Title]

## Problem statement

<!--
One or two sentences. Describe the customer pain in their language — not yours.
Do not hint at solutions. Do not use internal product terminology.
Format: "[Customer type] cannot [accomplish goal] because [specific barrier]."
-->

[Customer type] cannot [accomplish goal] because [specific barrier or gap].

---

## Evidence summary

**Total feedback records:** [N]
**Channels represented:** [N of 7] — [list them: Intercom, NPS, App Store, ...]
**Date range:** [YYYY-MM-DD] to [YYYY-MM-DD]
**Sentiment breakdown:** [N]% negative / [N]% neutral / [N]% positive

### Theme frequency by channel

| Channel | Mentions | Sentiment | Urgency signals |
|---|---|---|---|
| Intercom | N | [neg/neu/pos] | [list any: "blocking us", "can't use"] |
| NPS Survey | N | [neg/neu/pos] | |
| App Store | N | [neg/neu/pos] | |
| Salesforce | N | [neg/neu/pos] | |
| Reddit | N | [neg/neu/pos] | |
| Slack | N | [neg/neu/pos] | |
| LinkedIn | N | [neg/neu/pos] | |

---

## Verbatim customer evidence

<!--
REQUIRED: At minimum 5 verbatim quotes. At least 2 from different channels.
Include: source channel, customer segment, ARR band, date.
Do NOT paraphrase. Do NOT summarize. Exact words only.
Redact PII (names, emails) but preserve company tier and ARR band.
-->

**Quote 1**
> "[Exact customer words — verbatim, not paraphrased]"
— *[Channel: Intercom]* | *[Segment: Enterprise]* | *[ARR: $50k–100k]* | *[Date: YYYY-MM-DD]*

**Quote 2**
> "[Exact customer words]"
— *[Channel: NPS Survey]* | *[Segment: Mid-market]* | *[ARR: $10k–50k]* | *[Date: YYYY-MM-DD]*

**Quote 3**
> "[Exact customer words]"
— *[Channel: App Store]* | *[Segment: SMB]* | *[ARR: <$10k]* | *[Date: YYYY-MM-DD]*

**Quote 4**
> "[Exact customer words]"
— *[Channel: ...]* | *[Segment: ...]* | *[ARR: ...]* | *[Date: YYYY-MM-DD]*

**Quote 5**
> "[Exact customer words]"
— *[Channel: ...]* | *[Segment: ...]* | *[ARR: ...]* | *[Date: YYYY-MM-DD]*

---

## Customer segment impact

<!--
Break down who is affected and what their business impact is.
ARR at risk is the most important number for executive communication.
-->

| Segment | Customers affected | ARR represented | Primary signal source |
|---|---|---|---|
| Enterprise | [N] customers | $[X]M | [Channel] |
| Mid-market | [N] customers | $[X]M | [Channel] |
| SMB | [N] customers | $[X]M | [Channel] |

**Total ARR represented:** $[X]M across [N] customers

**Churn correlation:** [Yes — mentioned in N churn interviews | No correlation found | Insufficient data]

**Sales impact:** [Yes — mentioned in N deal-loss notes | No correlation found | Insufficient data]

---

## Related signals

<!--
Adjacent themes, integrations, or features frequently mentioned alongside this opportunity.
Helps scope the solution and identify dependencies.
-->

**Frequently co-mentioned:**
- [Related theme or feature request]
- [Competitor alternative customers mention as workaround]
- [Integration or tool customers are using instead]

**Competitor mentions:**
- [Competitor A] mentioned as having this capability by [N] customers
- [Competitor B] mentioned as workaround by [N] customers

---

## Strategic alignment

<!--
Link this opportunity to an active company OKR or strategic initiative.
If there is no OKR link, document why this opportunity matters strategically anyway.
-->

**Primary OKR:** [e.g., "Increase enterprise retention rate from 85% to 92% by Q3 2026"]
**OKR type:** [outcome — directly measures / leading-indicator — predicts]

**Strategic rationale:** [1-2 sentences explaining how solving this pain point advances the strategic goal]

**Competing opportunities:** [Other OPP-NNN items in the same strategic area, if any]

---

## Proposed solution directions

<!--
NOT a specification. This section surfaces solution hypotheses from the feedback itself.
Customers often describe their workarounds and ideal solutions in their own words.
2-4 options maximum. No technical implementation details.
-->

**Direction A:** [Customer-voiced solution description]
*Evidence:* [N] customers described something like this: "[brief quote summary]"

**Direction B:** [Alternative customer-voiced solution]
*Evidence:* [N] customers described something like this: "[brief quote summary]"

**Assumptions to test before committing:**
- [ ] [Assumption 1: e.g., "Enterprise customers would use this weekly, not just for migration"]
- [ ] [Assumption 2: e.g., "Self-service is preferred over support-assisted export"]

---

## RICE input recommendations

<!--
The scoring agent's first-draft estimates for the RICE scorecard.
These are suggestions — the PM reviews all components, engineering provides Effort.
-->

**Reach (suggested):** [N] users/quarter
*Basis:* [N] feedback records × [X]× dark matter multiplier, adjusted for [segment/product area coverage]

**Impact (suggested):** [1.0 / 2.0 / 3.0 / 0.5 / 0.25]
*Basis:* [Urgency signal count], [churn correlation], [ARR tier of reporters]

**Confidence (suggested):** [50 / 60 / 80 / 100]%
*Basis:* [N channels], [recency of evidence], [quality of ARR data]

**Effort:** ⚠️ Requires engineering input — not estimated here

---

## Recommended next steps

- [ ] **Review and approve** this brief (PM, [time estimate: ~15 min])
- [ ] **Get Effort estimate** from engineering for RICE scoring
- [ ] **Create RICE scorecard**: `./tools/scripts/new-rice-score.sh OPP-NNN`
- [ ] **Consider:** Run a quick survey or customer interview to increase Confidence if currently below 80%
- [ ] **Consider:** Cross-reference with deal-loss data in Salesforce if sales impact is suspected

---

## Approval checklist

Before setting `status: approved`:
- [ ] Problem statement contains no solution hints
- [ ] At least 5 verbatim quotes included with channel and segment attribution
- [ ] At least 2 different channels represented in evidence
- [ ] Customer segment impact table is populated
- [ ] Strategic alignment is linked to an active OKR
- [ ] RICE input recommendations section is complete

---

*Template version 1.0 — BHIL Product Roadmap Engine — [barryhurd.com](https://barryhurd.com)*
