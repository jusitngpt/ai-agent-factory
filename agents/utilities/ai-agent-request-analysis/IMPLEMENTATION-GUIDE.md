# AI Agent Request Analysis - Implementation Guide

**Workflow**: AI Agent Request Analysis
**Difficulty**: ⭐⭐ Medium
**Estimated Setup Time**: 45-60 minutes
**Prerequisites**: n8n instance, Airtable account, API keys

---

## Overview

This guide provides step-by-step instructions to deploy the AI Agent Request Analysis workflow in your n8n instance. Follow these instructions carefully to ensure proper configuration.

---

## Prerequisites

Before beginning, ensure you have:

### 1. n8n Instance
- **Version**: 1.0.0 or higher
- **Hosting**: Self-hosted or n8n Cloud
- **Access Level**: Admin (required to import workflows and configure credentials)

### 2. API Credentials

| Service | Required | Purpose |
|---------|----------|---------|
| **Anthropic Claude** | ✅ Yes | Primary analysis engine |
| **Google Gemini** | ✅ Yes | JSON extraction |
| **Airtable** | ✅ Yes | Data storage |
| **Slack** | ✅ Yes | Notifications |

### 3. Accounts & Permissions

- **Airtable**: Personal Access Token with base access
- **Slack**: OAuth app or bot token with `chat:write` permission
- **Claude**: API key from Anthropic Console
- **Gemini**: API key from Google AI Studio

---

## Step 1: Set Up Airtable Base

### 1.1 Create Base

1. Log into Airtable
2. Click **"Add a base"**
3. Choose **"Start from scratch"**
4. Name it: `"Katalon Agent Factory"`
5. Click **Create base**

### 1.2 Create Table

1. Rename default table to `"AI Agent Requests"`
2. Add the following fields (see AIRTABLE-SCHEMA.md for details):

| Field Name | Type | Options |
|------------|------|---------|
| Requestor Name | Single line text | Required |
| Requestor Department | Single line text | Required |
| AI Agent Request | Single line text | Required |
| Description of AI Agent | Long text | Required |
| Data Sources | Multiple select | Required, options: Airtable, Google Drive, Email/Gmail, Social Media, Web Scraping, APIs, RSS Feeds, Database, Slack, Other |
| Trigger or On Demand | Single select | Required, options: Trigger-based, On-Demand |
| KPI or OKR alignment | Long text | Required |
| Potential Impact | Long text | Required |
| Request Date | Created time | Auto-populated |
| ICE Rating | Single line text | (left empty, populated by workflow) |
| Reason for ICE Rating | Long text | (left empty, populated by workflow) |
| Recommended Agentic Workflow | Long text | (left empty, populated by workflow) |

### 1.3 Note Base and Table IDs

1. In Airtable, go to **Help** → **API documentation**
2. Copy **Base ID** (starts with `app...`)
3. Copy **Table ID** for `AI Agent Requests` (starts with `tbl...`)
4. Save these IDs - you'll need them in Step 3

### 1.4 Create Personal Access Token

1. Go to https://airtable.com/create/tokens
2. Click **"Create new token"**
3. Name it: `"n8n KAF Integration"`
4. Add scopes:
   - `data.records:read`
   - `data.records:write`
   - `schema.bases:read`
5. Add access to your "Katalon Agent Factory" base
6. Click **"Create token"**
7. **Copy token immediately** (shown only once)

---

## Step 2: Configure Slack Channel

### 2.1 Create Channel

1. In Slack, create a new channel: `#new-agent-requests`
2. Set description: `"AI agent request analysis notifications from KAF"`
3. Make it public or private (your choice)

### 2.2 Create Slack App (if needed)

If you don't have a Slack app yet:

1. Go to https://api.slack.com/apps
2. Click **"Create New App"**
3. Choose **"From scratch"**
4. Name: `"Katalon Agent Factory"`
5. Select your workspace
6. Click **"Create App"**

### 2.3 Configure OAuth & Permissions

1. In app settings, go to **"OAuth & Permissions"**
2. Under "Scopes", add **Bot Token Scopes**:
   - `chat:write`
   - `chat:write.public`
3. Click **"Install to Workspace"**
4. Authorize the app
5. **Copy the Bot User OAuth Token** (starts with `xoxb-`)

### 2.4 Invite Bot to Channel

1. In Slack, go to `#new-agent-requests`
2. Type: `/invite @Katalon Agent Factory`
3. Confirm the invitation

### 2.5 Note Channel ID

1. In Slack, go to `#new-agent-requests`
2. Click channel name → **"View channel details"**
3. Scroll down, copy **Channel ID** (e.g., `C09TPD4DEFQ`)

---

## Step 3: Configure n8n Credentials

### 3.1 Anthropic Claude Credentials

1. In n8n, go to **Settings** → **Credentials**
2. Click **"Add Credential"**
3. Search for `"Anthropic"`
4. Click **"Anthropic Api"**
5. Name: `"Anthropic account"`
6. Paste your Claude API key
7. Click **"Save"**

### 3.2 Google Gemini Credentials

1. In n8n, go to **Settings** → **Credentials**
2. Click **"Add Credential"**
3. Search for `"Google PaLM"`
4. Click **"Google PaLM Api"**
5. Name: `"Google Gemini(PaLM) Api account"`
6. Paste your Gemini API key
7. Click **"Save"**

### 3.3 Airtable Credentials

1. In n8n, go to **Settings** → **Credentials**
2. Click **"Add Credential"**
3. Search for `"Airtable"`
4. Click **"Airtable Personal Access Token Api"`
5. Name: `"Airtable Personal Access Token account 2"`
6. Paste your Airtable Personal Access Token
7. Click **"Save"**

### 3.4 Slack Credentials

1. In n8n, go to **Settings** → **Credentials**
2. Click **"Add Credential"**
3. Search for `"Slack"`
4. Click **"Slack OAuth2 Api"`
5. Name: `"Slack account 3"`
6. Choose authentication method:
   - **Option A (OAuth2)**: Follow OAuth flow (recommended)
   - **Option B (Access Token)**: Paste your Bot User OAuth Token
7. Click **"Save"**

---

## Step 4: Import Workflow

### 4.1 Download Workflow JSON

1. Get the workflow JSON file from:
   - Repository: `/workflows/ai-agent-request-analysis.json`
   - OR use the provided file

### 4.2 Import into n8n

1. In n8n, click **"Workflows"**
2. Click **"Import from File"**
3. Select `ai-agent-request-analysis.json`
4. Click **"Import"**

### 4.3 Verify Import

You should see 6 nodes:
- Airtable Trigger1
- Message a model (Claude)
- Information Extractor
- Google Gemini Chat Model
- Update record (Airtable)
- Send a message (Slack)

---

## Step 5: Update Configuration

### 5.1 Update Airtable Trigger Node

1. Click **"Airtable Trigger1"** node
2. Update **"Base"**: Select your base OR enter Base ID manually
3. Update **"Table"**: Select "AI Agent Requests" OR enter Table ID manually
4. Verify **"Trigger Field"** is set to `"Request Date"`
5. Verify **"Poll Times"** is set to `"Every hour"` (or adjust as needed)
6. Click **"Execute Node"** to test connection
7. Should show: `"Polling trigger node. Trigger data cannot be shown."`

### 5.2 Update Claude Node

1. Click **"Message a model"** node
2. Verify **"Model"** is `"claude-sonnet-4-5-20250929"` (or latest available)
3. Credential should auto-select if only one Anthropic credential exists
4. If not, select **"Anthropic account"** from dropdown
5. No need to test (will execute when triggered)

### 5.3 Update Information Extractor Node

1. Click **"Information Extractor"** node
2. Verify it's connected to **"Google Gemini Chat Model"**
3. No configuration changes needed

### 5.4 Update Gemini Model Node

1. Click **"Google Gemini Chat Model"** node
2. Verify **"Model Name"** is `"models/gemini-2.5-pro"`
3. Credential should auto-select
4. If not, select **"Google Gemini(PaLM) Api account"**

### 5.5 Update Airtable Update Node

1. Click **"Update record"** node
2. Update **"Base"**: Select your base OR enter Base ID manually
3. Update **"Table"**: Select "AI Agent Requests" OR enter Table ID manually
4. Verify **field mappings** are correct:
   - `id` → `={{ $('Airtable Trigger1').item.json.id }}`
   - `ICE Rating` → `={{ $json.output.properties.ice_rating.enum[0] }}`
   - `Reason for ICE Rating` → `={{ $json.output.properties.reason_for_ice_rating.description }}`
   - `Recommended Agentic Workflow` → `={{ $json.output.properties.recommended_workflow.description }}`

### 5.6 Update Slack Node

1. Click **"Send a message"** node
2. Update **"Channel"**:
   - **Option A**: Select `"#new-agent-requests"` from dropdown
   - **Option B**: Manually enter Channel ID: `C09TPD4DEFQ` (replace with yours)
3. Verify message template looks correct
4. Click **"Execute Node"** to test (will send a test message to Slack)

---

## Step 6: Test the Workflow

### 6.1 Create Test Record in Airtable

1. Go to your Airtable base
2. Add a new record to "AI Agent Requests" table:

```
Requestor Name: Test User
Requestor Department: Engineering
AI Agent Request: Test Pricing Monitor
Description of AI Agent: This is a test agent request to verify the workflow is functioning correctly. It should monitor competitor pricing and send alerts when prices change.
Data Sources: APIs, Web Scraping
Trigger or On Demand: Trigger-based
KPI or OKR alignment: Test OKR - Verify workflow functionality
Potential Impact: Successful execution will confirm the workflow is properly configured
```

### 6.2 Wait for Trigger (or Execute Manually)

**Option A - Wait for Hourly Trigger**:
- Wait up to 1 hour for the next trigger poll
- Check n8n **"Executions"** tab for new execution

**Option B - Execute Manually** (faster testing):
1. In n8n, click **"Execute Workflow"** button
2. The workflow will run immediately
3. Check **"Executions"** tab for results

### 6.3 Verify Results

**Check 1: n8n Execution**
- Open **"Executions"** tab
- Latest execution should show **"Success"**
- All 6 nodes should have green checkmarks

**Check 2: Airtable Record**
- Go back to Airtable
- Find your test record
- Verify these fields are now populated:
  - `ICE Rating`: Should have a value like `"1 - High Impact, Low Effort"`
  - `Reason for ICE Rating`: Should have detailed text
  - `Recommended Agentic Workflow`: Should have technical blueprint

**Check 3: Slack Notification**
- Go to `#new-agent-requests` in Slack
- You should see a new message with:
  - Agent request name
  - Requestor name
  - ICE Rating
  - KPI/OKR Alignment
  - Airtable ID

### 6.4 Review Execution Details

1. In n8n, click on the execution in **"Executions"** tab
2. Review each node's output:
   - **Airtable Trigger**: Should show the test record
   - **Claude**: Should show detailed ICE analysis
   - **Information Extractor**: Should show structured JSON
   - **Airtable Update**: Should show success
   - **Slack**: Should show message sent

---

## Step 7: Activate Workflow

### 7.1 Final Checks

Before activating, verify:
- [ ] All credentials configured correctly
- [ ] Airtable Base and Table IDs are correct
- [ ] Slack channel ID is correct
- [ ] Test execution completed successfully
- [ ] Airtable record updated correctly
- [ ] Slack notification received

### 7.2 Activate

1. In n8n workflow editor, toggle **"Active"** switch to ON
2. Workflow status should change to **"Active"**
3. Workflow will now run automatically every hour

### 7.3 Monitor

- **Week 1**: Check daily for execution errors
- **Week 2-4**: Check weekly
- **Ongoing**: Review monthly

---

## Step 8: User Training

### 8.1 Create User Guide

Share this simple guide with your team:

---

**How to Submit an AI Agent Request**

1. Go to Airtable: [Your base URL]
2. Open the "AI Agent Requests" table
3. Click **"+"** to add a new record
4. Fill out all required fields:
   - Your name and department
   - Agent name and description
   - Data sources needed
   - How it should trigger
   - Which KPIs/OKRs it supports
   - Expected business impact
5. Click **"Save"**
6. Within 1 hour, you'll receive ICE analysis via Slack

---

### 8.2 Set Expectations

Inform your team:
- **Analysis Time**: Up to 1 hour (hourly polling)
- **Notification**: Sent to `#new-agent-requests` Slack channel
- **Next Steps**: Product team will review ICE scores for prioritization
- **Questions**: Contact [your team/person]

---

## Troubleshooting During Setup

### Issue: Workflow Import Fails

**Error**: "Invalid JSON" or "Parsing error"

**Solutions**:
1. Ensure JSON file downloaded completely
2. Open JSON file in text editor, verify it's valid JSON
3. Try importing in a different browser
4. Re-download the JSON file

---

### Issue: Credentials Not Found

**Error**: "Credential 'XYZ' not found"

**Solutions**:
1. Go to **Settings** → **Credentials**
2. Verify credential exists and has correct name
3. Edit workflow node, re-select credential from dropdown
4. Save workflow

---

### Issue: Airtable Connection Fails

**Error**: "Invalid base/table ID" or "Unauthorized"

**Solutions**:
1. Verify Base ID starts with `app` (17 characters)
2. Verify Table ID starts with `tbl` (17 characters)
3. Check Personal Access Token has correct permissions
4. Verify token has access to this specific base
5. Test token with Airtable API directly:
   ```bash
   curl "https://api.airtable.com/v0/YOUR_BASE_ID/YOUR_TABLE_NAME?maxRecords=1" \
     -H "Authorization: Bearer YOUR_TOKEN"
   ```

---

### Issue: Slack Message Not Sent

**Error**: "channel_not_found" or "not_in_channel"

**Solutions**:
1. Verify Channel ID is correct (e.g., `C09TPD4DEFQ`)
2. Verify bot is invited to channel (use `/invite @bot_name`)
3. Check Slack OAuth token has `chat:write` permission
4. Test Slack API directly:
   ```bash
   curl -X POST https://slack.com/api/chat.postMessage \
     -H "Authorization: Bearer YOUR_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"channel":"C09TPD4DEFQ","text":"Test"}'
   ```

---

### Issue: Claude or Gemini API Fails

**Error**: "Unauthorized" or "Invalid API key"

**Solutions**:
1. Verify API key is correct (no extra spaces)
2. Check API key permissions and quotas
3. Test API key directly:
   ```bash
   # Test Claude
   curl https://api.anthropic.com/v1/messages \
     -H "x-api-key: YOUR_CLAUDE_KEY" \
     -H "anthropic-version: 2023-06-01" \
     -H "Content-Type: application/json" \
     -d '{"model":"claude-sonnet-4-5-20250929","messages":[{"role":"user","content":"test"}],"max_tokens":100}'

   # Test Gemini
   curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent?key=YOUR_GEMINI_KEY" \
     -H "Content-Type: application/json" \
     -d '{"contents":[{"parts":[{"text":"test"}]}]}'
   ```

---

## Post-Deployment

### Week 1 Checklist

- [ ] Monitor executions daily
- [ ] Review ICE scores for accuracy
- [ ] Collect user feedback
- [ ] Adjust trigger frequency if needed
- [ ] Verify all notifications received

### Month 1 Checklist

- [ ] Review cost (should be <$10/month for ~20 requests)
- [ ] Audit ICE score consistency
- [ ] Update prompt if needed
- [ ] Train additional team members
- [ ] Document any issues or improvements

### Ongoing Maintenance

- **Monthly**: Review execution history for errors
- **Quarterly**: Audit ICE score accuracy vs. actual outcomes
- **Annually**: Review and update prompt for improved analysis

---

## Support Resources

- **n8n Documentation**: https://docs.n8n.io
- **Airtable API**: https://airtable.com/developers/web/api
- **Claude API**: https://docs.anthropic.com
- **Gemini API**: https://ai.google.dev/docs
- **Slack API**: https://api.slack.com

---

## Next Steps

After successful deployment:
1. Review TROUBLESHOOTING.md for common issues
2. Monitor workflow performance
3. Collect team feedback on ICE scores
4. Consider implementing other KAF agents

---

**Setup Complete!** 🎉

Your AI Agent Request Analysis workflow is now operational.

**Questions?** See TROUBLESHOOTING.md or contact your KAF administrator.

---

**Last Updated**: November 19, 2025
**Guide Version**: 1.0
