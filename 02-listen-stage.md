# Guide 02: The Listen Stage

**Configuring all seven feedback channels for continuous ingestion**

---

## Overview

The Listen stage runs seven channel-specific ingestion agents in parallel, each on its own cadence, all producing normalized feedback records in the same canonical schema. The key architectural principle: **channels are configured, not hard-coded**. Each channel lives as a YAML configuration file in `integrations/channels/`, and the ingestion agent reads that config to know what to do.

This means adding a new channel means creating a new YAML config and activating it — no code changes required.

---

## The normalized feedback schema

Every record from every channel normalizes to this structure (see `schemas/normalized-feedback.schema.json` for the full JSON Schema):

```json
{
  "id": "FB-000001",
  "channel_id": "CHANNEL-001",
  "channel_type": "intercom",
  "source_id": "conversation_abc123",
  "source_url": "https://app.intercom.com/conversations/abc123",
  "timestamp": "2026-03-15T14:23:00Z",
  "content": "The raw customer text — verbatim, not summarized",
  "author": {
    "id": "customer_xyz",
    "type": "customer",
    "anonymized": false
  },
  "customer_metadata": {
    "segment": "enterprise",
    "plan": "pro",
    "arr_band": "50k-100k",
    "tenure_months": 14,
    "company_id": "acme-corp"
  },
  "enrichment": {
    "sentiment": "negative",
    "sentiment_score": -0.72,
    "themes": ["bulk-export", "data-portability"],
    "entities": {
      "features": ["CSV export", "bulk download"],
      "integrations": [],
      "competitors": [],
      "user_types": ["data analyst", "admin"]
    },
    "urgency_level": "high",
    "urgency_signals": ["can't use", "blocking us"],
    "ai_confidence": 0.87
  },
  "status": "processed",
  "linked_opportunities": ["OPP-001"]
}
```

The `enrichment` block is populated by the Tagging Agent after ingestion. The `linked_opportunities` array is populated when an OPP-NNN is created that references this record.

---

## Channel 1: Intercom (Support Chat)

**Signal type:** Pain points, bug reports, feature requests, satisfaction signals
**Cadence:** Near-real-time via webhooks; daily bulk sync as fallback
**API:** Intercom REST API v2 — `api.intercom.io`
**Rate limit:** 10,000 calls/minute (private apps)

**Authentication:**
- Generate an API key in Intercom Settings → Integrations → Developer Hub
- Create a Private App with scopes: `conversations:read`, `contacts:read`, `tags:read`, `events:read`
- Store key as `INTERCOM_API_KEY` environment variable — never in version control

**Webhook setup:**
```
Endpoint: POST /webhooks/intercom
Events to subscribe:
  - conversation.user.replied
  - conversation.admin.closed
  - conversation.user.created
Header: X-Hub-Signature (HMAC-SHA256 signed with your webhook secret)
```

**Key extraction logic:**
- Extract only parts where `author.type = "user"` — skip admin/bot responses
- Include `conversation_tags` as pre-existing labels
- Join `contacts` endpoint to enrich with customer plan, ARR, tenure
- For bulk historical backfill: use the Data Export API (`/export/content/data`)

**Configuration file:** `integrations/channels/CHANNEL-001-intercom.yaml`
**Reference example:** `examples/channels/CHANNEL-001-intercom.yaml`

---

## Channel 2: Salesforce (CRM / Call Notes)

**Signal type:** Sales blockers, competitive mentions, enterprise feature requests, deal-loss reasons
**Cadence:** Daily batch via SOQL query; near-real-time via Change Data Capture (CDC)
**API:** Salesforce REST API + Streaming API
**Rate limit:** ~100,000 API calls per 24-hour period

**Authentication:**
- Use OAuth 2.0 with Connected App (JWT Bearer Flow for server-to-server)
- Required scopes: `api`, `refresh_token`, `offline_access`
- Store credentials as `SF_CLIENT_ID`, `SF_CLIENT_SECRET`, `SF_PRIVATE_KEY`

**SOQL query for feedback extraction:**
```sql
SELECT Id, Subject, Description, AccountId, Account.AnnualRevenue,
       CreatedDate, Status, Priority, Type
FROM Case
WHERE Type IN ('Feature Request', 'Enhancement', 'Feedback')
  AND CreatedDate >= LAST_N_DAYS:90
ORDER BY CreatedDate DESC
```

**Also query:**
- `Task` (call notes, meeting summaries via Activity History)
- `Opportunity.Description` + `Opportunity.CloseDate` + `Opportunity.StageName = 'Closed Lost'`
- `ContentNote` linked to Account records

**Change Data Capture (CDC) for real-time:**
```
Channel: /data/CaseChangeEvent
Filter: Type__c IN ('Feature_Request', 'Feedback')
```

**Important:** Salesforce does not expose call recordings via standard REST API. Einstein Call Coaching (Service Cloud) is required for transcript access. If not available, use call note fields in Task records.

---

## Channel 3: HubSpot (CRM / Call Transcripts)

**Signal type:** Sales call feedback, deal notes, feature requests from prospects
**Cadence:** Daily batch; webhooks for new engagement activities
**API:** HubSpot CRM API v3
**Rate limit:** 150 requests per 10 seconds

**Authentication:**
- Private App with required scopes: `crm.objects.calls.read`, `crm.objects.contacts.read`, `crm.objects.deals.read`, `sales-email-read`
- Store key as `HUBSPOT_API_KEY`

**Key endpoints:**
```
GET /crm/v3/objects/calls
  Query: ?associations=contacts,deals&properties=hs_call_body,hs_call_recording_url,
         hs_call_duration,hs_call_disposition,hs_call_title
         
GET /crm/v3/objects/notes
  Query: ?associations=contacts,companies&properties=hs_note_body

GET /crm/v3/objects/feedback_submissions (requires Service Hub)
```

**Call transcripts:** Available only with Sales Hub Professional or Service Hub via Conversation Intelligence. The `hs_call_body` field contains a plain-text transcript or summary. The `hs_call_recording_url` field contains a signed URL valid for 1 hour.

**Deal-loss feedback extraction:**
```
GET /crm/v3/objects/deals?filters=[{"propertyName":"dealstage","operator":"EQ","value":"closedlost"}]
Include: hs_closed_lost_reason, notes_last_contacted, hs_deal_stage_probability
```

---

## Channel 4: App Store, G2, and Capterra (Reviews)

**Signal type:** Public product satisfaction, comparative feature gaps, onboarding friction
**Cadence:** Daily batch (all three)
**Authentication:** Varies per platform

### Apple App Store Connect API
- JWT authentication using a .p8 private key from App Store Connect → Users & Access → Keys
- Environment variables: `ASC_ISSUER_ID`, `ASC_KEY_ID`, `ASC_PRIVATE_KEY`
- Endpoint: `GET /v1/apps/{id}/customerReviews?sort=-createdDate&limit=200`
- No webhook support — polling required
- Returns: `rating` (1-5), `title`, `body`, `territory`, `createdDate`

### Google Play Developer API
- OAuth 2.0 service account (JSON key file)
- Scope: `https://www.googleapis.com/auth/androidpublisher`
- Endpoint: `GET /androidpublisher/v3/applications/{packageName}/reviews`
- Generous rate: ~200 requests/second
- Returns: `rating`, `originalText`, `replyText` (from developer), `reviewCreationTime`

### G2 Data API
- API key authentication (contact G2 for access)
- Base URL: `https://data.g2.com/api/v1`
- Endpoint: `GET /survey_responses` — full structured review data
- Supports RESThooks webhooks for new reviews
- Returns: structured fields including `what_do_you_like_best`, `what_do_you_dislike`, `what_problems_solving`

### Capterra
- **No official API** — requires web scraping via a third-party tool (Apify, Bright Data)
- Scrape structure: `<div data-testid="review">` contains rating, title, pros, cons, use-case
- Use proxy rotation to avoid rate-limiting blocks
- Flag in config: `requires_scraping: true`, `reliability: medium`

**Normalization note:** Review star ratings map to sentiment as a prior — use LLM analysis of text for true sentiment, not just the star rating. Research shows systematic discrepancy between rating and text sentiment.

---

## Channel 5: NPS Surveys (Delighted, Typeform, SurveyMonkey)

**Signal type:** Quantified satisfaction, churn risk signals, verbatim improvement suggestions
**Cadence:** Event-driven (webhooks) + weekly batch sweep

### Delighted
- Basic Auth: `DELIGHTED_API_KEY`
- Endpoint: `GET /v1/survey_responses.json?per_page=100`
- Webhook: HMAC-SHA256 signed, event types: `survey_response.created`
- NPS mapping: `score 0-6 = detractor`, `7-8 = passive`, `9-10 = promoter`
- Additional fields: `person_properties` (custom metadata you send at survey time — e.g., plan, ARR)

### Typeform
- OAuth 2.0: `TYPEFORM_ACCESS_TOKEN`
- Rate limit: 2 requests/second per token
- Endpoint: `GET /forms/{formId}/responses?page_size=200`
- Webhook: per-form webhook configuration → Events → `form_response`
- Requires joining responses with form definition to decode `answer_id` → `answer_text`

### SurveyMonkey
- OAuth 2.0: `SURVEYMONKEY_ACCESS_TOKEN`
- Rate limit: 120 requests/minute
- Endpoint: `GET /surveys/{survey_id}/responses/bulk?per_page=100`
- Join with `GET /surveys/{survey_id}/details` to map `choice_id` → `choice_text`

**Critical NPS context:** A verbatim comment from a detractor with 18-month tenure and $80K ARR weighs more heavily than the same comment from a 1-week free trial user. The `customer_metadata` block on the normalized record should carry plan, tenure, and ARR from the NPS distribution system metadata.

---

## Channel 6: Reddit and Community Forums

**Signal type:** Organic product sentiment, power user pain points, competitive comparisons, unsolicited feedback
**Cadence:** Near-real-time streaming + hourly polling fallback
**Authentication:** OAuth 2.0 (registered Reddit app)
**Rate limit:** 60-100 requests/minute; $0.24/1,000 calls for commercial use post-2023

**Reddit setup:**
1. Register at `reddit.com/prefs/apps` → create a "script" type app
2. Store: `REDDIT_CLIENT_ID`, `REDDIT_CLIENT_SECRET`, `REDDIT_USER_AGENT`
3. User-Agent format: `ProductRoadmapEngine/1.0 by /u/your-username`

**Subreddit streaming (PRAW):**
```python
import praw
reddit = praw.Reddit(client_id=..., client_secret=..., user_agent=...)
for submission in reddit.subreddit('your_product_subreddit').stream.submissions():
    process_submission(submission)
for comment in reddit.subreddit('your_product_subreddit').stream.comments():
    process_comment(comment)
```

**Search for mentions across Reddit:**
```
GET /search.json?q="{product_name}"&sort=new&type=link,comment&limit=100
```

**Discourse forums (if applicable):**
- Admin-generated API key with read permissions
- `GET /posts.json?before={post_id}` for pagination
- `GET /t/{topic_id}.json` for full thread with all replies
- Default rate limit: 200 requests/IP/minute (configurable)
- Webhook support via admin panel

---

## Channel 7: Slack (Internal)

**Signal type:** Support escalations, internal feature requests, product team discussions, customer quote captures
**Cadence:** Near-real-time via Events API (streaming) + daily batch for high-volume workspaces
**API:** Slack Web API + Events API
**Rate limit:** 50 requests/minute (Tier 3 methods); 30,000 events/workspace/hour

**Authentication:**
- Create a Slack app at `api.slack.com/apps`
- OAuth scopes: `channels:history`, `channels:read`, `groups:history`, `users:read`, `reactions:read`
- Bot Token: `SLACK_BOT_TOKEN`
- For Events API: `SLACK_SIGNING_SECRET` for request verification

**Which channels to monitor:**
Configure specific channel IDs — never monitor all channels. Recommended targets:
- `#product-feedback` — direct customer feedback shared internally
- `#support-escalations` — high-priority customer issues
- `#customer-requests` — feature requests logged by CS/sales
- `#churned-customers` — post-churn call notes

**Emoji reaction signals:**
Track reactions on messages in monitored channels as lightweight metadata:
```
🐛 = bug report signal
💡 = feature request signal  
⭐ = positive feedback signal
🚨 = urgent / escalation signal
+1 / 👍 = agreement / upvote
```
Count unique reactor IDs for each reaction type — this is a low-cost "vote" signal.

**Events API subscription:**
```json
{
  "event_subscriptions": {
    "bot_events": ["message.channels", "message.groups", "reaction_added"]
  }
}
```

---

## Channel 8: LinkedIn and Social Listening

**Signal type:** Brand perception, executive-visible feedback, competitor mentions, industry trends
**Cadence:** Daily batch via third-party social listening tool
**API access:** LinkedIn API is restricted to owned Company Page data only — no cross-network search

**LinkedIn API (owned content only):**
- Organization API: `GET /v2/organizations/{id}/comments` — comments on your posts
- UGC Posts API: `GET /v2/ugcPosts?q=authors&authors=urn:li:organization:{id}` — your posts + engagement
- Requires LinkedIn Marketing Developer Program access (separate application)

**For broader social listening (mentions across LinkedIn):**

| Tool | Coverage | API Access | Price/mo |
|---|---|---|---|
| Brand24 | 25M+ sources incl. LinkedIn | REST API ($99 add-on) | $149-399 |
| Mention | 1B+ sources | Full REST API | $49-99 |
| Sprout Social | Cross-platform + LinkedIn Listening | Full API | $249+ |

**Configuration approach:**
Configure a social listening tool webhook or scheduled export to write normalized mention data to `project/feedback/raw/linkedin/`. The ingestion agent reads from this directory.

**Important limitation:** LinkedIn social listening is the least reliable channel due to API restrictions. Mark `reliability: low` in the channel config and weight accordingly in opportunity briefs.

---

## Channel cadence summary

| Channel | Trigger | Cadence | Reliability |
|---|---|---|---|
| Intercom | Webhook + daily sweep | Near-real-time | High |
| Salesforce | CDC + daily SOQL | Daily | High |
| HubSpot | Webhook + daily sweep | Daily | High |
| App Store / G2 | Daily batch | Daily | High |
| Capterra | Daily scrape | Daily | Medium |
| NPS (Delighted) | Webhook | Event-driven | High |
| Reddit | Streaming + hourly poll | Near-real-time | Medium |
| Slack | Events API | Near-real-time | High |
| LinkedIn | Third-party tool daily | Daily | Low |

---

*Next: Read `guides/03-synthesize-stage.md` to understand how raw feedback becomes structured Opportunity Briefs.*

*BHIL Product Roadmap Engine — [barryhurd.com](https://barryhurd.com)*
