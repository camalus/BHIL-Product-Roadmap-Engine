# Guide 01: Methodology Overview

**The philosophy behind evidence-based product roadmapping with AI**

---

## The problem this system solves

Every product team faces the same trap: the roadmap reflects who spoke loudest at the last meeting, not what the most customers actually need. The CEO forwards a complaint from one enterprise customer. The sales team lobbies for a feature that unlocked one deal. The support manager escalates the ticket that came in twice this week. Meanwhile, the 47 customers who mentioned the same pain point in NPS verbatims — never read by anyone — go unheard.

This is not a data problem. Product teams today are drowning in feedback. Intercom transcripts. Salesforce call notes. App Store reviews. NPS survey comments. Slack threads. Reddit posts. LinkedIn mentions. The problem is synthesis — turning unstructured signals from seven different channels into a prioritized, defensible list of what to build next.

The BHIL Product Roadmap Engine solves this with a four-stage AI-powered pipeline: **Listen → Synthesize → Prioritize → Communicate**.

---

## The four core principles

**Principle 1: Evidence over intuition.**
Every roadmap item must cite the customer signals that motivated it. Verbatim quotes. Channel attribution. Frequency counts. Segment breakdown. Not "customers want this" but "47 customers mentioned this in Q2, 15 of them enterprise tier, representing $2.1M ARR, with 92% negative sentiment."

**Principle 2: Quantification over qualification.**
Vague prioritization ("high priority," "important," "strategic") is worse than no prioritization — it creates false confidence. RICE scoring converts qualitative signals into a defensible formula: `(Reach × Impact × Confidence) / Effort`. The formula isn't perfect, but it forces specificity. It requires you to say "I estimate this affects 800 users/quarter" instead of "lots of users want this."

**Principle 3: Traceability from signal to shipped feature.**
Every artifact in this pipeline links to its upstream source and its downstream consumer. An Opportunity Brief (OPP-001) links to the 47 feedback records that motivated it. A RICE Scorecard (RICE-001) links to OPP-001. A PRD Stub links to both. When BHIL's development toolkit picks it up as PRD-012, the chain extends to SPEC-012 → TASK-NNN → shipped code. Six months from now, you can ask "why did we build this?" and trace all the way back to a specific customer complaint.

**Principle 4: AI accelerates synthesis, humans make decisions.**
The AI agents in this pipeline do what they are genuinely good at: reading thousands of feedback records, identifying patterns, grouping similar signals, estimating frequency, drafting structured documents. Humans do what they are genuinely good at: judging strategic importance, calibrating effort with engineering context, deciding what to build. The system is designed so AI handles the synthesis burden and humans handle the judgment gates.

---

## The pipeline in detail

### Stage 1: Listen (Parallel Ingestion)

Seven channel-specific ingestion configurations pull feedback from different sources on different cadences:

| Channel | Cadence | Primary signal type |
|---|---|---|
| Intercom (support chat) | Near-real-time (webhook) | Pain points, bugs, feature requests |
| Salesforce / HubSpot (CRM calls) | Daily batch | Sales blockers, competitive mentions |
| App Store / G2 / Capterra (reviews) | Daily batch | Satisfaction drivers, feature gaps |
| NPS surveys | Event-driven (webhook) | Churn risk, delight drivers |
| Reddit / community forums | Hourly polling | Organic sentiment, power user needs |
| Slack (internal) | Near-real-time (Events API) | Support escalations, internal feature requests |
| LinkedIn / social listening | Daily batch (via third-party tool) | Brand perception, competitor comparisons |

Each channel produces normalized feedback records in a canonical schema (see `schemas/normalized-feedback.schema.json`): id, source channel, timestamp, content, author metadata, customer segment, and ARR band where available. This normalization is what makes cross-channel synthesis possible.

### Stage 2: Synthesize (Opportunity Discovery)

The Tagging Agent processes normalized feedback and enriches each record with:
- **Theme classification** against the hierarchical taxonomy in `schemas/tagging-taxonomy.yaml`
- **Sentiment score** (positive / negative / neutral at item level, aspect-level for multi-topic feedback)
- **Named entity extraction** (feature names, product areas, integrations, competitors mentioned)
- **Urgency signals** (language like "blocker," "dealbreaker," "can't use," "churn risk")

The Analyst Agent then clusters related feedback into Opportunity Briefs (OPP-NNN). An opportunity becomes a distinct brief when: a theme appears across ≥5 feedback records, spans ≥2 channels, or shows urgency signals from enterprise-tier customers regardless of volume. The OPP-NNN template (see `templates/opportunity/OPPORTUNITY-BRIEF-TEMPLATE.md`) forces structure: problem statement, verbatim evidence, customer segment impact, strategic alignment, and recommended next steps.

### Stage 3: Prioritize (RICE Scoring)

Approved Opportunity Briefs receive RICE scores from the Scoring Agent, with human review and override at every component:

- **Reach** — Estimated users affected per quarter, derived from feedback record counts extrapolated to full user base
- **Impact** — Strategic importance score (0.25 to 3.0) assigned by PM with reasoning
- **Confidence** — Data quality score (50-100%) based on evidence breadth and freshness
- **Effort** — Person-months from engineering, PM-provided after engineering consultation

`RICE Score = (Reach × Impact × Confidence) / Effort`

The resulting RICE-NNN scorecard documents every estimate with reasoning, runs a sensitivity analysis showing how the score changes if key assumptions shift, and surfaces the top RICE items in a force-ranked backlog.

### Stage 4: Communicate (Roadmap + PRD Generation)

The highest-RICE opportunities feed two outputs:

**Roadmap Board** — A Now / Next / Later view (`templates/roadmap/ROADMAP-BOARD-TEMPLATE.md`) for stakeholder communication. Opportunities are placed based on RICE score, engineering capacity, and strategic dependencies. Updated each sprint.

**PRD Stub** — For the top priorities, the `/generate-prd-from-feedback` skill creates a PRD stub with EARS-format requirements, verbatim-backed problem statements, and acceptance criteria. The stub carries `bhil_handoff` frontmatter that BHIL's `/new-feature` skill reads directly — no re-entry of context.

---

## What this system is not

This system does not replace product judgment. RICE scores are inputs to decisions, not the decisions themselves. A score of 840 does not automatically mean "build this next." Strategic dependencies, technical prerequisites, team capacity, and vision alignment all matter.

This system does not generate requirements from thin air. Every EARS requirement in a PRD stub is derived from real customer feedback. If the feedback doesn't support a requirement, the requirement doesn't appear.

This system does not make decisions faster. It makes decisions *better*. The throughput is: fewer loops in sprint planning because evidence is already assembled, fewer stakeholder challenges because data is cited, fewer post-launch surprises because multiple customer segments informed the requirements.

---

## The compounding value over time

In the first sprint, the pipeline produces its first Opportunity Briefs. In the third sprint, patterns across previous opportunities start emerging. By the sixth sprint, the feedback repository contains enough historical signal to answer questions like "how long do customers wait before churning after hitting this pain point?" and "which features do our highest-ARR customers mention most in churn interviews?"

The pipeline gets more valuable the longer it runs because context accumulates. This is why the storage architecture matters (see `guides/07-storage-architecture.md`) and why traceability IDs are enforced from day one.

---

*Next: Read `guides/02-listen-stage.md` for detailed channel setup instructions.*

*BHIL Product Roadmap Engine — [barryhurd.com](https://barryhurd.com)*
