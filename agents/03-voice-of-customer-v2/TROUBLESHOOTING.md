# Agent-3 Voice of Customer V2 - Troubleshooting Guide

## Common Issues

### 1. "Not Enough Recent Reviews Found"

**Symptoms:** Perplexity returns limited data, themes are sparse

**Causes:**
- Review platforms changed URLs
- Few recent reviews available
- Search recency too narrow (6 months)

**Solutions:**
1. **Expand search window:**
   ```
   Node 5 → searchRecencyFilter: "month:6" → "month:12"
   ```

2. **Verify review URLs active:**
   - Click each URL in Node 2
   - Ensure pages load and show reviews
   - Update if URLs changed

3. **Add more platforms:**
   ```javascript
   review_platforms: {
     g2: "...",
     capterra: "...",
     trustradius: "...",
     getapp: "...",  // Add GetApp
     software_advice: "..."  // Add Software Advice
   }
   ```

---

### 2. Perplexity Timeout (Node 5)

**Symptoms:** Node fails after 60+ seconds, timeout error

**Solutions:**
1. **Increase node timeout:**
   ```
   Node 5 → Settings → Timeout: 120000ms (2 minutes)
   ```

2. **Reduce max tokens:**
   ```
   Node 5 → maxTokens: 5000 → 3500
   ```

3. **Simplify prompt:**
   - Remove example sections
   - Focus on essential data only
   - Reduce from 5 research dimensions → 3

---

### 3. Low Analysis Confidence Scores

**Symptoms:** Key Metrics → analysis_confidence = "Low" or "Medium"

**Causes:**
- Insufficient review data
- Review URLs incorrect
- Competitor has very few reviews

**Solutions:**
1. **Verify data quality in Perplexity output:**
   ```
   Check execution log → Node 5 output
   → Look for: "No reviews found" or similar
   ```

2. **Improve competitor metadata:**
   ```javascript
   // Node 2: Add more context
   {
     name: "Competitor",
     review_platforms: {...},
     category: "Specific Category",
     target_audience: "Detailed Audience",
     alternative_names: ["Alt Name 1", "Alt Name 2"]  // Add this
   }
   ```

3. **Enhance Perplexity prompt:**
   - Add more specific questions
   - Request quantitative data explicitly
   - Ask for review count validation

---

### 4. Gemini Safety Filter Blocks Content

**Symptoms:** "Content blocked by safety filter" error at Node 6

**Solutions:**
1. **Adjust safety settings:**
   ```json
   Node 6 → Add parameter:
   "safetySettings": [
     {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_ONLY_HIGH"},
     {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_ONLY_HIGH"}
   ]
   ```

2. **Sanitize competitor names:**
   ```javascript
   // If competitor name triggers filter
   // Use generic reference in prompt
   "Competitor: Tool A" instead of actual name
   ```

---

### 5. JSON Parsing Errors (Node 7)

**Symptoms:** Information Extractor fails, "Invalid JSON" error

**Solutions:**
1. **Add JSON cleanup node before Node 7:**
   ```javascript
   let text = $input.item.json.output;
   text = text.replace(/```json\n?/g, '');
   text = text.replace(/```\n?/g, '');
   const match = text.match(/\{[\s\S]*\}/);
   return {json: {cleaned: match ? match[0] : text}};
   ```

2. **Strengthen Gemini prompt:**
   ```
   Add to end of Node 6 prompt:
   "CRITICAL: Return ONLY the JSON object.
   No markdown code blocks.
   No text before { or after }.
   Ensure all quotes properly escaped."
   ```

---

### 6. Airtable "Field Not Found" (Node 8)

**Symptoms:** Node 8 fails with "Unknown field name: X"

**Solutions:**
1. **Verify field names match exactly:**
   ```
   Airtable field: "Positive Themes (JSON)"
   Node 8 mapping:  "Positive Themes (JSON)"  // Must match case
   ```

2. **Refresh Airtable fields:**
   ```
   Node 8 → Click "Refresh Fields" button
   → Reloads schema from Airtable
   ```

---

### 7. High API Costs

**Symptoms:** Monthly bill >$5 instead of ~$1.50

**Causes:**
- Workflow running more than monthly
- Testing with large token limits
- Multiple workflow versions active

**Solutions:**
1. **Audit execution frequency:**
   ```
   n8n → Executions → Filter last 30 days
   → Should see ~1 execution
   → If more: Check for duplicate active workflows
   ```

2. **Reduce token limits:**
   ```
   Node 5: maxTokens 5000 → 3500
   Node 6: maxOutputTokens 8000 → 6000
   ```

3. **Set budget alerts:**
   ```
   Perplexity: Settings → Billing → Alert at $3
   Google Cloud: Budgets & alerts → $5/month
   ```

---

### 8. Workflow Takes Too Long (>40 minutes)

**Symptoms:** Execution exceeds 40 minutes for 5 competitors

**Target:** 20-30 minutes total

**Solutions:**
1. **Optimize Perplexity:**
   - maxTokens: 5000 → 3500 (faster)
   - Reduce prompt length
   - Remove non-essential questions

2. **Optimize Gemini:**
   - maxOutputTokens: 8000 → 6000
   - Simplify output structure (fewer fields)

3. **Check for delays:**
   - Remove unnecessary Wait nodes
   - Verify no rate limit delays

---

### 9. Missing Slack Notifications

**Symptoms:** Workflow succeeds but no Slack message

**Solutions:**
1. **Verify bot in channel:**
   ```
   Slack → #voice-of-customer → Members
   → Check bot present
   → If not: /invite @bot-name
   ```

2. **Check channel ID:**
   ```
   Node 10 → Channel field
   → Must be ID (C01XXX...) not name (#channel)
   ```

3. **Refresh OAuth:**
   ```
   n8n → Credentials → Slack OAuth2
   → Click "Reconnect"
   → Re-authorize
   ```

---

### 10. Competitor-Specific Failures

**Symptoms:** Workflow succeeds for 4 competitors, fails on 1 specific competitor

**Solutions:**
1. **Check competitor data:**
   ```javascript
   // Node 2: Verify this competitor's object
   {
     name: "Problematic Competitor",
     review_platforms: {
       g2: "VALID_URL?",  // Test each URL manually
       capterra: "VALID_URL?",
       trustradius: "VALID_URL?"
     }
   }
   ```

2. **Test competitor individually:**
   ```javascript
   // Temporarily set Node 2 to only this competitor
   competitors: [
     { /* problematic competitor only */ }
   ]
   ```

3. **Check for special characters:**
   - Competitor name has quotes, apostrophes
   - URLs have special encoding
   - Sanitize data

---

## Error Code Reference

| Error | Node | Meaning | Quick Fix |
|-------|------|---------|-----------|
| 401 | 5 or 6 | Invalid API key | Verify Perplexity/Gemini key |
| 403 | 6 or 8 | Permission denied | Check Gemini API enabled, Airtable token scopes |
| 404 | 8 | Base/table not found | Verify Base ID, Table Name |
| 429 | 5 or 6 | Rate limit | Add retry with backoff, reduce frequency |
| 500 | 5 or 6 | API server error | Retry, check service status |
| 504 | 5 | Timeout | Reduce tokens, increase timeout setting |

---

## Emergency Procedures

### Workflow Completely Broken

1. **Deactivate immediately:**
   ```
   n8n → Agent-3 VOC V2 → Toggle to Inactive
   ```

2. **Find last working version:**
   ```
   n8n → Executions → Find last successful
   → Note date/time
   → Export that version if available
   ```

3. **Reimport clean workflow:**
   ```
   Import from: /workflows/agent-3-voice-of-customer-v2.json
   Reconfigure credentials
   Test with 1 competitor
   ```

---

## Getting Help

**Before requesting support, gather:**
- Error message (exact text)
- Node that failed
- Execution ID
- Competitor that caused failure (if specific)
- Recent changes made

**Support Channels:**
- Katalon team: Internal support
- n8n Community: https://community.n8n.io/
- GitHub: Open issue in ai-agent-factory repo

---

**Last Updated:** 2025-11-19
**Status:** ✅ Production Ready
