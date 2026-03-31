# BHIL Product Roadmap Engine — Claude Code Configuration

## Project identity

This is the BHIL Product Roadmap Engine — a methodology toolkit that transforms customer feedback from seven channels into evidence-backed product opportunities, RICE-scored priorities, and PRD stubs ready for handoff to the BHIL AI-First Development Toolkit.

**Pipeline:** LISTEN (7 channels) → SYNTHESIZE (OPP-NNN) → PRIORITIZE (RICE-NNN) → COMMUNICATE (PRD-STUB-NNN → BHIL PRD-NNN)
**Stack:** Markdown, YAML, shell scripts, JSON Schema, GitHub Actions
**Agent toolchain:** Claude Code primary, RuFlo orchestration, PostgreSQL + pgvector or RuVector for feedback repository

---

## CRITICAL: Read before creating any artifact

This is a **methodology and data repository**. Before creating any opportunity brief, RICE scorecard, or PRD stub:

1. Check `project/.sdlc/context/product-context.md` for current product strategy and active OKRs
2. Search existing OPP-NNN files for duplicate or overlapping opportunities
3. Verify the feedback evidence exists in `project/feedback/normalized/` or `integrations/channels/`
4. Ensure the traceability chain is complete before setting status above `draft`

---

## Commands

```bash
# Initialize for a new product
./tools/scripts/init.sh "Product Name" "Context"

# Create a new opportunity brief
./tools/scripts/new-opportunity.sh "Theme name" "CHANNEL-NNN[,CHANNEL-NNN]"

# Create a RICE scorecard for an opportunity
./tools/scripts/new-rice-score.sh "OPP-NNN"

# Validate the full pipeline traceability
./tools/scripts/validate-pipeline.sh

# Check for orphaned artifacts (no upstream or downstream links)
./tools/scripts/validate-pipeline.sh --check-orphans
```

---

## Pipeline artifact rules

### ALWAYS
- Include YAML frontmatter with `id`, `status`, `date` in every artifact
- Use correct ID formats: `OPP-NNN`, `RICE-NNN`, `PRD-STUB-NNN`, `CHANNEL-NNN` (zero-padded to 3 digits)
- Cite verbatim customer quotes with channel attribution for every claim in an Opportunity Brief
- Write EARS-format requirements in PRD stubs: `WHEN [trigger], the system SHALL [response]`
- Write probabilistic acceptance criteria: `≥[X.XX] on [N] runs` for AI components
- Run `./tools/scripts/validate-pipeline.sh` after creating or modifying any artifact
- Cross-reference RICE-NNN back to OPP-NNN and forward to PRD-STUB-NNN in frontmatter

### ASK before
- Creating an OPP-NNN for a theme with fewer than 5 distinct customer mentions
- Setting any OPP-NNN to `status: approved` without at least 2 channels of evidence
- Changing the tagging taxonomy in `schemas/tagging-taxonomy.yaml`
- Modifying a RICE-NNN with `status: validated`

### NEVER
- Create a RICE-NNN without a parent OPP-NNN at `status: approved`
- Fabricate customer quotes — every quote must trace to a real feedback record
- Create a PRD-STUB-NNN without a parent RICE-NNN at `status: validated`
- Modify a channel config in `integrations/channels/` without updating its `last_modified` date
- Set `status: ready-for-handoff` on a PRD stub without EARS-format requirements

---

## Skills available

- **new-opportunity-brief** — Create an OPP-NNN from aggregated feedback evidence
- **new-rice-score** — Score an approved OPP-NNN with RICE framework
- **generate-prd-from-feedback** — Convert OPP + RICE into a BHIL-ready PRD stub

---

## Storage context

This toolkit supports three feedback repository options (see `guides/07-storage-architecture.md`):
- **PostgreSQL + pgvector** — Recommended for production; handles relational metadata and vector search in one system
- **RuVector** — Preferred if already using the Agentics Foundation stack (RuFlo + RuVector)
- **File-based** — Normalized JSON files in `project/feedback/normalized/` — suitable for MVP without database infrastructure

If no database is configured, all feedback operations fall back to the file-based approach.

*BHIL Product Roadmap Engine — [barryhurd.com](https://barryhurd.com)*
