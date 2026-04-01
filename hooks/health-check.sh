#!/usr/bin/env bash
set -euo pipefail

CONTEXT_FILE="${CLAUDE_PLUGIN_ROOT}/hooks/session-context.md"

# 1. Check METRIKIA_API_KEY is set
if [ -z "${METRIKIA_API_KEY:-}" ]; then
  cat <<'MSG'
# Metrikia Plugin — Configuration Required

`METRIKIA_API_KEY` is not set. The Metrikia MCP tools will not work.

## Setup

1. Generate an API key at https://app.metrikia.io/app/settings?group=advanced&section=api-webhooks (scope: `mcp:read`)
2. Add to your shell profile:

```bash
export METRIKIA_API_KEY="mk_live_your_key_here"
```

3. Restart Claude Code
MSG
  exit 0
fi

# 2. Check curl availability
if ! command -v curl &> /dev/null; then
  cat "$CONTEXT_FILE"
  echo ""
  echo "> **Note:** \`curl\` not found — MCP connectivity check skipped. Install curl for automatic verification."
  exit 0
fi

# 3. Check MCP server connectivity
HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}" --max-time 3 \
  -H "Authorization: Bearer ${METRIKIA_API_KEY}" \
  "https://mcp.metrikia.io/api/v1/mcp" 2>/dev/null) || HTTP_STATUS="000"

case "$HTTP_STATUS" in
  2*)
    # Success — inject session context
    cat "$CONTEXT_FILE"
    ;;
  401|403)
    cat <<'MSG'
# Metrikia Plugin — Authentication Failed

Your `METRIKIA_API_KEY` is invalid or has insufficient scopes.

## Fix

1. Verify your key at https://app.metrikia.io/app/settings?group=advanced&section=api-webhooks
2. Ensure the key has at least `mcp:read` scope
3. Update the environment variable and restart Claude Code
MSG
    ;;
  *)
    # Timeout, network error, or unexpected status
    cat "$CONTEXT_FILE"
    echo ""
    echo "> **Warning:** Metrikia MCP server unreachable (HTTP $HTTP_STATUS). Tools may fail. Check your network connection."
    ;;
esac

exit 0
