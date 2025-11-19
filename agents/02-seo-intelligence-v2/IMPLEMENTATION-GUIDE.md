# Agent-2 SEO Intelligence V2 - Implementation Guide

## Overview

This guide provides step-by-step instructions for deploying Agent-2 SEO Intelligence V2 in your environment. Follow these steps to set up weekly automated SEO competitive intelligence for your business.

**Estimated Time:** 60-90 minutes
**Difficulty:** Intermediate
**Prerequisites:** n8n instance, Airtable account, Slack workspace, API access for Perplexity and Google Gemini

---

## Table of Contents

1. [Prerequisites Check](#prerequisites-check)
2. [Prepare Competitor List](#step-1-prepare-competitor-list)
3. [Set Up Airtable Base](#step-2-set-up-airtable-base)
4. [Configure Slack Notifications](#step-3-configure-slack-notifications)
5. [Set Up n8n Credentials](#step-4-set-up-n8n-credentials)
6. [Import and Configure Workflow](#step-5-import-and-configure-workflow)
7. [Test Workflow](#step-6-test-workflow)
8. [Activate and Schedule](#step-7-activate-and-schedule)
9. [Ongoing Maintenance](#step-8-ongoing-maintenance)
10. [Cost Management](#cost-management)

---

## Prerequisites Check

Before starting implementation, verify you have:

### Required Services

- [ ] **n8n Instance**
  - Version: 1.0+ recommended
  - Self-hosted OR n8n.cloud account
  - Sufficient execution timeout (30 minutes minimum)
  - Langchain nodes available (@n8n/n8n-nodes-langchain)

- [ ] **Airtable Account**
  - Free or paid tier
  - Ability to create new bases
  - API access enabled
  - Personal Access Token with write permissions

- [ ] **Slack Workspace**
  - Admin or bot creation permissions
  - Ability to create OAuth apps
  - Channel for notifications (e.g., #seo-intelligence)

- [ ] **Perplexity API Access**
  - API key with Sonar Pro access
  - Sufficient credit balance (at least $10)
  - Understand pricing: ~$0.06 per competitor analysis

- [ ] **Google Gemini API Access**
  - Google Cloud Project with Gemini API enabled
  - API key or service account
  - Access to gemini-2.0-flash-exp model
  - Understand pricing: ~$0.12 per competitor analysis

### Required Knowledge

- [ ] Basic n8n workflow editing
- [ ] JSON data structure understanding
- [ ] Airtable base management
- [ ] API credential configuration

### Estimated Costs

| Component | Setup Cost | Monthly Cost |
|-----------|-----------|--------------|
| n8n hosting | $0 (self-hosted) or $20 (cloud) | $20 (if cloud) |
| Perplexity API | $0 | ~$1.20 (5 competitors × 4 weeks) |
| Google Gemini API | $0 | ~$2.40 (5 competitors × 4 weeks) |
| Airtable | $0 (free tier) | $0-$20 (pro if needed) |
| Slack | $0 | $0 |
| **Total** | **$0-$20** | **$3.60-$43.60** |

---

## Step 1: Prepare Competitor List

### 1.1 Identify Competitors

Create a list of 3-7 competitors to monitor. Choose competitors based on:

**Selection Criteria:**
- Direct product competitors (same market)
- Share target keywords and audience
- Active content marketing strategy
- Significant organic search presence
- Publicly accessible blog/content hub

**Example Competitor List (Test Automation Industry):**
```
1. Selenium (https://www.selenium.dev/)
2. Cypress (https://www.cypress.io/)
3. Playwright (https://playwright.dev/)
4. TestCafe (https://testcafe.io/)
5. Puppeteer (https://pptr.dev/)
```

### 1.2 Research Competitor Details

For each competitor, gather:

| Field | Example | How to Find |
|-------|---------|-------------|
| **Name** | Selenium | Official website |
| **Website** | https://www.selenium.dev/ | Main homepage URL |
| **Focus Areas** | web automation, browser testing, open source | About page, product descriptions |
| **Primary Keywords** | selenium webdriver, selenium grid, selenium ide | Ahrefs, SEMrush, or manual research |
| **Content Hub** | https://www.selenium.dev/blog/ | Find /blog, /resources, /learn sections |

### 1.3 Create Competitor Data Sheet

Use this template to organize your research:

```json
{
  "competitors": [
    {
      "name": "Competitor Name",
      "website": "https://www.example.com/",
      "focus_areas": ["area 1", "area 2", "area 3"],
      "primary_keywords": ["keyword 1", "keyword 2", "keyword 3"],
      "content_hub": "https://www.example.com/blog/"
    }
  ]
}
```

**Save this file:** You'll paste this into the workflow in Step 5.

**Time Required:** 20-30 minutes

---

## Step 2: Set Up Airtable Base

### 2.1 Create New Airtable Base

1. Log into [Airtable](https://airtable.com/)
2. Click "Add a base" → "Start from scratch"
3. Name your base: **"Katalon Agent Factory"** (or your company name)
4. Rename the default table to: **"Competitor SEO Analysis"**

### 2.2 Create Schema Fields

Add these fields to your table (in order):

| # | Field Name | Type | Configuration |
|---|------------|------|---------------|
| 1 | Competitor Name | Single line text | - |
| 2 | Analysis Date | Date & time | Include time, Use GMT |
| 3 | Executive Summary | Long text | Enable rich text |
| 4 | Content Strategy Overview | Long text | Enable rich text |
| 5 | Content Types | Long text | - |
| 6 | Top Performing Topics | Long text | - |
| 7 | Content Depth Score | Single line text | - |
| 8 | Organic Visibility | Long text | Enable rich text |
| 9 | Top Keywords | Long text | - |
| 10 | Domain Authority | Single line text | - |
| 11 | SERP Features | Long text | - |
| 12 | Traffic Estimate | Single line text | - |
| 13 | Content Gaps (JSON) | Long text | - |
| 14 | Content Tactics (JSON) | Long text | - |
| 15 | SEO Tactics (JSON) | Long text | - |
| 16 | Competitive Threats (JSON) | Long text | - |
| 17 | Katalon Advantages (JSON) | Long text | - |
| 18 | Strategic Priority Score | Number | Integer, 0-100 |
| 19 | Analysis Confidence | Single select | Options: High, Medium, Low |
| 20 | Data Freshness | Single line text | - |
| 21 | Review Frequency | Single select | Options: Weekly, Bi-Weekly, Monthly, Quarterly |
| 22 | Workflow Execution ID | Single line text | - |
| 23 | Status | Single select | Options: New Analysis, Under Review, Actions Planned, In Progress, Completed, Archived |
| 24 | Assigned To | User | Optional, link to collaborators |
| 25 | Action Items | Long text | Enable rich text |
| 26 | Notes | Long text | Enable rich text |

**Single Select Field Setup:**

For **Analysis Confidence:**
```
- High (color: green)
- Medium (color: yellow)
- Low (color: red)
```

For **Review Frequency:**
```
- Weekly (color: red)
- Bi-Weekly (color: orange)
- Monthly (color: yellow)
- Quarterly (color: blue)
```

For **Status:**
```
- New Analysis (color: blue)
- Under Review (color: yellow)
- Actions Planned (color: orange)
- In Progress (color: purple)
- Completed (color: green)
- Archived (color: gray)
```

### 2.3 Configure Default View

1. Hide "Last Modified" and "Created Time" columns (keep them in schema)
2. Set default sort: **Analysis Date** (descending)
3. Set default filter: **Status** is not "Archived"
4. Adjust column widths for readability

### 2.4 Create Recommended Views

**Create these additional views:**

**View 1: New Analyses**
- Filter: Status = "New Analysis"
- Sort: Analysis Date (newest first)
- Show: Competitor Name, Analysis Date, Strategic Priority Score, Executive Summary, Status

**View 2: High Priority**
- Filter: Strategic Priority Score >= 70 AND Status != "Completed" AND Status != "Archived"
- Sort: Strategic Priority Score (descending)
- Show: All fields

**View 3: By Competitor**
- Group by: Competitor Name
- Sort: Analysis Date (newest first)
- Show: All fields

### 2.5 Get Airtable Credentials

1. Click your profile picture (top right) → Account
2. Go to "Developers" section
3. Click "Personal Access Tokens" → "Create token"
4. Name: **"n8n Agent-2 SEO Intelligence"**
5. Scopes:
   - ✅ `data.records:read`
   - ✅ `data.records:write`
   - ✅ `schema.bases:read`
6. Access: Select your "Katalon Agent Factory" base
7. Click "Create token" → **Copy and save the token securely**

### 2.6 Get Base and Table IDs

**Base ID:**
1. Open your Airtable base
2. Look at URL: `https://airtable.com/appXXXXXXXXXXXXXX/...`
3. Copy the part starting with `app...` → This is your **Base ID**

**Table ID:**
1. In your base, click "..." next to table name
2. Click "Copy table ID"
3. Save this → This is your **Table ID**

**Save these values:**
```
AIRTABLE_BASE_ID=appXXXXXXXXXXXXXX
AIRTABLE_TABLE_NAME=Competitor SEO Analysis
AIRTABLE_API_TOKEN=patXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

**Time Required:** 20-30 minutes

---

## Step 3: Configure Slack Notifications

### 3.1 Create Slack Channel

1. In your Slack workspace, create a new channel
2. Recommended name: **#seo-intelligence** or **#marketing-automation**
3. Set channel description:
   ```
   Weekly SEO competitive intelligence from Agent-2.
   Automated analyses of competitor content and SEO strategies.
   ```
4. Add relevant team members (marketing, SEO, content strategists)

### 3.2 Create Slack App

1. Go to [Slack API](https://api.slack.com/apps)
2. Click "Create New App" → "From scratch"
3. App Name: **"Agent-2 SEO Intelligence Bot"**
4. Select your workspace
5. Click "Create App"

### 3.3 Configure OAuth Scopes

1. In your app settings, go to "OAuth & Permissions"
2. Scroll to "Scopes" → "Bot Token Scopes"
3. Add these scopes:
   - ✅ `chat:write` (send messages)
   - ✅ `channels:read` (view channel list)
   - ✅ `chat:write.public` (send to public channels)
4. Scroll to top, click "Install to Workspace"
5. Review permissions, click "Allow"
6. **Copy the "Bot User OAuth Token"** (starts with `xoxb-...`)

### 3.4 Add Bot to Channel

1. Go to your #seo-intelligence channel in Slack
2. Type `/invite @Agent-2 SEO Intelligence Bot`
3. Verify bot appears in channel members

### 3.5 Get Channel ID

**Method 1: From Slack**
1. Right-click your #seo-intelligence channel
2. Select "Copy link"
3. URL looks like: `https://yourworkspace.slack.com/archives/C01XXXXXXXXXX`
4. Copy `C01XXXXXXXXXX` → This is your **Channel ID**

**Method 2: Test message**
1. Use Slack API tester: https://api.slack.com/methods/conversations.list/test
2. Select your OAuth token
3. Click "Test Method"
4. Find your channel in results, note the ID

**Save these values:**
```
SLACK_BOT_TOKEN=xoxb-XXXXXXXXXXXX-XXXXXXXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXX
SLACK_CHANNEL_ID=C01XXXXXXXXXX
SLACK_CHANNEL_NAME=#seo-intelligence
```

**Time Required:** 10-15 minutes

---

## Step 4: Set Up n8n Credentials

### 4.1 Perplexity Credential

1. Get Perplexity API key from [Perplexity Console](https://www.perplexity.ai/settings/api)
2. In n8n, go to **Credentials** → **New Credential**
3. Search for "Perplexity API"
4. If not found, use "HTTP Request Auth":
   - **Name:** Perplexity API
   - **Auth Type:** Bearer Token
   - **Token:** [Your Perplexity API Key]
5. Click "Save"

### 4.2 Google Gemini Credential

1. Get Gemini API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. In n8n, go to **Credentials** → **New Credential**
3. Search for "Google Gemini API" or "Google PaLM API"
4. Configure:
   - **Name:** Google Gemini 2.0
   - **API Key:** [Your Gemini API Key]
   - **Project ID:** (optional, your Google Cloud project)
5. Click "Save"

**Alternative: Service Account (Production)**
- Create service account in Google Cloud Console
- Enable Vertex AI API
- Download JSON key
- Use "Google Cloud Service Account" credential in n8n

### 4.3 Airtable Credential

1. In n8n, go to **Credentials** → **New Credential**
2. Search for "Airtable API"
3. Configure:
   - **Name:** Airtable - KAF
   - **Authentication:** Access Token
   - **Access Token:** [Your Airtable Personal Access Token from Step 2.5]
4. Click "Test" to verify connection
5. Click "Save"

### 4.4 Slack Credential

1. In n8n, go to **Credentials** → **New Credential**
2. Search for "Slack OAuth2 API"
3. Configure:
   - **Name:** Slack - SEO Intelligence Bot
   - **OAuth Version:** OAuth2
   - **Client ID:** [From your Slack App → Basic Information]
   - **Client Secret:** [From your Slack App → Basic Information]
4. Click "Connect my account"
5. Authorize in popup window
6. Verify "Connected" status
7. Click "Save"

### 4.5 Verify All Credentials

Checklist:
- [ ] Perplexity API credential saved
- [ ] Google Gemini credential saved and tested
- [ ] Airtable credential saved and tested
- [ ] Slack OAuth credential connected

**Time Required:** 15-20 minutes

---

## Step 5: Import and Configure Workflow

### 5.1 Import Workflow JSON

1. Download workflow JSON: [agent-2-seo-intelligence-v2.json](../../workflows/agent-2-seo-intelligence-v2.json)
2. In n8n, go to **Workflows** → **Add Workflow**
3. Click "..." menu → "Import from File"
4. Select downloaded JSON file
5. Workflow appears in canvas

### 5.2 Update Workflow Credentials

**Node 5: SEO Research (Perplexity)**
1. Click node to open settings
2. Under "Credentials", select your **Perplexity API** credential
3. Save node

**Node 6: Strategic Analysis (Gemini)**
1. Click node to open settings
2. Under "Credentials", select your **Google Gemini 2.0** credential
3. Verify model is set to `gemini-2.0-flash-exp`
4. Save node

**Node 8: Save to Airtable**
1. Click node to open settings
2. Under "Credentials", select your **Airtable - KAF** credential
3. Update **Base ID**: Enter your Airtable Base ID from Step 2.6
4. Update **Table Name**: Enter "Competitor SEO Analysis"
5. Verify field mappings match your schema
6. Save node

**Node 9: Slack Notification**
1. Click node to open settings
2. Under "Credentials", select your **Slack - SEO Intelligence Bot** credential
3. Update **Channel**: Enter your channel ID (e.g., `C01XXXXXXXXXX`)
4. Review message template, customize if desired
5. Save node

### 5.3 Configure Competitor List

**Node 2: Competitor SEO Array Setup**
1. Click node to open settings
2. Replace the `competitors` array with your data from Step 1.3
3. Verify JSON is valid (no syntax errors)
4. Update `analysis_date` to use dynamic timestamp:
   ```javascript
   analysis_date: new Date().toISOString()
   ```
5. Save node

**Example configuration:**
```javascript
return [
  {
    json: {
      competitors: [
        {
          name: "Selenium",
          website: "https://www.selenium.dev/",
          focus_areas: ["web automation", "browser testing", "open source"],
          primary_keywords: ["selenium webdriver", "selenium grid", "selenium ide"],
          content_hub: "https://www.selenium.dev/blog/"
        },
        {
          name: "Cypress",
          website: "https://www.cypress.io/",
          focus_areas: ["e2e testing", "developer experience", "modern web"],
          primary_keywords: ["cypress testing", "cypress io", "javascript testing"],
          content_hub: "https://www.cypress.io/blog/"
        }
        // Add your other competitors...
      ],
      analysis_date: new Date().toISOString(),
      analysis_type: "weekly_seo_intelligence"
    }
  }
];
```

### 5.4 Adjust Schedule (Optional)

**Node 1: Schedule Trigger**
1. Click node to open settings
2. Default: Every Monday at 9:00 AM ET
3. To change:
   - Adjust **Day of Week** (Monday recommended)
   - Adjust **Hour** (9 AM recommended)
   - Adjust **Timezone** to your local timezone
4. Save node

**Recommended schedules:**
- **Weekly:** Monday 9 AM (captures weekend content)
- **Bi-Weekly:** Every other Monday
- **Monthly:** First Monday of month

### 5.5 Save Workflow

1. Click workflow name at top, rename to: **"Agent-2 SEO Intelligence V2"**
2. Click "Save" (top right)
3. Verify all nodes have no warning icons

**Time Required:** 15-20 minutes

---

## Step 6: Test Workflow

### 6.1 Disable Schedule Trigger (For Testing)

1. Click **Node 1: Schedule Trigger**
2. Toggle to "Execute Once" or disable
3. This prevents accidental scheduled execution during testing

### 6.2 Test with Single Competitor

**Modify Node 2 for testing:**
1. Temporarily reduce competitor array to just 1 competitor
2. Choose a competitor you know well (easier to validate results)
3. Example:
   ```javascript
   competitors: [
     {
       name: "Selenium",
       website: "https://www.selenium.dev/",
       focus_areas: ["web automation", "browser testing"],
       primary_keywords: ["selenium webdriver", "selenium testing"],
       content_hub: "https://www.selenium.dev/blog/"
     }
   ]
   ```
4. Save node

### 6.3 Manual Execution

1. Click **"Execute Workflow"** button (top right)
2. Watch execution in real-time:
   - **Node 5 (Perplexity):** Should take 30-60 seconds
   - **Node 6 (Gemini):** Should take 60-90 seconds
   - **Node 7 (JSON Extraction):** Should take 1-2 seconds
   - **Node 8 (Airtable):** Should take 2-3 seconds
   - **Node 9 (Slack):** Should take 1-2 seconds

3. Watch for success/error indicators on each node

### 6.4 Validate Results

**Check Airtable:**
1. Open your Airtable base
2. Verify new record created
3. Check these critical fields:
   - ✅ Competitor Name populated
   - ✅ Executive Summary is coherent and actionable
   - ✅ Content Gaps (JSON) has 5-7 items
   - ✅ Content Tactics (JSON) has 5 items
   - ✅ SEO Tactics (JSON) has 5 items
   - ✅ Strategic Priority Score is 1-100
   - ✅ All required fields populated

**Check Slack:**
1. Go to #seo-intelligence channel
2. Verify notification received
3. Check notification includes:
   - ✅ Competitor name
   - ✅ Analysis summary
   - ✅ Link to Airtable record
   - ✅ Execution ID

**Check n8n Execution Log:**
1. Go to n8n → **Executions**
2. Find your test execution
3. Review for any warnings or errors
4. Note execution time (should be 3-5 minutes)
5. Verify all nodes show green checkmarks

### 6.5 Validate Data Quality

**Review Airtable record content:**

1. **Executive Summary:**
   - Is it 2-3 paragraphs?
   - Does it provide strategic insights?
   - Is it actionable for your team?

2. **Content Gaps:**
   - Are there 5-7 gaps identified?
   - Are they realistic opportunities?
   - Do target keywords make sense?

3. **Recommendations:**
   - Are tactics specific and actionable?
   - Do rationales reference competitive insights?
   - Are priorities (High/Medium/Low) appropriate?

4. **JSON Validation:**
   - Copy Content Gaps (JSON) field
   - Paste into JSON validator: https://jsonlint.com/
   - Verify no syntax errors
   - Repeat for other JSON fields

### 6.6 Troubleshooting Test Issues

**If Perplexity node fails:**
- Check API key is valid
- Verify account has sufficient credits
- Check model is set to `sonar-pro`
- Review error message for rate limits

**If Gemini node fails:**
- Verify API key is correct
- Check model `gemini-2.0-flash-exp` is accessible
- Ensure Google Cloud project has Gemini API enabled
- Review quota limits in Google Cloud Console

**If Airtable node fails:**
- Verify field names match exactly (case-sensitive)
- Check Personal Access Token has write permissions
- Confirm Base ID and Table Name are correct
- Review Airtable field types match expectations

**If Slack node fails:**
- Verify bot is added to channel
- Check OAuth token is valid
- Confirm channel ID is correct
- Test with a simpler message first

**If JSON extraction fails:**
- Review Gemini output for invalid JSON
- Check Information Extractor schema matches prompt
- Verify all required fields present
- Adjust Gemini prompt if needed

### 6.7 Full Test (All Competitors)

Once single competitor test succeeds:

1. Restore full competitor list in Node 2
2. Execute workflow again (will take 15-25 minutes for 5 competitors)
3. Monitor execution progress
4. Verify all competitors get analyzed
5. Check Airtable has 5 new records (or your competitor count)
6. Confirm Slack notification includes all competitors

**Expected execution time:**
- 1 competitor: 3-5 minutes
- 5 competitors: 15-25 minutes
- 7 competitors: 21-35 minutes

**Time Required:** 30-45 minutes (including troubleshooting)

---

## Step 7: Activate and Schedule

### 7.1 Re-enable Schedule Trigger

1. Click **Node 1: Schedule Trigger**
2. Restore original schedule configuration:
   - Mode: "Every Week"
   - Day: Monday
   - Time: 9:00 AM
   - Timezone: Your timezone
3. Save node

### 7.2 Activate Workflow

1. In workflow canvas, find **"Inactive"** toggle (top right)
2. Click to change to **"Active"**
3. Workflow is now live and will execute on schedule

### 7.3 Verify Schedule

1. Go to n8n → **Workflows**
2. Find "Agent-2 SEO Intelligence V2"
3. Verify status shows "Active"
4. Check next execution time is correct

### 7.4 Set Execution Timeout (Important)

1. Go to n8n → **Settings** → **Workflow Settings**
2. Find **"Execution Timeout"**
3. Set to at least **30 minutes** (1800 seconds)
4. This prevents workflow from timing out during long Perplexity/Gemini calls
5. Save settings

### 7.5 Configure Error Notifications

**Option 1: n8n Cloud**
- Enable email notifications for failed executions
- Settings → Notifications → Workflow Errors

**Option 2: Self-Hosted**
- Add error trigger workflow
- Send Slack alert on failures
- Example: "Agent-2 failed at Node X with error Y"

### 7.6 Document Deployment

Create a simple deployment record:

```markdown
# Agent-2 SEO Intelligence V2 Deployment

**Deployed:** [Date]
**Deployed By:** [Your Name]
**Status:** Active ✅

**Configuration:**
- Competitors Monitored: [Number]
- Schedule: Every Monday, 9:00 AM ET
- Estimated Cost: $4/month
- Slack Channel: #seo-intelligence

**Credentials:**
- Perplexity: ✅ Configured
- Gemini: ✅ Configured
- Airtable: ✅ Configured
- Slack: ✅ Configured

**Next Execution:** [Date of next Monday 9 AM]

**Support Contact:** [Your email or team]
```

**Time Required:** 10-15 minutes

---

## Step 8: Ongoing Maintenance

### Weekly Maintenance (5 minutes)

**Monday After Execution:**
- [ ] Check Slack notification received
- [ ] Spot-check 1-2 Airtable records for quality
- [ ] Verify execution time was within normal range
- [ ] Review any error notifications

**Actions if Issues Found:**
- Check n8n execution logs
- Verify API credits sufficient (Perplexity, Gemini)
- Review data quality issues with prompts

### Monthly Maintenance (20-30 minutes)

**Review Workflow Performance:**
- [ ] Check success rate (target: >95%)
- [ ] Review average execution time
- [ ] Monitor API costs vs. budget
- [ ] Analyze data quality trends

**Update Competitor Data:**
- [ ] Verify competitor list still relevant
- [ ] Update focus areas if competitor pivots
- [ ] Refresh primary keywords based on market
- [ ] Add new competitors if needed

**Optimize Prompts:**
- [ ] Review Executive Summary quality
- [ ] Assess Content Gap relevance
- [ ] Evaluate Recommendation actionability
- [ ] Refine prompt language if needed

**Review Airtable Data:**
- [ ] Archive completed analyses (status = "Completed" for 90+ days)
- [ ] Clean up duplicate records (if any)
- [ ] Export data for trend analysis
- [ ] Share insights with stakeholders

### Quarterly Maintenance (1-2 hours)

**Strategic Review:**
- [ ] Evaluate competitor selection (still relevant?)
- [ ] Assess ROI of SEO intelligence
- [ ] Identify workflow improvements
- [ ] Plan content based on accumulated gaps

**Model Evaluation:**
- [ ] Research newer/better models (Gemini, Perplexity upgrades)
- [ ] Test alternative LLMs if available
- [ ] Compare cost vs. quality trade-offs
- [ ] Update workflow if better options exist

**Schema Updates:**
- [ ] Review Airtable schema for new fields needed
- [ ] Update workflow to populate new fields
- [ ] Migrate historical data if schema changes

**Documentation Updates:**
- [ ] Update implementation guide with learnings
- [ ] Document any custom modifications
- [ ] Share best practices with team

---

## Cost Management

### Monitor Monthly Costs

**Track Spending:**

| Service | Monitoring Method | Alert Threshold |
|---------|-------------------|-----------------|
| **Perplexity** | Check dashboard at perplexity.ai/settings/billing | >$2/month |
| **Google Gemini** | Google Cloud Console → Billing | >$3/month |
| **Airtable** | Airtable account usage page | Approaching free tier limit |
| **n8n Cloud** | n8n billing dashboard | >$20/month |

**Expected Monthly Costs (5 competitors, weekly):**
```
Perplexity Sonar Pro: $1.20
Google Gemini 2.0:    $2.40
Airtable:             $0.00 (free tier)
Slack:                $0.00 (free)
n8n Cloud:            $20.00 (if using cloud)
────────────────────────────
Total:                $23.60

OR (self-hosted n8n):  $3.60
```

### Cost Optimization Strategies

**If costs too high:**

1. **Reduce competitor count**
   - Monitor 3 instead of 5 competitors
   - Saves 40% on API costs

2. **Change to bi-weekly schedule**
   - Saves 50% on API costs
   - Still provides valuable insights

3. **Use cheaper models (with quality trade-off)**
   - Gemini 1.5 Flash instead of 2.0 Flash Exp
   - Regular Sonar instead of Sonar Pro
   - May reduce analysis quality

4. **Implement caching**
   - Cache competitor metadata (saves minimal cost)
   - Don't cache analysis (defeats purpose)

**If budget allows expansion:**

1. **Add more competitors** (7-10 total)
2. **Increase frequency** (bi-weekly instead of weekly)
3. **Add deeper analysis** (longer prompts, more context)

### Cost vs. Manual Comparison

**Monthly Cost Comparison:**

| Method | Time | Cost | Notes |
|--------|------|------|-------|
| **Manual Analysis** | 20 hrs | $1,000 | $50/hr analyst rate, 1 hr per competitor × 5 × 4 weeks |
| **Agent-2 V2 (self-hosted)** | 0.5 hrs | $3.60 | 30 min supervision, $3.60 API costs |
| **Agent-2 V2 (cloud)** | 0.5 hrs | $23.60 | 30 min supervision, $3.60 API + $20 n8n |
| **Savings (self-hosted)** | 19.5 hrs | $996.40 | 99.6% cost reduction |
| **Savings (cloud)** | 19.5 hrs | $976.40 | 97.6% cost reduction |

**ROI Calculation:**
- Self-hosted: **27,678% ROI** ($996.40 saved / $3.60 spent)
- Cloud: **4,137% ROI** ($976.40 saved / $23.60 spent)

---

## Success Criteria

Your implementation is successful when:

### Technical Success
- [ ] Workflow executes weekly without errors (>95% success rate)
- [ ] All 5 competitors analyzed each week
- [ ] Airtable records fully populated with quality data
- [ ] Slack notifications delivered reliably
- [ ] Execution time consistently 15-25 minutes

### Business Success
- [ ] Executive summaries are actionable and insightful
- [ ] Content gaps identified lead to new content ideas
- [ ] SEO recommendations drive measurable improvements
- [ ] Team reviews analyses regularly (status transitions)
- [ ] Strategic priority scores help prioritize work

### Quality Indicators
- [ ] Analysis confidence consistently "High"
- [ ] Content gaps are specific and realistic
- [ ] Recommendations include rationale and expected outcomes
- [ ] JSON fields parse without errors
- [ ] Data freshness indicator shows recent research

### ROI Markers
- [ ] Cost stays under $5/month (API costs)
- [ ] Saves 15+ hours/month vs. manual analysis
- [ ] Generates 10+ content ideas per month
- [ ] Informs SEO strategy improvements
- [ ] Competitive intelligence used in planning

---

## Troubleshooting Common Issues

### Issue: Workflow Times Out

**Symptoms:** Execution fails after 10-15 minutes

**Causes:**
- n8n execution timeout too low
- Perplexity/Gemini API slow response

**Solutions:**
1. Increase n8n execution timeout to 30+ minutes
2. Reduce competitor count per execution
3. Check API service status

---

### Issue: Low Quality Analyses

**Symptoms:** Executive summaries generic, gaps not useful

**Causes:**
- Perplexity search recency too broad
- Gemini prompt needs refinement
- Competitor data incomplete

**Solutions:**
1. Adjust Perplexity search recency (try "week" instead of "month")
2. Enhance Gemini prompt with more specific questions
3. Improve competitor metadata (focus areas, keywords)
4. Increase Gemini temperature slightly (0.4 → 0.5)

---

### Issue: High API Costs

**Symptoms:** Costs exceed $10/month

**Causes:**
- Too many competitors
- High token usage (long prompts/responses)
- Accidental duplicate executions

**Solutions:**
1. Reduce competitor count
2. Shorten prompts (reduce example text)
3. Change to bi-weekly schedule
4. Set Gemini max tokens lower (8000 → 6000)
5. Check for duplicate workflow activations

---

### Issue: Slack Notifications Not Received

**Symptoms:** Workflow succeeds but no Slack message

**Causes:**
- Bot not in channel
- OAuth token expired
- Channel ID incorrect

**Solutions:**
1. Re-invite bot to channel: `/invite @bot-name`
2. Refresh OAuth credential in n8n
3. Verify channel ID is correct
4. Test with different channel

---

## Next Steps

After successful deployment:

1. **Week 1-2:** Monitor closely
   - Check each execution manually
   - Validate data quality
   - Gather team feedback

2. **Week 3-4:** Optimize
   - Refine prompts based on learnings
   - Adjust competitor list if needed
   - Fine-tune schedule timing

3. **Month 2:** Integrate
   - Incorporate analyses into content planning
   - Use SEO recommendations in sprints
   - Track impact on organic traffic

4. **Month 3:** Scale
   - Add more competitors if valuable
   - Create dashboards from Airtable data
   - Share insights with broader team

---

## Additional Resources

**Documentation:**
- [README.md](./README.md) - Business overview and use cases
- [N8N-WORKFLOW.md](./N8N-WORKFLOW.md) - Technical node specifications
- [AIRTABLE-SCHEMA.md](./AIRTABLE-SCHEMA.md) - Complete database schema
- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - Error resolution guide

**External Resources:**
- [n8n Documentation](https://docs.n8n.io/)
- [Perplexity API Docs](https://docs.perplexity.ai/)
- [Google Gemini API Docs](https://ai.google.dev/docs)
- [Airtable API Reference](https://airtable.com/developers/web/api/introduction)
- [Slack API Documentation](https://api.slack.com/)

**Support:**
- Katalon Marketing Automation Team
- n8n Community Forum: https://community.n8n.io/
- Airtable Community: https://community.airtable.com/

---

**Last Updated:** 2025-11-19
**Guide Version:** 2.0
**Status:** ✅ Production Ready
