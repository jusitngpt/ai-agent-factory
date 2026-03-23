# Implementation Guide
## Agent-1B V4: Multi-Feed RSS Monitor

**Estimated Setup Time**: 45-60 minutes
**Difficulty**: Intermediate
**Prerequisites**: n8n instance, Airtable account, Slack workspace

---

## Overview

This guide will walk you through deploying Agent-1B V4 Multi-Feed RSS Monitor from start to finish. By the end, you'll have an automated competitive intelligence system monitoring 5 competitors and delivering insights daily.

### What You'll Build

- Automated RSS feed monitoring for 5 competitors
- AI-powered competitive analysis using Gemini 2.5 Pro
- Structured intelligence storage in Airtable
- Real-time Slack notifications for new discoveries

---

## Prerequisites

### Required Accounts & Access

| Service | Requirement | Cost |
|---------|-------------|------|
| **n8n** | Self-hosted or cloud instance (v1.0+) | Free (self-hosted) or $20/month (cloud) |
| **Google Cloud** | API access for Gemini 2.5 Pro | Pay-as-you-go (~$0.24/month) |
| **Airtable** | Free or Plus plan | Free (limited) or $10/user/month |
| **Slack** | Workspace with app installation permissions | Free or paid plan |
| **Competitor RSS Feeds** | 5 valid RSS/Atom feed URLs | Free |

### Technical Requirements

- n8n version 1.0 or higher
- Internet connectivity for API calls
- ~100 MB disk space for workflow execution history

### Skills Needed

- Basic n8n workflow understanding
- Airtable familiarity (creating bases/tables)
- Slack app configuration (beginner level)
- JSON/API concepts (helpful but not required)

---

## Step 1: Prepare Competitor RSS Feed URLs

### 1.1 Identify Target Competitors

List 5 competitors you want to monitor:

```
Competitor 1: _____________________
Competitor 2: _____________________
Competitor 3: _____________________
Competitor 4: _____________________
Competitor 5: _____________________
```

### 1.2 Find RSS Feed URLs

Most company blogs have RSS feeds. Common locations:

**Standard URLs to Try**:
- `https://[company].com/blog/feed/`
- `https://[company].com/blog/rss.xml`
- `https://[company].com/feed.xml`
- `https://blog.[company].com/rss`

**How to Find**:
1. Visit competitor's blog homepage
2. Look for RSS icon (usually in footer or sidebar)
3. Right-click RSS link → Copy Link Address
4. Or view page source and search for "rss" or "feed"

**If No RSS Feed Exists**:
Use a service like [FetchRSS](https://fetchrss.com/) or [Feed43](https://feed43.com/) to create an RSS feed from any webpage.

**Example Configuration**:
```javascript
feedUrls: [
  "https://www.selenium.dev/blog/feed.xml",
  "https://testsigma.com/blog/feed/",
  "https://www.browserstack.com/blog/feed/",
  "https://www.ranorex.com/blog/feed/",
  "https://www.tricentis.com/blog/feed/"
],
competitors: [
  "Selenium",
  "Testsigma",
  "BrowserStack",
  "Ranorex",
  "Tricentis"
]
```

### 1.3 Validate RSS Feeds

Test each feed URL:
1. Open URL in browser
2. You should see XML content (not HTML)
3. Verify recent posts appear (check `<pubDate>` tags)

**Validation Tool**: https://validator.w3.org/feed/

---

## Step 2: Set Up Airtable Base

### 2.1 Create New Base

1. Log in to Airtable (https://airtable.com)
2. Click **"Add a base"** → **"Start from scratch"**
3. Name it: **"Katalon Agent Factory"** (or your preferred name)
4. Click into the new base

### 2.2 Create RSS Feed Items Table

1. Rename the default table from "Table 1" to **"RSS Feed Items"**
2. Delete default fields (Name, Notes, etc.)
3. Add the following 16 fields:

| Field Name | Field Type | Configuration |
|------------|------------|---------------|
| **Item Title** | Single line text | (default settings) |
| **Competitor** | Single line text | (default settings) |
| **Post URL** | URL | (default settings) |
| **Published Date** | Date & time | Include time, Use GMT |
| **Discovered Date** | Date & time | Include time, Use GMT |
| **Content Snippet** | Long text | (default settings) |
| **Full Content** | Long text | Enable rich text formatting |
| **Author** | Single line text | (default settings) |
| **Categories** | Multiple select | Add options: Product Launch, Feature Update, Company News, Technical, Customer Story, Industry Insights, Thought Leadership |
| **Analysis Status** | Single select | Add options: Pending, Analyzed, Skipped, Error |
| **Priority Score** | Number | Integer, 0-100 range |
| **Research Result** | Long text | Enable rich text formatting |
| **Strategic Value** | Single select | Add options: High, Medium, Low, None |
| **Flagged** | Checkbox | (default settings) |
| **Notes** | Long text | (default settings) |

**Field Creation Tips**:
- Click **"+"** button to add each field
- Choose field type carefully (can't easily change later)
- For Multiple Select fields, add all options at once

### 2.3 Get Base ID and Table ID

**Method 1: From URL**
When viewing your table, the URL is:
```
https://airtable.com/appXXXXXXXXXXXXXX/tblYYYYYYYYYYYYYY
                     └─── Base ID ──┘ └─── Table ID ──┘
```

**Method 2: From API Page**
1. Go to https://airtable.com/api
2. Select your base
3. IDs are shown in example code

**Save These Values**:
```
Base ID:  app_________________
Table ID: tbl_________________
```

### 2.4 Create Recommended Views

**View: High Priority Intelligence**
1. Click **"+"** next to "Grid view"
2. Name: "High Priority Intelligence"
3. Add filter: Priority Score >= 70
4. Sort by: Priority Score (descending)

**View: By Competitor**
1. Create new view
2. Name: "By Competitor"
3. Group by: Competitor
4. Sort by: Published Date (newest first)

---

## Step 3: Configure Slack Notifications

### 3.1 Create Slack Channel

1. In Slack, create a new channel: `#competitor-monitoring` (or your preferred name)
2. Add team members who should receive alerts
3. Note the channel name

### 3.2 Create Slack App

1. Go to https://api.slack.com/apps
2. Click **"Create New App"** → **"From scratch"**
3. App Name: "KAF Agent-1B"
4. Select your workspace
5. Click **"Create App"**

### 3.3 Configure OAuth & Permissions

1. In app settings, click **"OAuth & Permissions"** (left sidebar)
2. Scroll to **"Scopes"** → **"Bot Token Scopes"**
3. Add these scopes:
   - `chat:write` (Send messages)
   - `channels:read` (View basic channel info)
4. Scroll to top, click **"Install to Workspace"**
5. Click **"Allow"**
6. Copy the **"Bot User OAuth Token"** (starts with `xoxb-`)

**Save This Value**:
```
Slack Bot Token: xoxb-_______________
```

### 3.4 Invite Bot to Channel

1. In Slack, go to `#competitor-monitoring` channel
2. Type: `/invite @KAF Agent-1B`
3. Bot should join the channel

### 3.5 Get Channel ID

**Method 1: From Channel URL**
1. Click channel name → View channel details
2. Scroll to bottom, see Channel ID

**Method 2: From Slack API Tester**
1. Go to https://api.slack.com/methods/conversations.list/test
2. Select your app
3. Click **"Test Method"**
4. Find your channel in results, copy `id` field

**Save This Value**:
```
Channel ID: C_______________
```

---

## Step 4: Set Up n8n Credentials

### 4.1 Google Gemini API Credential

1. **Get API Key**:
   - Go to https://aistudio.google.com/app/apikey
   - Click **"Create API Key"**
   - Select existing Google Cloud project or create new
   - Copy API key

2. **Add to n8n**:
   - In n8n, click **Settings** → **Credentials**
   - Click **"Add Credential"** → Search "Google PaLM"
   - Select **"Google PaLM (Gemini) Api"**
   - Paste API key
   - Name: "Google Gemini API"
   - Click **"Save"**

### 4.2 Airtable Credential

1. **Get Personal Access Token**:
   - In Airtable, click profile icon → **"Developer hub"**
   - Click **"Create new token"**
   - Name: "n8n KAF Integration"
   - Add scopes: `data.records:read`, `data.records:write`, `schema.bases:read`
   - Add access to your base
   - Click **"Create token"**
   - Copy token (starts with `pat`)

2. **Add to n8n**:
   - In n8n, **Credentials** → **"Add Credential"**
   - Search "Airtable Token"
   - Select **"Airtable Personal Access Token"**
   - Paste token
   - Name: "Airtable KAF Access"
   - Click **"Save"**

### 4.3 Slack Credential

1. **Add to n8n**:
   - In n8n, **Credentials** → **"Add Credential"**
   - Search "Slack OAuth2"
   - Select **"Slack OAuth2 API"**
   - Paste Bot User OAuth Token (from Step 3.3)
   - Name: "Slack KAF Bot"
   - Click **"Save"**

---

## Step 5: Import and Configure Workflow

### 5.1 Download Workflow JSON

1. Download file: `workflows/agent-1b-v4-multi-feed.json` from repository
2. Save to your computer

### 5.2 Import to n8n

1. In n8n, click **"Workflows"** (left sidebar)
2. Click **"Add Workflow"** → **"Import from File"**
3. Select `agent-1b-v4-multi-feed.json`
4. Click **"Import"**
5. Workflow opens in editor

### 5.3 Update RSS Feed Configuration

**Node: "RSS Feed Array Setup" (Node 2)**

1. Click the **"RSS Feed Array Setup"** code node
2. Replace the placeholder arrays with your actual data:

```javascript
return [
  {
    json: {
      feedUrls: [
        "https://your-competitor-1.com/blog/feed/",  // Replace with actual URLs
        "https://your-competitor-2.com/blog/feed/",
        "https://your-competitor-3.com/blog/feed/",
        "https://your-competitor-4.com/blog/feed/",
        "https://your-competitor-5.com/blog/feed/"
      ],
      competitors: [
        "Competitor 1 Name",  // Replace with actual names (must match feedUrls order)
        "Competitor 2 Name",
        "Competitor 3 Name",
        "Competitor 4 Name",
        "Competitor 5 Name"
      ]
    }
  }
];
```

3. Click **"Execute Node"** to test (should output your arrays)
4. Verify no errors

### 5.4 Update Airtable Nodes

**Node: "Create RSS Feed Item in Airtable" (Node 11)**

1. Click the node
2. Update **"Credential to connect with"**: Select "Airtable KAF Access"
3. Update **"Base"**:
   - Click dropdown
   - If you see your base, select it
   - Otherwise, select "By ID" and enter your Base ID: `app_______________`
4. Update **"Table"**:
   - Click dropdown
   - If you see "RSS Feed Items", select it
   - Otherwise, select "By ID" and enter your Table ID: `tbl_______________`
5. Verify field mappings match your Airtable field names (should auto-populate)
6. Click **"Execute Node"** to test (should create a test record - delete it after)

### 5.5 Update Slack Node

**Node: "Slack Notification" (Node 12)**

1. Click the node
2. Update **"Credential to connect with"**: Select "Slack KAF Bot"
3. Update **"Channel"**:
   - Click dropdown to list channels
   - Select your `#competitor-monitoring` channel
   - Or select "By ID" and enter Channel ID: `C_______________`
4. Review message template (customize if desired)
5. Click **"Execute Node"** to test (should send a test message to channel)

### 5.6 Update Gemini Nodes

**Nodes: "Message a model" (Node 7) and "Google Gemini Chat Model" (Node 9)**

1. Click **"Message a model"** node
2. Update **"Credential to connect with"**: Select "Google Gemini API"
3. Click **"Google Gemini Chat Model"** node
4. Update **"Credential to connect with"**: Select "Google Gemini API"

---

## Step 6: Test the Workflow

### 6.1 Manual Test Execution

1. **Important**: Do NOT activate the workflow yet
2. Click **"Execute Workflow"** button (play icon at bottom)
3. Wait for execution to complete (45-90 seconds)
4. Check execution panel for green checkmarks on all nodes

### 6.2 Verify Results

**Check Airtable**:
1. Open your "RSS Feed Items" table
2. You should see new records (1-10, depending on how many posts were published in last 24 hours)
3. Verify all fields are populated correctly:
   - Item Title, Competitor, Post URL filled
   - Research Result has full AI analysis
   - Priority Score is a number 0-100
   - Categories are selected

**Check Slack**:
1. Open `#competitor-monitoring` channel
2. You should see notification(s) for each new post discovered
3. Verify links are clickable

### 6.3 Troubleshoot Test Failures

**If execution fails**:
1. Click the red "X" on failed node
2. Read error message carefully
3. Common issues:
   - **"Credential not found"**: Reselect credential in node
   - **"Base not found"**: Check Base ID is correct
   - **"Field not found"**: Check field names match exactly (case-sensitive)
   - **"Invalid feed URL"**: Verify RSS feed is accessible

See **TROUBLESHOOTING.md** for detailed solutions.

---

## Step 7: Adjust Schedule and Activate

### 7.1 Configure Schedule

**Node: "Schedule Trigger - Every 24 Hours" (Node 1)**

1. Click the node
2. Current setting: Every 24 hours (runs once daily at time of activation)
3. To change frequency:
   - **Twice daily**: Change to 12 hours
   - **Specific time**: Use cron expression

**Example: Run every day at 2:00 AM UTC**:
```json
{
  "parameters": {
    "rule": {
      "interval": [
        {
          "field": "cronExpression",
          "expression": "0 2 * * *"
        }
      ]
    }
  }
}
```

### 7.2 Activate Workflow

1. Click **"Active"** toggle switch (top right)
2. Workflow status changes from "Inactive" to "Active"
3. Schedule trigger is now armed
4. First execution will occur based on schedule (e.g., 24 hours from now, or at scheduled time)

### 7.3 Monitor First Scheduled Execution

**After first scheduled run (e.g., next day)**:
1. Go to **"Executions"** tab
2. Find most recent execution
3. Click to review
4. Verify success (all green checkmarks)
5. Check Airtable and Slack for new data

---

## Step 8: Ongoing Maintenance

### 8.1 Daily Tasks (5 minutes)

- Review Airtable "High Priority Intelligence" view
- Action flagged items
- Archive old records (>30 days)

### 8.2 Weekly Tasks (15 minutes)

- Review all new competitive intelligence
- Update internal battle cards
- Share insights with stakeholders

### 8.3 Monthly Tasks (30 minutes)

- Analyze trends (are competitors posting more Product Launches?)
- Adjust competitor list (add/remove feeds)
- Review workflow execution history
- Check API costs

### 8.4 Quarterly Tasks (1 hour)

- Comprehensive competitive intelligence report
- Adjust AI analysis prompts (if needed)
- Review and archive old Airtable records
- Optimize workflow performance

---

## Advanced Configuration

### Adding More Competitors

1. Edit **"RSS Feed Array Setup"** node
2. Add feed URL and name to arrays:
```javascript
feedUrls: [
  // ... existing 5 feeds
  "https://new-competitor.com/blog/feed/"  // Add here
],
competitors: [
  // ... existing 5 names
  "New Competitor Name"  // Add here (must match order)
]
```
3. Save and test
4. **Note**: Each additional competitor adds ~10-15 seconds to execution time

### Changing Time Window

Default: 24 hours (only process posts from last day)

**To change to 48 hours**:
1. Edit **"Filter New Posts (24h)"** node
2. Change expression:
```javascript
$now.minus({days: 2}).toISO()  // Changed from {days: 1}
```

### Customizing AI Analysis Prompt

**Edit "Message a model" node**:
1. Click node
2. Modify system prompt to emphasize specific areas:
```
Additional focus areas:
- Technical implementation details
- Pricing and packaging signals
- Customer segment targeting
- Geographic expansion signals
```

### Adding Email Notifications

**Create new node after Slack**:
1. Add **"Send Email"** node
2. Connect from "Slack Notification" node
3. Configure:
   - **To**: competitive-intel@yourcompany.com
   - **Subject**: `New High Priority Intelligence: {{ $json.output.rss_item_analysis.priority_score }}`
   - **Text**: Include post details
4. Add **IF** node before email to only send if Priority >= 85

---

## Cost Estimation

### Monthly Operating Costs

**Assumptions**:
- 5 competitors
- Average 2 new posts per competitor per week
- ~40 total posts per month
- Gemini 2.5 Pro pricing: $0.002/1K input tokens, $0.006/1K output tokens

**Breakdown**:
| Service | Monthly Cost |
|---------|--------------|
| Gemini API | ~$0.24 |
| Airtable | $0 (Free tier) or $10/user |
| Slack | $0 (Free tier) or included in plan |
| n8n | $0 (self-hosted) or $20/month |
| **Total** | **$0.24 - $30.24** |

**Cost Savings vs Manual**:
- Manual competitive monitoring: ~5 hours/month @ $50/hr = $250/month
- Agent-1B V4 cost: $0.24/month
- **Savings: $249.76/month (99.9%)**

---

## Success Criteria

✅ **After 1 Week**:
- Workflow executed 7 times successfully
- 10-50 blog posts discovered and analyzed
- Team reviewing Airtable daily
- Zero execution failures

✅ **After 1 Month**:
- 40-200 competitive intelligence records
- High priority insights actioned (product, marketing, sales)
- Battle cards updated with new intelligence
- ROI clearly demonstrated (time saved, insights gained)

✅ **After 3 Months**:
- Trends identified (competitor posting patterns)
- Strategic decisions informed by intelligence
- Workflow integrated into competitive process
- Team could not imagine working without it

---

## Next Steps

1. **Complete this implementation guide** step-by-step
2. **Test thoroughly** before activating schedule
3. **Train your team** on reviewing Airtable intelligence
4. **Establish workflows** for acting on insights (update battle cards, brief product team, etc.)
5. **Scale** by adding more competitors or deploying additional agent workflows

---

## Support Resources

- **Technical Documentation**: N8N-WORKFLOW.md, AIRTABLE-SCHEMA.md
- **Troubleshooting**: TROUBLESHOOTING.md
- **Community**: n8n community forum, Airtable community
- **Professional Support**: Anthropic (Gemini), n8n support channels

---

## Checklist

Use this checklist to track your implementation progress:

- [ ] Step 1: RSS feed URLs collected and validated (5 competitors)
- [ ] Step 2: Airtable base created with 16 fields configured
- [ ] Step 3: Slack channel and app configured, channel ID obtained
- [ ] Step 4: All 3 n8n credentials created and tested
- [ ] Step 5: Workflow imported and all nodes configured
- [ ] Step 6: Test execution successful (green checkmarks)
- [ ] Step 6: Airtable records created correctly
- [ ] Step 6: Slack notifications received
- [ ] Step 7: Schedule configured for desired frequency
- [ ] Step 7: Workflow activated
- [ ] Step 8: First scheduled execution verified successful
- [ ] Team trained on using Airtable intelligence
- [ ] Success criteria for Week 1 met

---

**Implementation Guide Version**: 1.0
**Last Updated**: November 19, 2025
**Estimated Setup Time**: 45-60 minutes
**Maintained By**: KAF Team

🎉 **Congratulations!** You've successfully deployed Agent-1B V4 Multi-Feed RSS Monitor. Your automated competitive intelligence system is now running 24/7.
