---
name: new-opportunity-brief
description: Create a new Opportunity Brief (OPP-NNN) from aggregated customer feedback. Use when you have identified a recurring theme across feedback channels and want to formalize it into a scored, traceable opportunity. Triggers on phrases like 'create an opportunity brief', 'new opportunity', 'document this theme', 'create OPP for'.
---

# Skill: New Opportunity Brief

## Purpose
Guide the user through creating a complete, evidence-backed OPP-NNN document from aggregated customer feedback. Enforces the evidence standard: every claim must be backed by verbatim quotes.

## Execution steps

### Step 1: Gather context

Ask the user:
1. What is the theme or pain point? (describe in one sentence)
2. Which channels have you seen this in? (list known channels)
3. What is your product context file path? (default: `project/.sdlc/context/product-context.md`)

Do not proceed until all three questions are answered.

### Step 2: Check for duplicates

Search existing OPP-NNN files for semantic overlap:

```bash
grep -r "[key theme words]" project/.sdlc/opportunities/ 2>/dev/null
grep -r "[key theme words]" examples/ 2>/dev/null
```

If a similar OPP exists, surface it to the user and ask whether to:
a) Update the existing OPP with new evidence
b) Create a new OPP for a distinct angle
c) Abandon (the existing OPP already covers this)

### Step 3: Get the next available OPP number

```bash
ls project/.sdlc/opportunities/OPP-*.md 2>/dev/null | \
  grep -oE 'OPP-[0-9]+' | \
  sort -t- -k2 -n | \
  tail -1 | \
  grep -oE '[0-9]+' | \
  awk '{printf "OPP-%03d\n", $1+1}'
```

If no OPPs exist, start at OPP-001.

### Step 4: Gather evidence from feedback records

Search for relevant feedback records in the normalized feedback directory:

```bash
# File-based: search normalized feedback
grep -rl "[theme keyword]" project/feedback/normalized/ 2>/dev/null | head -20

# Check channel records
for channel_dir in project/channels/active/; do
  grep -rl "[theme keyword]" "$channel_dir" 2>/dev/null
done
```

Count distinct feedback records found. If fewer than 5 are found:
- Warn the user: "Only [N] records found for this theme. An OPP-NNN should have ≥5 distinct customer mentions. Continue anyway?"
- If they confirm, proceed but set `urgency_level: low` and note the limited evidence in the brief.

### Step 5: Extract verbatim quotes

From the records found, extract verbatim customer quotes. Select:
- The most urgent/emotionally intense quote
- At least one quote from each channel represented
- At least one enterprise-tier quote (if available)
- At least one quote that mentions a competitor or workaround (if available)

CRITICAL: Quotes must be verbatim. Do not summarize. Do not paraphrase. Copy exact text from the record's `content` field.

### Step 6: Generate the opportunity brief

Create the OPP file at: `project/.sdlc/opportunities/OPP-NNN-[kebab-theme-title].md`

Use `templates/opportunity/OPPORTUNITY-BRIEF-TEMPLATE.md` as the base.

Fill in:
- frontmatter: id, date (today), sprint (current sprint from `project/sprints/`), source_channels (list CHANNEL-NNN IDs found), feedback_record_count
- Problem statement: derive from the user's theme description + evidence pattern. No solution hints.
- Evidence summary table: count records per channel
- Verbatim quotes: at least 5, with channel/segment/ARR/date attribution
- Customer segment impact: estimate from available metadata in feedback records
- Related signals: identify co-mentioned themes from the records found
- RICE input recommendations: suggest Reach, Impact, Confidence based on `schemas/scoring-rubric.yaml` calibration standards
- Strategic alignment: read `project/.sdlc/context/product-context.md` for current OKRs

Set `status: draft`.

### Step 7: Validate and report

Run:
```bash
./tools/scripts/validate-pipeline.sh OPP-NNN
```

Report to user:
```
✅ OPP-NNN created: project/.sdlc/opportunities/OPP-NNN-[title].md

Evidence summary:
  - [N] feedback records across [N] channels
  - [N] verbatim quotes included
  - Primary theme: [theme]
  - Urgency level: [level]

RICE input recommendations (review before scoring):
  - Reach suggestion: [N] users/quarter
  - Impact suggestion: [X.X] ([label])
  - Confidence suggestion: [N]%
  - Effort: ⚠️ Requires engineering input

Next steps:
1. Review the brief and set status: in-review
2. Get Effort estimate from engineering
3. Run: ./tools/scripts/new-rice-score.sh OPP-NNN
   OR: Use the new-rice-score skill in Claude Code
```

---

*BHIL Product Roadmap Engine — Skill version 1.0*
