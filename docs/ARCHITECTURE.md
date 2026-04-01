# Metrikia Plugin -- Technical Architecture

Technical reference for the Metrikia Claude Code plugin. Covers plugin structure, MCP integration, skill execution model, agent system, security, and multi-platform support.

## Overview

The Metrikia plugin connects Claude Code (and Cursor) to Metrikia's MCP server, enabling AI assistants to read and write ad performance, CRM, and attribution data without exposing PII. The plugin provides 17 MCP tools, 6 skills, 2 agents, and a session hook.

```
+--------------------------------------------------+
|  User (Media Buyer / Performance Manager)        |
+--------------------------------------------------+
        |
        | Natural language
        v
+--------------------------------------------------+
|  Claude Code (or Cursor)                         |
|  - Loads plugin from .claude-plugin/plugin.json  |
|  - Registers MCP server                          |
|  - Injects session context via hook              |
|  - Exposes skills and agents                     |
+--------------------------------------------------+
        |                           |
        | Skill instructions        | Agent persona
        | (markdown recipes)        | (markdown identity)
        v                           v
+--------------------------------------------------+
|  MCP Tool Calls (JSON-RPC over HTTP)             |
|  Authorization: Bearer ${METRIKIA_API_KEY}       |
+--------------------------------------------------+
        |
        | HTTPS
        v
+--------------------------------------------------+
|  Metrikia MCP Server                             |
|  https://mcp.metrikia.io/api/v1/mcp             |
|  (Symfony MCP Bundle, Railway EU West)           |
+--------------------------------------------------+
        |
        | Symfony DI
        v
+--------------------------------------------------+
|  Application Layer                               |
|  UseCase + Repository + Domain Services          |
+--------------------------------------------------+
        |
        | Doctrine ORM / PDO
        v
+--------------------------------------------------+
|  PostgreSQL (tenant-scoped) + Redis              |
|  (sessions, circuit breaker, rate limits)        |
+--------------------------------------------------+
```

## Plugin Structure

```
metrikia-plugin/
|-- .claude-plugin/
|   |-- plugin.json          # Claude Code plugin manifest
|   |-- marketplace.json     # Marketplace listing metadata
|   |-- ignore               # Files excluded from plugin packaging
|
|-- .cursor-plugin/
|   |-- plugin.json          # Cursor plugin manifest (mirrors Claude Code)
|
|-- skills/
|   |-- weekly-report/
|   |   +-- SKILL.md         # Skill definition (frontmatter + instructions)
|   |-- campaign-audit/
|   |   +-- SKILL.md
|   |-- lead-pipeline/
|   |   +-- SKILL.md
|   |-- budget-optimizer/
|   |   +-- SKILL.md
|   |-- creative-analysis/
|   |   +-- SKILL.md
|   +-- attribution-deep-dive/
|       +-- SKILL.md
|
|-- agents/
|   |-- media-buyer.md       # Agent persona definition
|   +-- growth-analyst.md
|
|-- hooks/
|   |-- hooks.json           # Hook configuration
|   +-- session-context.md   # Injected at session start
|
|-- docs/                    # This documentation
|-- README.md
|-- CHANGELOG.md
+-- LICENSE
```

### Conventions

**Plugin manifests** (`.claude-plugin/plugin.json`, `.cursor-plugin/plugin.json`) declare:
- MCP server URL and authentication headers
- Paths to skills, agents, and hooks directories
- User-configurable options (`default_period`, `language`)

**Skill files** use YAML frontmatter (`name`, `description`) followed by markdown instructions that guide Claude through a sequence of MCP tool calls.

**Agent files** use YAML frontmatter (`name`, `description`, `model`) followed by a persona definition with expertise areas and communication style.

**Hooks** use `hooks.json` to declare lifecycle callbacks. Currently, a `SessionStart` hook injects context about available skills, agents, and tools.

## MCP Server Integration

### Registration

The plugin registers the Metrikia MCP server declaratively in `plugin.json`:

```json
{
  "mcpServers": {
    "metrikia": {
      "type": "http",
      "url": "https://mcp.metrikia.io/api/v1/mcp",
      "headers": {
        "Authorization": "Bearer ${METRIKIA_API_KEY}"
      }
    }
  }
}
```

The `${METRIKIA_API_KEY}` variable is resolved from the user's environment at runtime. The plugin never stores or caches the key.

### Authentication Flow

```
1. User sets METRIKIA_API_KEY in shell environment
2. Claude Code loads plugin.json, resolves ${METRIKIA_API_KEY}
3. Every MCP tool call includes: Authorization: Bearer mk_live_xxx
4. Metrikia validates key, checks scopes (mcp:read / mcp:write)
5. User and Tenant loaded from database
6. All queries scoped to tenant via McpUserResolverInterface
```

Keys use the `mk_live_` prefix and are generated in Metrikia Settings > API Keys. Two scopes exist:
- `mcp:read` -- Required. Grants access to 13 read tools.
- `mcp:write` -- Optional. Grants access to 4 write tools (create_lead, transition_lead, create_deal, trigger_sync).

### Transport

HTTP transport over TLS. The MCP server runs on a dedicated Railway service at `https://mcp.metrikia.io/api/v1/mcp`, scaled independently from the main API. Streamable HTTP (SSE) is planned for `ask_diana` in v1.2.

## Skill Execution Model

Skills are **markdown-based orchestration recipes** -- they do not contain executable code. Instead, they provide structured instructions that Claude follows, making MCP tool calls in the prescribed order.

### Anatomy of a Skill

```markdown
---
name: weekly-report
description: Generate a comprehensive weekly ad performance report
---

# Weekly Performance Report

## Process

1. **Fetch current period metrics**
   - Call `get_metrics` with last 7 days
   - Call `compare_performance` with comparisonType: "previous_period"

2. **Identify top performers**
   - Call `get_creative_report` with sortBy: "roas", limit: 5

...

## Output Format

### Performance Summary
- Total Spend | Revenue | Profit
- MER | ROAS | CRM ROAS
...

## Red Flags
- MER dropping >20% week-over-week ...

## Error Handling
- If rate limited (429) ...
```

### Execution Sequence

```
User: "/metrikia:weekly-report"
    |
    v
Claude reads SKILL.md instructions
    |
    v
Step 1: get_metrics(startDate="-7d") --> MCP server --> JSON response
Step 2: compare_performance(comparisonType="previous_period") --> JSON
Step 3: get_creative_report(sortBy="roas", limit=5) --> JSON
Step 4: get_anomalies() --> JSON
Step 5: get_budget_advice(period="7d") --> JSON
Step 6: ask_diana("Based on this week's performance...") --> JSON
    |
    v
Claude synthesizes all responses into the prescribed Output Format
    |
    v
Structured report presented to user
```

### Why Markdown, Not Code

Skills are intentionally markdown, not TypeScript or Python. See [ADR-002](adr/ADR-002-skill-design-philosophy.md) for the full rationale. In short:
- Claude understands intent and adapts to edge cases (empty data, errors, partial results).
- No build step, no runtime dependencies.
- Users can read and understand what a skill does before running it.
- The same skill works across Claude Code and Cursor without platform-specific code.

## Agent System

Agents are persistent personas that use MCP tools proactively rather than following a scripted sequence.

### Media Buyer Agent

Expert in campaign optimization, budget allocation, and scaling strategies. Starts with data (`get_metrics`, `list_campaigns`) before making any recommendation. Focuses on ROAS, MER, creative performance, and cross-platform synergy.

### Growth Analyst Agent

Bridges marketing spend and sales revenue. Works backwards from deals to understand true ROI. Focuses on attribution journeys, conversion paths, lead quality, and long-term trends (30-90 day windows).

### Agent vs Skill

| Aspect | Skill | Agent |
|--------|-------|-------|
| Invocation | `/metrikia:skill-name` | Selected as active agent |
| Execution | Scripted sequence of tool calls | Autonomous, goal-driven |
| Output | Structured report (prescribed format) | Conversational, adaptive |
| Best for | Repeatable analyses | Open-ended exploration |
| Tool usage | Prescribed order | Chooses tools based on context |

## Hook System

The plugin uses a `SessionStart` hook to inject context when Claude Code initializes:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "cat \"${CLAUDE_PLUGIN_ROOT}/hooks/session-context.md\"",
            "async": false
          }
        ]
      }
    ]
  }
}
```

The `session-context.md` file provides Claude with:
- List of available skills and when to use each
- List of agents and their focus areas
- Categorized list of all 17 MCP tools
- Reminder to always fetch data before making recommendations

The empty `matcher` means the hook fires on every session start, regardless of project context.

## Security Model

### API Key Scopes

| Scope | Tools | Count |
|-------|-------|-------|
| `mcp:read` | list_leads, get_lead, list_campaigns, get_campaign_performance, get_creative_report, get_metrics, compare_performance, list_deals, get_attribution_journey, get_anomalies, get_budget_advice, get_sync_status, ask_diana | 13 |
| `mcp:write` | create_lead, transition_lead, create_deal, trigger_sync | 4 |

### PII Masking

The MCP server enforces a strict PII invariant at the tool level. Every tool uses explicit field mapping -- no automatic entity serialization.

**Never exposed:** email addresses, phone numbers, social media handles, hashed PII (nameHash, emailHash).

**Safe to expose:** UUIDs, full names (first + last only), statuses, source labels, campaign names, monetary amounts, timestamps, attribution data.

### Rate Limiting

| Category | Limit | Window |
|----------|-------|--------|
| Read tools | 60 requests | 1 minute |
| Diana AI | 10 requests | 5 minutes |
| Write tools | 30 requests | 1 minute |
| Sync trigger | 5 requests | 1 hour |

Implemented via Symfony's sliding window rate limiter. Returns HTTP 429 with `Retry-After` header when exceeded.

### Circuit Breaker (Diana AI)

`ask_diana` calls Claude Haiku internally (AI-calling-AI). A Redis-backed circuit breaker prevents runaway loops:

```
Closed (normal) --5 failures--> Open (blocked, 30s cooldown)
                                    |
                                   30s
                                    |
                                    v
                              Half-Open (1 probe request)
                              /                         \
                         success                      failure
                            |                            |
                            v                            v
                         Closed                        Open
```

- Threshold: 5 consecutive failures within 5 minutes
- Cooldown: 30 seconds
- Storage: Redis (keyed per tenant, cross-instance)
- Implementation: `McpCircuitBreaker` implements `CircuitBreakerInterface`

### Multi-Tenancy

Every MCP query is filtered by tenant at three levels:
1. **SQL layer:** `WHERE tenant_id = ?` on every repository query
2. **Doctrine layer:** Global `TenantFilter` active on all entities
3. **Tool layer:** `$this->userResolver->getTenant()` called explicitly in every tool

### Environment Variable Security

The `METRIKIA_API_KEY` environment variable must never be committed to version control. The `.claude-plugin/ignore` file excludes sensitive paths. Users should set the key in their shell profile (`~/.zshrc` or `~/.bashrc`) or use a secrets manager.

## Multi-Platform Support

The plugin ships with two manifest directories:

| Platform | Manifest | Key Differences |
|----------|----------|-----------------|
| Claude Code | `.claude-plugin/plugin.json` | Includes `skills`, `agents`, `hooks` paths |
| Cursor | `.cursor-plugin/plugin.json` | Same MCP server config, same `userConfig` |

Both platforms share the same MCP server URL and authentication mechanism. Skills and agents are available wherever the platform supports them. The MCP tool calls are identical regardless of client.

## Data Flow

Complete data flow for a skill execution:

```
User: "/metrikia:weekly-report"
  |
  v
Claude Code
  |-- Reads skills/weekly-report/SKILL.md
  |-- Follows Process steps 1-6
  |
  |-- Step 1: POST https://mcp.metrikia.io/api/v1/mcp
  |     Body: {"jsonrpc":"2.0","method":"tools/call",
  |            "params":{"name":"get_metrics",
  |                      "arguments":{"startDate":"2026-03-25","endDate":"2026-04-01"}}}
  |     Auth: Bearer mk_live_xxx
  |
  v
Metrikia MCP Server (Symfony)
  |-- Validates API key, checks mcp:read scope
  |-- Resolves User + Tenant via McpUserResolverInterface
  |-- Dispatches to GetMetricsTool.__invoke()
  |     |-- GetMERUseCase.execute(tenantId, dateRange)
  |     |-- GetRealROASUseCase.execute(tenantId, dateRange)
  |     +-- Returns: {period, mer, totalRevenue, totalSpend, roas, ...}
  |
  v
PostgreSQL (tenant-scoped queries)
  |-- performance_data WHERE tenant_id = ? AND date BETWEEN ? AND ?
  |-- deals WHERE tenant_id = ? AND closed_at BETWEEN ? AND ?
  |
  v
JSON response -> Claude Code -> Synthesized report -> User
```

## Extension Points

### Adding a New Skill

1. Create `skills/my-skill/SKILL.md` with YAML frontmatter and process instructions.
2. The plugin auto-discovers skills from the `skills/` directory.
3. No code changes needed -- just markdown.

### Adding a New Agent

1. Create `agents/my-agent.md` with YAML frontmatter and persona definition.
2. Auto-discovered from the `agents/` directory.

### Server-Side Tool Additions

When new MCP tools are added to the Metrikia backend (in `src/Presentation/Mcp/Tool/`), they are auto-discovered by the Symfony MCP Bundle via the `#[McpTool]` attribute. The plugin picks them up automatically on the next session -- no plugin update needed for new tools.

---

**Version:** 1.0.0
**Last Updated:** April 2026
**MCP Server:** Symfony MCP Bundle ^0.6.0
**Transport:** HTTP (Streamable HTTP planned v1.2)
