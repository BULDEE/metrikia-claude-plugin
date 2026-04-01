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
