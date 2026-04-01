# Metrikia Plugin for Claude Code

AI-powered ad tracking and ROI analysis directly in Claude Code. Connect your AI assistant to Metrikia's MCP server and access campaigns, leads, attribution, and Diana AI insights.

## What is Metrikia?

Metrikia is a SaaS platform that correlates ad investments (Meta, Google, TikTok) with CRM sales data to calculate real ROI. It provides multi-touch attribution (9 models including Shapley and Markov), lead pipeline tracking, creative performance analysis, and Diana AI for strategic recommendations. Built for Media Buyers, Creative Strategists, Performance Managers, and Ad Agencies.

## Installation

### 1. Install the plugin

```bash
claude plugins add metrikia-plugin
```

### 2. Set your API key

Generate an API key in [Metrikia Settings -> API Keys](https://app.metrikia.io/app/settings?group=advanced&section=api-webhooks) with `mcp:read` scope.

```bash
export METRIKIA_API_KEY="mk_live_your_key_here"
```

Or add to your shell profile (`~/.zshrc` / `~/.bashrc`).

### 3. Restart Claude Code

The Metrikia MCP server and all skills will be available immediately.

### Quick Verification

Ask Claude:

> "Use metrikia to show my campaign performance for the last 7 days"

If you see real campaign data, the plugin is working correctly.

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

## Basic Workflow

Skills chain together for comprehensive analysis:

1. **Start broad** — `/metrikia:weekly-report` for the overall picture
2. **Drill down** — `/metrikia:campaign-audit` on underperforming campaigns
3. **Check creatives** — `/metrikia:creative-analysis` to find fatigue or winners
4. **Understand journeys** — `/metrikia:attribution-deep-dive` for true channel value
5. **Optimize** — `/metrikia:budget-optimizer` to reallocate based on findings
6. **Monitor pipeline** — `/metrikia:lead-pipeline` to verify lead quality follows

## Configuration

The plugin supports user-configurable options in `plugin.json`:

| Option | Values | Default | Description |
|--------|--------|---------|-------------|
| `default_period` | `7d`, `30d`, `90d` | `30d` | Default time window for analysis |
| `language` | `en`, `fr` | `en` | Report output language |

## Requirements

- [Claude Code](https://claude.ai/claude-code) installed
- Metrikia account with API key (`mcp:read` scope minimum)
- `METRIKIA_API_KEY` environment variable set

## Support

- [Metrikia Documentation](https://api.metrikia.io/public/api/v1/docs?ui=redoc)
- [Support](mailto:support@metrikia.io)
- [GitHub Issues](https://github.com/BULDEE/metrikia-claude-plugin/issues)
