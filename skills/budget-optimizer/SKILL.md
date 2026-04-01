---
name: budget-optimizer
description: Optimize ad budget allocation across platforms and campaigns using MTA attribution data and Diana AI recommendations
---

# Budget Optimizer

Optimize budget allocation across platforms and campaigns.

## Process

1. **Current allocation**
   - Call `get_metrics` for current period
   - Call `get_campaign_performance` for top 10 campaigns by spend

2. **Attribution-based analysis**
   - Call `get_budget_advice` for MTA-enriched recommendations
   - This uses multi-touch attribution to identify where budget actually drives conversions

3. **What-if scenarios**
   - Call `ask_diana`: "If I shift 20% of budget from [lowest ROAS platform] to [highest ROAS platform], what's the expected impact?"

4. **Anomaly check**
   - Call `get_anomalies` to identify any spend anomalies before reallocating

## Output Format

### Current Budget Allocation
Platform breakdown: Spend | Revenue | ROAS | % of Budget

### MTA-Based Recommendations
Diana's reallocation suggestions with expected impact

### Risk Assessment
Anomalies or concerns to address before changes

### Action Plan
Step-by-step reallocation instructions with specific amounts
