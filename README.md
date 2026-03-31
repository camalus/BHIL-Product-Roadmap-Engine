# BHIL Product Roadmap Engine

**Human-Directed. AI-Enabled. Commercially Tested.**

> *"Your roadmap should be built on evidence, not on whoever spoke loudest at the last all-hands."*

An AI-powered product roadmap methodology that continuously ingests customer feedback from seven channels, synthesizes it into quantified opportunities, scores them with RICE, and generates evidence-backed PRD stubs that feed directly into the **BHIL AI-First Development Toolkit**.

**Companion toolkit:** [BHIL AI-First Development Toolkit](https://github.com/camalus/BHIL-AI-First-Development-Toolkit)

---

## The four-stage pipeline

```
LISTEN           SYNTHESIZE         PRIORITIZE         COMMUNICATE
────────         ──────────         ──────────         ───────────
7 channels  →   Tagging +      →   RICE scoring   →   Roadmap board
(parallel)      clustering          (OPP → RICE)       PRD stub →
                OPP-NNN brief                          BHIL PRD-NNN
```

Every artifact is traceable. An Opportunity Brief (OPP-001) references the channel records that fed it. A RICE Scorecard (RICE-001) references the OPP-001 that motivated it. A PRD Stub references both. When BHIL's `/new-feature` skill picks up that PRD stub, the chain extends: PRD-NNN → SPEC-NNN → TASK-NNN → shipped code. Every engineering decision traces back to a real customer signal.

---

## Repository structure

```
/
├── README.md                              ← You are here
├── CLAUDE.md                              ← Claude Code configuration
├── AGENTS.md                              ← Cross-tool agent context
├── CHANGELOG.md                           ← Version history
│
├── guides/
│   ├── 00-getting-started.md             ← 5-minute setup
│   ├── 01-methodology-overview.md        ← Philosophy and principles
│   ├── 02-listen-stage.md                ← Channel ingestion guide
│   ├── 03-synthesize-stage.md            ← Tagging and opportunity discovery
│   ├── 04-prioritize-stage.md            ← RICE scoring methodology
│   ├── 05-communicate-stage.md           ← Roadmap and PRD generation
│   ├── 06-cross-toolkit-handoff.md       ← Connecting to BHIL AI-First Dev Toolkit
│   └── 07-storage-architecture.md        ← Repository and storage options
│
├── templates/
│   ├── channel/
│   │   └── CHANNEL-CONFIG-TEMPLATE.yaml  ← Channel configuration
│   ├── opportunity/
│   │   └── OPPORTUNITY-BRIEF-TEMPLATE.md ← OPP-NNN document
│   ├── scoring/
│   │   └── RICE-SCORECARD-TEMPLATE.md    ← RICE-NNN document
│   ├── prd-stub/
│   │   └── PRD-STUB-TEMPLATE.md          ← PRD stub for BHIL handoff
│   └── roadmap/
│       └── ROADMAP-BOARD-TEMPLATE.md     ← Now / Next / Later board
│
├── examples/
│   ├── full-chain/                        ← End-to-end example
│   │   ├── OPP-001-bulk-csv-export.md
│   │   ├── RICE-001-bulk-csv-export.md
│   │   └── PRD-STUB-001-bulk-csv-export.md
│   └── channels/                          ← Channel-specific examples
│       ├── CHANNEL-001-intercom.yaml
│       └── CHANNEL-002-app-store.yaml
│
├── schemas/
│   ├── normalized-feedback.schema.json    ← Canonical feedback record schema
│   ├── tagging-taxonomy.yaml             ← Hierarchical theme taxonomy
│   └── scoring-rubric.yaml              ← RICE calibration guide
│
├── integrations/
│   └── channels/
│       ├── CHANNEL-001-intercom.yaml
│       ├── CHANNEL-002-salesforce.yaml
│       ├── CHANNEL-003-hubspot.yaml
│       ├── CHANNEL-004-app-store.yaml
│       ├── CHANNEL-005-nps.yaml
│       ├── CHANNEL-006-reddit-community.yaml
│       ├── CHANNEL-007-slack-internal.yaml
│       └── CHANNEL-008-linkedin-social.yaml
│
├── .claude/
│   ├── settings.json                      ← Hooks and permissions
│   ├── rules/
│   │   ├── traceability-rules.md          ← ID and linking enforcement
│   │   ├── scoring-rules.md               ← RICE quality constraints
│   │   └── evidence-rules.md              ← Feedback citation standards
│   ├── skills/
│   │   ├── new-opportunity-brief/SKILL.md
│   │   ├── new-rice-score/SKILL.md
│   │   └── generate-prd-from-feedback/SKILL.md
│   └── agents/
│       ├── ingestion-agent.md
│       ├── tagging-agent.md
│       ├── analyst-agent.md
│       └── scoring-agent.md
│
├── tools/scripts/
│   ├── init.sh                           ← Project initialization
│   ├── new-opportunity.sh                ← OPP-NNN creation
│   ├── new-rice-score.sh                 ← RICE-NNN creation
│   └── validate-pipeline.sh             ← Traceability validation
│
├── .github/workflows/
│   ├── validate-artifacts.yml
│   ├── check-traceability.yml
│   └── weekly-digest.yml
│
└── project/                              ← Active workspace
    ├── .sdlc/context/
    │   └── product-context.md            ← Product and strategic context
    ├── channels/active/                  ← Active channel configs
    ├── feedback/                         ← Raw and normalized feedback
    └── sprints/S-01/                     ← Current opportunity sprint
```

---

## Artifact traceability system

Every artifact carries a traceability ID and links to its upstream and downstream dependencies:

| Artifact | ID Format | Links to |
|---|---|---|
| Channel configuration | `CHANNEL-NNN` | (root source) |
| Feedback record | `FB-NNNNNN` | `CHANNEL-NNN` |
| Opportunity Brief | `OPP-NNN` | `CHANNEL-NNN[]`, `FB-NNNNNN[]` |
| RICE Scorecard | `RICE-NNN` | `OPP-NNN` |
| PRD Stub | `PRD-STUB-NNN` | `OPP-NNN`, `RICE-NNN` |
| BHIL PRD | `PRD-NNN` | `PRD-STUB-NNN` (cross-toolkit) |

Valid statuses per artifact type:
- Channel: `active` → `paused` → `deprecated`
- Opportunity: `draft` → `in-review` → `approved` → `scored` → `roadmapped` → `complete`
- RICE: `draft` → `ai-scored` → `human-reviewed` → `validated` → `disputed`
- PRD Stub: `draft` → `ready-for-handoff` → `handed-off`

---

## Quick start

```bash
# Clone and initialize
git clone https://github.com/YOUR-USERNAME/product-roadmap-engine.git
cd product-roadmap-engine
chmod +x tools/scripts/*.sh
./tools/scripts/init.sh "Product Name" "SaaS / B2B / [your context]"

# Open Claude Code
claude

# Start listening on your first channel
# In Claude Code: "Use the new-opportunity-brief skill to create OPP-001 for [theme]"
```

**Prerequisites:** Claude Code installed, Node.js 18+, PostgreSQL 15+ with pgvector extension (for feedback repository), or RuVector (for Agentics Foundation stack).

See `guides/00-getting-started.md` for the complete setup sequence.

---

## Cross-toolkit connection

This toolkit is the **upstream** companion to the BHIL AI-First Development Toolkit:

```
This toolkit produces:         BHIL AI-First Dev Toolkit consumes:
─────────────────────          ────────────────────────────────────
PRD-STUB-NNN           →       PRD-NNN (via /new-feature skill)
  ↑ RICE-NNN                   ↓ SPEC-NNN → ADR-NNN → TASK-NNN
  ↑ OPP-NNN                    ↓ CODE → REVIEW → DEPLOY
  ↑ FB-NNNNNN (customer voice)
```

The PRD stub carries `bhil_handoff` frontmatter fields that BHIL's `/new-feature` skill reads automatically when you reference it during sprint planning.

---

## About

**Author:** Barry Hurd
**Organization:** Barry Hurd Intelligence Lab (BHIL)
**Tagline:** Human-Directed. AI-Enabled. Commercially Tested.

---

## License

[MIT License](LICENSE) — Use freely, commercially or otherwise, with attribution.

Attribution: *BHIL Product Roadmap Engine by Barry Hurd (barryhurd.com)*
