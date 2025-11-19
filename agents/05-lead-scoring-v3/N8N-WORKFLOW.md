# Agent 5 Lead Scoring V3 - n8n Workflow

## Workflow ID: SUAWI4IOqnU62yhJ

## Node Architecture (10 Nodes)

```
[1] Airtable Trigger → [2] Extract Lead Data → [3] Build Scoring Prompt
→ [4] Gemini Analysis → [5] Extract JSON → [6] Calculate Final Score
→ [7] Determine Routing → [8] Update Airtable → [9] Slack Notification → [10] Error Handler
```

---

## Key Nodes

### Node 1: Airtable Trigger
**Type:** `n8n-nodes-base.airtableTrigger`
**Config:**
```json
{
  "event": "recordCreated",
  "table": "Leads",
  "polling": 30000  // Poll every 30 seconds
}
```

### Node 3: Build Scoring Prompt
**Type:** `n8n-nodes-base.code`
**Prompt Structure:**
```
Analyze this lead and provide scoring:

**Lead Info:**
- Name: {{name}}
- Email: {{email}}
- Company: {{company}}
- Role: {{job_title}}
- Company Size: {{company_size}}
- Industry: {{industry}}
- Form Source: {{form_source}}
- Message: {{message}}
- Website: {{company_website}}

**Scoring Criteria (0-100):**
1. Company Fit (0-25): Industry, size, tech stack match
2. Role Fit (0-20): Decision-making authority
3. Intent Signals (0-20): Urgency, keywords, form type
4. Engagement (0-10): Activity level
5. Geographic Fit (0-10): Target market
6. Budget Indicators (0-10): Funding, team size
7. Strategic Value (0-5): Brand, growth, expansion potential

**Output JSON:**
{
  "company_fit_score": 0-25,
  "role_fit_score": 0-20,
  "intent_score": 0-20,
  "engagement_score": 0-10,
  "geo_fit_score": 0-10,
  "budget_score": 0-10,
  "strategic_score": 0-5,
  "key_signals": ["signal1", "signal2"],
  "recommended_actions": ["action1", "action2"],
  "talking_points": ["point1", "point2"],
  "red_flags": ["flag1", "flag2"]
}
```

### Node 4: Gemini Analysis
**Type:** `@n8n/n8n-nodes-langchain.lmChatGoogleGemini`
**Config:**
```json
{
  "modelName": "gemini-2.0-flash-exp",
  "temperature": 0.3,
  "maxOutputTokens": 2000
}
```

### Node 6: Calculate Final Score
**Type:** `n8n-nodes-base.code`
```javascript
const scores = $json;
const totalScore =
  scores.company_fit_score +
  scores.role_fit_score +
  scores.intent_score +
  scores.engagement_score +
  scores.geo_fit_score +
  scores.budget_score +
  scores.strategic_score;

return {json: {...scores, lead_score: totalScore}};
```

### Node 7: Determine Routing
**Type:** `n8n-nodes-base.switch`
**Routing Logic:**
```
Score >= 75: Enterprise (Route 1)
Score 50-74: SMB (Route 2)
Score < 50: Nurture (Route 3)
```

### Node 8: Update Airtable
**Fields Updated:**
```json
{
  "Lead Score": "={{$json.lead_score}}",
  "Routing": "={{$json.routing}}",
  "Company Fit": "={{$json.company_fit_score}}",
  "Role Fit": "={{$json.role_fit_score}}",
  "Intent Score": "={{$json.intent_score}}",
  "Key Signals": "={{$json.key_signals.join(', ')}}",
  "Recommended Actions": "={{$json.recommended_actions.join('\n')}}",
  "Talking Points": "={{$json.talking_points.join('\n')}}",
  "Status": "Scored",
  "Scored At": "={{$now}}"
}
```

### Node 9: Slack Notification (Conditional)
**Condition:** `lead_score >= 50`
**Template:**
```
🎯 New Lead Scored: {{lead_score}}/100

**{{company}}** - {{name}}
{{role}} | {{company_size}} employees

**Top Signals:**
{{key_signals[0]}}
{{key_signals[1]}}

**Routing:** {{routing}}
**Next Action:** {{recommended_actions[0]}}

View: [Airtable Link]
```

---

## Performance

- **Execution Time:** 15-30 seconds
- **Cost per Lead:** $0.02-$0.04
- **Success Rate:** 99%+

---

**Last Updated:** 2025-11-19
