# Troubleshooting Guide
## Agent-1B V4: Multi-Feed RSS Monitor

This guide covers common issues, error messages, and solutions for Agent-1B V4 deployment and operation.

---

## Quick Diagnostic Checklist

Before diving into specific issues, run this quick check:

- [ ] n8n workflow is "Active" (toggle switch is ON)
- [ ] All 4 credentials are configured and saved
- [ ] RSS feed URLs are valid and accessible
- [ ] Airtable Base ID and Table ID are correct
- [ ] Slack channel exists and bot is invited
- [ ] Test execution completed successfully at least once

---

## Issue Categories

1. [Workflow Not Executing](#1-workflow-not-executing)
2. [RSS Feed Errors](#2-rss-feed-errors)
3. [AI Analysis Failures](#3-ai-analysis-failures)
4. [Airtable Errors](#4-airtable-errors)
5. [Slack Notification Failures](#5-slack-notification-failures)
6. [Performance Issues](#6-performance-issues)
7. [Data Quality Problems](#7-data-quality-problems)
8. [Cost/Billing Issues](#8-costbilling-issues)

---

## 1. Workflow Not Executing

### Issue 1.1: Workflow Never Runs Automatically

**Symptoms**:
- Workflow is "Active" but no executions in history
- No Slack notifications received
- No new Airtable records

**Possible Causes**:

#### Cause A: Schedule Trigger Not Configured
**Check**:
1. Click "Schedule Trigger - Every 24 Hours" node
2. Verify "Interval" is set (not empty)

**Solution**:
- Set interval to 24 hours or desired frequency
- Save workflow
- Deactivate and reactivate workflow

#### Cause B: Workflow Was Never Activated
**Check**:
- Look at top-right toggle - is it "Active" (green) or "Inactive" (gray)?

**Solution**:
- Click "Active" toggle
- Confirm activation
- First execution will occur after interval (e.g., 24 hours)

#### Cause C: n8n Service Not Running
**Check** (self-hosted):
```bash
systemctl status n8n  # Linux
# or
docker ps | grep n8n  # Docker
```

**Solution**:
- Restart n8n service
- Check n8n logs for errors

---

### Issue 1.2: Manual Execution Works, Scheduled Doesn't

**Symptoms**:
- "Execute Workflow" button works fine
- Scheduled trigger never fires

**Possible Causes**:

#### Cause A: Workflow Deactivated After Test
**Solution**:
- Ensure "Active" toggle is ON after manual testing

#### Cause B: Timezone Mismatch
**Check**:
- Workflow settings → Timezone is UTC
- Your expected execution time matches UTC

**Solution**:
- Convert your desired local time to UTC
- Or change workflow timezone setting to your local timezone

---

### Issue 1.3: Execution Starts But Stops Immediately

**Symptoms**:
- Execution appears in history
- Status shows "Error" or "Stopped"
- No data processed

**Possible Causes**:

#### Cause A: Filter Returns No Results
**Check**:
- Look at "Filter New Posts (24h)" node execution
- Output shows 0 items

**Reason**: No blog posts published in last 24 hours (normal for low-activity competitors)

**Solution**: Not an error - workflow is working correctly. Wait for next competitor post.

**Verification**:
- Manually check competitor blog - last post date
- If recent post exists but wasn't caught, check filter date logic

#### Cause B: Error in Early Node
**Check**:
- Click failed node (red X)
- Read error message

**Solution**: See specific error sections below

---

## 2. RSS Feed Errors

### Issue 2.1: "Error fetching RSS feed"

**Error Message**:
```
The resource you are trying to access is not reachable
```

**Possible Causes**:

#### Cause A: Invalid Feed URL
**Check**:
- Open feed URL in browser
- Should display XML content, not HTML page

**Solution**:
- Fix URL typo
- Or find correct RSS feed URL (see IMPLEMENTATION-GUIDE.md Step 1.2)

#### Cause B: Feed Temporarily Down
**Check**:
- Try again in 10 minutes
- Check if competitor website is accessible

**Solution**:
- If persistent, contact competitor or use RSS feed service (FetchRSS)
- Loop will continue to next competitor

#### Cause C: Rate Limiting / Blocked
**Check**:
- Competitor blocking automated requests

**Solution**:
- Use RSS feed proxy service (FetchRSS, Feed43)
- Add delay between feed fetches (edit loop node)

---

### Issue 2.2: "No pubDate field found"

**Error Message**:
```
Cannot read property 'pubDate' of undefined
```

**Cause**: RSS feed doesn't include standard `pubDate` field

**Solution**:
1. Edit "Filter New Posts" node
2. Change expression to use alternative date field:
```javascript
// Try these alternatives:
$json.isoDate
$json.updated
$json.published
```
3. Or remove filter entirely (processes all posts - may cause duplicates)

---

### Issue 2.3: "Invalid XML"

**Error Message**:
```
XML parsing error
```

**Cause**: Malformed XML in RSS feed

**Solution**:
1. Validate feed at https://validator.w3.org/feed/
2. If errors, use RSS proxy service to clean feed
3. Contact competitor to fix feed (unlikely to help)

---

## 3. AI Analysis Failures

### Issue 3.1: "Gemini API Error: Invalid API Key"

**Error Message**:
```
Authentication error: API key not valid
```

**Cause**: Google Gemini API key is incorrect or expired

**Solution**:
1. Go to https://aistudio.google.com/app/apikey
2. Verify API key is active
3. Copy key again
4. In n8n: Credentials → Edit "Google Gemini API" → Paste new key → Save
5. Test workflow again

---

### Issue 3.2: "Gemini API Error: Quota Exceeded"

**Error Message**:
```
Resource exhausted: Quota exceeded for quota metric
```

**Cause**: Exceeded Google Cloud free tier or quota limits

**Solution**:
1. Go to Google Cloud Console → APIs & Services → Quotas
2. Check Gemini API usage
3. Options:
   - **Wait**: Quotas reset daily/monthly
   - **Upgrade**: Enable billing for higher limits
   - **Reduce**: Monitor fewer competitors

**Temporary Workaround**:
- Deactivate workflow until quota resets
- Reduce execution frequency (48-hour interval instead of 24)

---

### Issue 3.3: "Gemini API Error: Timeout"

**Error Message**:
```
Request timeout after 30000ms
```

**Cause**: Very long blog post exceeding processing time

**Solution**:
1. Edit "Message a model" node
2. Add timeout option:
```json
{
  "timeout": 60000  // 60 seconds instead of 30
}
```
3. Or let HTTP Request Tool fetch content (it may excerpt automatically)

---

### Issue 3.4: "Information Extractor: Invalid JSON"

**Error Message**:
```
Failed to extract valid JSON from response
```

**Cause**: AI didn't return properly formatted JSON

**Solution**:
1. Review "Message a model" output
2. Check if AI returned markdown code blocks (```json...```) instead of raw JSON
3. Edit system prompt to emphasize:
```
CRITICAL: Output ONLY raw JSON. No markdown, no code blocks, no explanations.
```
4. Or add preprocessing node to strip markdown code fences

---

## 4. Airtable Errors

### Issue 4.1: "Base not found"

**Error Message**:
```
Could not find base with ID appXXXXXXXXXXXXXX
```

**Cause**: Base ID is incorrect or credential doesn't have access

**Solution**:
1. Verify Base ID:
   - Open Airtable base
   - Check URL: `https://airtable.com/appXXXXXXXXXXXXXX/...`
   - Copy Base ID (starts with `app`)
2. Update "Create RSS Feed Item" node → Base field
3. Verify credential has access:
   - Airtable → Developer hub → Personal access tokens
   - Edit token → Check base is in "Access" list

---

### Issue 4.2: "Table not found"

**Error Message**:
```
Could not find table with ID tblXXXXXXXXXXXXXX
```

**Cause**: Table ID incorrect or table was renamed/deleted

**Solution**:
1. Verify Table ID:
   - URL when viewing table: `https://airtable.com/app.../tblXXXXXXXXXXXXXX/...`
2. Ensure table is named exactly "RSS Feed Items"
3. Update "Create RSS Feed Item" node → Table field

---

### Issue 4.3: "Field 'X' not found"

**Error Message**:
```
Unknown field name: "Priority Score"
```

**Cause**: Field name in n8n doesn't match Airtable exactly (case-sensitive)

**Solution**:
1. Open Airtable → RSS Feed Items table
2. Check exact field name (including capitalization, spaces)
3. Update field mapping in "Create RSS Feed Item" node
4. Common mistakes:
   - "priority score" vs "Priority Score" (case matters)
   - Extra spaces: "Priority Score " vs "Priority Score"
   - Similar names: "Priority" vs "Priority Score"

---

### Issue 4.4: "Invalid value for field 'X'"

**Error Message**:
```
Invalid value for field "Strategic Value". Must be one of: High, Medium, Low, None
```

**Cause**: Sending value not in Multiple Select options

**Solution**:
1. Check Airtable field options
2. Ensure AI outputs exact match (case-sensitive)
3. Edit Information Extractor schema to enforce enum values:
```json
{
  "strategic_value": {
    "type": "string",
    "enum": ["High", "Medium", "Low", "None"]  // Exact matches
  }
}
```

---

### Issue 4.5: "Required field 'X' missing"

**Error Message**:
```
Field "Competitor" is required but was not provided
```

**Cause**: Field marked as required in Airtable, but workflow sends null/empty

**Solution**:
1. Check if source data exists (e.g., competitor name in loop variable)
2. Add fallback value:
```javascript
{{ $json.currentCompetitor || 'Unknown' }}
```
3. Or make field optional in Airtable (not recommended)

---

## 5. Slack Notification Failures

### Issue 5.1: "Channel not found"

**Error Message**:
```
Channel not found: C09TXR2N0CC
```

**Cause**: Channel ID is wrong or bot was removed from channel

**Solution**:
1. Verify bot is in channel:
   - In Slack, go to channel
   - Type `/invite @KAF Agent-1B`
2. Double-check Channel ID:
   - Channel details → Copy Channel ID
   - Update "Slack Notification" node

---

### Issue 5.2: "Insufficient Permissions"

**Error Message**:
```
not_in_channel or missing scope: chat:write
```

**Cause**: Bot lacks required permissions or not in channel

**Solution**:
1. Check Slack app scopes:
   - https://api.slack.com/apps → Your App → OAuth & Permissions
   - Verify scopes: `chat:write`, `channels:read`
2. Reinstall app to workspace if scopes added
3. Invite bot to channel: `/invite @KAF Agent-1B`

---

### Issue 5.3: "Messages Sent But Not Visible"

**Symptoms**:
- Workflow succeeds
- No error
- But no message appears in Slack

**Cause**: Bot posting to wrong channel (e.g., private channel or DM)

**Solution**:
1. Check n8n execution output for Slack node
2. Verify `channel` field in response
3. Update channel ID in node configuration

---

## 6. Performance Issues

### Issue 6.1: Workflow Takes Too Long (>5 minutes)

**Symptoms**:
- Execution doesn't complete
- Times out

**Possible Causes**:

#### Cause A: Too Many Competitors
**Check**: Monitoring more than 10 competitors?

**Solution**:
- Reduce to 5-7 competitors per workflow
- Deploy multiple workflow instances for more competitors

#### Cause B: Many New Posts to Process
**Check**: Execution log shows processing 20+ posts

**Solution**: Normal if competitor posts frequently. Options:
- Increase execution timeout: Workflow settings → Timeout → 7200 seconds (2 hours)
- Or run workflow more frequently (every 12 hours) to process fewer posts per run

#### Cause C: Slow API Responses
**Check**: Gemini or Airtable calls taking >30 seconds each

**Solution**:
- Check Google Cloud status page
- Check Airtable status page
- Retry execution later

---

### Issue 6.2: Duplicate Records in Airtable

**Symptoms**:
- Same blog post appears multiple times in Airtable

**Cause**: Filter not working correctly, reprocessing old posts

**Solution**:
1. Check "Filter New Posts" node
2. Verify date comparison logic
3. Add deduplication check:
   - Before creating Airtable record, search for existing record with same Post URL
   - Use Airtable "Search" node
   - Only create if not exists

**Quick Fix** (Manual):
1. In Airtable, add filter: Post URL (is not empty)
2. Group by Post URL
3. Delete duplicates manually

---

## 7. Data Quality Problems

### Issue 7.1: Research Result is Empty or Generic

**Symptoms**:
- "Research Result" field has minimal content
- AI analysis is not insightful

**Possible Causes**:

#### Cause A: RSS Feed Has No Content
**Check**: "Full Content" field in Airtable is empty or very short

**Solution**:
- HTTP Request Tool should fetch full article
- Verify HTTP Request Tool is connected to "Message a model" as AI Tool
- Test manually: Open Post URL, check if content is accessible

#### Cause B: AI Prompt Needs Refinement
**Solution**:
1. Edit "Message a model" system prompt
2. Add more specific instructions:
```
Focus analysis on:
- Specific product features mentioned
- Technical implementation details
- Target customer segments
- Pricing signals
- Competitive positioning statements
```

#### Cause C: Article Content is Paywalled / Login-Required
**Check**: Open Post URL - does it require login?

**Solution**: Not much can be done automatically. Options:
- Manual review
- Use web scraping service
- Focus on competitors with open blogs

---

### Issue 7.2: Priority Scores Always Same Value

**Symptoms**:
- All posts get Priority Score of 50 or 0

**Cause**: Information Extractor not parsing priority_score correctly

**Solution**:
1. Check "Information Extractor" output
2. Verify `priority_score` is a number, not string
3. Update schema:
```json
{
  "priority_score": {
    "type": "number",  // Not "string"
    "minimum": 0,
    "maximum": 100
  }
}
```

---

### Issue 7.3: Categories Always Empty

**Symptoms**:
- "Categories" field in Airtable is blank

**Cause**: AI returns categories as array, Airtable expects specific format

**Solution**:
1. Check Airtable "Categories" field options
2. Ensure exact match between AI output and Airtable options
3. Verify Information Extractor schema enforces valid options:
```json
{
  "categories": {
    "type": "array",
    "items": {
      "type": "string",
      "enum": [
        "Product Launch",
        "Feature Update",
        "Company News",
        "Technical",
        "Customer Story",
        "Industry Insights",
        "Thought Leadership"
      ]
    }
  }
}
```

---

## 8. Cost/Billing Issues

### Issue 8.1: Unexpected High Gemini Costs

**Symptoms**:
- Google Cloud bill higher than expected

**Possible Causes**:

#### Cause A: Processing Old Posts on First Run
**Explanation**: First execution may process many historical posts

**Solution**:
- Expected: First run may cost $0.50-$1.00
- Subsequent runs: ~$0.24/month
- If concerned, adjust filter to last 7 days on first run, then 24 hours

#### Cause B: Very Long Articles
**Check**: Token usage in execution logs

**Solution**:
- Monitor token usage per request
- If consistently high (>10,000 tokens), consider:
  - Article excerpting (first 2,000 words)
  - Cheaper model for initial filtering, premium for high-priority

---

### Issue 8.2: Airtable Over Free Tier Limit

**Symptoms**:
- Airtable warns about record limits (1,200 on free tier)

**Solution**:
1. Archive old records (>90 days)
2. Move to "Archive" table
3. Or upgrade to Airtable Plus ($10/user/month)

---

## 9. Advanced Debugging

### Enable Verbose Logging

1. Workflow settings → Execution order → "Debug mode"
2. Run workflow
3. Check detailed execution logs for each node

### Test Individual Nodes

1. Click node to select
2. Click "Execute Node" (play button)
3. Review input/output data
4. Identify where data transformation breaks

### Check n8n Server Logs

Self-hosted n8n:
```bash
# Check recent logs
journalctl -u n8n -n 100 --no-pager

# Follow logs in real-time
journalctl -u n8n -f
```

Docker:
```bash
docker logs n8n -f
```

---

## Getting Additional Help

### Before Asking for Help

Gather this information:
1. **Error message** (exact text)
2. **Node name** where error occurred
3. **Input data** to that node (from execution panel)
4. **Expected vs actual behavior**
5. **Screenshots** (if helpful)

### Support Channels

1. **n8n Community**: https://community.n8n.io/
2. **Airtable Community**: https://community.airtable.com/
3. **Google Gemini Support**: https://ai.google.dev/support
4. **GitHub Issues**: (for KAF workflow-specific issues)

---

## Error Reference Quick Lookup

| Error Message (Excerpt) | Issue Section | Quick Fix |
|-------------------------|---------------|-----------|
| "Base not found" | 4.1 | Check Base ID |
| "Table not found" | 4.2 | Check Table ID |
| "Field not found" | 4.3 | Check field name matches exactly |
| "Invalid API key" | 3.1 | Regenerate Gemini API key |
| "Quota exceeded" | 3.2 | Enable billing or wait for reset |
| "Channel not found" | 5.1 | Invite bot to Slack channel |
| "not_in_channel" | 5.2 | `/invite @bot` in Slack |
| "XML parsing error" | 2.3 | Use RSS proxy service |
| "Request timeout" | 3.3 | Increase timeout value |
| "Invalid JSON" | 3.4 | Fix AI prompt, emphasize JSON only |

---

## Preventive Maintenance

### Weekly Checks

- [ ] Review execution history for failures
- [ ] Check API costs in Google Cloud
- [ ] Verify Slack notifications arriving

### Monthly Checks

- [ ] Validate all RSS feeds still accessible
- [ ] Review Airtable storage usage
- [ ] Update competitor list if needed
- [ ] Archive old Airtable records (>60 days)

### Quarterly Checks

- [ ] Review and rotate API keys (security)
- [ ] Analyze cost trends
- [ ] Optimize workflow based on usage patterns
- [ ] Update AI prompts for better analysis

---

**Troubleshooting Guide Version**: 1.0
**Last Updated**: November 19, 2025
**Maintained By**: KAF Team

**Still stuck?** Create a detailed issue report with error messages and node execution data for further assistance.
