---
name: campaign-audit
description: Deep audit of a specific campaign — performance metrics, creative breakdown, attribution journey, and optimization recommendations
---

# Campaign Audit

Perform a deep audit of a specific campaign.

## Prerequisites
Ask the user which campaign to audit. Use `list_campaigns` to show available campaigns if needed.

## Process

1. **Campaign performance**
   - Call `get_campaign_performance` with the campaignId and last 30 days
   - Call `compare_performance` for the same campaign to see trends

2. **Creative breakdown**
   - Call `get_creative_report` filtered by campaign
   - Identify top and underperforming creatives

3. **Lead quality**
   - Call `list_leads` to find leads attributed to this campaign
   - For key leads, call `get_attribution_journey` to see the full path

4. **Ask Diana**
   - Call `ask_diana`: "Audit campaign [name]: what's working, what's not, and what should I change?"

## Output Format

### Campaign Overview
Key metrics: Spend, Revenue, ROAS, CRM ROAS, CPL, CPC, CTR

### Creative Performance Matrix
Table of all creatives ranked by efficiency

### Attribution Insights
How leads from this campaign convert — journey patterns, time to conversion

### Optimization Recommendations
Actionable next steps: scale, pause, or iterate

Be specific with numbers. Don't just say "good" — say "3.2x ROAS vs 2.1x benchmark."
