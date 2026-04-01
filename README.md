# Metrikia Plugin for Claude Code

AI-powered ad tracking and ROI analysis directly in Claude Code. Connect your AI assistant to Metrikia's MCP server and access campaigns, leads, attribution, and Diana AI insights.

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

## Available Skills

| Skill | Description |
|-------|-------------|
| `/metrikia:weekly-report` | Generate a weekly ad performance report |
| `/metrikia:campaign-audit` | Deep audit of a specific campaign |
| `/metrikia:lead-pipeline` | Analyze CRM lead pipeline health |
| `/metrikia:budget-optimizer` | Optimize budget allocation with MTA data |
| `/metrikia:creative-analysis` | Identify winning and losing creatives |
| `/metrikia:attribution-deep-dive` | Multi-touch attribution analysis |

## Available Agents

| Agent | Description |
|-------|-------------|
| `media-buyer` | Senior Media Buyer for campaign optimization |
| `growth-analyst` | Growth Analyst for funnel and attribution analysis |

## MCP Tools

17 tools available via the Metrikia MCP server:

**Read (13):** list_leads, get_lead, list_campaigns, get_campaign_performance, get_creative_report, get_metrics, compare_performance, list_deals, get_attribution_journey, get_anomalies, get_budget_advice, get_sync_status, ask_diana

**Write (4):** create_lead, transition_lead, create_deal, trigger_sync

## Requirements

- [Claude Code](https://claude.ai/claude-code) installed
- Metrikia account with API key (`mcp:read` scope minimum)
- `METRIKIA_API_KEY` environment variable set

## Support

- [Metrikia Documentation](https://api.metrikia.io/api/v1/docs)
- [Support](mailto:support@metrikia.io)
