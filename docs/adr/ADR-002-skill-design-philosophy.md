# ADR-002: Skill Design Philosophy -- Markdown Orchestration Recipes

## Status

Accepted

## Date

2026-04-01

## Context

The Metrikia plugin needs to provide guided analysis workflows that chain multiple MCP tool calls into coherent reports. Skills are the mechanism for this.

Skills could be implemented in three ways:

1. **Executable code** (TypeScript/Python scripts that call MCP tools programmatically)
2. **Configuration files** (JSON/YAML that define a rigid tool call sequence with parameter templates)
3. **Markdown instructions** (natural language recipes that guide Claude through the analysis)

The choice affects maintainability, flexibility, user trust, and cross-platform compatibility.

## Options Considered

### Option A: Executable Code (TypeScript Scripts)

Each skill is a TypeScript file that imports an MCP client, calls tools in sequence, and formats the output.

```typescript
// Hypothetical: skills/weekly-report/index.ts
export async function execute(mcp: McpClient) {
  const metrics = await mcp.call('get_metrics', { startDate: '-7d' });
  const comparison = await mcp.call('compare_performance', { comparisonType: 'previous_period' });
  // ... format and return report
}
```

**Pros:**
- Deterministic execution. The exact sequence is guaranteed.
- Type-safe parameter passing.
- Can include complex logic (conditional branches, aggregations, formatting).

**Cons:**
- Requires a runtime (Node.js) and build step.
- Platform-specific. Would not work on Cursor or other clients without adaptation.
- Cannot adapt to edge cases. If `get_metrics` returns empty data, the script must explicitly handle every possible state. Claude handles these naturally.
- Opaque to users. A media buyer cannot read TypeScript to understand what the skill does.
- Every MCP tool change requires code updates, rebuild, and redistribution.
- Duplicates Claude's core competency. Claude already orchestrates multi-step workflows natively.

**Verdict:** Over-engineered. Fights against the AI-native paradigm.

### Option B: Configuration Files (JSON/YAML Pipelines)

Each skill is a JSON file that defines an ordered list of tool calls with parameter templates.

```json
{
  "steps": [
    { "tool": "get_metrics", "params": { "startDate": "${-7d}" } },
    { "tool": "compare_performance", "params": { "comparisonType": "previous_period" } },
    { "tool": "get_creative_report", "params": { "sortBy": "roas", "limit": 5 } }
  ],
  "outputTemplate": "## Performance Summary\n{{metrics.mer}} MER..."
}
```

**Pros:**
- No code to execute. Pure configuration.
- Deterministic sequence.
- Machine-readable.

**Cons:**
- Rigid. Cannot handle conditional logic ("if anomalies are detected, investigate further").
- Template syntax becomes complex for real-world reports.
- No error handling guidance. What should happen if a tool returns empty data?
- No domain context. Cannot explain to Claude why a metric matters or what a red flag looks like.
- Still opaque to non-technical users (JSON is not natural language).

**Verdict:** Too rigid. Loses the adaptive intelligence that makes AI assistants valuable.

### Option C: Markdown Instructions (Chosen)

Each skill is a markdown file with:
- YAML frontmatter (name, description)
- A **Process** section listing tool calls in order with context on why each call matters
- An **Output Format** section prescribing the report structure
- A **Red Flags** section teaching Claude domain-specific warning signals
- An **Error Handling** section for common failure modes

```markdown
---
name: weekly-report
description: Generate a weekly ad performance report
---

# Weekly Performance Report

## Process

1. **Fetch current period metrics**
   - Call `get_metrics` with last 7 days
   - Call `compare_performance` for week-over-week trends

2. **Identify top performers**
   - Call `get_creative_report` with sortBy: "roas", limit: 5

...

## Red Flags
- MER dropping >20% week-over-week -- investigate immediately
- Spend anomaly with no revenue change -- possible tracking issue

## Error Handling
- If empty results -- check get_sync_status
```

**Pros:**
- **Claude understands intent.** "Call get_metrics with last 7 days" gives Claude enough context to resolve actual dates, handle date format, and adapt if the user asks for a different period.
- **Adaptive to edge cases.** If `get_anomalies` returns zero anomalies, Claude naturally says "No anomalies detected" instead of crashing on an empty template.
- **Domain knowledge embedded.** Red Flags sections teach Claude media buying expertise. A code script cannot do this.
- **Transparent.** Any user can read the skill and understand exactly what it does. This builds trust.
- **No build step.** Pure markdown, works on any platform.
- **Easy to extend.** Adding a new skill is creating a markdown file. No code, no dependencies, no rebuild.
- **Cross-platform.** The same skill file works identically on Claude Code and Cursor.
- **Graceful degradation.** If a tool is temporarily unavailable, Claude can skip that step and note the gap in the report.

**Cons:**
- **Non-deterministic.** Claude may reorder steps, skip steps it judges unnecessary, or add steps it thinks are helpful. The sequence is a recommendation, not a guarantee.
- **No compile-time validation.** Tool names are strings in markdown. A typo will only be caught at runtime.
- **Depends on Claude's competence.** If Claude misunderstands the instructions, the output quality degrades. (In practice, Claude Code follows structured markdown instructions very reliably.)

## Decision

Adopt **Option C: Markdown-based skills** as orchestration recipes.

### Design Principles

1. **Instruct, do not script.** Skills tell Claude what to fetch and how to present it, not the exact API calls with exact parameters. Claude resolves the details.

2. **Embed domain knowledge.** Every skill includes a Red Flags section that teaches Claude media buying/growth analysis expertise. This is impossible with code or config-based approaches.

3. **Prescribe output structure.** Skills define the report format (sections, tables, bullet points) so output is consistent across runs. Claude fills in the data.

4. **Handle failure gracefully.** Every skill includes an Error Handling section that tells Claude what to do when things go wrong (connection errors, empty data, rate limits).

5. **One skill, one analysis.** Each skill focuses on a single analysis type. Users chain skills for comprehensive analysis rather than having one monolithic "do everything" skill.

6. **Process flow as a guide.** The Process section is ordered from "broad context" to "specific analysis" to "strategic recommendation." This mirrors how a human analyst works.

### Skill Anatomy

Every skill follows this structure:

```
YAML Frontmatter (name, description)
  |
  v
Title and brief description
  |
  v
Prerequisites (if any -- e.g., which campaign to audit)
  |
  v
Process (ordered steps with tool calls and context)
  |
  v
Output Format (report structure with sections and tables)
  |
  v
Process Flow (dot graph for visualization)
  |
  v
Red Flags (domain-specific warning signals)
  |
  v
Error Handling (what to do when things go wrong)
```

## Consequences

### Positive

- **Skills are documentation.** Reading a skill file teaches you how to analyze ad performance, even without the plugin. The knowledge is embedded in the instructions, not hidden in code.
- **Claude adapts intelligently.** If the user asks "just show me anomalies, skip the rest," Claude can follow that instruction while still referencing the skill's error handling guidance.
- **Zero maintenance for tool parameter changes.** Skills reference tool names, not exact parameter schemas. Claude reads the tool's actual schema from the MCP server at call time.
- **Community-extensible.** Anyone can write a new skill by creating a markdown file. No programming knowledge required.

### Negative

- **No execution guarantee.** Claude may deviate from the prescribed sequence. In rare cases, this could lead to incomplete reports if Claude judges a step unnecessary.
- **Testing is qualitative.** You cannot unit-test a markdown file. Validation requires running the skill and evaluating the output quality.
- **Depends on LLM capabilities.** A less capable model might not follow the instructions as reliably. The skills are optimized for Claude's instruction-following capabilities.

### Trade-Off Summary

| Criterion | Code | Config | Markdown |
|-----------|------|--------|----------|
| Determinism | High | High | Medium |
| Adaptability | Low | Low | High |
| Domain knowledge | None | None | Embedded |
| Transparency | Low | Medium | High |
| Maintenance | High | Medium | Low |
| Cross-platform | Low | Medium | High |
| Build step | Required | None | None |
| Error handling | Explicit code | None | Natural language |

The trade-off is clear: we accept slightly less determinism in exchange for significantly better adaptability, transparency, and maintainability. For an AI-native plugin, this is the right trade-off.

## References

- [ADR-001 -- Plugin Architecture](ADR-001-plugin-architecture.md)
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
- [MCP Protocol Specification](https://modelcontextprotocol.io)
