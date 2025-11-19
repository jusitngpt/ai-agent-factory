# AI Agent Request Analysis - Troubleshooting Guide

**Workflow**: AI Agent Request Analysis
**Last Updated**: November 19, 2025

---

## Quick Diagnostics

### Is the workflow working?

**Check these 3 things first**:

1. **Workflow Active?**
   - In n8n, verify the workflow toggle is **ON** (green)

2. **Recent Execution?**
   - Check **Executions** tab for recent runs
   - Look for green (success) or red (error) indicators

3. **Airtable Records Updated?**
   - Check if `ICE Rating` field is being populated
   - If empty, workflow isn't running or is failing

---

## Common Issues & Solutions

### Issue 1: Workflow Not Triggering

**Symptoms**:
- No executions appearing in n8n
- Test records in Airtable not being analyzed
- No Slack notifications

**Possible Causes & Solutions**:

#### Cause A: Workflow Not Active
**Check**:
```
1. Open workflow in n8n
2. Look at top-right toggle
3. Should show "Active" (green)
```

**Solution**:
- Click toggle to activate workflow
- Status should change to "Active"

---

#### Cause B: Trigger Not Configured Correctly
**Check**:
```
1. Click "Airtable Trigger1" node
2. Verify "Base" and "Table" are correct
3. Verify "Trigger Field" is "Request Date"
```

**Solution**:
- Update Base ID and Table ID
- Ensure "Trigger Field" is set to the Created Time field
- Test trigger with "Execute Node"

---

#### Cause C: No New Records
**Check**:
```
The trigger only fires for NEW records created after workflow activation
```

**Solution**:
- Create a new test record in Airtable
- Wait for next hourly poll (or execute manually)
- Check Executions tab

---

#### Cause D: Polling Interval Too Long
**Check**:
```
Default polling: Every hour
If you created a record 10 minutes ago, may need to wait 50 more minutes
```

**Solution**:
- **Option A**: Wait for next poll cycle
- **Option B**: Execute workflow manually (faster testing)
- **Option C**: Adjust polling frequency:
  1. Click "Airtable Trigger1"
  2. Change "Poll Times" to "Every 5 minutes" (for testing)
  3. Remember to change back to hourly for production

---

### Issue 2: Execution Fails at Claude Node

**Symptoms**:
- Execution shows red X on "Message a model" node
- Error: "Unauthorized" or "Invalid API key"
- Error: "Rate limit exceeded"

**Possible Causes & Solutions**:

#### Cause A: Invalid API Key
**Check**:
```bash
# Test Claude API key directly
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: YOUR_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-sonnet-4-5-20250929",
    "messages": [{"role": "user", "content": "test"}],
    "max_tokens": 100
  }'
```

**Solution**:
- Go to Anthropic Console: https://console.anthropic.com/settings/keys
- Generate new API key
- Update n8n credential with new key

---

#### Cause B: Model Not Available
**Error**: "model_not_found"

**Check**:
```
Model ID in workflow: claude-sonnet-4-5-20250929
```

**Solution**:
- Check Anthropic docs for latest model ID
- Update "Message a model" node with current model
- Common model IDs:
  - `claude-sonnet-4-5-20250929` (latest)
  - `claude-sonnet-4-20250514`
  - `claude-3-5-sonnet-20241022`

---

#### Cause C: Rate Limit Exceeded
**Error**: "rate_limit_error"

**Check**:
```
Free tier limits:
- 50 requests/day
- 5 requests/minute
```

**Solution**:
- **Short-term**: Wait 1 minute, retry
- **Long-term**: Upgrade to paid tier
- **Workaround**: Reduce polling frequency

---

#### Cause D: Timeout
**Error**: "Timeout" or "ETIMEDOUT"

**Solution**:
- Claude responses typically take 4-8 seconds
- If timing out, check:
  1. Internet connection stable
  2. Anthropic status page: https://status.anthropic.com
  3. n8n execution timeout setting (default 1 hour, should be fine)
- Retry execution - usually transient issue

---

### Issue 3: Information Extractor Fails

**Symptoms**:
- Execution fails at "Information Extractor" node
- Error: "Failed to extract valid JSON"
- Empty output from extractor

**Possible Causes & Solutions**:

#### Cause A: Claude Response Doesn't Match Schema
**Check execution output**:
```
1. Open failed execution
2. Click "Message a model" node
3. Review Claude's output
4. Check if it follows expected format:
   ICE RATING: [...]
   REASON FOR ICE RATING: [...]
   RECOMMENDED AGENTIC WORKFLOW: [...]
```

**Solution**:
- Claude prompt may need adjustment
- Retry execution (Claude is usually consistent)
- If persistent, report issue with execution ID

---

#### Cause B: Gemini API Issues
**Error**: "Gemini API error" or "Invalid API key"

**Check**:
```bash
# Test Gemini API key
curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent?key=YOUR_KEY" \
  -H "Content-Type: application/json" \
  -d '{"contents":[{"parts":[{"text":"test"}]}]}'
```

**Solution**:
- Verify Gemini API key in n8n credentials
- Check Google AI Studio: https://makersuite.google.com/app/apikey
- Ensure API is enabled in Google Cloud project

---

#### Cause C: Schema Validation Fails
**Error**: "Output doesn't match schema"

**Solution**:
- Review JSON schema in Information Extractor node
- Ensure it matches expected Claude output format
- Schema should have 3 required properties:
  - `ice_rating` (enum)
  - `reason_for_ice_rating` (string)
  - `recommended_workflow` (string)

---

### Issue 4: Airtable Update Fails

**Symptoms**:
- Execution fails at "Update record" node
- Error: "Record not found"
- Error: "Invalid field value"
- Error: "Unauthorized"

**Possible Causes & Solutions**:

#### Cause A: Record ID Mismatch
**Error**: "Record recXXXXXX not found"

**Check**:
```
Expression in "Update record" node:
id: ={{ $('Airtable Trigger1').item.json.id }}
```

**Solution**:
- Verify expression is correct
- Ensure it references the trigger node correctly
- Node name must match exactly (case-sensitive)

---

#### Cause B: Field Name Mismatch
**Error**: "Field 'XYZ' not found"

**Check**:
```
Airtable field names must match exactly (case-sensitive):
- "ICE Rating" (correct)
- "ICE rating" (wrong - lowercase 'r')
```

**Solution**:
- Go to Airtable base
- Verify exact field names
- Update field mappings in "Update record" node
- Match case exactly

---

#### Cause C: Field Type Mismatch
**Error**: "Invalid value for field 'XYZ'"

**Common scenarios**:
```
- Trying to write text to a number field
- Trying to write number to a select field
```

**Solution**:
- Check field types in Airtable schema
- Ensure workflow output matches field type
- Example: `ICE Rating` should be Single Line Text, not Single Select

---

#### Cause D: Permission Issues
**Error**: "Unauthorized" or "Forbidden"

**Check**:
```
1. Airtable Personal Access Token permissions
2. Token must have:
   - data.records:read
   - data.records:write
   - Access to specific base
```

**Solution**:
- Go to https://airtable.com/create/tokens
- Review token permissions
- Add missing scopes
- Add base access if missing
- Update token in n8n credentials

---

### Issue 5: Slack Notification Fails

**Symptoms**:
- Execution fails at "Send a message" node
- Error: "channel_not_found"
- Error: "not_in_channel"
- No Slack message received

**Possible Causes & Solutions**:

#### Cause A: Channel Not Found
**Error**: "channel_not_found"

**Check**:
```
Channel ID in workflow: C09TPD4DEFQ
Your channel ID: ??? (need to verify)
```

**Solution**:
1. Go to Slack channel
2. Click channel name → "View channel details"
3. Scroll down, copy Channel ID
4. Update "Send a message" node with correct ID

---

#### Cause B: Bot Not In Channel
**Error**: "not_in_channel"

**Solution**:
1. Go to `#new-agent-requests` channel in Slack
2. Type: `/invite @Katalon Agent Factory`
   (Replace with your bot name)
3. Confirm invitation
4. Retry workflow execution

---

#### Cause C: Missing Permissions
**Error**: "missing_scope: chat:write"

**Solution**:
1. Go to https://api.slack.com/apps
2. Select your app
3. Go to "OAuth & Permissions"
4. Under "Scopes", add:
   - `chat:write`
   - `chat:write.public`
5. Reinstall app to workspace
6. Update n8n credential with new token

---

#### Cause D: Invalid Token
**Error**: "invalid_auth" or "token_revoked"

**Solution**:
1. Go to https://api.slack.com/apps
2. Select your app
3. Go to "OAuth & Permissions"
4. Copy the "Bot User OAuth Token"
5. Update n8n Slack credential with new token
6. Test connection

---

### Issue 6: Incomplete Analysis

**Symptoms**:
- Workflow executes successfully
- But ICE Rating is empty or incorrect
- Or Reason for ICE Rating is truncated

**Possible Causes & Solutions**:

#### Cause A: Claude Response Truncated
**Check**:
```
1. Open execution
2. Click "Message a model"
3. Check output token count
4. If near max_tokens limit, response may be cut off
```

**Solution**:
- Increase `max_tokens` parameter in Claude node
- Default: 4096
- Suggested: 8192 (for longer responses)

---

#### Cause B: Request Description Too Long
**Issue**: If request description is >2000 words, may exceed token limits

**Solution**:
- Ask users to keep descriptions concise
- Add character limit guidance in Airtable form
- Suggested max: 1000 words per field

---

#### Cause C: Airtable Field Size Limit
**Issue**: Airtable Long Text fields have 100,000 character limit

**Check**:
```
If workflow output exceeds limit, Airtable truncates
```

**Solution**:
- This is rarely an issue (Claude responses are usually <10,000 chars)
- If it occurs, review prompt to reduce verbosity

---

### Issue 7: Workflow Runs Multiple Times

**Symptoms**:
- Same request analyzed multiple times
- Multiple Slack notifications for one request
- Duplicate Airtable updates

**Possible Causes & Solutions**:

#### Cause A: Trigger Field Changed
**Issue**: If "Request Date" field is edited, it may retrigger

**Solution**:
- Use "Created Time" field type (auto-populated, never changes)
- Don't use formula fields or manually edited date fields

---

#### Cause B: Workflow Saved During Execution
**Issue**: Saving workflow while running can cause duplicate executions

**Solution**:
- Don't save workflow while executions are in progress
- Wait for execution to complete before making changes

---

### Issue 8: High Costs

**Symptoms**:
- Monthly API costs higher than expected
- Should be <$0.50/month for ~20 requests
- But seeing $5-$10+ costs

**Possible Causes & Solutions**:

#### Cause A: Excessive Polling
**Check**:
```
Trigger set to poll every minute instead of hourly
Every minute = 43,200 polls/month
Hourly = 720 polls/month
```

**Solution**:
- Change polling to hourly for production
- Use more frequent polling only for testing

---

#### Cause B: Long Claude Responses
**Check**:
```
Average tokens per request:
Input: 800-1200 tokens (~$0.003)
Output: 300-500 tokens (~$0.003-$0.005)
Total: ~$0.006 per request
```

**If costs are higher**:
```
- Check execution logs for token counts
- May need to shorten prompt
- Or reduce max_tokens parameter
```

---

#### Cause C: Failed Retries
**Check**:
```
n8n automatic retries can increase costs
If Claude fails 3 times per request:
Cost = 3x normal
```

**Solution**:
- Investigate why executions are failing
- Fix root cause to avoid retry costs

---

## Debugging Procedures

### Procedure 1: Trace Execution Flow

When workflow fails, follow the data:

```
Step 1: Check Airtable Trigger
→ Did it fetch the record?
→ Are all fields populated?

Step 2: Check Claude Analysis
→ Did Claude respond?
→ Is response complete?
→ Does it follow the expected format?

Step 3: Check Information Extractor
→ Did Gemini parse the response?
→ Is JSON structure correct?
→ Are all required fields present?

Step 4: Check Airtable Update
→ Did update succeed?
→ Are fields populated in Airtable?

Step 5: Check Slack Notification
→ Did message send?
→ Is it in the correct channel?
```

---

### Procedure 2: Test Individual Nodes

You can test nodes independently:

```
1. Click any node
2. Click "Execute Node" button
3. Review output
4. Fix any issues
5. Repeat for next node
```

**Note**: Some nodes require data from previous nodes
- Use "Execute Previous Nodes" option to get data

---

### Procedure 3: Enable Detailed Logging

```
1. Go to Workflow Settings
2. Enable:
   - Save Execution Progress
   - Save Manual Executions
   - Save Data (Success)
   - Save Data (Error)
3. This provides detailed execution history
```

---

### Procedure 4: Review Execution JSON

For advanced debugging:

```
1. Open failed execution
2. Click "Execution Data" tab
3. Review raw JSON for each node
4. Look for unexpected data or errors
```

---

## Error Messages Reference

### Airtable Errors

| Error | Meaning | Solution |
|-------|---------|----------|
| `INVALID_REQUEST_BODY` | Malformed API request | Check field mappings |
| `INVALID_VALUE_FOR_COLUMN` | Wrong data type | Check field types match |
| `NOT_FOUND` | Base/Table/Record not found | Verify IDs |
| `UNAUTHORIZED` | Invalid token or permissions | Check Personal Access Token |
| `RATE_LIMIT_EXCEEDED` | Too many requests | Wait and retry |

### Claude Errors

| Error | Meaning | Solution |
|-------|---------|----------|
| `invalid_api_key` | API key is wrong or missing | Update credential |
| `model_not_found` | Invalid model ID | Update to current model |
| `rate_limit_error` | Too many requests | Wait or upgrade plan |
| `overloaded_error` | Anthropic servers busy | Retry in a few seconds |
| `timeout` | Request took too long | Retry, usually transient |

### Gemini Errors

| Error | Meaning | Solution |
|-------|---------|----------|
| `invalid_api_key` | API key is wrong | Update credential |
| `permission_denied` | API not enabled | Enable in Google Cloud |
| `resource_exhausted` | Quota exceeded | Check Google Cloud quotas |
| `unavailable` | Service temporarily down | Retry in a minute |

### Slack Errors

| Error | Meaning | Solution |
|-------|---------|----------|
| `channel_not_found` | Invalid channel ID | Update with correct ID |
| `not_in_channel` | Bot not invited to channel | Invite bot with `/invite` |
| `missing_scope` | Permission not granted | Add OAuth scopes |
| `invalid_auth` | Token is invalid | Update with new token |

---

## Performance Issues

### Issue: Workflow Takes >30 Seconds

**Normal execution**: 8-12 seconds
**If taking longer**:

**Check**:
```
1. Claude API response time (usually 4-8 sec)
2. Gemini API response time (usually 2-3 sec)
3. Network latency
```

**Solutions**:
- Usually transient, retry
- Check Anthropic/Google status pages
- If persistent, may be regional networking issue

---

### Issue: Workflow Times Out

**Timeout setting**: 3600 seconds (1 hour)
**Should never timeout unless**:

**Causes**:
```
- API completely unresponsive
- Network issues
- n8n server issues
```

**Solution**:
- Check n8n logs
- Verify internet connectivity
- Check API status pages

---

## Getting Help

### Before Asking for Help

Collect this information:

1. **Execution ID**: Found in Executions tab
2. **Error Message**: Exact error text
3. **Node That Failed**: Which node shows red X
4. **What You've Tried**: Steps already attempted
5. **Workflow Version**: Check workflow settings
6. **n8n Version**: Check n8n settings

### Where to Get Help

1. **KAF Documentation**:
   - README.md - Overview
   - N8N-WORKFLOW.md - Technical details
   - IMPLEMENTATION-GUIDE.md - Setup help

2. **n8n Community**:
   - Forum: https://community.n8n.io
   - Discord: https://discord.gg/n8n

3. **API Documentation**:
   - Anthropic: https://docs.anthropic.com
   - Google Gemini: https://ai.google.dev/docs
   - Airtable: https://airtable.com/developers/web/api
   - Slack: https://api.slack.com/docs

---

## Preventive Maintenance

### Weekly Checks

- [ ] Review execution history
- [ ] Check error rate (<5% is normal)
- [ ] Verify Slack notifications arriving
- [ ] Spot-check ICE rating accuracy

### Monthly Checks

- [ ] Review API costs
- [ ] Audit ICE scores vs. actual outcomes
- [ ] Update prompt if needed
- [ ] Check for n8n updates
- [ ] Verify all credentials still valid

### Quarterly Checks

- [ ] Full workflow audit
- [ ] Review and update documentation
- [ ] Analyze usage patterns
- [ ] Plan improvements

---

## Known Limitations

### Current Constraints

1. **Hourly Polling**: Requests analyzed every hour (not instant)
2. **No Batching**: Processes one request at a time
3. **No Historical Context**: Doesn't consider previous agents
4. **Manual Review Required**: Claude scores should be validated
5. **Single Language**: English only (can be extended)

### Workarounds

- **For faster response**: Reduce polling interval or use webhooks
- **For batch processing**: n8n Pro supports parallel execution
- **For context**: Add lookup node to query past agents

---

## Changelog of Common Fixes

### November 2025
- Initial troubleshooting guide created
- Based on expected common issues

*This section will be updated with actual issues encountered in production*

---

**Last Updated**: November 19, 2025
**Guide Version**: 1.0
**Workflow Version**: 1.0.0

---

**Still having issues?** Create a detailed bug report with execution ID and error message.
