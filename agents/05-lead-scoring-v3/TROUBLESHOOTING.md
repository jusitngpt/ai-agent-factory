# Agent 5 Lead Scoring V3 - Troubleshooting

## Common Issues

### 1. Lead Not Being Scored

**Symptoms:** New record in Airtable, but no score appears

**Causes & Solutions:**

1. **Workflow not active**
   - Check: n8n → Workflows → Agent 5 status
   - Fix: Toggle to "Active"

2. **Airtable trigger not polling**
   - Check: Node 1 → Polling interval
   - Fix: Ensure polling enabled, interval = 30s

3. **Table/view mismatch**
   - Check: Node 1 → Table name matches exactly
   - Fix: Update table name, verify case-sensitive match

4. **Required fields missing**
   - Check: Lead has minimum required fields (name, email, company)
   - Fix: Ensure form captures required data

---

### 2. Scores Seem Inaccurate

**Symptoms:** All leads getting high/low scores, not differentiated

**Causes & Solutions:**

1. **Scoring weights need adjustment**
   - Check: Node 3 prompt scoring criteria
   - Fix: Adjust weights to match your ICP
   ```
   Example: If targeting enterprise, increase company size weight
   ```

2. **Gemini temperature too high/low**
   - Check: Node 4 → Temperature setting
   - Fix: Should be 0.3-0.4 for consistency
   - Too high (>0.5): Scores vary wildly
   - Too low (<0.2): Scores cluster narrowly

3. **Insufficient lead data**
   - Check: How many fields are populated?
   - Fix: Enhance form to capture more data
   - Add: Company website, phone, detailed message

---

### 3. No Slack Notifications

**Symptoms:** Leads scored, but no Slack alerts

**Solutions:**

1. **Score below threshold**
   - Check: Node 9 condition → Score >= 50?
   - Fix: Lower threshold or check why scores low

2. **Bot not in channel**
   - Fix: `/invite @bot-name` in Slack channel

3. **Channel ID incorrect**
   - Check: Node 9 → Channel field
   - Fix: Must be ID (C01XXX...) not name (#channel)
   - Get ID: Right-click channel → Copy link → Extract ID

4. **OAuth token expired**
   - Check: n8n → Credentials → Slack OAuth2
   - Fix: Click "Reconnect" → Re-authorize

---

### 4. Gemini API Errors

**Error 403: Permission Denied**
- Check: API key valid, Gemini API enabled in Google Cloud
- Fix: Regenerate key, enable Generative Language API

**Error 429: Quota Exceeded**
- Cause: Too many leads in short time
- Fix: Request quota increase in Google Cloud Console
- Workaround: Add delay between leads (Wait node)

**Error 400: Safety Filter**
- Cause: Lead message contains flagged content
- Fix: Adjust safety settings to BLOCK_ONLY_HIGH
- Workaround: Sanitize message field before analysis

---

### 5. Workflow Takes Too Long

**Symptoms:** >60 seconds to score a lead

**Target:** 15-30 seconds

**Solutions:**

1. **Reduce Gemini max tokens**
   - Node 4 → maxOutputTokens: 2000 → 1500

2. **Simplify prompt**
   - Node 3 → Remove non-essential questions
   - Focus on core scoring factors only

3. **Check Airtable API response time**
   - Node 8 → Monitor execution time
   - Slow? Contact Airtable support

---

### 6. High API Costs

**Symptoms:** Gemini costs >$0.05 per lead

**Expected:** $0.02-$0.04 per lead

**Solutions:**

1. **Reduce output tokens**
   - Node 4 → maxOutputTokens: 2000 → 1000
   - Still get quality scores with less verbose output

2. **Check for duplicate executions**
   - n8n → Executions → Look for duplicates
   - Fix: Ensure only one workflow active

3. **Set budget alerts**
   - Google Cloud Console → Billing → Budgets
   - Alert at $50/month

---

### 7. Routing Incorrect

**Symptoms:** High-value leads going to nurture, or vice versa

**Solutions:**

1. **Review routing logic**
   - Node 7 → Verify threshold values
   - Adjust based on your sales capacity

2. **Validate scoring**
   - Manually review 10 leads
   - Check if scores align with sales team assessment
   - Refine Node 3 prompt based on feedback

3. **Test edge cases**
   ```
   Create test leads:
   - Perfect fit (should score 90+)
   - Bad fit (should score <30)
   - Borderline (50-60 range)
   ```

---

### 8. JSON Extraction Fails

**Symptoms:** Node 5 (Information Extractor) error

**Causes:**

1. **Gemini output not valid JSON**
   - Check: Node 4 output in execution log
   - Fix: Strengthen prompt → "Return ONLY valid JSON, no markdown"

2. **Schema mismatch**
   - Check: Node 5 schema matches Node 3 expected structure
   - Fix: Align schema with prompt

3. **Unexpected fields**
   - Fix: Add JSON cleanup node before Node 5:
   ```javascript
   let text = $json.output;
   text = text.replace(/```json\n?/g, '');
   text = text.replace(/```/g, '');
   return {json: JSON.parse(text)};
   ```

---

## Error Code Reference

| Code | Meaning | Quick Fix |
|------|---------|-----------|
| 401 | Gemini API key invalid | Verify key, regenerate if needed |
| 403 | Permission denied | Enable Gemini API in Google Cloud |
| 429 | Rate limit exceeded | Request quota increase |
| 500 | API server error | Retry, check Google Cloud status |

---

## Emergency Procedures

### Workflow Broken - Immediate Actions

1. **Pause Airtable trigger**
   - Node 1 → Disable polling
   - Prevents more failures

2. **Switch to manual scoring**
   - Sales team scores leads temporarily
   - Export unscored leads from Airtable

3. **Restore from backup**
   - Reimport: `/workflows/agent-5-lead-scoring-v3.json`
   - Reconfigure credentials
   - Test with 1 lead before activating

---

## Getting Help

**Before requesting support:**
- Error message (exact text)
- Lead data that caused error
- Execution ID from n8n
- Recent workflow changes

**Support:**
- Katalon team: Internal support
- n8n Community: https://community.n8n.io/
- GitHub: ai-agent-factory issues

---

**Last Updated:** 2025-11-19
**Status:** ✅ Production Ready
