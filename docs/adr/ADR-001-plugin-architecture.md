# ADR-001: Plugin Architecture for Claude Code MCP Integration

## Status

Accepted

## Date

2026-04-01

## Context

Metrikia has an MCP server (ADR-085 in the main project) that exposes 17 tools for ad performance, CRM, attribution, and Diana AI. This server is already accessible to any MCP-compatible client via direct configuration (adding the server URL and API key to the client's config file).

We need to make the Metrikia MCP integration accessible to AI clients (Claude Code, Cursor) in a way that maximizes usability for media buyers and performance managers who are not developers. The raw MCP tools are powerful but require the user to know which tools exist, what parameters they accept, and how to chain them together for meaningful analysis.

Three approaches were evaluated.

## Options Considered

### Option A: Direct .mcp.json Configuration Only

The simplest approach. Users add Metrikia's MCP server URL and API key to their client's MCP configuration file. No skills, no agents, no session context.

**Pros:**
- Zero distribution overhead. No plugin to install.
- Users get immediate access to all 17 tools.
- Any MCP client works without platform-specific packaging.

**Cons:**
- Users must know tool names and parameters by heart.
- No guided workflows. Users must manually orchestrate multi-tool analyses (e.g., a weekly report requires 6-7 tool calls in the right order).
- No session context. Claude has no awareness of Metrikia's capabilities until the user explicitly asks.
- No agent personas. Generic Claude responses without media buyer expertise.
- Barrier to entry: requires editing JSON config files.

**Verdict:** Sufficient for developers, insufficient for the target audience (media buyers, agency teams).

### Option B: Full SDK Integration (TypeScript Package)

Build a TypeScript package that wraps the MCP tools with a typed API client, helper functions, and pre-built analysis pipelines.

**Pros:**
- Type-safe API with IntelliSense.
- Pre-built analysis functions (e.g., `generateWeeklyReport()`, `auditCampaign(id)`).
- Could include caching, retry logic, and error handling in code.

**Cons:**
- Requires a build step and package distribution (npm).
- Platform-specific: would only work in Claude Code (not Cursor or other MCP clients without adaptation).
- Duplicates logic that Claude can handle natively. Claude already knows how to chain tool calls, handle errors, and synthesize results -- it just needs instructions.
- Maintenance burden: every MCP tool change requires an SDK update, rebuild, and redistribution.
- Breaks the MCP abstraction. The whole point of MCP is that tools are self-describing and callable without client-side code.

**Verdict:** Over-engineered. Solves a problem Claude already solves natively.

### Option C: Claude Code Plugin with Skills + Agents + MCP Registration (Chosen)

A plugin that:
1. Registers the MCP server declaratively (no manual config editing).
2. Provides 6 markdown-based skills that guide Claude through multi-tool analysis workflows.
3. Provides 2 agent personas (Media Buyer, Growth Analyst) with domain expertise.
4. Injects session context via a hook so Claude always knows what tools are available.

**Pros:**
- Simple install: `claude --plugin-dir ./metrikia-claude-plugin` (marketplace: `claude plugin install metrikia` when available).
- Skills provide guided workflows without code. Claude follows the markdown instructions, making tool calls in the right order, handling errors, and synthesizing results.
- Agent personas bring domain expertise. A "Media Buyer" agent thinks in ROAS, CPL, and scaling strategies -- not generic AI responses.
- Session hook ensures Claude always knows about Metrikia's capabilities, even in a new conversation.
- Multi-platform: works on Claude Code and Cursor via separate manifest files.
- No build step. Pure markdown + JSON. Anyone can read and understand what the plugin does.
- New MCP tools are automatically available without plugin updates (auto-discovered by the server).
- New skills can be added by creating a markdown file -- no code changes.

**Cons:**
- Plugin distribution mechanism is platform-dependent (Claude Code marketplace, Cursor plugin system).
- Skills are instructions, not guarantees. Claude may deviate from the prescribed sequence if it judges a different approach is better. (In practice, this is more feature than bug.)
- Two manifest files to maintain (.claude-plugin and .cursor-plugin).

## Decision

Adopt **Option C: Claude Code Plugin** as the distribution mechanism for Metrikia's MCP integration.

The plugin provides:
- **MCP server registration** via `plugin.json` with `${METRIKIA_API_KEY}` environment variable resolution.
- **6 skills** as markdown orchestration recipes in `skills/*/SKILL.md`.
- **2 agents** as markdown personas in `agents/*.md`.
- **1 session hook** that injects context about available tools and skills.
- **Multi-platform support** via `.claude-plugin/` and `.cursor-plugin/` directories.
- **User configuration** for default analysis period and language.

## Consequences

### Positive

- **Low barrier to entry.** Media buyers install the plugin and start asking questions. No JSON editing, no API client configuration.
- **Guided workflows.** Skills transform 17 raw tools into 6 actionable analysis workflows that chain the right tools in the right order.
- **Domain expertise.** Agent personas bring media buying and growth analysis context that generic AI responses lack.
- **Zero maintenance for new tools.** When the Metrikia backend adds a new MCP tool, the plugin picks it up automatically. Only new skills need explicit addition.
- **Transparent.** All skills and agents are readable markdown. Users can verify exactly what the plugin does.
- **Multi-platform.** Same core content works across Claude Code and Cursor.

### Negative

- **Platform dependency.** The plugin format is tied to Claude Code and Cursor's plugin systems. A new AI client would need a new manifest directory.
- **No compile-time guarantees.** Skills reference tool names as strings. A renamed tool would break the skill silently until Claude encounters the error at runtime.
- **Dual manifest maintenance.** Changes to `plugin.json` must be reflected in both `.claude-plugin/` and `.cursor-plugin/`.

### Risks

- **Skill drift.** If MCP tool parameters change, skills may reference outdated parameter names. Mitigated by: skills reference tool names only, not exact parameter schemas. Claude reads the tool's actual schema at call time.
- **Claude deviation from skill sequence.** Claude may skip steps or reorder them if it judges a different approach is better. Mitigated by: skills are designed as recommended sequences, not rigid scripts. Deviation is acceptable when Claude has good reason.
- **API key exposure.** Users might accidentally commit their `METRIKIA_API_KEY`. Mitigated by: environment variable resolution (never stored in plugin files), documentation warnings, `.gitignore` patterns.

## References

- [ADR-085 -- MCP Server Architecture](https://github.com/BULDEE/metrikia/blob/main/docs/adr/ADR-085-mcp-server-architecture.md) (main project)
- [MCP Protocol Specification](https://modelcontextprotocol.io)
- [Claude Code Plugin Documentation](https://code.claude.com/docs/en/plugins)
