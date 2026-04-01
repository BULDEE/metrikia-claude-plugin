# Metrikia MCP Tools Reference

Complete reference for all 17 MCP tools exposed by the Metrikia server. Each tool is a `final class` in the Symfony backend with the `#[McpTool]` attribute, auto-discovered at boot time.

**Endpoint:** `https://mcp.metrikia.io/api/v1/mcp`
**Protocol:** JSON-RPC 2.0 over HTTP
**Authentication:** `Authorization: Bearer mk_live_xxx`

---

## 1. Campaign and Performance (4 tools)

### list_campaigns

List ad campaigns across all connected ad accounts (Meta, Google, TikTok).

**Scope:** `mcp:read`
**Rate limit:** 60/min (read)

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `page` | int | No | 1 | Page number |
| `limit` | int | No | 50 | Results per page (max 200) |
| `activeOnly` | bool | No | false | If true, returns only active campaigns |

**Returns:**
```json
{
  "campaigns": [
    {
      "id": "uuid",
      "externalId": "23851234567890",
      "name": "Prospect Froid Q1",
      "status": "active",
      "platform": "meta",
      "adAccountId": "uuid",
      "createdAt": "2026-01-01T00:00:00+00:00"
    }
  ],
  "total": 24
}
```

**Return fields:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Internal UUID |
| `externalId` | string | Platform-native campaign ID |
| `name` | string | Campaign name |
| `status` | string | Campaign status (active, paused, archived) |
| `platform` | string | Ad platform: `meta`, `google`, `tiktok` |
| `adAccountId` | string | UUID of the parent ad account |
| `createdAt` | string | ISO 8601 timestamp |

**Skill usage example:**
```
Step 1: Call list_campaigns(activeOnly=true) to see all active campaigns
Step 2: For each campaign of interest, call get_campaign_performance(campaignId=...)
```

---

### get_campaign_performance

Get detailed performance metrics for a specific campaign.

**Scope:** `mcp:read`
**Rate limit:** 60/min (read)

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `campaignId` | string | Yes | -- | Campaign UUID |
| `startDate` | string | No | -30 days | Start date (YYYY-MM-DD) |
| `endDate` | string | No | today | End date (YYYY-MM-DD) |
| `adAccountId` | string | No | -- | Filter by ad account UUID |
| `dataSourceId` | string | No | -- | Filter by data source UUID |

**Returns:**
```json
{
  "campaignId": "uuid",
  "period": { "start": "2026-03-01", "end": "2026-03-31" },
  "impressions": 145230,
  "clicks": 3421,
  "spend": 2340.50,
  "revenue": 8400.00,
  "leads": 42,
  "conversions": 12,
  "cpl": 55.72,
  "cpc": 0.68,
  "ctr": 2.35,
  "roas": 3.59,
  "crmRoas": 3.12,
  "currency": "EUR",
  "appointments": 8,
  "deals": 5,
  "profit": 6059.50,
  "roiPercent": 258.9
}
```

**Return fields:**
| Field | Type | Description |
|-------|------|-------------|
| `campaignId` | string | Campaign UUID (echo of input) |
| `period` | object | `{start, end}` resolved date range |
| `impressions` | int | Total impressions |
| `clicks` | int | Total clicks |
| `spend` | float | Total spend in currency units (not cents) |
| `revenue` | float | Total CRM revenue attributed |
| `leads` | int | Leads generated |
| `conversions` | int | Conversions tracked |
| `cpl` | float | Cost per lead |
| `cpc` | float | Cost per click |
| `ctr` | float | Click-through rate (%) |
| `roas` | float | Platform-reported ROAS |
| `crmRoas` | float | CRM-based real ROAS |
| `currency` | string | ISO 4217 currency code |
| `appointments` | int | Appointments from this campaign |
| `deals` | int | Deals from this campaign |
| `profit` | float | Revenue minus spend |
| `roiPercent` | float | ROI as percentage |

**Skill usage example (campaign-audit):**
```
Call get_campaign_performance(campaignId="abc-123", startDate="2026-03-01", endDate="2026-03-31")
Compare crmRoas vs roas to identify lead quality gaps
```

---

### get_creative_report

Get creative/ad performance report ranked by a chosen metric.

**Scope:** `mcp:read`
**Rate limit:** 60/min (read)

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `sortBy` | string | No | `spend` | Sort metric: `spend`, `ctr`, `cpl`, `roas` |
| `limit` | int | No | 20 | Results (max 50) |
| `startDate` | string | No | -30 days | Start date (YYYY-MM-DD) |
| `endDate` | string | No | today | End date (YYYY-MM-DD) |
| `campaignId` | string | No | -- | Filter by campaign UUID |
| `adAccountId` | string | No | -- | Filter by ad account UUID |

**Returns:**
```json
{
  "creatives": [
    {
      "adId": "uuid",
      "adName": "Video Temoignage v2",
      "platform": "meta",
      "campaignName": "Prospect Froid Q1",
      "isActive": true,
      "impressions": 45000,
      "clicks": 1200,
      "spend": 890.50,
      "revenue": 3200.00,
      "leads": 18,
      "deals": 4,
      "appointments": 6,
      "ctr": 2.67,
      "cpc": 0.74,
      "cpl": 49.47,
      "roas": 3.59,
      "currency": "EUR"
    }
  ],
  "total": 35,
  "currency": "EUR"
}
```

**Return fields (per creative):**
| Field | Type | Description |
|-------|------|-------------|
| `adId` | string | Ad UUID |
| `adName` | string | Ad creative name |
| `platform` | string | `meta`, `google`, `tiktok` |
| `campaignName` | string | Parent campaign name |
| `isActive` | bool | Whether the ad is currently active |
| `impressions` | int | Total impressions |
| `clicks` | int | Total clicks |
| `spend` | float | Spend in currency units |
| `revenue` | float | CRM revenue attributed |
| `leads` | int | Leads generated |
| `deals` | int | Deals from this creative |
| `appointments` | int | Appointments from this creative |
| `ctr` | float | Click-through rate (%) |
| `cpc` | float | Cost per click |
| `cpl` | float | Cost per lead |
| `roas` | float | Return on ad spend |
| `currency` | string | ISO 4217 currency code |

**Skill usage example (creative-analysis):**
```
Step 1: get_creative_report(sortBy="roas", limit=50) -- find top performers
Step 2: get_creative_report(sortBy="spend", limit=50) -- find biggest spenders
Cross-reference: high spend + low ROAS = waste candidates
```

---

### compare_performance

Compare ad performance between two periods with percentage deltas.

**Scope:** `mcp:read`
**Rate limit:** 60/min (read)

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `startDate` | string | No | -30 days | Current period start (YYYY-MM-DD) |
| `endDate` | string | No | today | Current period end (YYYY-MM-DD) |
| `comparisonType` | string | No | `previous_period` | `previous_period`, `previous_month`, `previous_year` |
| `campaignId` | string | No | -- | Filter by campaign UUID |
| `adAccountId` | string | No | -- | Filter by ad account UUID |

**Returns:**
```json
{
  "period": { "start": "2026-03-01", "end": "2026-03-31" },
  "current": {
    "spend": 4500.00,
    "revenue": 14200.00,
    "impressions": 320000,
    "clicks": 8500,
    "leads": 84,
    "conversions": 28,
    "cpl": 53.57,
    "cpc": 0.53,
    "ctr": 2.66,
    "roas": 3.15,
    "crmRoas": 2.89,
    "profit": 9700.00,
    "roiPercent": 215.6,
    "currency": "EUR"
  },
  "changes": {
    "spendChange": -6.67,
    "revenueChange": 8.45,
    "impressionsChange": 12.3,
    "clicksChange": 5.1,
    "leadsChange": 9.52,
    "conversionsChange": 16.7,
    "cplChange": -14.8,
    "cpcChange": -11.2,
    "ctrChange": -6.5,
    "roasChange": 16.51,
    "crmRoasChange": 12.8,
    "profitChange": 22.3,
    "roiPercentChange": 31.0
  },
  "comparisonType": "previous_period"
}
```

All `*Change` fields are percentage changes (positive = improvement for revenue/ROAS/leads, negative = improvement for spend/CPL/CPC).

**Skill usage example (weekly-report):**
```
Call compare_performance(startDate="2026-03-25", endDate="2026-04-01", comparisonType="previous_period")
Present changes with trend arrows (positive green, negative red)
```

---

## 2. Leads and CRM (3 tools)

### list_leads

List CRM leads for the current tenant with pagination and status filtering.

**Scope:** `mcp:read`
**Rate limit:** 60/min (read)

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `limit` | int | No | 20 | Results per page (max 100) |
| `page` | int | No | 1 | Page number |
| `status` | string | No | -- | Filter by status: `new`, `contacted`, `qualified`, `disqualified`, `appointment_proposed`, `appointment_booked`, `no_show`, `deal_pending`, `closed_won`, `nurturing`, `no_response` |

**Returns:**
```json
{
  "leads": [
    {
      "id": "uuid",
      "fullName": "Jean Dupont",
      "status": "qualified",
      "source": "Meta Ads",
      "createdAt": "2026-01-15T10:30:00+00:00",
      "updatedAt": "2026-01-20T14:00:00+00:00",
      "setterId": "uuid|null",
      "closerId": "uuid|null",
      "isAnonymized": false
    }
  ],
  "total": 142,
  "page": 1,
  "limit": 20
}
```

**Return fields (per lead):**
| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Lead UUID |
| `fullName` | string | First name + last name (no email or phone) |
| `status` | string | Current lead status |
| `source` | string | Acquisition source label |
| `createdAt` | string | ISO 8601 creation timestamp |
| `updatedAt` | string | ISO 8601 last update timestamp |
| `setterId` | string or null | UUID of assigned setter |
| `closerId` | string or null | UUID of assigned closer |
| `isAnonymized` | bool | Whether lead has been GDPR-anonymized |

**Skill usage example (lead-pipeline):**
```
Step 1: list_leads(status="qualified", limit=100) -- qualified pipeline
Step 2: list_leads(status="converted", limit=50)  -- recent conversions
Compare counts for conversion rate calculation
```

---

### get_lead

Get detailed information about a specific CRM lead by ID.

**Scope:** `mcp:read`
**Rate limit:** 60/min (read)

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `id` | string | Yes | -- | Lead UUID |

**Returns (success):**
```json
{
  "id": "uuid",
  "fullName": "Jean Dupont",
  "status": "qualified",
  "source": "Meta Ads",
  "campaign": "Prospect Froid Q1",
  "campaignId": "uuid",
  "setterId": "uuid|null",
  "closerId": "uuid|null",
  "estimatedRevenue": 5000,
  "notes": "Interesse par offre premium",
  "disqualificationReason": null,
  "isAnonymized": false,
  "hasAttribution": true,
  "createdAt": "2026-01-15T10:30:00+00:00",
  "updatedAt": "2026-01-20T14:00:00+00:00"
}
```

**Returns (not found):**
```json
{
  "error": "not_found",
  "message": "Lead {id} not found in your tenant."
}
```

**Return fields:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Lead UUID |
| `fullName` | string | First name + last name |
| `status` | string | Current lead status |
| `source` | string | Acquisition source label |
| `campaign` | string or null | Name of attributed campaign |
| `campaignId` | string or null | UUID of attributed campaign |
| `setterId` | string or null | Assigned setter UUID |
| `closerId` | string or null | Assigned closer UUID |
| `estimatedRevenue` | int or null | Estimated revenue in cents |
| `notes` | string or null | Internal notes |
| `disqualificationReason` | string or null | Reason if disqualified |
| `isAnonymized` | bool | GDPR anonymization status |
| `hasAttribution` | bool | Whether attribution data exists |
| `createdAt` | string | ISO 8601 timestamp |
| `updatedAt` | string | ISO 8601 timestamp |

**Skill usage example (campaign-audit):**
```
After list_leads finds leads from a campaign:
Call get_lead(id="abc-123") for each key lead to check estimatedRevenue and attribution
```

---

### list_deals

List CRM deals in the sales pipeline.

**Scope:** `mcp:read`
**Rate limit:** 60/min (read)

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `limit` | int | No | 20 | Results per page (max 100) |
| `page` | int | No | 1 | Page number |
| `status` | string | No | -- | Filter by status: `open`, `won`, `lost` |

**Returns:**
```json
{
  "deals": [
    {
      "id": "uuid",
      "status": "won",
      "totalAmount": 5000.00,
      "currency": "EUR",
      "closerId": "uuid",
      "closedAt": "2026-03-15T16:00:00+00:00",
      "createdAt": "2026-03-10T09:00:00+00:00",
      "leadId": "uuid"
    }
  ],
  "total": 38,
  "page": 1,
  "limit": 20
}
```

**Return fields (per deal):**
| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Deal UUID |
| `status` | string | `open`, `won`, `lost` |
| `totalAmount` | float | Deal amount in currency units (converted from cents) |
| `currency` | string | ISO 4217 currency code |
| `closerId` | string | UUID of the closer |
| `closedAt` | string | ISO 8601 close timestamp |
| `createdAt` | string | ISO 8601 creation timestamp |
| `leadId` | string or null | UUID of linked lead |

**Skill usage example (attribution-deep-dive):**
```
Step 1: list_deals(status="won", limit=50) -- get recent won deals
Step 2: For each deal.leadId, call get_attribution_journey to map conversion path
```

---

## 3. Attribution and Insights (3 tools)

### get_attribution_journey

Get the full customer journey for a lead with touchpoints and multi-touch attribution credits.

**Scope:** `mcp:read`
**Rate limit:** 60/min (read)

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `leadId` | string | Yes | -- | Lead UUID |

**Returns (success):**
```json
{
  "leadId": "uuid",
  "leadName": "Jean Dupont",
  "dealId": "uuid|null",
  "conversionValue": 5000.00,
  "conversionCurrency": "EUR",
  "convertedAt": "2026-03-15T16:00:00+00:00",
  "touchpointCount": 4,
  "firstTouchAt": "2026-02-20T09:15:00+00:00",
  "lastTouchAt": "2026-03-14T14:30:00+00:00",
  "touchpoints": [
    {
      "id": "uuid",
      "channel": "meta",
      "position": 1,
      "isFirst": true,
      "isLast": false,
      "isLeadCreation": true,
      "isOpportunity": false,
      "daysBefore": 23,
      "occurredAt": "2026-02-20T09:15:00+00:00",
      "deviceType": "mobile",
      "campaignName": "Prospect Froid Q1",
      "utmSource": "facebook",
      "utmMedium": "paid",
      "utmCampaign": "prospect-froid-q1",
      "landingPageUrl": "https://example.com/offer"
    }
  ],
  "attributionByModel": {
    "linear": [{"touchpointId": "uuid", "credit": 0.25}],
    "shapley": [{"touchpointId": "uuid", "credit": 0.42}],
    "time_decay": [{"touchpointId": "uuid", "credit": 0.18}]
  }
}
```

**Returns (not found):**
```json
{
  "error": "not_found",
  "message": "Lead or journey not found."
}
```

**Return fields:**
| Field | Type | Description |
|-------|------|-------------|
| `leadId` | string | Lead UUID |
| `leadName` | string | Lead name |
| `dealId` | string or null | Linked deal UUID |
| `conversionValue` | float or null | Deal value in currency units |
| `conversionCurrency` | string or null | Currency code |
| `convertedAt` | string or null | Conversion timestamp |
| `touchpointCount` | int | Number of touchpoints |
| `firstTouchAt` | string | First touchpoint timestamp |
| `lastTouchAt` | string | Last touchpoint timestamp |
| `touchpoints` | array | Ordered list of touchpoints |
| `attributionByModel` | object | Credit distribution per attribution model |

**Touchpoint fields:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Touchpoint UUID |
| `channel` | string | Channel: `meta`, `google`, `tiktok`, `organic`, `direct` |
| `position` | int | Position in journey (1-based) |
| `isFirst` | bool | Is first touch |
| `isLast` | bool | Is last touch |
| `isLeadCreation` | bool | Is the touchpoint that created the lead |
| `isOpportunity` | bool | Is an opportunity-creating touchpoint |
| `daysBefore` | int | Days before conversion |
| `occurredAt` | string | Touchpoint timestamp |
| `deviceType` | string or null | Device: `mobile`, `desktop`, `tablet` |
| `campaignName` | string or null | Campaign name |
| `utmSource` | string or null | UTM source parameter |
| `utmMedium` | string or null | UTM medium parameter |
| `utmCampaign` | string or null | UTM campaign parameter |
| `landingPageUrl` | string or null | Landing page URL |

**Skill usage example (attribution-deep-dive):**
```
For 5-10 converted leads, call get_attribution_journey(leadId=...)
Compare shapley credits vs last-touch to find undervalued channels
```

---

### get_budget_advice

Get AI-powered budget reallocation recommendations based on multi-touch attribution.

**Scope:** `mcp:read`
**Rate limit:** 60/min (read)

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `period` | string | No | `30d` | Analysis period: `7d`, `30d`, `90d` |
| `language` | string | No | `en` | Response language: `en`, `fr` |

**Returns:**
```json
{
  "advice": "Based on multi-touch attribution analysis over the last 30 days...",
  "analysis": {
    "platformBreakdown": [...],
    "topCampaigns": [...]
  },
  "attributionInsights": {
    "undervaluedChannels": [...],
    "overvaluedChannels": [...]
  },
  "period": "30d",
  "generatedAt": "2026-04-01T10:00:00+00:00"
}
```

**Return fields:**
| Field | Type | Description |
|-------|------|-------------|
| `advice` | string | Narrative budget reallocation recommendations |
| `analysis` | object | Platform breakdown and top campaigns data |
| `attributionInsights` | object | MTA-based channel valuation insights |
| `period` | string | Analysis period used |
| `generatedAt` | string | ISO 8601 generation timestamp |

**Skill usage example (budget-optimizer):**
```
Call get_budget_advice(period="30d", language="en")
Present advice narrative, then detail the analysis and attribution insights
```

---

### get_anomalies

Get AI-detected anomalies in ad performance (spend spikes, CPL drift, CTR drops, ROAS changes).

**Scope:** `mcp:read`
**Rate limit:** 60/min (read)

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `includeAcknowledged` | bool | No | false | Include already-acknowledged anomalies |

**Returns:**
```json
{
  "anomalies": [
    {
      "id": "uuid",
      "metricType": "cpa",
      "metricLabel": "Cost Per Acquisition",
      "severity": "high",
      "detectedValue": 75.84,
      "baselineValue": 52.30,
      "deltaPercent": 45.01,
      "campaignId": "uuid",
      "detectedAt": "2026-03-31T14:00:00+00:00",
      "isActive": true
    }
  ],
  "total": 3
}
```

**Return fields (per anomaly):**
| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Anomaly record UUID |
| `metricType` | string | Metric identifier (cpa, cpl, ctr, roas, spend) |
| `metricLabel` | string | Human-readable metric name |
| `severity` | string | `low`, `medium`, `high` |
| `detectedValue` | float | Current anomalous value |
| `baselineValue` | float | Expected baseline value |
| `deltaPercent` | float | Percentage change from baseline |
| `campaignId` | string or null | Affected campaign UUID |
| `detectedAt` | string | ISO 8601 detection timestamp |
| `isActive` | bool | Whether anomaly is still active |

Anomaly detection runs hourly. The tool returns anomalies from the last 30 days.

**Skill usage example (weekly-report):**
```
Call get_anomalies() to check for active issues
Present high-severity anomalies first with recommended action
```

---

## 4. Metrics and Status (2 tools)

### get_metrics

Get aggregated KPIs: MER (Marketing Efficiency Ratio), ROAS, total spend and revenue.

**Scope:** `mcp:read`
**Rate limit:** 60/min (read)

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `startDate` | string | No | -30 days | Start date (YYYY-MM-DD) |
| `endDate` | string | No | today | End date (YYYY-MM-DD) |

**Returns:**
```json
{
  "period": { "start": "2026-03-01", "end": "2026-03-31" },
  "mer": 3.24,
  "totalRevenue": 15420.50,
  "totalRevenueCurrency": "EUR",
  "totalSpend": 4758.30,
  "totalSpendCurrency": "EUR",
  "previousMer": 2.89,
  "merTrend": 12.11,
  "roas": {
    "realRoas": 3.24,
    "platformRoas": 4.1
  }
}
```

**Return fields:**
| Field | Type | Description |
|-------|------|-------------|
| `period` | object | `{start, end}` resolved date range |
| `mer` | float | Marketing Efficiency Ratio (revenue / spend) |
| `totalRevenue` | float | Total CRM revenue in currency units |
| `totalRevenueCurrency` | string | Revenue currency code |
| `totalSpend` | float | Total ad spend in currency units |
| `totalSpendCurrency` | string | Spend currency code |
| `previousMer` | float or null | MER from previous equivalent period |
| `merTrend` | float or null | MER trend as percentage change |
| `roas` | object | `{realRoas, platformRoas}` -- CRM-based vs platform-reported |

**Skill usage example (weekly-report):**
```
Call get_metrics(startDate="2026-03-25", endDate="2026-04-01")
Compare mer vs previousMer to identify weekly trend
Highlight gap between realRoas and platformRoas (if >20%, flag it)
```

---

### get_sync_status

Get sync status of all active data sources (Meta, Google, TikTok, CRM).

**Scope:** `mcp:read`
**Rate limit:** 60/min (read)

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| (none) | -- | -- | -- | No parameters required |

**Returns:**
```json
{
  "dataSources": [
    {
      "id": "uuid",
      "name": "Meta Ads - Mon Compte",
      "type": "meta",
      "lastSyncAt": "2026-03-31T14:30:00+00:00",
      "lastHierarchySyncAt": "2026-03-31T03:00:00+00:00"
    }
  ]
}
```

**Return fields (per data source):**
| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Data source UUID |
| `name` | string | User-defined data source name |
| `type` | string | Platform type: `meta`, `google`, `tiktok` |
| `lastSyncAt` | string or null | Last performance data sync timestamp |
| `lastHierarchySyncAt` | string or null | Last campaign hierarchy sync timestamp |

**Skill usage example:**
```
Call get_sync_status() before any analysis
If lastSyncAt is >4 hours old, warn the user and suggest trigger_sync
```

---

## 5. Diana AI (1 tool)

### ask_diana

Ask Diana, Metrikia's AI assistant, strategic questions about your data. Diana has access to the tenant's vectorized knowledge base, performance history, and business objectives.

**Scope:** `mcp:read`
**Rate limit:** 10/5min (diana)
**Circuit breaker:** 5 failures -> open (30s) -> half-open (1 probe)

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `question` | string | Yes | -- | Question in natural language |

**Returns:**
```json
{
  "answer": "Your CPA has increased 23% this week. I recommend...",
  "conversationId": "uuid"
}
```

**Return fields:**
| Field | Type | Description |
|-------|------|-------------|
| `answer` | string | Diana's response |
| `conversationId` | string or null | Conversation UUID (for context continuity) |

**When circuit breaker is open:**
```json
{
  "answer": "Diana is temporarily unavailable. Please try again in a moment.",
  "conversationId": null
}
```

**Notes:**
- Diana calls Claude Haiku internally (AI-calling-AI). The circuit breaker prevents runaway loops.
- The `source: "mcp"` tag is added to the DTO so Diana can adapt her responses for AI client context.
- Use Diana for strategic questions that require business context. For raw data, use the other tools directly.

**Skill usage example (weekly-report):**
```
After gathering all data with other tools:
Call ask_diana("Based on this week's performance data, what are the top 3 actions I should take next week?")
Present Diana's response in the Strategic Recommendations section
```

---

## 6. Write Operations (4 tools)

All write tools require the `mcp:write` scope in addition to `mcp:read`.

### create_lead

Create a new CRM lead. Email is never accepted via MCP (PII invariant).

**Scope:** `mcp:write`
**Rate limit:** 30/min (write)

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `firstName` | string | Yes | -- | First name |
| `lastName` | string | Yes | -- | Last name |
| `phone` | string | No | -- | Phone number in E.164 format (e.g., +33612345678) |
| `source` | string | No | -- | Source config ID or label: `ads`, `website`, `referral`, `manual` |
| `notes` | string | No | -- | Internal notes |

**Returns:**
```json
{
  "id": "uuid",
  "status": "new",
  "fullName": "Jean Dupont"
}
```

**Return fields:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Created lead UUID |
| `status` | string | Initial lead status (typically `new`) |
| `fullName` | string | Full name of created lead |

---

### transition_lead

Change a lead's status by applying a workflow transition.

**Scope:** `mcp:write`
**Rate limit:** 30/min (write)

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `leadId` | string | Yes | -- | Lead UUID |
| `transition` | string | Yes | -- | Transition name (see below) |

**Available transitions:**
`contact`, `mark_no_response`, `resume_contact`, `propose_appointment`, `book_appointment`, `show_up`, `mark_no_show`, `reschedule`, `start_nurturing`, `resume_deal`, `close_won`, `express_win`, `direct_close`, `cross_sell`, `disqualify`

**Returns (success):**
```json
{
  "success": true,
  "fromStatus": "qualified",
  "toStatus": "contacted",
  "error": null,
  "blockers": []
}
```

**Returns (failure -- lead not found):**
```json
{
  "success": false,
  "fromStatus": null,
  "toStatus": null,
  "error": "Lead {leadId} not found in your tenant.",
  "blockers": []
}
```

**Returns (failure -- invalid transition):**
```json
{
  "success": false,
  "fromStatus": "new",
  "toStatus": null,
  "error": "Unknown transition 'invalid'.",
  "blockers": []
}
```

**Returns (failure -- blocked transition):**
```json
{
  "success": false,
  "fromStatus": "new",
  "toStatus": null,
  "error": "Transition blocked",
  "blockers": ["Reason the transition is blocked"]
}
```

**Return fields:**
| Field | Type | Description |
|-------|------|-------------|
| `success` | bool | Whether the transition was applied |
| `fromStatus` | string or null | Previous status |
| `toStatus` | string or null | New status (if successful) |
| `error` | string or null | Error message (if failed) |
| `blockers` | array | List of reasons the transition was blocked |

---

### create_deal

Create a CRM deal linked to a lead. Amount is in cents.

**Scope:** `mcp:write`
**Rate limit:** 30/min (write)

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `leadId` | string | Yes | -- | Lead UUID |
| `amount` | int | Yes | -- | Amount in cents (e.g., 500000 = 5000.00 EUR) |
| `currency` | string | No | `EUR` | ISO 4217 currency code |
| `notes` | string | No | -- | Deal notes |

**Returns:**
```json
{
  "id": "uuid",
  "status": "open",
  "totalAmount": 5000.00,
  "currency": "EUR"
}
```

**Return fields:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Created deal UUID |
| `status` | string | Initial deal status (typically `open`) |
| `totalAmount` | float | Deal amount in currency units (converted from cents) |
| `currency` | string | ISO 4217 currency code |

---

### trigger_sync

Trigger an asynchronous data source sync. Dispatches a message to the sync worker queue.

**Scope:** `mcp:write`
**Rate limit:** 5/hour (sync)

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `dataSourceId` | string | No | -- | Data source UUID. If omitted, syncs all sources. |

**Returns (single source):**
```json
{
  "dispatched": true,
  "message": "Sync queued for data source {id}.",
  "dataSourceId": "uuid"
}
```

**Returns (all sources):**
```json
{
  "dispatched": true,
  "message": "Sync queued for all data sources.",
  "dataSourceId": null
}
```

**Returns (error -- invalid ID):**
```json
{
  "dispatched": false,
  "message": "Invalid data source ID '{id}'.",
  "dataSourceId": "invalid-id"
}
```

**Returns (error -- not found):**
```json
{
  "dispatched": false,
  "message": "Data source {id} not found in your tenant.",
  "dataSourceId": "uuid"
}
```

**Return fields:**
| Field | Type | Description |
|-------|------|-------------|
| `dispatched` | bool | Whether the sync command was dispatched |
| `message` | string | Human-readable status message |
| `dataSourceId` | string or null | Data source UUID (null if all sources) |

**Notes:**
- Sync is asynchronous. The tool returns immediately after dispatching the command to RabbitMQ.
- Use `get_sync_status` after 1-2 minutes to verify the sync completed.
- Syncing all sources at once counts as a single rate limit hit.

---

## Rate Limit Summary

| Category | Tools | Limit | Window |
|----------|-------|-------|--------|
| Read | list_campaigns, get_campaign_performance, get_creative_report, compare_performance, list_leads, get_lead, list_deals, get_attribution_journey, get_budget_advice, get_anomalies, get_metrics, get_sync_status | 60 requests | 1 minute |
| Diana | ask_diana | 10 requests | 5 minutes |
| Write | create_lead, transition_lead, create_deal | 30 requests | 1 minute |
| Sync | trigger_sync | 5 requests | 1 hour |

When a rate limit is exceeded, the server returns HTTP 429 with a `Retry-After` header. Most AI clients automatically respect this header and retry after the specified delay.
