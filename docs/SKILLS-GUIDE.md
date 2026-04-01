# Metrikia Plugin -- Skills Guide

Detailed usage guide for all 6 Metrikia skills. Each skill is a structured orchestration recipe that guides Claude through a sequence of MCP tool calls to produce actionable analysis.

---

## /metrikia:weekly-report

**Purpose:** Generate a comprehensive weekly ad performance report.

### When to Use

- User asks for a weekly performance summary or regular reporting
- User says "how did we do this week" or "weekly report"
- User wants to understand overall trends before diving into specifics

### What Data It Fetches

| Step | Tool Call | Purpose |
|------|-----------|---------|
| 1 | `get_metrics(startDate=-7d)` | Current week's KPIs: MER, ROAS, spend, revenue |
| 2 | `compare_performance(comparisonType="previous_period")` | Week-over-week trend deltas |
| 3 | `get_creative_report(sortBy="roas", limit=5)` | Top 5 creatives by ROAS |
| 4 | `get_creative_report(sortBy="spend", limit=10)` | Top 10 creatives by spend |
| 5 | `get_anomalies()` | Active anomalies to flag |
| 6 | `get_budget_advice(period="7d")` | MTA-based budget recommendations |
| 7 | `ask_diana("Based on this week's performance...")` | Strategic top 3 actions |

### How to Interpret the Output

The report is structured in five sections:

1. **Performance Summary** -- Total spend, revenue, profit, MER, ROAS, and CRM ROAS with week-over-week changes. A positive MER trend means your marketing is getting more efficient. A gap between `roas` (platform-reported) and `crmRoas` (actual CRM revenue) indicates lead quality issues.

2. **Top 5 Creatives by ROAS** -- These are your most efficient ads. If a creative has high ROAS but low total spend, it may have room to scale. If ROAS is declining week-over-week, watch for fatigue.

3. **Anomalies Detected** -- High-severity anomalies require immediate action. A spend spike with no revenue change often indicates a tracking issue rather than a performance issue. Check `get_sync_status` first.

4. **Budget Recommendations** -- Diana's MTA-enriched reallocation suggestions. These account for multi-touch attribution, not just last-click. Undervalued channels (high assist credit, low budget) are the biggest optimization opportunities.

5. **Strategic Recommendations** -- Diana's top 3 actions for the coming week. These factor in the tenant's business context, historical patterns, and current performance trajectory.

### Real-World Example Scenario

A media buyer runs `/metrikia:weekly-report` on Monday morning.

**Sample output structure:**

```
Performance Summary (Mar 25 - Apr 1)
  Spend:     4,200 EUR (-8.7% vs prev week)
  Revenue:  13,400 EUR (+5.2%)
  Profit:    9,200 EUR (+12.1%)
  MER:       3.19 (+15.2%)
  ROAS:      3.19 (platform: 4.1)

Top 5 Creatives by ROAS
  1. Video Temoignage v2 (Meta) -- ROAS 5.8x, Spend 320 EUR
  2. UGC Story 3 (TikTok)      -- ROAS 4.2x, Spend 180 EUR
  ...

Anomalies
  [HIGH] CPA on "Retargeting General" spiked +45% (52 -> 76 EUR)
  Action: Check audience overlap, may need fresh exclusions

Budget Recommendations
  Move 150 EUR/week from Retargeting General to Prospect Froid Q1
  Expected: +8 leads/week based on Shapley attribution credits

Diana's Top 3 Actions
  1. Scale Video Temoignage v2 by 30% -- room to grow at current ROAS
  2. Pause Retargeting General until CPA anomaly resolved
  3. Test new Google Search campaign -- organic search data shows demand
```

### Common Follow-Up Actions

- `/metrikia:campaign-audit` on any campaign flagged in anomalies
- `/metrikia:creative-analysis` if multiple creatives are declining
- `/metrikia:budget-optimizer` for detailed reallocation plan

### Tips

- Run this every Monday for consistent week-over-week tracking.
- If MER trend is negative for 3+ consecutive weeks, escalate to `/metrikia:attribution-deep-dive` to understand structural changes.
- The gap between platform ROAS and CRM ROAS is one of the most valuable signals. A large gap (>30%) means the platforms are over-reporting conversions.

---

## /metrikia:campaign-audit

**Purpose:** Deep audit of a specific campaign with creative breakdown and attribution insights.

### When to Use

- User wants to deep-dive into a specific campaign
- A campaign was flagged in the weekly report as underperforming or anomalous
- User asks "why is campaign X not performing" or "audit campaign X"

### What Data It Fetches

| Step | Tool Call | Purpose |
|------|-----------|---------|
| 0 | `list_campaigns()` | (If needed) Show available campaigns for user to select |
| 1 | `get_campaign_performance(campaignId, startDate=-30d)` | 30-day campaign metrics |
| 2 | `compare_performance(campaignId, comparisonType="previous_period")` | Trend analysis |
| 3 | `get_creative_report(campaignId=...)` | All creatives in this campaign |
| 4 | `list_leads(status filters)` | Leads attributed to this campaign |
| 5 | `get_attribution_journey(leadId=...)` | Full journey for key leads |
| 6 | `ask_diana("Audit campaign [name]...")` | Diana's optimization recommendations |

### How to Interpret the Output

1. **Campaign Overview** -- If CRM ROAS diverges significantly from platform ROAS, the issue is lead quality, not ad performance. High CTR + low conversions points to a landing page problem.

2. **Creative Performance Matrix** -- Creatives ranked by efficiency. A single creative consuming >60% of campaign spend is a concentration risk. Declining CTR over time signals fatigue.

3. **Attribution Insights** -- Shows how leads from this campaign actually convert. If most conversions require 3+ touchpoints, the campaign may be a strong "introducer" but gets unfairly penalized by last-click attribution.

4. **Optimization Recommendations** -- Specific actions: scale winning creatives, pause losers, test new angles based on journey patterns.

### Real-World Example Scenario

A campaign "Prospect Froid Q1" was flagged with declining ROAS in the weekly report.

**Sample output structure:**

```
Campaign: Prospect Froid Q1 (Meta)
Period: Mar 1 - Mar 31

Metrics
  Spend: 2,340 EUR | Revenue: 8,400 EUR | ROAS: 3.59
  CRM ROAS: 3.12 | CPL: 55.72 EUR | CTR: 2.35%
  Trend: ROAS -12% vs previous period

Creative Breakdown
  Video Temoignage v2: ROAS 5.8x, 38% of spend -- SCALE
  Carousel Product:    ROAS 2.1x, 25% of spend -- MAINTAIN
  Static Banner v1:    ROAS 0.9x, 22% of spend -- KILL (losing money)
  UGC Story:           ROAS 3.2x, 15% of spend -- SCALE

Attribution
  Average journey: 3.2 touchpoints, 12 days to conversion
  This campaign is #1 first-touch but #3 last-touch
  Shapley credit: 42% (vs 28% last-touch credit)

Recommendations
  1. Kill Static Banner v1 -- saving 515 EUR/month
  2. Scale Video Temoignage v2 by 20% -- ROAS headroom exists
  3. The campaign is undervalued by last-click. Real contribution is 50% higher.
```

### Common Follow-Up Actions

- `/metrikia:creative-analysis` to dive deeper into creative performance patterns
- `/metrikia:attribution-deep-dive` if the campaign's attribution story is complex
- `transition_lead` or `create_deal` for leads identified during the audit

### Tips

- Always compare CRM ROAS to platform ROAS. The delta tells you about lead quality.
- A campaign can look bad on last-click but be essential as a first-touch introducer. Check Shapley credits before cutting budget.
- If CTR is healthy but conversions are low, the problem is downstream (landing page, offer, sales process) -- not the campaign itself.

---

## /metrikia:lead-pipeline

**Purpose:** Analyze CRM pipeline health, conversion rates, and source attribution.

### When to Use

- User asks about CRM pipeline health, lead quality, or conversion rates
- User says "how is our pipeline" or "what's happening with leads"
- User wants to understand which sources produce the best leads

### What Data It Fetches

| Step | Tool Call | Purpose |
|------|-----------|---------|
| 1 | `list_leads(status="qualified")` | Qualified leads in pipeline |
| 2 | `list_leads(status="contacted")` | Contacted leads |
| 3 | `list_leads(status="converted")` | Recent conversions |
| 4 | `list_deals(status="open")` | Open deals |
| 5 | `list_deals(status="won")` | Won deals |
| 6 | `get_attribution_journey(leadId=...)` | Journeys for converted leads |
| 7 | `get_metrics()` | Period metrics for spend/revenue correlation |
| 8 | `ask_diana("Analyze my lead pipeline...")` | Pipeline insights |

### How to Interpret the Output

1. **Pipeline Health** -- Total leads by status, forming a funnel. Look for bottlenecks: if 80% of leads are "contacted" but few are "qualified," the qualification criteria may be too strict or the sales process too slow.

2. **Source Performance** -- Which acquisition sources produce leads that actually convert and generate revenue. A source with many leads but low conversion rate is wasting budget.

3. **Top Conversion Journeys** -- Example attribution journeys for converted leads. Common patterns reveal which channel combinations work best.

4. **Recommendations** -- Where to invest more (high-converting sources), where to cut (high-volume but low-quality sources), and bottleneck fixes.

### Real-World Example Scenario

A growth analyst runs `/metrikia:lead-pipeline` to assess Q1 performance.

**Sample output structure:**

```
Pipeline Funnel (Last 30 Days)
  New:           42
  Contacted:     35 (83% contact rate)
  Qualified:     28 (80% qualification rate)
  Converted:     12 (43% conversion rate)
  Average deal:  4,200 EUR

Source Performance
  Source        | Leads | Qualified | Converted | Conv Rate | Avg Deal
  Meta Ads      |    24 |        16 |         8 |     33%   | 3,800 EUR
  Google Search |    10 |         8 |         3 |     30%   | 6,200 EUR
  Referral      |     5 |         4 |         1 |     20%   | 5,000 EUR
  Direct        |     3 |         0 |         0 |      0%   |     - EUR

Top Conversion Journeys
  Lead A: Meta Ad (day -18) -> Google Search (day -5) -> Direct (day 0)
  Lead B: TikTok (day -12) -> Meta Retargeting (day -3) -> Conversion
  Pattern: Multi-touch with 2-3 touchpoints, 10-18 day cycle

Recommendations
  1. Google Search leads have highest deal value -- increase budget
  2. Direct leads never qualify -- investigate source (may be bot traffic)
  3. Sales bottleneck: 35 contacted but only 28 qualified in 30 days
```

### Common Follow-Up Actions

- `/metrikia:campaign-audit` on the source with best conversion rate
- `/metrikia:attribution-deep-dive` to understand cross-channel effects
- `create_deal` for leads ready to close

### Tips

- Conversion rate is more important than lead volume. 10 leads at 50% conversion beats 100 leads at 5%.
- Look at the time leads spend in each status. Long "contacted" times indicate sales capacity issues, not marketing issues.
- Cross-reference source performance with `get_metrics` spend data to calculate true cost-per-qualified-lead by source.

---

## /metrikia:budget-optimizer

**Purpose:** Optimize budget allocation across platforms and campaigns using MTA attribution data.

### When to Use

- User wants to reallocate budget or optimize spend
- User asks "where should I spend more" or "how do I optimize budget"
- After a weekly report reveals inefficiencies

### What Data It Fetches

| Step | Tool Call | Purpose |
|------|-----------|---------|
| 1 | `get_metrics()` | Current period spend and revenue |
| 2 | `get_campaign_performance()` | Top 10 campaigns by spend |
| 3 | `get_budget_advice(period="30d")` | MTA-enriched reallocation recommendations |
| 4 | `get_anomalies()` | Spend anomalies to address first |
| 5 | `ask_diana("If I shift 20% of budget...")` | What-if scenario analysis |

### How to Interpret the Output

1. **Current Budget Allocation** -- Platform breakdown showing where money goes today. If one platform gets 80% of budget but produces 40% of MTA-attributed conversions, there is a reallocation opportunity.

2. **MTA-Based Recommendations** -- Unlike last-click recommendations, these account for the full customer journey. A channel that rarely gets the last click but frequently introduces customers (first touch) will be recommended for more budget.

3. **Risk Assessment** -- Anomalies or tracking issues that should be resolved before making budget changes. Never reallocate budget based on incomplete data.

4. **Action Plan** -- Step-by-step instructions with specific amounts. Conservative approach: move 10-15% of budget at a time, not 30%+.

### Real-World Example Scenario

A media buyer runs `/metrikia:budget-optimizer` after noticing inefficient spend distribution.

**Sample output structure:**

```
Current Allocation (Monthly)
  Platform   | Spend    | Revenue  | ROAS | MTA Credit | % Budget
  Meta       | 2,800 EUR| 8,400 EUR| 3.0x |    45%     |   62%
  Google     | 1,200 EUR| 5,200 EUR| 4.3x |    35%     |   27%
  TikTok     |   500 EUR| 1,800 EUR| 3.6x |    20%     |   11%

MTA-Based Recommendations
  - Move 300 EUR/month from Meta to Google
    Reason: Google's MTA credit (35%) exceeds its budget share (27%)
    Expected: +12% revenue from Google at similar ROAS
  - Increase TikTok by 200 EUR/month
    Reason: TikTok introduces 20% of journeys but gets only 11% of budget
    Expected: +6 new leads/month as first-touch introducer

Risk Assessment
  [WARN] Meta CPA anomaly detected 2 days ago -- resolve before reducing Meta budget
  [OK] Google and TikTok tracking verified, data fresh

Action Plan
  Week 1: Resolve Meta CPA anomaly, monitor
  Week 2: Shift 150 EUR Meta -> Google
  Week 3: Add 200 EUR to TikTok
  Week 4: Shift remaining 150 EUR Meta -> Google
  Week 5: Measure results, run /metrikia:weekly-report
```

### Common Follow-Up Actions

- Resolve any anomalies flagged in the risk assessment first
- `/metrikia:weekly-report` after 2 weeks to measure impact
- `/metrikia:campaign-audit` on specific campaigns being scaled up

### Tips

- Never reallocate more than 15% of budget at once. Gradual shifts allow you to measure impact and reverse if needed.
- Always check `get_anomalies` before making budget decisions. Anomalies can distort the data that recommendations are based on.
- MTA-based advice is more accurate than last-click, but requires sufficient conversion volume. If you have <20 conversions/month, treat recommendations as directional rather than precise.
- If a platform has no attribution data, fix tracking first -- do not cut its budget based on absence of data.

---

## /metrikia:creative-analysis

**Purpose:** Identify winning/losing creatives, fatigue signals, and scaling opportunities.

### When to Use

- User asks about creative performance, fatigue, or scaling
- User says "which ads are working" or "should I change any creatives"
- Weekly report shows declining CTR across multiple creatives

### What Data It Fetches

| Step | Tool Call | Purpose |
|------|-----------|---------|
| 1 | `get_creative_report(sortBy="roas", limit=50)` | All creatives ranked by efficiency |
| 2 | `get_creative_report(sortBy="spend", limit=50)` | Same creatives ranked by spend |
| 3 | `compare_performance()` | Period comparison for trend detection |
| 4 | `ask_diana("Which creatives show fatigue...")` | AI-powered fatigue and scaling analysis |

### How to Interpret the Output

1. **Creative Performance Tiers** -- Creatives are classified into four tiers:
   - **Scale**: High ROAS with room for more spend (not yet at saturation)
   - **Maintain**: Solid ROAS, stable performance. Keep running.
   - **Watch**: Declining metrics (CTR dropping, CPL rising). May need refresh.
   - **Kill**: Negative or near-zero ROAS with significant spend. Pause immediately.

2. **Platform Comparison** -- Which platform's creatives perform best. This helps decide where to launch new creative tests.

3. **Scaling Recommendations** -- Specific creatives to increase budget on, with suggested amounts based on current headroom.

### Real-World Example Scenario

**Sample output structure:**

```
Creative Tiers (Last 30 Days)

SCALE (high ROAS, room to grow)
  Video Temoignage v2 (Meta) -- ROAS 5.8x, CTR 3.2%, Spend 320 EUR
  UGC Story 3 (TikTok)      -- ROAS 4.2x, CTR 4.1%, Spend 180 EUR

MAINTAIN (solid, stable)
  Carousel Product (Meta)    -- ROAS 2.8x, CTR 2.1%, Spend 450 EUR
  Search Ad v5 (Google)      -- ROAS 3.5x, CTR 8.2%, Spend 280 EUR

WATCH (declining signals)
  Video Demo v1 (Meta)       -- ROAS 2.1x (-18% vs prev), CTR 1.8% (-22%)
    Signal: CTR declining 3 consecutive weeks = fatigue confirmed

KILL (losing money)
  Static Banner v1 (Meta)    -- ROAS 0.9x, CTR 0.8%, Spend 220 EUR
    Savings: 220 EUR/month if paused

Platform Summary
  Best creative performance: TikTok (avg ROAS 3.9x)
  Highest volume: Meta (12 active creatives)
  Recommendation: Test more video formats on TikTok

Scaling Plan
  1. Increase Video Temoignage v2 budget by 30% (+96 EUR/month)
  2. Double UGC Story 3 budget (+180 EUR/month) -- ROAS headroom
  3. Pause Static Banner v1 -- redeploy 220 EUR to top performers
```

### Common Follow-Up Actions

- `/metrikia:campaign-audit` on campaigns with "Kill" tier creatives
- `/metrikia:budget-optimizer` to reallocate saved budget
- `trigger_sync` if data seems stale before making creative decisions

### Tips

- A declining CTR for 3+ consecutive weeks is a confirmed fatigue signal. Refresh the creative, do not just increase budget.
- High impressions + stable CTR but declining conversions means audience saturation, not creative fatigue. The fix is audience expansion, not new creatives.
- Never declare a new creative a "winner" based on less than 1,000 impressions. Wait for statistical significance.
- If all creatives on one platform are declining simultaneously, the issue is likely audience-level (targeting, frequency capping) rather than creative-level.

---

## /metrikia:attribution-deep-dive

**Purpose:** Multi-touch attribution analysis with journey mapping and channel valuation.

### When to Use

- User wants multi-touch attribution analysis or channel valuation
- User asks "what's the real value of each channel" or "how do customers convert"
- Need to understand why last-click attribution differs from true contribution

### What Data It Fetches

| Step | Tool Call | Purpose |
|------|-----------|---------|
| 1 | `list_leads(status="converted")` | Recent conversions to analyze |
| 2 | `list_deals(status="won")` | Won deals with revenue data |
| 3 | `get_attribution_journey(leadId=...)` | Full journey for 5-10 leads |
| 4 | `get_budget_advice()` | MTA-enriched insights |
| 5 | `ask_diana("Based on MTA, which channels are undervalued...")` | Strategic channel assessment |

### How to Interpret the Output

1. **Journey Patterns** -- Common conversion paths reveal how your customers actually buy. A typical B2B pattern might be: "Paid Social (awareness) -> Search (research) -> Direct (conversion)." If you only measure last-click, Search and Direct get all the credit while Paid Social (which introduced the customer) gets none.

2. **Channel Contribution** -- Compares first-touch credit, assist credit, and last-touch credit for each channel. Channels with high assist percentage but low last-touch are systematically undervalued by simple attribution models.

3. **Undervalued Channels** -- Channels where MTA credit significantly exceeds their budget share. These are the biggest reallocation opportunities.

4. **Optimization Opportunities** -- Specific actions to improve the conversion path (reducing friction between touchpoints, shortening the journey, etc.).

### Real-World Example Scenario

**Sample output structure:**

```
Journey Analysis (Last 30 Days, 12 Conversions)

Common Patterns
  Pattern 1 (42%): Meta Ad -> Google Search -> Direct -> Conversion
  Pattern 2 (25%): TikTok -> Meta Retargeting -> Conversion
  Pattern 3 (17%): Google Search -> Direct -> Conversion
  Average journey: 2.8 touchpoints, 14 days

Channel Contribution
  Channel      | First Touch | Assist | Last Touch | MTA (Shapley)
  Meta Ads     |       50%   |   35%  |     25%    |     38%
  Google Search|       25%   |   30%  |     42%    |     35%
  TikTok       |       17%   |   15%  |      8%    |     15%
  Direct       |        8%   |   20%  |     25%    |     12%

Undervalued Channels
  Meta Ads:  Gets 25% last-touch credit but 38% Shapley credit (+52% undervalued)
  TikTok:    Gets 8% last-touch credit but 15% Shapley credit (+87% undervalued)

Overvalued Channels
  Direct:    Gets 25% last-touch credit but 12% Shapley credit (53% overvalued)
  Google:    Gets 42% last-touch credit but 35% Shapley credit (17% overvalued)

Recommendations
  1. Meta Ads is the primary introducer. Cutting its budget would starve downstream.
  2. TikTok drives 17% of first touches at 11% of budget -- significant opportunity.
  3. "Direct" conversions are actually multi-touch: 92% had prior paid touchpoints.
```

### Common Follow-Up Actions

- `/metrikia:budget-optimizer` to act on the undervalued channel findings
- `/metrikia:campaign-audit` on the top first-touch campaigns
- `/metrikia:weekly-report` to track the impact of reallocation over time

### Tips

- Focus on Shapley attribution, not just linear or time-decay. Shapley is the most mathematically rigorous model for assigning credit across touchpoints.
- If average journey length is >7 touchpoints, you may have a very long consideration cycle. Adjust your budget evaluation window accordingly (use `period="90d"` instead of `30d`).
- "Direct" conversions that have prior paid touchpoints are not truly direct. MTA reveals this hidden contribution.
- A large gap between platform-reported conversions and MTA-attributed conversions often indicates cross-device tracking gaps or deduplication issues. Check if Metrikia's lead matching (HashedPii) is catching these.

---

## Skill Chaining Strategy

Skills are designed to be chained together for comprehensive analysis:

```
1. /metrikia:weekly-report          -- Start with the big picture
       |
       v
2. /metrikia:campaign-audit         -- Deep-dive flagged campaigns
       |
       v
3. /metrikia:creative-analysis      -- Find winners and losers
       |
       v
4. /metrikia:attribution-deep-dive  -- Understand true channel value
       |
       v
5. /metrikia:budget-optimizer       -- Reallocate based on findings
       |
       v
6. /metrikia:lead-pipeline          -- Verify lead quality follows
```

This sequence moves from broad observation to specific action, ensuring that budget decisions are grounded in attribution data and that lead quality is monitored after changes are made.
