# Agent 5 Lead Scoring V3 - Implementation Guide

## Quick Setup (45 minutes)

### Step 1: Airtable Setup (15 min)

1. **Create Leads table** with these fields:
   - Input: Name, Email, Company, Job Title, Company Size, Industry, Message, Form Source
   - Output: Lead Score, Routing, scoring breakdowns, recommendations

2. **Configure Single Selects:**
   - Company Size: 1-10, 11-50, 51-200, 201-500, 501-1000, 1000+
   - Industry: SaaS, E-commerce, Financial Services, Healthcare, etc.
   - Form Source: Demo Request, Contact Sales, Free Trial, etc.
   - Routing: Enterprise, SMB, Nurture
   - Status: New, Scored, Contacted, Qualified, Lost

3. **Create Personal Access Token:**
   - Scopes: `data.records:read`, `data.records:write`
   - Note Base ID and Table ID

### Step 2: Slack Setup (10 min)

1. Create channels:
   - `#high-priority-leads` (Enterprise, score 75+)
   - `#smb-leads` (SMB, score 50-74)

2. Create Slack app with OAuth bot token
3. Add scopes: `chat:write`, `channels:read`
4. Install to workspace, invite bot to channels

### Step 3: n8n Configuration (15 min)

1. **Import workflow:** `/workflows/agent-5-lead-scoring-v3.json`

2. **Configure credentials:**
   - Airtable API (Node 1, 8)
   - Google Gemini API (Node 4)
   - Slack OAuth2 (Node 9)

3. **Update Node 3:** Customize scoring criteria for your ICP

4. **Update Node 7:** Adjust routing thresholds if needed

5. **Update Node 9:** Set Slack channel IDs

6. **Activate workflow**

### Step 4: Test (5 min)

1. **Create test lead in Airtable:**
   ```
   Name: Test Lead
   Email: test@example.com
   Company: Acme Corp
   Job Title: VP Engineering
   Company Size: 201-500 employees
   Industry: SaaS/Software
   Message: "Need to replace Selenium ASAP"
   Form Source: Demo Request
   ```

2. **Verify:**
   - Lead scored within 30 seconds
   - Score appears in Airtable (should be 70-85)
   - Routing assigned correctly
   - Slack notification sent (if score >= 50)

3. **Check quality:**
   - Scoring breakdown makes sense?
   - Recommendations relevant?
   - Talking points accurate?

---

## Customization

### Adjust Scoring Weights

**Edit Node 3 prompt to match your ICP:**

```javascript
// Example: If you target enterprise more
"Company Fit (0-30):" // Increased from 25
"Role Fit (0-25):"    // Increased from 20
"Intent (0-15):"      // Decreased from 20
```

### Modify Routing Thresholds

**Edit Node 7 (Switch):**

```javascript
// Default:
Score >= 75: Enterprise
Score 50-74: SMB
Score < 50: Nurture

// Custom (more aggressive enterprise routing):
Score >= 65: Enterprise  // Lowered from 75
Score 40-64: SMB         // Lowered from 50
Score < 40: Nurture      // Lowered from 50
```

---

## Integration with Forms

### Website Form → Airtable

**Option 1: Airtable Form (simplest)**
- Create Airtable form view
- Embed on website
- Auto-creates records → triggers workflow

**Option 2: Zapier/Make.com**
- Website form (Webflow, WordPress, etc.)
- Zapier/Make → Airtable
- Triggers workflow

**Option 3: API Integration**
- Form submission → POST to Airtable API
- Direct integration, most control

---

## Monitoring

**Daily:**
- Check Slack for notifications
- Spot-check scored leads for accuracy

**Weekly:**
- Review scoring distribution (too many/few high scores?)
- Check execution success rate
- Monitor API costs

**Monthly:**
- Analyze lead score vs conversion correlation
- Refine scoring criteria based on learnings
- Update ICP if market changes

---

## Troubleshooting Quick Fixes

| Issue | Solution |
|-------|----------|
| Lead not scored | Check Airtable trigger polling interval |
| Score seems off | Review Gemini prompt, adjust weights |
| No Slack notification | Verify bot in channel, score threshold |
| High API costs | Reduce maxOutputTokens in Node 4 |

---

## Success Criteria

✅ Leads scored within 60 seconds of creation
✅ 95%+ execution success rate
✅ Scoring accuracy validated by sales team
✅ Cost < $0.05 per lead
✅ 30% faster response time vs manual

---

**Setup Time:** 45 minutes
**Monthly Maintenance:** 1 hour
**ROI:** 99% cost reduction vs manual

**Last Updated:** 2025-11-19
