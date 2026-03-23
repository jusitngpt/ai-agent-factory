# Agent-3 Voice of Customer V2 - Implementation Guide

## Quick Start (60-75 minutes)

### Step 1: Airtable Setup (20 min)
1. Create base: "Katalon Agent Factory"
2. Create table: "Competitor VOC Analysis"
3. Add 27 fields from schema (see AIRTABLE-SCHEMA.md)
4. Create Personal Access Token with write permissions
5. Note Base ID and Table ID

### Step 2: Slack Setup (10 min)
1. Create channel: #voice-of-customer
2. Create Slack app with bot token
3. Add scopes: chat:write, channels:read
4. Install to workspace
5. Invite bot to channel

### Step 3: API Credentials (15 min)
1. **Perplexity:** Get API key from perplexity.ai/settings/api
2. **Gemini:** Get API key from makersuite.google.com/app/apikey
3. **Airtable:** Personal Access Token from Step 1
4. **Slack:** Bot token from Step 2

### Step 4: n8n Configuration (15 min)
1. Import workflow JSON: `/workflows/agent-3-voice-of-customer-v2.json`
2. Add credentials:
   - Perplexity API (Node 5)
   - Google Gemini API (Node 6)
   - Airtable API (Node 8)
   - Slack OAuth2 (Node 10)
3. Update Node 2: Competitor array with your review URLs
4. Update Node 8: Base ID and Table Name
5. Update Node 10: Slack channel ID

### Step 5: Test Execution (20 min)
1. Disable schedule trigger (test manually)
2. Reduce to 1 competitor in Node 2
3. Execute workflow
4. Verify:
   - Perplexity completes (~90s)
   - Gemini completes (~120s)
   - Airtable record created
   - Slack notification sent
5. Check data quality in Airtable
6. Restore full competitor list

### Step 6: Activate (5 min)
1. Re-enable monthly schedule (1st at 10 AM)
2. Activate workflow
3. Verify next execution date

---

## Competitor List Configuration

### Node 2: Review Platform URLs

**How to find review URLs:**

**G2:**
```
1. Go to g2.com
2. Search for competitor name
3. Click on their product page
4. Navigate to "Reviews" tab
5. Copy full URL (e.g., https://www.g2.com/products/TOOL-NAME/reviews)
```

**Capterra:**
```
1. Go to capterra.com
2. Search for competitor
3. Product page URL format: https://www.capterra.com/p/{ID}/{TOOL-NAME}/
4. Reviews are on same page
```

**TrustRadius:**
```
1. Go to trustradius.com
2. Search for competitor
3. Navigate to Reviews section
4. Copy URL: https://www.trustradius.com/products/TOOL-NAME/reviews
```

**Update Node 2:**
```javascript
{
  name: "Your Competitor",
  review_platforms: {
    g2: "ACTUAL_G2_URL",
    capterra: "ACTUAL_CAPTERRA_URL",
    trustradius: "ACTUAL_TRUSTRADIUS_URL"
  },
  category: "Tool Category",
  target_audience: "Primary Users"
}
```

---

## Cost Management

**Expected Monthly Cost:**
- Perplexity: ~$0.60 (5 competitors × $0.12)
- Gemini: ~$0.90 (5 competitors × $0.18)
- **Total: ~$1.50/month**

**If costs too high:**
1. Reduce to 3 competitors (save 40%)
2. Change to quarterly schedule (save 66%)
3. Reduce max tokens in nodes 5 & 6

---

## Troubleshooting Quick Fixes

| Issue | Quick Fix |
|-------|-----------|
| "Not enough reviews found" | Expand search from 6 months → 12 months in Node 5 |
| Perplexity timeout | Reduce maxTokens: 5000 → 3500 |
| Gemini safety block | Adjust safety settings to BLOCK_ONLY_HIGH |
| Low confidence scores | Verify review URLs are correct and active |
| Slack not_in_channel | Re-invite bot: `/invite @bot-name` |

---

## Success Criteria

✅ Workflow executes monthly without errors
✅ All 5 competitors analyzed each month
✅ Airtable records complete with themes and recommendations
✅ Analysis confidence consistently "High"
✅ Team reviews insights within 1 week

---

**Estimated Total Setup Time:** 60-75 minutes
**Monthly Maintenance:** 10-15 minutes
**ROI:** 96-97% cost savings vs manual analysis

**Full details:** See complete sections in this guide

**Last Updated:** 2025-11-19
