# Metrikia Plugin for Claude Code

AI-powered ad tracking and ROI analysis directly in Claude Code. Connect your AI assistant to Metrikia's MCP server and access campaigns, leads, attribution, and Diana AI insights.

## What is Metrikia?

Metrikia is a SaaS platform that correlates ad investments (Meta, Google, TikTok) with CRM sales data to calculate real ROI. It provides multi-touch attribution (9 models including Shapley and Markov), lead pipeline tracking, creative performance analysis, and Diana AI for strategic recommendations. Built for Media Buyers, Creative Strategists, Performance Managers, and Ad Agencies.

## Installation

### From GitHub (recommended)

```bash
# Step 1: Set your API key
export METRIKIA_API_KEY="mk_live_your_key_here"
```

Generate an API key in [Metrikia Settings -> API Keys](https://app.metrikia.io/app/settings?group=advanced&section=api-webhooks) with `mcp:read` scope. Add it to your shell profile (`~/.zshrc` / `~/.bashrc`).

Then in Claude Code:

```bash
# Step 2: Add the marketplace
/plugin marketplace add BULDEE/metrikia-claude-plugin

# Step 3: Install the plugin
/plugin install metrikia@BULDEE-metrikia-claude-plugin

# Step 4: Restart Claude Code
exit
claude
```

### From Local Path

```bash
# If you cloned the repo locally
git clone https://github.com/BULDEE/metrikia-claude-plugin.git
/plugin marketplace add /path/to/metrikia-claude-plugin
/plugin install metrikia@metrikia-plugin
```

### Verify Installation

```bash
# Open plugin manager
/plugin

# Go to "Installed" tab to see metrikia plugin
# Go to "Errors" tab if skills don't appear
```

The plugin runs an automatic health check at startup. If you see **"Metrikia Plugin Active"**, everything is connected.

### Official Marketplace (coming soon)

> When published to the official Claude Code marketplace:
>
> ```bash
> claude plugin install metrikia
> ```

## Health Check

At every session start, the plugin automatically verifies:

1. `METRIKIA_API_KEY` is set
2. The MCP server at `mcp.metrikia.io` is reachable and the key is valid

If something is wrong, you get a clear error message with instructions to fix it — no silent failures.

## What's Inside

### Skills (6)

| Skill | Description |
|-------|-------------|
| `/metrikia:weekly-report` | Generate a weekly ad performance report with MER, ROAS, anomalies, and Diana recommendations |
| `/metrikia:campaign-audit` | Deep audit of a specific campaign with creative breakdown and attribution insights |
| `/metrikia:lead-pipeline` | Analyze CRM pipeline health, conversion rates, and source attribution |
| `/metrikia:budget-optimizer` | Optimize budget allocation using MTA attribution data |
| `/metrikia:creative-analysis` | Identify winning/losing creatives, fatigue signals, and scaling opportunities |
| `/metrikia:attribution-deep-dive` | Multi-touch attribution analysis with journey mapping and channel valuation |

### Agents (2)

| Agent | Description |
|-------|-------------|
| `media-buyer` | Senior Media Buyer for campaign optimization, budget allocation, and scaling strategies |
| `growth-analyst` | Growth Analyst for funnel analysis, attribution modeling, and revenue correlation |

### MCP Tools (17)

**Campaigns:** `list_campaigns`, `get_campaign_performance`, `get_creative_report`, `compare_performance`

**Leads/CRM:** `list_leads`, `get_lead`, `list_deals`

**Attribution:** `get_attribution_journey`, `get_budget_advice`

**Metrics:** `get_metrics`, `get_anomalies`, `get_sync_status`

**Diana AI:** `ask_diana`

**Write:** `create_lead`, `transition_lead`, `create_deal`, `trigger_sync`

## Examples

### Simple — Quick Status Check

> "How are my campaigns performing this week?"

Claude uses `get_metrics` and `compare_performance` to fetch your real data and returns a summary with week-over-week trends. No dashboard navigation needed.

### Simple — Lead Quality by Source

> "Which ad platforms bring leads that actually close as deals?"

Claude calls `list_leads`, `list_deals`, and `get_attribution_journey` to correlate CRM data with ad sources — something that normally requires exporting CSVs from multiple tools and joining them manually.

### Intermediate — Weekly Report with Anomaly Detection

> `/metrikia:weekly-report`

Generates a structured report in one shot:
- Aggregated metrics (MER, ROAS, CPA, CPL) with week-over-week trends
- Top/bottom campaigns ranked by ROAS
- Anomaly detection (spend spikes, CTR drops, conversion rate shifts)
- Diana AI strategic recommendations
- Concrete next actions with priority

**What Claude Code alone can't do:** Access your live campaign data, calculate real MER across platforms, or detect anomalies based on your historical performance.

### Intermediate — Creative Fatigue Analysis

> `/metrikia:creative-analysis`

Identifies which creatives are fatiguing and which are ready to scale:
- Frequency vs. CTR degradation curves per creative
- Winners (high ROAS, stable performance) vs. losers (declining CTR, rising CPA)
- Scaling recommendations with budget suggestions
- New creative angle suggestions based on top performers

**What Claude Code alone can't do:** Access per-creative performance data, track frequency curves over time, or correlate creative performance with actual conversions.

### Advanced — Full-Funnel Attribution Audit

> "Compare Shapley vs last-click attribution for my Meta campaigns this quarter, then show me which channels are undervalued and recommend a budget reallocation"

Claude chains multiple tools:
1. `get_campaign_performance` — fetches Meta campaigns for the quarter
2. `get_attribution_journey` — pulls multi-touch attribution (Shapley model)
3. `compare_performance` — benchmarks against last-click model
4. `get_budget_advice` — gets data-driven reallocation recommendations
5. `ask_diana` — validates the strategy with Diana AI

Result: a complete analysis showing which channels get too much/too little budget based on their true contribution, with specific reallocation percentages.

**What Claude Code alone can't do:** Run Shapley/Markov attribution models, access your cross-platform journey data, or calculate channel contribution across touchpoints.

### Advanced — Pipeline-to-Revenue Correlation

> `/metrikia:lead-pipeline` then "Cross-reference the top 3 lead sources with their average deal size and sales cycle length"

Claude performs end-to-end funnel analysis:
1. Pipeline health: conversion rates per stage, velocity, bottlenecks
2. Source quality ranking: not just volume, but lead-to-deal conversion rate per source
3. Revenue attribution: average deal size and cycle length per ad source
4. ROI calculation: true cost-per-acquisition including sales cycle cost

**What Claude Code alone can't do:** Access your CRM pipeline data, correlate ad spend with deal outcomes, or calculate true customer acquisition cost across the full funnel.

### Expert — Monday Morning Playbook

> "Give me my Monday morning playbook: what changed over the weekend, what needs immediate action, and what should I test this week"

Claude orchestrates the full toolkit:
1. `get_anomalies` — flags weekend changes (spend, performance shifts)
2. `get_metrics` + `compare_performance` — weekend vs. weekday benchmarks
3. `get_creative_report` — creative fatigue signals emerging
4. `get_budget_advice` — reallocation opportunities from fresh data
5. `list_leads` — new leads from weekend, quality assessment
6. `ask_diana` — strategic priorities for the week

Result: an actionable brief with 3 sections — **Urgent** (fix now), **Optimize** (improve this week), **Test** (new experiments to launch).

## Basic Workflow

Skills chain together for comprehensive analysis:

1. **Start broad** — `/metrikia:weekly-report` for the overall picture
2. **Drill down** — `/metrikia:campaign-audit` on underperforming campaigns
3. **Check creatives** — `/metrikia:creative-analysis` to find fatigue or winners
4. **Understand journeys** — `/metrikia:attribution-deep-dive` for true channel value
5. **Optimize** — `/metrikia:budget-optimizer` to reallocate based on findings
6. **Monitor pipeline** — `/metrikia:lead-pipeline` to verify lead quality follows

## Configuration

The plugin prompts for these options when enabled:

| Option | Description |
|--------|-------------|
| `default_period` | Default analysis period: 7d, 30d, or 90d (default: 30d) |
| `language` | Report language: en or fr (default: en) |

## Requirements

- [Claude Code](https://claude.ai/claude-code) 1.0.33 or later
- Metrikia account with API key (`mcp:read` scope minimum)
- `METRIKIA_API_KEY` environment variable set
- `curl` (for automatic health check at startup)

## Support

- [Metrikia AI Integration](https://metrikia.io/integrations/ai)
- [MCP Server Documentation](https://api.metrikia.io/public/api/v1/docs?ui=redoc#section/MCP-Server)
- [API Documentation](https://api.metrikia.io/public/api/v1/docs?ui=redoc)
- [Support](mailto:support@metrikia.io)
- [GitHub Issues](https://github.com/BULDEE/metrikia-claude-plugin/issues)
