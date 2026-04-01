# Metrikia Plugin -- Security and Compliance

Security architecture for the Metrikia Claude Code plugin and MCP server integration. Covers authentication, authorization, data isolation, PII protection, rate limiting, and GDPR considerations.

## API Key Authentication

### Key Format

All Metrikia API keys use the `mk_live_` prefix:

```
mk_live_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
```

Keys are generated in **Metrikia Settings > API Keys** and can only be viewed once at creation time. They cannot be retrieved after initial display.

### Authentication Headers

The MCP server accepts the API key via two headers (either is valid):

| Header | Format |
|--------|--------|
| `X-API-Key` | `mk_live_xxx` |

The plugin uses the `X-API-Key` header, resolved from the `METRIKIA_API_KEY` environment variable:

```json
{
  "headers": {
    "X-API-Key": "${METRIKIA_API_KEY}"
  }
}
```

### Key Management Best Practices

1. **Never commit keys to version control.** Set `METRIKIA_API_KEY` in your shell profile (`~/.zshrc` or `~/.bashrc`) or use a secrets manager.
2. **Rotate keys periodically.** Generate a new key, update your environment, revoke the old key.
3. **Use minimal scopes.** If you only need read access, generate a key with `mcp:read` only.
4. **Revoke immediately if compromised.** In Settings > API Keys, revoke and regenerate.
5. **One key per environment.** Use separate keys for development and production.

## Scopes

API keys are scoped to control access:

| Scope | Purpose | Tools Granted |
|-------|---------|---------------|
| `mcp:read` | Read-only access to all data | list_leads, get_lead, list_campaigns, get_campaign_performance, get_creative_report, get_metrics, compare_performance, list_deals, get_attribution_journey, get_anomalies, get_budget_advice, get_sync_status, ask_diana |
| `mcp:write` | CRM write operations | create_lead, transition_lead, create_deal, trigger_sync |

MCP scopes are separate from REST API scopes (`leads:read`, `deals:write`, etc.). An MCP key cannot access REST API endpoints and vice versa.

Write tools require **both** `mcp:read` and `mcp:write` scopes. A key with only `mcp:write` will be rejected.

### Scope Enforcement

Scope checking happens at two levels:

1. **Symfony Security layer:** The API key authenticator validates the key and loads the User entity.
2. **Tool level:** Write tools explicitly check `$apiKey->hasScope('mcp:write')` before executing.

If a tool is called without the required scope, the server returns HTTP 403 Forbidden.

## Multi-Tenancy and Data Isolation

Every MCP request is bound to a single tenant. Cross-tenant data access is impossible by design.

### Triple Enforcement

| Layer | Mechanism | Description |
|-------|-----------|-------------|
| SQL | `WHERE tenant_id = ?` | Every repository query includes tenant filter |
| Doctrine | `TenantFilter` | Global ORM filter active on all entities |
| Tool | `$this->userResolver->getTenant()` | Every tool explicitly resolves and passes tenant |

### Isolation Guarantee

- A user's API key is bound to their tenant at creation time.
- The `McpUserResolverInterface` resolves the authenticated user and their tenant from the security token.
- Tools pass the tenant to every repository method. There is no `findAll()` without tenant -- it does not exist in the repository interfaces.
- Even if a user knows another tenant's UUID, the query will return no results because the tenant filter is applied at the SQL level.

## PII Masking

The MCP server enforces a strict PII invariant: **no personally identifiable information is ever returned in MCP responses.**

This is a design invariant, not a configurable option.

### What is NEVER Exposed

| Data | Reason |
|------|--------|
| Email addresses | PII -- direct identifier |
| Phone numbers | PII -- direct identifier |
| Social media handles | PII -- can identify individuals |
| Hashed PII (emailHash, nameHash, phoneHash) | Hashes are reversible with rainbow tables for common values |
| IP addresses | PII under GDPR |
| Social profiles (JSON) | May contain identifiers |

### What IS Exposed

| Data | Reason |
|------|--------|
| Lead UUID | Non-identifying internal identifier |
| Full name (firstName + lastName) | Necessary for human context; non-unique identifier |
| Lead status | Business state, not PII |
| Source label | Acquisition channel, not PII |
| Estimated revenue | Business metric |
| Timestamps (createdAt, updatedAt) | Operational data |
| Campaign names | Business label |
| Deal amounts and currency | Financial metric |
| Attribution data (touchpoints, credits) | Anonymized journey data |
| Ad performance metrics | Aggregated business data |

### Enforcement Mechanism

PII exclusion is enforced by **explicit field mapping** in every tool's `mapLead()`, `mapDeal()`, or equivalent method. There is no automatic entity serialization -- every field returned to the MCP client is deliberately chosen.

```php
// Example from ListLeadsTool -- notice what is included and what is NOT
private static function mapLead(Lead $lead): array
{
    return [
        'id' => $lead->getId()->toRfc4122(),
        'fullName' => $lead->getFullName(),
        'status' => $lead->getStatus()->value,
        'source' => $lead->getSourceLabel(),
        // NEVER included:
        // 'email' => $lead->getEmail(),
        // 'phone' => $lead->getPhone(),
        // 'emailHash' => $lead->getEmailHash(),
    ];
}
```

## Rate Limiting

Rate limits prevent abuse and protect shared infrastructure. They are implemented per API key using Symfony's sliding window rate limiter with Redis backing.

### Limits by Category

| Category | Limit | Window | Applies To |
|----------|-------|--------|------------|
| `mcp_read` | 60 requests | 1 minute | All 12 read tools |
| `mcp_diana` | 10 requests | 5 minutes | ask_diana only |
| `mcp_write` | 30 requests | 1 minute | create_lead, transition_lead, create_deal |
| `mcp_sync` | 5 requests | 1 hour | trigger_sync only |

### Rate Limit Response

When a limit is exceeded:

```
HTTP/1.1 429 Too Many Requests
Retry-After: 42
Content-Type: application/json

{
  "error": "rate_limit_exceeded",
  "message": "Rate limit exceeded. Retry after 42 seconds.",
  "retryAfter": 42
}
```

Most AI clients (Claude Code, Cursor) automatically respect the `Retry-After` header and retry transparently.

### Why Different Limits

- **Read tools (60/min):** AI agents are bursty -- a skill may chain 5-10 tool calls in rapid succession. 60/min accommodates this while preventing abuse.
- **Diana (10/5min):** Diana calls Claude Haiku internally. This limit prevents cost overruns and AI-calling-AI loops.
- **Write tools (30/min):** Lower than read to prevent accidental bulk operations (e.g., an agent creating 100 leads in a loop).
- **Sync (5/hour):** Syncs trigger external API calls to Meta/Google/TikTok. Too many syncs can exhaust platform rate limits.

## Circuit Breaker

The `ask_diana` tool is protected by a Redis-backed circuit breaker to prevent cascading failures when Diana's AI backend (Claude Haiku) is unavailable.

### State Machine

```
         normal operation
              |
              v
+--------+  5 consecutive  +---------+
| CLOSED | ---failures----> |  OPEN   |
+--------+                  +---------+
    ^                           |
    |                          30s cooldown
    |                           |
    |                           v
    |                     +-----------+
    +----success---------| HALF-OPEN |
                          +-----------+
                               |
                            failure
                               |
                               v
                          +---------+
                          |  OPEN   |
                          +---------+
```

### Parameters

| Parameter | Value |
|-----------|-------|
| Failure threshold | 5 consecutive failures |
| Failure window | 5 minutes |
| Cooldown period | 30 seconds |
| Half-open probes | 1 request |
| Storage | Redis (keyed per tenant) |
| Implementation | `McpCircuitBreaker` implements `CircuitBreakerInterface` |

### Behavior When Open

When the circuit breaker is open, `ask_diana` returns immediately without calling the AI backend:

```json
{
  "answer": "Diana is temporarily unavailable. Please try again in a moment.",
  "conversationId": null
}
```

This is not an error -- it is a graceful degradation. The rest of the MCP tools continue working normally.

## Prompt Injection Protection

The `ask_diana` tool tags all MCP-sourced questions with `source: "mcp"` in the DTO. This allows Diana's backend to:

1. Apply MCP-specific guardrails (e.g., refuse to execute commands).
2. Adapt response format for AI client consumption.
3. Sandbox the conversation separately from the web UI conversations.

Diana's backend also has its own prompt injection defenses (instruction hierarchy, output validation) which are not documented here as they are part of the main Metrikia platform.

## GDPR Considerations

### Data Processing

- **MCP tools do not process PII.** Emails, phones, and hashes are never transmitted to the AI client.
- **Names are exposed** for operational context. Under GDPR, names alone are contextual identifiers, not unique identifiers.
- **Anonymized leads** are marked with `isAnonymized: true`. Their name fields contain placeholder values after GDPR anonymization.

### Data Residency

- The MCP server runs on Railway EU West (Amsterdam).
- PostgreSQL with tenant data is hosted in EU.
- Redis (sessions, circuit breaker) is hosted in EU.
- API keys and authentication data are stored in EU.

### Right to Erasure

When a lead exercises their right to erasure:
1. `Lead::archive()` purges firstName, email, phone, and all hash fields.
2. The lead's `isAnonymized` field is set to true.
3. MCP tools will return the anonymized lead with placeholder data.
4. Attribution data is retained but de-linked from PII.

### Data Retention

- MCP sessions: 3600 seconds TTL in Redis.
- API keys: no automatic expiration (manual revocation).
- Anomaly data: 30 days rolling window.
- Performance data: retained per tenant retention policy.

## Incident Response

### Compromised API Key

1. Immediately revoke the key in Settings > API Keys.
2. Generate a new key with the same scopes.
3. Update the `METRIKIA_API_KEY` environment variable.
4. Review audit logs for unauthorized access.

### Suspicious Activity

Rate limiting and circuit breaker automatically mitigate most abuse patterns. If you suspect unauthorized access:

1. Revoke all API keys.
2. Contact support@metrikia.io with the suspected timeframe.
3. Metrikia can provide access logs for your tenant.

## Security Checklist

- [ ] `METRIKIA_API_KEY` is set in environment, not committed to source control
- [ ] API key has minimal required scopes (`mcp:read` only if write is not needed)
- [ ] API key is rotated at least quarterly
- [ ] No `.env` files containing the key are committed
- [ ] Team members use individual API keys, not shared keys
- [ ] Unused keys are revoked promptly
