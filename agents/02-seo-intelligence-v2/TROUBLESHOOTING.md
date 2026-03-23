# Agent-2 SEO Intelligence V2 - Troubleshooting Guide

## Overview

This guide provides solutions to common issues encountered when running Agent-2 SEO Intelligence V2. Issues are organized by category with symptoms, causes, and step-by-step resolution procedures.

**Quick Reference:**
- [Workflow Execution Issues](#1-workflow-execution-issues)
- [Perplexity API Errors](#2-perplexity-api-errors)
- [Gemini API Errors](#3-gemini-api-errors)
- [Airtable Integration Errors](#4-airtable-integration-errors)
- [Slack Notification Failures](#5-slack-notification-failures)
- [Data Quality Issues](#6-data-quality-issues)
- [Performance and Timeout Issues](#7-performance-and-timeout-issues)
- [Cost and Billing Issues](#8-cost-and-billing-issues)

---

## 1. Workflow Execution Issues

### 1.1 Workflow Not Triggering on Schedule

**Symptoms:**
- Workflow doesn't execute on Monday 9 AM as expected
- No execution logs for scheduled time
- Slack notifications not received on schedule

**Possible Causes:**
- Workflow not activated
- Trigger node configured incorrectly
- Timezone mismatch
- n8n instance not running (self-hosted)

**Resolution Steps:**

1. **Check Workflow Active Status:**
   ```
   n8n → Workflows → Agent-2 SEO Intelligence V2
   → Verify toggle shows "Active" (not "Inactive")
   ```
   - If inactive, click toggle to activate

2. **Verify Schedule Trigger Configuration:**
   ```
   Click Node 1 (Schedule Trigger)
   → Check:
   - Mode: "Every Week"
   - Day: Monday
   - Hour: 9
   - Minute: 0
   - Timezone: [Your timezone]
   ```

3. **Check Timezone Settings:**
   ```
   Compare:
   - Schedule trigger timezone
   - n8n instance timezone
   - Your local timezone
   ```
   - Common issue: Trigger set to UTC but expecting local time
   - Solution: Set trigger timezone explicitly

4. **Verify n8n Instance Running (Self-Hosted):**
   ```bash
   # Check if n8n is running
   ps aux | grep n8n

   # Check logs for errors
   journalctl -u n8n -f

   # Restart if needed
   systemctl restart n8n
   ```

5. **Check Execution Queue:**
   ```
   n8n → Executions → Check for any "Waiting" status
   ```
   - If executions queued, check queue settings
   - Increase concurrency if needed

**Verification:**
- Manual test: Click "Execute Workflow" to verify it runs
- Check next scheduled execution time in workflow list
- Monitor for next scheduled execution

**Prevention:**
- Set calendar reminder for expected execution time
- Configure n8n monitoring/alerts
- Use n8n Cloud (99.9% uptime) if self-hosting unreliable

---

### 1.2 Workflow Fails Immediately

**Symptoms:**
- Workflow execution starts but fails within seconds
- Error shown on Node 1 or Node 2
- No data passes to subsequent nodes

**Possible Causes:**
- Syntax error in competitor array (Node 2)
- Invalid JSON structure
- Missing required fields in competitor data

**Resolution Steps:**

1. **Check Node 2 (Competitor Array Setup):**
   ```javascript
   // Common syntax errors:

   // ❌ Missing comma between objects
   {
     name: "Selenium"
   }
   {
     name: "Cypress"
   }

   // ✅ Correct
   {
     name: "Selenium"
   },
   {
     name: "Cypress"
   }

   // ❌ Trailing comma in array
   competitors: [
     {...},
     {...},  // ← Remove this comma
   ]

   // ✅ Correct
   competitors: [
     {...},
     {...}   // ← No comma on last item
   ]
   ```

2. **Validate JSON Structure:**
   - Copy code from Node 2
   - Paste into JSON validator: https://jsonlint.com/
   - Fix any syntax errors reported

3. **Verify Required Fields:**
   ```javascript
   // Each competitor must have:
   {
     name: "string",              // ✅ Required
     website: "url",              // ✅ Required
     focus_areas: ["array"],      // ✅ Required
     primary_keywords: ["array"], // ✅ Required
     content_hub: "url"           // ✅ Required
   }
   ```

4. **Check for Special Characters:**
   ```javascript
   // ❌ Unescaped quotes
   name: "Competitor's Name"

   // ✅ Escaped quotes
   name: "Competitor\'s Name"
   // OR
   name: "Competitor's Name"  // Use smart quotes
   ```

5. **Test with Minimal Data:**
   ```javascript
   // Temporarily use single competitor
   return [{
     json: {
       competitors: [{
         name: "Test",
         website: "https://example.com/",
         focus_areas: ["test"],
         primary_keywords: ["test keyword"],
         content_hub: "https://example.com/blog/"
       }],
       analysis_date: new Date().toISOString(),
       analysis_type: "weekly_seo_intelligence"
     }
   }];
   ```

**Verification:**
- Execute workflow with test data
- Verify Node 2 shows success (green checkmark)
- Check output data contains competitor array
- Restore full competitor list once working

---

### 1.3 Workflow Fails Partway Through Loop

**Symptoms:**
- First 1-2 competitors processed successfully
- Workflow fails on 3rd or 4th competitor
- Inconsistent failure (different competitor each time)

**Possible Causes:**
- API rate limiting (Perplexity or Gemini)
- Timeout on specific competitor research
- Transient API errors
- Memory issues (n8n instance)

**Resolution Steps:**

1. **Check Execution Logs:**
   ```
   n8n → Executions → Find failed execution
   → Click to view details
   → Identify which node failed
   → Read error message
   ```

2. **Identify Pattern:**
   - Does it always fail on same competitor?
   - Does it fail at same node?
   - What time does it fail?

3. **If Random Competitor Fails:**
   - Likely API rate limit or transient error
   - **Solution:** Enable retries on API nodes
   ```
   Node 5 (Perplexity):
   Settings → Retry On Fail → Enable
   - Max Retries: 3
   - Retry Interval: 5000ms
   - Backoff: Exponential

   Node 6 (Gemini):
   Settings → Retry On Fail → Enable
   - Max Retries: 3
   - Retry Interval: 3000ms
   - Backoff: Exponential
   ```

4. **If Same Competitor Always Fails:**
   - Competitor data may have issues
   - **Solution:** Check competitor object
   ```javascript
   // Verify:
   - Valid URL format (https://)
   - No special characters in name
   - Content hub URL accessible
   - Focus areas and keywords not empty
   ```

5. **Add Delays Between Loop Iterations:**
   ```
   Add "Wait" node after Node 8 (Airtable)
   - Duration: 5-10 seconds
   - Prevents API rate limits
   - Only needed if hitting limits
   ```

6. **Check API Status:**
   - Perplexity: https://status.perplexity.ai/
   - Google Cloud: https://status.cloud.google.com/
   - Check for ongoing incidents

**Verification:**
- Re-run workflow with retries enabled
- Monitor execution for all competitors
- Check API dashboards for error rates

---

## 2. Perplexity API Errors

### 2.1 Authentication Failed (401 Error)

**Symptoms:**
- Node 5 (Perplexity) fails immediately
- Error: "401 Unauthorized" or "Invalid API key"
- No research data generated

**Resolution Steps:**

1. **Verify API Key:**
   ```
   n8n → Credentials → Perplexity API
   → Check API key format:
   - Should start with "pplx-"
   - No extra spaces or characters
   ```

2. **Get Fresh API Key:**
   ```
   Go to: https://www.perplexity.ai/settings/api
   → Generate new API key
   → Copy entire key
   → Update n8n credential
   ```

3. **Test API Key Directly:**
   ```bash
   curl https://api.perplexity.ai/chat/completions \
     -H "Authorization: Bearer pplx-YOUR_KEY" \
     -H "Content-Type: application/json" \
     -d '{
       "model": "sonar-pro",
       "messages": [{"role": "user", "content": "test"}]
     }'
   ```
   - Should return valid response, not 401

4. **Check API Key Permissions:**
   - Ensure key has access to `sonar-pro` model
   - Verify account is not restricted
   - Check API key hasn't been revoked

**Prevention:**
- Store API key in password manager
- Set reminder to rotate key quarterly
- Monitor Perplexity email for security alerts

---

### 2.2 Rate Limit Exceeded (429 Error)

**Symptoms:**
- Node 5 fails with "429 Too Many Requests"
- Error message mentions rate limit
- Occurs on 2nd or 3rd competitor

**Perplexity Rate Limits:**
- Free tier: 20 requests/minute
- Paid tier: Varies by plan
- Burst limit: 5 concurrent requests

**Resolution Steps:**

1. **Reduce Request Frequency:**
   ```
   Add "Wait" node after Node 8
   → Duration: 10 seconds
   → Delays next loop iteration
   ```

2. **Enable Retries with Backoff:**
   ```
   Node 5 (Perplexity):
   → Retry On Fail: ✅ Enable
   → Max Retries: 3
   → Retry Interval: 10000ms (10 seconds)
   → Backoff: Exponential (10s, 20s, 40s)
   ```

3. **Reduce Competitor Count:**
   - Temporarily process 3 competitors instead of 5
   - Run workflow twice per week instead of once

4. **Upgrade Perplexity Plan:**
   ```
   Check current plan: perplexity.ai/settings/billing
   → Upgrade to higher tier for increased limits
   ```

5. **Batch Process:**
   ```
   Split competitor list into 2 workflows:
   - Workflow A: Competitors 1-3 (Monday 9 AM)
   - Workflow B: Competitors 4-5 (Monday 10 AM)
   ```

**Verification:**
- Check Perplexity dashboard for rate limit stats
- Monitor execution logs for 429 errors
- Verify retries succeed on second attempt

---

### 2.3 Model Not Available (400 Error)

**Symptoms:**
- Error: "Model sonar-pro not found"
- 400 Bad Request error
- Execution fails at Node 5

**Resolution Steps:**

1. **Check Model Name:**
   ```
   Node 5 (Perplexity) → Model parameter
   → Should be exactly: "sonar-pro"
   → Not: "sonar", "sonar-small", "sonar-medium"
   ```

2. **Verify API Access:**
   - Sonar Pro requires paid Perplexity account
   - Check your plan includes Pro access
   - Upgrade if needed: perplexity.ai/settings/billing

3. **Try Alternative Model (Temporary):**
   ```
   Change to "sonar" (standard, cheaper)
   → Quality may be lower
   → Use as temporary workaround
   → Upgrade account when possible
   ```

4. **Check Perplexity Service Status:**
   - Visit: https://status.perplexity.ai/
   - Verify Sonar Pro is operational
   - Check for scheduled maintenance

**Prevention:**
- Maintain active Perplexity subscription
- Set calendar reminder before billing renewal
- Monitor Perplexity announcements for model changes

---

### 2.4 Request Timeout (504 Error)

**Symptoms:**
- Node 5 takes 60+ seconds then fails
- Error: "Gateway Timeout" or "Request timeout"
- Happens inconsistently

**Resolution Steps:**

1. **Increase Node Timeout:**
   ```
   Node 5 (Perplexity):
   → Settings → Timeout
   → Set to: 120000ms (2 minutes)
   ```

2. **Reduce Prompt Length:**
   ```
   Edit Perplexity prompt in Node 5
   → Remove example sections
   → Shorten instructions
   → Keep under 1,000 tokens
   ```

3. **Reduce Max Tokens:**
   ```
   Node 5 configuration:
   → Max Tokens: Change from 4000 → 3000
   → Faster response, still comprehensive
   ```

4. **Check Network Connectivity:**
   ```bash
   # Test connection to Perplexity API
   ping api.perplexity.ai

   # Check for packet loss or high latency
   ```

5. **Retry Logic:**
   ```
   Enable automatic retry on timeout
   → Retry On Fail: ✅
   → Max Retries: 2
   ```

**Verification:**
- Monitor execution times in logs
- Target: <60 seconds per Perplexity call
- Check consistency across executions

---

## 3. Gemini API Errors

### 3.1 Authentication Failed (403 Error)

**Symptoms:**
- Node 6 (Gemini) fails with "403 Forbidden"
- Error mentions "API key invalid" or "Permission denied"
- Execution stops after Perplexity succeeds

**Resolution Steps:**

1. **Verify API Key:**
   ```
   n8n → Credentials → Google Gemini 2.0
   → Check API key format
   → Should start with "AIzaSy"
   ```

2. **Generate New API Key:**
   ```
   Visit: https://makersuite.google.com/app/apikey
   → Select your Google Cloud project
   → Create API key
   → Copy and save key
   → Update n8n credential
   ```

3. **Enable Required APIs:**
   ```
   Go to: https://console.cloud.google.com/apis
   → Enable these APIs:
   - ✅ Generative Language API
   - ✅ Vertex AI API (optional but recommended)
   ```

4. **Check API Key Restrictions:**
   ```
   Google Cloud Console → Credentials
   → Find your API key
   → Check restrictions:
   - ✅ Application restrictions: None (or allow IP)
   - ✅ API restrictions: Allow Generative Language API
   ```

5. **Verify Billing Enabled:**
   ```
   Google Cloud Console → Billing
   → Ensure billing account linked
   → Gemini requires enabled billing (even for free tier)
   ```

**Verification:**
```bash
# Test API key directly
curl https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=YOUR_KEY \
  -H 'Content-Type: application/json' \
  -d '{"contents":[{"parts":[{"text":"test"}]}]}'
```

---

### 3.2 Model Not Found (404 Error)

**Symptoms:**
- Error: "Model gemini-2.0-flash-exp not found"
- 404 Not Found error
- Other Gemini models may work

**Resolution Steps:**

1. **Check Model Availability:**
   ```
   Visit: https://ai.google.dev/models/gemini
   → Verify "gemini-2.0-flash-exp" is available in your region
   → Check if model deprecated or renamed
   ```

2. **Try Stable Model:**
   ```
   Node 6 (Gemini):
   → Change model from "gemini-2.0-flash-exp"
   → To: "gemini-1.5-pro" or "gemini-1.5-flash"
   → Stable models, similar performance
   ```

3. **Check API Version:**
   ```
   Ensure using correct API endpoint:
   → v1beta for experimental models
   → v1 for stable models
   ```

4. **Verify Region Access:**
   - Some models region-restricted
   - Check: https://ai.google.dev/available_regions
   - May need VPN or different project region

**Alternative Models (If 2.0 Flash Exp Unavailable):**
```
Priority order:
1. gemini-2.0-flash-exp (best, experimental)
2. gemini-1.5-pro (stable, high quality)
3. gemini-1.5-flash (stable, fast, cheaper)
```

---

### 3.3 Quota Exceeded (429 Error)

**Symptoms:**
- Error: "Quota exceeded" or "Resource exhausted"
- 429 status code
- Occurs after several successful requests

**Gemini Free Tier Quotas:**
- 15 requests per minute
- 1,500 requests per day
- 1 million tokens per month

**Resolution Steps:**

1. **Check Current Usage:**
   ```
   Google Cloud Console → APIs & Services → Dashboard
   → Select "Generative Language API"
   → View quotas and usage
   ```

2. **Add Delay Between Requests:**
   ```
   Add "Wait" node after Node 8
   → Duration: 5000ms (5 seconds)
   → Ensures under 15/minute limit
   ```

3. **Enable Retries:**
   ```
   Node 6 (Gemini):
   → Retry On Fail: ✅
   → Max Retries: 3
   → Retry Interval: 15000ms (15 sec)
   → Allows quota to reset
   ```

4. **Request Quota Increase:**
   ```
   Google Cloud Console → IAM & Admin → Quotas
   → Search: "Generative Language API"
   → Select quota to increase
   → Click "Edit Quotas" → Request increase
   → Usually approved within 24-48 hours
   ```

5. **Reduce Token Usage:**
   ```
   Node 6:
   → Max Tokens: Reduce from 8000 → 6000
   → Saves quota, still comprehensive
   ```

**Prevention:**
- Monitor daily usage trends
- Set up quota alerts in Google Cloud
- Plan for quota increases before scaling

---

### 3.4 Safety Filter Blocked (400 Error)

**Symptoms:**
- Error: "Content blocked by safety filter"
- 400 Bad Request with safety message
- Happens inconsistently based on competitor content

**Resolution Steps:**

1. **Review Competitor Content:**
   - Check if competitor has controversial content
   - May trigger safety filters in research

2. **Adjust Safety Settings:**
   ```
   Node 6 (Gemini):
   → Add safety settings parameter:
   {
     "safetySettings": [
       {
         "category": "HARM_CATEGORY_HARASSMENT",
         "threshold": "BLOCK_ONLY_HIGH"
       },
       {
         "category": "HARM_CATEGORY_HATE_SPEECH",
         "threshold": "BLOCK_ONLY_HIGH"
       },
       {
         "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
         "threshold": "BLOCK_ONLY_HIGH"
       },
       {
         "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
         "threshold": "BLOCK_ONLY_HIGH"
       }
     ]
   }
   ```

3. **Sanitize Input:**
   ```
   Add code node before Node 6:
   → Remove potentially flagged content
   → Filter out profanity or controversial terms
   → Keep analysis objective
   ```

4. **Review Prompt Language:**
   - Avoid aggressive or negative framing
   - Use neutral, analytical language
   - Focus on factual observations

**Note:** Don't disable safety filters completely unless absolutely necessary and appropriate for your use case.

---

## 4. Airtable Integration Errors

### 4.1 Field Not Found (400 Error)

**Symptoms:**
- Error: "Unknown field name: 'X'"
- Node 8 (Airtable) fails
- Error mentions specific field name

**Resolution Steps:**

1. **Check Field Name Exact Match:**
   ```
   Airtable field names are case-sensitive:

   ❌ "competitor name"
   ❌ "Competitor name"
   ✅ "Competitor Name"
   ```

2. **Verify Field Exists:**
   ```
   Open Airtable base
   → Table: "Competitor SEO Analysis"
   → Check field exists in schema
   → Note EXACT name including spaces, capitalization
   ```

3. **Update Node 8 Mapping:**
   ```
   Node 8 → Field Mappings
   → For each field, verify name matches Airtable exactly
   → Common mistakes:
   - "Content Gaps" vs "Content Gaps (JSON)"
   - "Priority Score" vs "Strategic Priority Score"
   ```

4. **Refresh Airtable Connection:**
   ```
   Node 8:
   → Click "Refresh Fields" button
   → Reloads schema from Airtable
   → Updates available field list
   ```

5. **Check for Hidden Fields:**
   ```
   Airtable → Table settings
   → "Hide fields" → Ensure needed fields visible
   → Hidden fields may not appear in API
   ```

**Prevention:**
- Use exact field names from AIRTABLE-SCHEMA.md
- Copy-paste field names instead of typing
- Document any schema changes

---

### 4.2 Permission Denied (403 Error)

**Symptoms:**
- Error: "Forbidden" or "Permission denied"
- Node 8 fails on create record
- Credential test may pass but workflow fails

**Resolution Steps:**

1. **Check Personal Access Token Scopes:**
   ```
   Airtable → Account → Personal Access Tokens
   → Find your token
   → Verify scopes:
   - ✅ data.records:read
   - ✅ data.records:write
   - ✅ schema.bases:read
   ```

2. **Verify Base Access:**
   ```
   Token settings:
   → "Access" section
   → Ensure "DTN Agent Factory" base is selected
   → If not, add base to token permissions
   ```

3. **Regenerate Token (If Needed):**
   ```
   Create new Personal Access Token:
   → Name: "n8n Agent-2 V2"
   → Scopes: All three (read, write, schema)
   → Bases: Select your base
   → Copy new token
   → Update n8n credential
   ```

4. **Check Table Permissions:**
   ```
   Airtable base → Share
   → If enterprise: Verify your account has write access
   → Check for any restrictive base-level permissions
   ```

**Verification:**
```bash
# Test API access directly
curl "https://api.airtable.com/v0/BASE_ID/TABLE_NAME" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

### 4.3 Record Too Large (413 Error)

**Symptoms:**
- Error: "Request entity too large"
- 413 status code
- Happens when creating record

**Airtable Limits:**
- Max record size: 100,000 characters per record
- Max field size: 100,000 characters per long text field
- Max attachment size: 20 MB (not applicable here)

**Resolution Steps:**

1. **Identify Large Fields:**
   ```
   Check JSON fields for excessive size:
   - Content Gaps (JSON)
   - Content Tactics (JSON)
   - SEO Tactics (JSON)
   - Competitive Threats (JSON)
   ```

2. **Reduce Gemini Output Length:**
   ```
   Node 6 (Gemini):
   → Max Tokens: Reduce from 8000 → 6000
   → Update prompt to request fewer items:
   - "Identify 3-5 content gaps" (instead of 5-7)
   - "Top 3 content tactics" (instead of 5)
   ```

3. **Truncate Long Fields:**
   ```
   Add code node before Node 8:
   → Truncate each JSON field to max 20,000 chars
   → Ensures under Airtable limits

   const maxLength = 20000;
   $json.content_gaps = JSON.stringify($json.content_gaps)
     .substring(0, maxLength);
   ```

4. **Split Data Across Records:**
   ```
   Option: Create related tables
   - Main record: Executive summary + metrics
   - Related records: Individual gaps/tactics
   - Requires schema redesign
   ```

**Prevention:**
- Set reasonable Gemini max tokens (6000-8000)
- Request focused output (3-5 items vs 10+)
- Monitor average record sizes in Airtable

---

### 4.4 Base or Table Not Found (404 Error)

**Symptoms:**
- Error: "Not found" or "Unknown base/table"
- 404 status code
- Airtable credential test passes

**Resolution Steps:**

1. **Verify Base ID:**
   ```
   Node 8 → Base ID field
   → Should be format: "appXXXXXXXXXXXXXX"
   → Get from Airtable URL:
   https://airtable.com/appYOURBASEID/...
   ```

2. **Verify Table Name:**
   ```
   Node 8 → Table Name field
   → Must match exactly: "Competitor SEO Analysis"
   → Case-sensitive
   → Check for extra spaces
   ```

3. **Check Base Not Deleted:**
   ```
   Go to: airtable.com/workspace
   → Verify base still exists
   → Check trash if recently deleted
   ```

4. **Verify Token Has Base Access:**
   ```
   Airtable → Account → Personal Access Tokens
   → Find token
   → Check "Bases" section includes your base
   → Add if missing
   ```

**Quick Fix:**
```
1. Copy Base ID from Airtable URL
2. Copy Table Name exactly from Airtable
3. Update both in Node 8
4. Test connection
```

---

## 5. Slack Notification Failures

### 5.1 Bot Not in Channel

**Symptoms:**
- Error: "not_in_channel" or "channel_not_found"
- Node 9 fails
- Rest of workflow succeeds

**Resolution Steps:**

1. **Invite Bot to Channel:**
   ```
   In Slack:
   → Go to #seo-intelligence channel
   → Type: /invite @Agent-2 SEO Intelligence Bot
   → Press Enter
   → Verify bot appears in member list
   ```

2. **Check Channel ID:**
   ```
   Node 9 → Channel field
   → Should be: C01XXXXXXXXXX (not #channel-name)
   → Get Channel ID:
   - Right-click channel → Copy link
   - URL: .../archives/C01XXXXXXXXXX
   - Use the C01... part
   ```

3. **Verify Bot Scopes:**
   ```
   Slack API → Your App → OAuth & Permissions
   → Bot Token Scopes:
   - ✅ chat:write
   - ✅ channels:read
   - ✅ chat:write.public
   ```

4. **Reinstall App (If Needed):**
   ```
   Slack API → Your App
   → "Reinstall to Workspace"
   → Accept new permissions
   → Update n8n credential with new token
   ```

**Verification:**
```
Send test message:
Slack API → Methods → chat.postMessage
→ Test with your channel ID
→ Should succeed
```

---

### 5.2 OAuth Token Expired

**Symptoms:**
- Error: "invalid_auth" or "token_revoked"
- Node 9 fails
- Worked previously but stopped

**Resolution Steps:**

1. **Refresh OAuth Connection:**
   ```
   n8n → Credentials → Slack OAuth
   → Click "Reconnect"
   → Authorize in popup
   → Save credential
   ```

2. **Check Token Expiry:**
   ```
   Slack API → Your App → OAuth & Permissions
   → Check "Bot User OAuth Token" section
   → If revoked, reinstall app
   ```

3. **Verify App Not Uninstalled:**
   ```
   Slack workspace → Apps
   → Search for "Agent-2 SEO Intelligence Bot"
   → If missing, reinstall from Slack API dashboard
   ```

4. **Generate New Token:**
   ```
   Slack API → Your App
   → "Reinstall to Workspace"
   → Get new Bot User OAuth Token
   → Update n8n credential
   ```

**Prevention:**
- Use OAuth2 (auto-refresh) instead of static token
- Monitor Slack app settings for changes
- Document token refresh procedure

---

### 5.3 Message Too Long

**Symptoms:**
- Error: "message_too_long"
- Notification partially sent or failed
- Message exceeds Slack limits

**Slack Message Limits:**
- Max message length: 40,000 characters
- Max blocks: 50 blocks
- Recommended: <4,000 characters for readability

**Resolution Steps:**

1. **Shorten Notification Template:**
   ```
   Node 9 → Message field
   → Remove verbose sections
   → Use summary stats only
   → Link to Airtable for details
   ```

2. **Use Blocks Instead of Text:**
   ```
   Switch to Slack Block Kit:
   → More structured, better formatting
   → Higher character limits
   → Better mobile display
   ```

3. **Dynamic Truncation:**
   ```
   Add code node before Node 9:
   → Truncate message if > 3,000 chars
   → Add "... see Airtable for full details"
   ```

**Optimized Template:**
```
✅ **Weekly SEO Analysis Complete**

📊 **Summary:**
• 5 competitors analyzed
• {{$json.total_gaps}} content gaps identified
• Avg priority: {{$json.avg_priority}}/100

🔗 [View Full Analysis](https://airtable.com/...)

Next: Monday 9 AM ET
```

---

## 6. Data Quality Issues

### 6.1 Generic or Unhelpful Analyses

**Symptoms:**
- Executive summaries are vague
- Content gaps not specific
- Recommendations not actionable
- Analysis feels generic

**Possible Causes:**
- Perplexity search too broad
- Gemini prompt needs improvement
- Competitor data incomplete
- Temperature settings incorrect

**Resolution Steps:**

1. **Improve Competitor Metadata:**
   ```
   Node 2: Update competitor objects
   → Add more specific focus_areas
   → Include 5-10 primary_keywords (not just 3)
   → Verify content_hub URLs are active
   ```

2. **Refine Perplexity Prompt:**
   ```
   Node 5: Make prompt more specific

   ❌ Generic: "What is their SEO strategy?"
   ✅ Specific: "What 5 keywords do they rank #1-3 for?
                Include search volume and difficulty estimates."
   ```

3. **Enhance Gemini Prompt:**
   ```
   Node 6: Add examples and constraints

   Add to prompt:
   "For each content gap, provide:
   - Specific article title (not just topic)
   - Estimated search volume for target keywords
   - Competitive difficulty (Low/Medium/High)
   - Expected time to rank (3/6/12 months)"
   ```

4. **Adjust Temperature:**
   ```
   Node 6 (Gemini):
   → Current: 0.4
   → Try: 0.5-0.6 for more creative insights
   → Don't exceed 0.7 (too random)
   ```

5. **Narrow Search Recency:**
   ```
   Node 5 (Perplexity):
   → Change searchRecencyFilter from "month" → "week"
   → More current data, more specific insights
   ```

**Verification:**
- Compare before/after analyses quality
- Review with team for actionability
- Track which insights lead to actual content creation

---

### 6.2 Duplicate Records in Airtable

**Symptoms:**
- Multiple records for same competitor on same date
- Airtable table grows faster than expected
- Workflow ran multiple times unintentionally

**Possible Causes:**
- Workflow executed manually multiple times
- Schedule trigger fired multiple times (rare)
- Loop not exiting properly
- Multiple workflow versions active

**Resolution Steps:**

1. **Check for Duplicate Workflows:**
   ```
   n8n → Workflows
   → Search: "Agent-2 SEO"
   → Verify only ONE workflow is "Active"
   → Deactivate or delete duplicates
   ```

2. **Review Execution History:**
   ```
   n8n → Executions
   → Filter by workflow
   → Check for multiple executions on same date
   → Identify cause (manual vs scheduled)
   ```

3. **Clean Up Duplicates:**
   ```
   Airtable:
   → Sort by: Competitor Name, Analysis Date
   → Identify duplicates (same name + date)
   → Manually delete older duplicates
   → Keep most recent/complete record
   ```

4. **Add Deduplication Logic (Advanced):**
   ```
   Add code node before Node 8:
   → Query Airtable for existing records
   → Check if record exists for competitor + today's date
   → Skip creation if duplicate found
   → Requires additional Airtable node
   ```

5. **Prevent Future Duplicates:**
   ```
   Create Airtable automation:
   → Trigger: Record created
   → Condition: Duplicate Competitor Name + Analysis Date
   → Action: Delete record + send alert
   ```

**Prevention:**
- Only manual execute when testing
- Verify single active workflow
- Monitor execution logs weekly

---

### 6.3 JSON Fields Not Parsing

**Symptoms:**
- Content Gaps (JSON) shows as plain text, not structured
- Can't parse JSON in formulas or scripts
- JSON appears with escape characters

**Possible Causes:**
- Gemini output not valid JSON
- Information Extractor (Node 7) failing silently
- Extra formatting/markdown in output
- Character encoding issues

**Resolution Steps:**

1. **Check Node 7 Output:**
   ```
   n8n → Last execution → Node 7
   → Verify output is clean JSON
   → Look for:
   - No markdown code blocks (```json```)
   - No extra text before/after JSON
   - Valid JSON syntax
   ```

2. **Validate JSON Structure:**
   ```
   Copy output from Node 7
   → Paste into: https://jsonlint.com/
   → Check for errors
   → Common issues:
   - Trailing commas
   - Unescaped quotes in strings
   - Missing brackets
   ```

3. **Improve Gemini Prompt:**
   ```
   Node 6: Make JSON requirement explicit

   Add to end of prompt:
   "CRITICAL: Return ONLY the JSON object.
   No markdown formatting.
   No code blocks.
   No additional text before or after.
   Start with { and end with }."
   ```

4. **Add JSON Cleanup Node:**
   ```
   Insert code node between Node 6 and 7:

   let text = $input.item.json.output;
   // Remove markdown code blocks
   text = text.replace(/```json\n?/g, '');
   text = text.replace(/```\n?/g, '');
   // Extract JSON if wrapped
   const match = text.match(/\{[\s\S]*\}/);
   return {
     json: {
       cleaned_output: match ? match[0] : text
     }
   };
   ```

5. **Update Information Extractor Schema:**
   ```
   Node 7:
   → Verify schema matches exactly what Gemini outputs
   → Enable "strict" mode if available
   → Set "removeInvalidFields": false (fail on errors)
   ```

**Verification:**
- Copy JSON from Airtable
- Paste into JSON validator
- Should parse without errors
- Try: `JSON.parse(field_value)` in browser console

---

## 7. Performance and Timeout Issues

### 7.1 Workflow Takes Too Long (>30 minutes)

**Symptoms:**
- Execution time exceeds 30 minutes
- Workflow times out
- Some competitors not processed

**Target Execution Times:**
- 1 competitor: 3-5 minutes
- 5 competitors: 15-25 minutes
- 7 competitors: 21-35 minutes

**Resolution Steps:**

1. **Identify Slow Nodes:**
   ```
   n8n → Execution log
   → Note time spent in each node
   → Common slow nodes:
   - Node 5 (Perplexity): Should be <60s
   - Node 6 (Gemini): Should be <90s
   ```

2. **Optimize Perplexity (Node 5):**
   ```
   Reduce prompt length:
   - Remove examples
   - Shorten instructions
   - Target <800 tokens

   Reduce max tokens:
   - Change from 4000 → 3000

   Narrow search recency:
   - "month" → "week" (faster search)
   ```

3. **Optimize Gemini (Node 6):**
   ```
   Reduce max tokens:
   - Change from 8000 → 6000

   Reduce input size:
   - Summarize Perplexity output before passing
   - Don't include full research (just key points)
   ```

4. **Remove Unnecessary Delays:**
   ```
   Check for Wait nodes
   → Remove if not needed for rate limiting
   → Reduce delay time (10s → 5s)
   ```

5. **Parallel Processing (Advanced):**
   ```
   Instead of sequential loop:
   → Use "Split Out Items" node
   → Process competitors in parallel
   → WARNING: May hit rate limits
   → Only if APIs support concurrency
   ```

**Verification:**
- Monitor next execution time
- Target: <20 minutes for 5 competitors
- Document optimization results

---

### 7.2 High Memory Usage / Crashes

**Symptoms:**
- n8n instance crashes during execution
- "Out of memory" errors
- Workflow stops unexpectedly

**Resolution Steps:**

1. **Check n8n Instance Resources:**
   ```bash
   # Check memory usage
   free -h

   # Check n8n process memory
   ps aux | grep n8n

   # Check available disk space
   df -h
   ```

2. **Increase n8n Memory Limit:**
   ```bash
   # For self-hosted (systemd)
   sudo nano /etc/systemd/system/n8n.service

   # Add or modify:
   Environment="NODE_OPTIONS=--max-old-space-size=4096"

   # Restart
   sudo systemctl daemon-reload
   sudo systemctl restart n8n
   ```

3. **Reduce Data Retention:**
   ```
   n8n Settings → Executions
   → "Save execution progress": Manual executions only
   → "Save data of success executions": 7 days
   → Reduces database size
   ```

4. **Reduce Concurrent Executions:**
   ```
   n8n Settings → Executions
   → Max concurrent executions: 1-2
   → Prevents memory overload
   ```

5. **Optimize Workflow:**
   ```
   - Don't store large data in variables
   - Clear unused data between nodes
   - Reduce logging verbosity
   ```

**Prevention:**
- Monitor n8n instance resources
- Set up memory alerts
- Scale to larger instance if needed
- Consider n8n Cloud (managed infrastructure)

---

## 8. Cost and Billing Issues

### 8.1 Unexpected High API Costs

**Symptoms:**
- Perplexity bill higher than expected
- Gemini costs exceed $10/month
- Surprise charges on credit card

**Expected Costs (5 competitors, weekly):**
- Perplexity: ~$1.20/month
- Gemini: ~$2.40/month
- Total API: ~$3.60/month

**Resolution Steps:**

1. **Audit Execution Frequency:**
   ```
   n8n → Executions
   → Filter last 30 days
   → Count executions
   → Expected: 4-5 per month (weekly)
   → If >10: Investigate duplicate executions
   ```

2. **Check Token Usage:**
   ```
   Perplexity Dashboard:
   → Usage tab
   → Check tokens per request
   → Should be <4,000 tokens/request

   Gemini Dashboard:
   → Google Cloud Console → API Usage
   → Check token metrics
   → Should be <8,000 tokens/request
   ```

3. **Identify Cost Drivers:**
   ```
   Common causes of high costs:
   - ✗ Workflow running hourly instead of weekly
   - ✗ Testing with 10+ competitors
   - ✗ Max tokens set too high (>10,000)
   - ✗ Multiple workflow versions active
   ```

4. **Set Budget Alerts:**
   ```
   Perplexity:
   → Settings → Billing
   → Set usage alerts at $5, $10, $20

   Google Cloud:
   → Billing → Budgets & alerts
   → Set budget: $10/month
   → Alerts at 50%, 90%, 100%
   ```

5. **Optimize for Cost:**
   ```
   Reduce frequency:
   → Weekly → Bi-weekly (50% savings)

   Reduce competitors:
   → 5 → 3 competitors (40% savings)

   Use cheaper models:
   → Gemini 2.0 Flash → 1.5 Flash (cheaper)
   → Sonar Pro → Sonar (if quality acceptable)
   ```

**Verification:**
- Check next month's costs
- Verify charges match execution count
- Document baseline costs for comparison

---

### 8.2 Free Tier Limits Exceeded

**Symptoms:**
- Gemini: "Quota exceeded" errors
- Workflow fails mid-execution
- Daily/monthly limits reached

**Gemini Free Tier Limits:**
- 15 requests/minute
- 1,500 requests/day
- 1 million tokens/month

**Resolution Steps:**

1. **Calculate Current Usage:**
   ```
   Weekly execution:
   - 5 competitors × 1 request each = 5 requests
   - 5 × ~6,000 tokens = ~30,000 tokens

   Monthly usage:
   - 4 weeks × 5 requests = 20 requests
   - 4 weeks × 30,000 tokens = 120,000 tokens

   ✅ Well within free tier
   ```

2. **Check for Unexpected Usage:**
   ```
   Google Cloud Console:
   → API Dashboard
   → Check daily request pattern
   → Look for spikes or unexpected usage
   ```

3. **Request Quota Increase:**
   ```
   Google Cloud Console:
   → IAM & Admin → Quotas
   → Filter: Generative Language API
   → Request increase (usually free)
   ```

4. **Upgrade to Paid Tier:**
   ```
   Enable billing on Google Cloud project
   → Costs still minimal (~$2-3/month)
   → No more quota restrictions
   → Pay-as-you-go
   ```

**Prevention:**
- Monitor quota usage weekly
- Set alerts at 50% of quota
- Plan for paid tier if scaling

---

## Emergency Procedures

### Workflow Completely Broken

**Quick Recovery Steps:**

1. **Deactivate Workflow:**
   ```
   n8n → Workflows → Agent-2
   → Toggle to "Inactive"
   → Prevents more failures
   ```

2. **Export Working Version:**
   ```
   Find last successful execution
   → Note the date
   → Restore from git/backup if available
   ```

3. **Start Fresh:**
   ```
   Import clean workflow JSON from repo
   → Reconfigure credentials
   → Test with 1 competitor
   → Restore when working
   ```

4. **Contact Support:**
   - n8n Community: https://community.n8n.io/
   - This repository: Open GitHub issue
   - DTN team: Internal support

---

## Getting Help

### Before Requesting Support

Gather this information:

1. **Error Details:**
   - Exact error message
   - Node that failed
   - Execution ID
   - Screenshot of error

2. **Environment:**
   - n8n version
   - Hosting (cloud/self-hosted)
   - Workflow version
   - Recent changes

3. **Execution Context:**
   - When did it last work?
   - How many competitors?
   - Manual or scheduled execution?

4. **Troubleshooting Tried:**
   - Steps already attempted
   - Results of those steps

### Support Channels

**Internal:**
- DTN Marketing Automation Team
- AI Agent Factory GitHub: [Open Issue](https://github.com/your-org/ai-agent-factory/issues)

**External:**
- n8n Community: https://community.n8n.io/
- n8n Discord: https://discord.gg/n8n
- Airtable Community: https://community.airtable.com/
- Perplexity Support: support@perplexity.ai
- Google Cloud Support: https://cloud.google.com/support

---

## Appendix: Error Code Reference

| Code | Service | Meaning | Quick Fix |
|------|---------|---------|-----------|
| 400 | Perplexity/Gemini/Airtable | Bad Request | Check request format/parameters |
| 401 | Perplexity/Gemini | Unauthorized | Verify API key valid |
| 403 | Gemini/Airtable | Forbidden | Check permissions/scopes |
| 404 | Airtable | Not Found | Verify Base ID and Table Name |
| 413 | Airtable | Payload Too Large | Reduce data size |
| 429 | Perplexity/Gemini | Rate Limit | Add delays, enable retries |
| 500 | Any | Server Error | Retry, check service status |
| 504 | Perplexity | Timeout | Reduce prompt/token length |

---

**Last Updated:** 2025-11-19
**Guide Version:** 2.0
**Status:** ✅ Production Ready
