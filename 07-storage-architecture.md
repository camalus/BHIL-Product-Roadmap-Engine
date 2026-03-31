# Guide 07: Storage Architecture

**Three options for the feedback repository, with ADR documenting the choice**

---

## Overview

The feedback repository is the central data store that makes the entire pipeline possible. It needs to do two things well: store structured metadata about feedback records (channel, customer segment, ARR, timestamp) AND enable semantic search (finding feedback records that are conceptually similar, not just lexically matching).

This guide documents three options and includes a storage ADR template pre-filled for each. Pick the one that fits your stack — or adapt one of the pre-filled ADRs as your actual decision record.

---

## Option A: PostgreSQL + pgvector (Recommended)

**One database for everything.** Relational metadata (customer segment, channel, timestamps, themes) lives in standard PostgreSQL columns. Vector embeddings for semantic search live in a `vector(1536)` column alongside the same rows. Queries are atomic — no sync between two systems, no consistency gaps, no operational overhead of two databases.

### Why this is the default recommendation

The 2025 production benchmark: pgvector achieves **471 QPS at 99% recall on 50M vectors** with the pgvectorscale extension — 11.4× better than Qdrant at the same recall level. For a typical product feedback repository (50K–500K records), standard pgvector with HNSW indexing provides adequate performance with no additional infrastructure.

Instacart migrated from Elasticsearch to PostgreSQL + pgvector and reported **80% cost savings** on storage and indexing with improved search relevance. The key insight: when documents and embeddings live in the same atomic transaction, you never have a state where the relational data is updated but the vector hasn't caught up.

### Setup

```sql
-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Core feedback table
CREATE TABLE feedback_records (
  id              TEXT PRIMARY KEY,          -- FB-NNNNNN
  channel_id      TEXT NOT NULL,             -- CHANNEL-NNN
  channel_type    TEXT NOT NULL,
  source_id       TEXT NOT NULL,
  source_url      TEXT,
  ingested_at     TIMESTAMPTZ DEFAULT NOW(),
  feedback_date   TIMESTAMPTZ NOT NULL,
  content         TEXT NOT NULL,
  author_id       TEXT,
  author_type     TEXT,                      -- customer | prospect | internal
  segment         TEXT,                      -- enterprise | mid-market | smb | free
  plan            TEXT,
  arr_band        TEXT,                      -- <10k | 10k-50k | 50k-100k | 100k+
  tenure_months   INTEGER,
  company_id      TEXT,
  sentiment       TEXT,                      -- positive | negative | neutral
  sentiment_score DECIMAL(4,3),
  themes          TEXT[],                    -- from tagging taxonomy
  urgency_level   TEXT,                      -- critical | high | medium | low
  urgency_signals TEXT[],
  ai_confidence   DECIMAL(4,3),
  status          TEXT DEFAULT 'raw',        -- raw | processed | linked
  linked_opps     TEXT[],                    -- OPP-NNN references
  embedding       vector(1536),             -- OpenAI text-embedding-3-small
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- HNSW index for fast approximate nearest-neighbor search
CREATE INDEX ON feedback_records
  USING hnsw (embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 64);

-- GIN index for fast theme array filtering
CREATE INDEX ON feedback_records USING GIN (themes);

-- Composite index for common analyst queries
CREATE INDEX ON feedback_records (channel_id, feedback_date DESC);
CREATE INDEX ON feedback_records (segment, arr_band, feedback_date DESC);

-- Materialized view for theme frequency tracking
CREATE MATERIALIZED VIEW theme_weekly_counts AS
SELECT
  date_trunc('week', feedback_date) AS week,
  unnest(themes) AS theme,
  COUNT(*) AS mention_count,
  COUNT(DISTINCT company_id) AS unique_companies,
  AVG(sentiment_score) AS avg_sentiment
FROM feedback_records
GROUP BY 1, 2;

CREATE UNIQUE INDEX ON theme_weekly_counts (week, theme);
```

### Key query patterns

```sql
-- Trend detection: z-score anomaly for emerging themes
WITH theme_stats AS (
  SELECT theme,
    COUNT(*) AS recent_count,
    AVG(cnt) OVER (PARTITION BY theme ORDER BY week
                   ROWS BETWEEN 12 PRECEDING AND 1 PRECEDING) AS rolling_avg,
    STDDEV(cnt) OVER (PARTITION BY theme ORDER BY week
                     ROWS BETWEEN 12 PRECEDING AND 1 PRECEDING) AS rolling_std
  FROM theme_weekly_counts
  WHERE week >= NOW() - INTERVAL '4 weeks'
)
SELECT theme, recent_count,
  (recent_count - rolling_avg) / NULLIF(rolling_std, 0) AS z_score
FROM theme_stats
WHERE z_score > 2.0
ORDER BY z_score DESC;

-- Semantic similarity search with metadata filter
SELECT id, content, sentiment, segment, arr_band,
       embedding <=> $1 AS distance
FROM feedback_records
WHERE segment = 'enterprise'
  AND feedback_date > NOW() - INTERVAL '90 days'
  AND status = 'processed'
ORDER BY embedding <=> $1
LIMIT 20;

-- RICE Reach estimation for a theme
SELECT
  COUNT(DISTINCT company_id) AS unique_companies,
  COUNT(DISTINCT author_id) AS unique_customers,
  SUM(CASE WHEN arr_band IN ('50k-100k', '100k+') THEN 1 ELSE 0 END) AS enterprise_customers,
  STRING_AGG(DISTINCT channel_id, ', ') AS channels_represented
FROM feedback_records
WHERE themes @> ARRAY['bulk-export']
  AND feedback_date > NOW() - INTERVAL '90 days';
```

### Embedding model choice

For the `embedding` column:
- **OpenAI `text-embedding-3-small`** (1536 dimensions, $0.02/1M tokens) — best quality/cost for production
- **`all-MiniLM-L6-v2`** (384 dimensions, self-hosted, free) — adequate for MVP, significant cost savings
- **`all-mpnet-base-v2`** (768 dimensions, self-hosted, free) — better quality than MiniLM, still free

Configure embedding model in `project/.sdlc/context/product-context.md` and document the choice in the storage ADR.

---

## Option B: RuVector (Agentics Foundation Stack)

**Best choice if you are already using RuFlo.** RuVector provides self-learning vector storage with graph neural network intelligence — it gets better at routing queries as it learns from your feedback data. The SONA (Self-Optimizing Neural Architecture) engine auto-tunes routing, ranking, and compression without manual intervention.

### Integration with the Roadmap Engine

RuVector stores feedback records and opportunity briefs as embeddings with structured metadata. The analyst agent queries it semantically: "find feedback records similar to this opportunity brief" or "what feedback mentions the same problem as OPP-001?"

```bash
# Initialize RuVector for the roadmap engine
npx ruvector hooks init --pretrain --build-agents quality
```

This generates `.claude/agents/` configurations pre-trained on your feedback data patterns.

### Key capabilities for this pipeline

- **Self-learning routing:** RuVector's GNN learns which feedback records cluster together, improving theme grouping over time
- **Co-edit pattern memory:** Learns from how you link feedback records to opportunities, improving future auto-linking suggestions
- **Cross-session persistence:** The `.rvf` (RuVector Format) file persists the entire vector state across Claude Code sessions — relevant for long-running feedback analysis
- **AgentDB integration:** Analyst and scoring agents can query memory for past decisions: "what did we decide last quarter about API rate limits?"

### Limitation

RuVector is optimized for agent-to-agent communication and vector similarity search. It is not optimized for the relational queries the analyst agent needs (segment filtering, ARR band grouping, date-range trend analysis). For production use, pair RuVector with a standard relational store (even SQLite for MVP) for the structured metadata.

---

## Option C: File-Based (MVP / No Database)

**Zero infrastructure setup.** Normalized feedback records are stored as JSON files in `project/feedback/normalized/`. The analyst agent reads these files directly, performs analysis in-memory, and writes opportunity briefs as Markdown files. No database required.

### Directory structure

```
project/feedback/
├── raw/
│   ├── intercom/          # Raw API responses, JSON format
│   ├── salesforce/
│   ├── app-store/
│   ├── nps/
│   └── ...
└── normalized/
    ├── FB-000001.json     # Normalized feedback record
    ├── FB-000002.json
    ├── index.json         # Theme index: theme → [FB-NNN, FB-NNN, ...]
    └── stats.json         # Running theme frequency counts
```

### Limitations

- **No semantic search:** File-based approach relies on keyword matching and theme tags, not embedding-based similarity
- **Slow at scale:** Performance degrades significantly above ~10,000 records; 50K+ records becomes impractical
- **No SQL analytics:** Trend detection, cohort filtering, and ARR analysis require in-memory processing of all records
- **No concurrent access:** Multiple agent sessions reading/writing the same files can cause race conditions

**Recommendation:** Use file-based for the first 60-90 days while validating the pipeline concept. Migrate to PostgreSQL + pgvector once you have >5,000 feedback records.

---

## Storage ADR Template (pre-filled)

Copy this ADR to `docs/adr/ADR-STORAGE-001.md` and complete the sections marked [COMPLETE THIS]:

```markdown
---
id: ADR-STORAGE-001
title: "Feedback repository storage architecture"
status: proposed
type: standard
date: [COMPLETE THIS]
decision_makers: [COMPLETE THIS]
sprint: S-01
tags: [storage, database, vector-search, feedback-repository]
---

# ADR-STORAGE-001: Feedback Repository Storage Architecture

## Context

The BHIL Product Roadmap Engine requires a storage system that handles
two distinct access patterns: (1) structured queries filtering by customer
segment, channel, ARR band, and date range, and (2) semantic similarity
search across feedback content using vector embeddings.

## Decision drivers
- [COMPLETE THIS: your performance requirements, scale estimates, budget constraints]
- Embedding-based semantic search required for theme clustering
- SQL analytics required for RICE Reach estimation
- [Solo practitioner / small team] with [low / medium / high] operational overhead tolerance

## Candidates evaluated
1. PostgreSQL + pgvector — Single system, ACID compliant, SQL + vector search
2. RuVector — Self-learning GNN vector store, integrates with RuFlo/Claude Code stack  
3. File-based JSON — Zero infrastructure, in-memory analysis

## Decision
[COMPLETE THIS: chosen option]

## Rationale
[COMPLETE THIS: 2-3 sentences tying back to decision drivers]

## Consequences
Positive: [COMPLETE THIS]
Negative: [COMPLETE THIS]

## Review trigger
Revisit if feedback record count exceeds 500,000 OR query latency P95 exceeds 2,000ms.
```

---

*BHIL Product Roadmap Engine — [barryhurd.com](https://barryhurd.com)*
