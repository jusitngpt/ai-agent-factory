# Airtable Database Schema - AI Agent Factory

This document provides complete table definitions for the AI Agent Factory Airtable base, including field configurations, relationships, and usage guidelines.

## Base Overview

**Base Name**: AI Agent Factory
**Purpose**: Centralized data storage for all agent operations
**Tables**: 7 (3 active, 4 planned)

## Active Tables (Agent 1A)

### 1. Research Requests

**Purpose**: Stores all incoming competitive research requests
**Primary Key**: Request ID (autonumber)
**Record Creation**: Manual (form/table) or automated (API)

#### Field Definitions

| Field Name | Field Type | Options/Config | Required | Description |
|------------|------------|----------------|----------|-------------|
| Request ID | Autonumber | Starting: 1, Increment: 1 | Auto | Unique identifier |
| Company Name | Single line text | Max 255 chars | ✅ Yes | Target company name |
| Research Focus | Long text | Enable rich text | ✅ Yes | Specific research angle or question |
| Status | Single select | Options below | ✅ Yes | Current request status |
| Priority | Single select | Low, Medium, High, Urgent | No | Request priority |
| Requested By | Single line text | Email or name | No | User who submitted request |
| Created Date | Created time | GMT, Date + Time | Auto | Timestamp of creation |
| Due Date | Date | Date only | No | Optional deadline |
| Notes | Long text | Enable rich text | No | Additional context or instructions |
| Link to Results | Link to another record | → Research Results | Auto | Link to completed research |
| Last Updated | Last modified time | GMT, Date + Time | Auto | Timestamp of last edit |
| Assigned To | Single line text | - | No | Team member assigned (future use) |

#### Status Field Options

1. **Pending** (default for new records)
   - Color: Yellow
   - Meaning: Queued for processing

2. **Processing**
   - Color: Blue
   - Meaning: n8n workflow currently executing

3. **Complete**
   - Color: Green
   - Meaning: Research finished, results available

4. **Failed**
   - Color: Red
   - Meaning: Error occurred, manual review needed

5. **Cancelled**
   - Color: Gray
   - Meaning: User cancelled request

#### Views

**All Requests** (default)
- Shows: All records
- Sort: Created Date (newest first)
- Group: None

**Active Requests**
- Filter: Status is not "Complete" AND not "Cancelled"
- Sort: Priority (Urgent → Low), then Created Date
- Group: By Status

**My Requests**
- Filter: Requested By = [User Email]
- Sort: Created Date (newest first)

**Failed Requests**
- Filter: Status = "Failed"
- Sort: Created Date (newest first)

**Pending Queue**
- Filter: Status = "Pending"
- Sort: Priority, then Created Date
- Use: Monitor automation queue

---

### 2. Research Results

**Purpose**: Stores completed research outputs from Agent 1A
**Primary Key**: Result ID (autonumber)
**Record Creation**: Automated (n8n workflow)

#### Field Definitions

| Field Name | Field Type | Options/Config | Required | Description |
|------------|------------|----------------|----------|-------------|
| Result ID | Autonumber | Starting: 1, Increment: 1 | Auto | Unique identifier |
| Request | Link to another record | ← Research Requests | ✅ Yes | Source request |
| Company Name | Lookup | From: Request → Company Name | Auto | For easy reference |
| Executive Summary | Long text | Enable rich text | ✅ Yes | 2-3 paragraph summary |
| Full Report | Long text | Enable rich text | ✅ Yes | Complete analysis from Claude |
| Key Findings | Long text | Enable rich text | ✅ Yes | Bullet point findings |
| Competitive Advantages | Long text | Enable rich text | No | Identified strengths |
| Weaknesses | Long text | Enable rich text | No | Identified vulnerabilities |
| Recommendations | Long text | Enable rich text | No | Strategic recommendations |
| Sources | Long text | Enable rich text | ✅ Yes | URLs and citations |
| Competitor Names | Multiple select | Dynamic | No | Identified competitors |
| Industries | Multiple select | Dynamic | No | Relevant industry tags |
| Confidence Score | Number | Precision: 0, Format: Integer | No | 0-100 quality score |
| Research Date | Created time | GMT, Date + Time | Auto | Completion timestamp |
| Processing Time | Number | Precision: 0, Format: Integer | No | Execution time in seconds |
| Cost | Currency | Precision: 2, Symbol: $ | No | Total LLM API costs |
| Perplexity Tokens | Number | Precision: 0 | No | Token usage tracking |
| Claude Tokens | Number | Precision: 0 | No | Token usage tracking |
| Gemini Tokens | Number | Precision: 0 | No | Token usage tracking |
| Attachments | Attachment | - | No | Screenshots, PDFs, etc. |
| Rating | Rating | Max: 5, Icon: Star, Color: Yellow | No | User quality rating |
| Feedback | Long text | - | No | User comments on quality |

#### Formulas

**Average Cost** (Formula field)
```
AVERAGE(Cost)
```

**Total Processing Time** (Formula field)
```
CONCATENATE(
  ROUND({Processing Time} / 60, 1),
  " minutes"
)
```

#### Views

**All Results** (default)
- Shows: All records
- Sort: Research Date (newest first)

**Recent Research**
- Filter: Research Date is within last 30 days
- Sort: Research Date (newest first)

**By Company** (Gallery view)
- Group: By Company Name
- Sort: Research Date (newest first)
- Card: Show Executive Summary preview

**Low Confidence**
- Filter: Confidence Score < 70
- Sort: Confidence Score (ascending)
- Use: Quality review queue

**Cost Analysis**
- Shows: All records
- Fields: Company Name, Research Date, Cost, Processing Time
- Sort: Cost (descending)
- Use: Budget tracking

---

### 3. Competitor Tracking

**Purpose**: Master list of tracked competitors and research history
**Primary Key**: Company Name (text)
**Record Creation**: Manual or automated from research

#### Field Definitions

| Field Name | Field Type | Options/Config | Required | Description |
|------------|------------|----------------|----------|-------------|
| Company Name | Single line text | Max 255 chars | ✅ Yes | Primary field, competitor name |
| Website | URL | - | No | Company homepage |
| Industry | Single select | SaaS, Fintech, E-commerce, etc. | No | Primary industry |
| Company Size | Single select | 1-10, 11-50, 51-200, 201-500, 500+ | No | Employee count range |
| Headquarters | Single line text | - | No | Location |
| Founded Year | Number | Precision: 0 | No | Year founded |
| Funding Status | Single select | Bootstrapped, Seed, Series A/B/C, Public | No | Funding stage |
| Last Researched | Rollup | From: Research Results, Field: Research Date, Function: MAX | Auto | Most recent research date |
| Research Count | Count | From: Research Results | Auto | Number of times researched |
| Priority | Single select | Low, Medium, High, Strategic | No | Tracking priority |
| RSS Feed | URL | - | No | Blog RSS (for Agent 1B) |
| LinkedIn | URL | - | No | Company LinkedIn page |
| Twitter | URL | - | No | Company Twitter handle |
| Notes | Long text | Enable rich text | No | Strategic notes and context |
| Tier | Single select | Tier 1, Tier 2, Tier 3, Not Competitor | No | Competitive tier |
| Tags | Multiple select | Dynamic | No | Custom categorization |
| Research Results | Link to another record | ← Research Results | Auto | All research records |
| Days Since Last Research | Formula | See below | Auto | Staleness indicator |

#### Formulas

**Days Since Last Research**
```
IF(
  {Last Researched},
  DATETIME_DIFF(NOW(), {Last Researched}, 'days'),
  BLANK()
)
```

**Research Frequency** (Formula)
```
IF(
  {Research Count} > 5,
  "🔥 High",
  IF(
    {Research Count} > 2,
    "📊 Medium",
    "📋 Low"
  )
)
```

#### Views

**All Competitors** (default)
- Shows: All records
- Sort: Company Name (A-Z)

**Strategic Competitors**
- Filter: Tier = "Tier 1" OR Priority = "Strategic"
- Sort: Last Researched (oldest first)
- Use: Identify competitors needing updates

**Research Needed**
- Filter: Days Since Last Research > 90 OR Last Researched is empty
- Sort: Priority (descending)
- Use: Queue for new research

**By Industry**
- Group: By Industry
- Sort: Company Name (A-Z)

**RSS Monitoring** (for Agent 1B)
- Filter: RSS Feed is not empty
- Shows: Company Name, RSS Feed, Last Researched
- Use: Configure Agent 1B monitoring

---

## Planned Tables (Future Agents)

### 4. SEO Keywords (Agent 2)

**Purpose**: Track target keywords, search volume, and rankings

#### Planned Fields
- Keyword (text)
- Search Volume (number)
- Difficulty Score (number)
- Current Ranking (number)
- Target Ranking (number)
- SERP URL (URL)
- Content Associated (link to another table)
- Last Checked (date)
- Trend (single select: Rising, Stable, Falling)

---

### 5. Customer Reviews (Agent 3)

**Purpose**: Aggregate reviews from multiple platforms

#### Planned Fields
- Review ID (autonumber)
- Platform (single select: G2, Capterra, Trustpilot, etc.)
- Review Text (long text)
- Rating (number 1-5)
- Review Date (date)
- Reviewer Name (text)
- Sentiment (single select: Positive, Neutral, Negative)
- Product Mentioned (text)
- Feature Requests (multiple select)
- Themes (multiple select)

---

### 6. Social Content (Agent 4)

**Purpose**: Store generated social media content

#### Planned Fields
- Content ID (autonumber)
- Platform (single select: LinkedIn, Twitter, Facebook, etc.)
- Content Type (single select: Post, Thread, Story)
- Generated Content (long text)
- Source Material (link to records)
- Status (single select: Draft, Scheduled, Published)
- Scheduled Date (date)
- Performance Metrics (JSON)
- Hashtags (multiple select)

---

### 7. Lead Intelligence (Agent 5)

**Purpose**: Store enriched lead data and scores

#### Planned Fields
- Lead ID (autonumber)
- Company Name (text)
- Contact Name (text)
- Email (email)
- Fit Score (number 0-100)
- Intent Score (number 0-100)
- Overall Priority (formula)
- Tier (single select)
- Enrichment Data (long text, JSON)
- Last Enriched (date)
- CRM Sync Status (single select)

---

## Automation Setup

### Automation 1: Trigger Research (Agent 1A)

**Trigger**: When record created in Research Requests
**Condition**: Status = "Pending"
**Action**: Send webhook to n8n

**Webhook Configuration**:
```json
{
  "url": "https://your-n8n-instance.com/webhook/agent-1a-research",
  "method": "POST",
  "body": {
    "company_name": "{{ Company Name }}",
    "research_focus": "{{ Research Focus }}",
    "request_id": "{{ Record ID }}"
  }
}
```

### Automation 2: Status Update Notification

**Trigger**: When record updated in Research Requests
**Condition**: Status changed to "Complete"
**Action**: Send email to Requested By

**Email Template**:
```
Subject: Your research on {Company Name} is complete

Hi {Requested By},

Your competitive research on {Company Name} is ready!

View results: [Link to Research Results]

Key findings:
{Key Findings preview}

- AI Agent Factory
```

---

## API Integration

### Airtable API Endpoints

**Base ID**: `appXXXXXXXXXXXXXX` (replace with your base ID)

**Create Research Request**:
```bash
curl https://api.airtable.com/v0/appXXXXXXXX/Research%20Requests \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "Company Name": "Stripe",
      "Research Focus": "Payment processing competitive landscape",
      "Priority": "High",
      "Requested By": "user@example.com",
      "Status": "Pending"
    }
  }'
```

**Get Research Results**:
```bash
curl "https://api.airtable.com/v0/appXXXXXXXX/Research%20Results?filterByFormula={Request}='recXXXXXX'" \
  -H "Authorization: Bearer YOUR_API_KEY"
```

---

## Data Maintenance

### Weekly Tasks
- [ ] Review failed requests
- [ ] Archive old completed requests (>6 months)
- [ ] Update competitor tracking data
- [ ] Check automation health

### Monthly Tasks
- [ ] Cost analysis review
- [ ] Quality rating review (low-rated results)
- [ ] Competitor priority review
- [ ] Update competitor RSS feeds (Agent 1B prep)

### Quarterly Tasks
- [ ] Full data audit
- [ ] Archive old research results (>1 year)
- [ ] Review and update field configurations
- [ ] Optimize views and filters

---

## Export & Backup

### Manual Export
1. Open table
2. Click "..." menu → "Download CSV"
3. Select fields to export
4. Save to backup location

### Automated Backup (Recommended)
- Use n8n workflow to export daily
- Store in Google Drive or S3
- Keep 30-day history

---

## Data Privacy & Security

### Airtable Security Settings
- **Base sharing**: Invite only (no public links)
- **User permissions**: Editor for team, Viewer for read-only
- **API access**: Restricted to authorized services only

### Data Handling
- ✅ Store only publicly available business information
- ✅ No personal/private customer data
- ✅ Comply with data retention policies
- ❌ Never store credentials or API keys in Airtable

### GDPR Compliance
- Right to delete: Provide deletion workflow
- Data retention: Max 1 year for research results
- Access control: Role-based permissions

---

## Troubleshooting

### Issue: Automation not firing

**Check**:
1. Automation is enabled (toggle in automations panel)
2. Webhook URL is correct
3. Test with manual record creation
4. Review automation run history

### Issue: Linked records not appearing

**Check**:
1. Field type is "Link to another record"
2. Correct table selected in configuration
3. Record IDs match between tables
4. Try re-linking manually

### Issue: Formula not calculating

**Check**:
1. Referenced field names are exact (case-sensitive)
2. Field types are compatible with formula
3. No circular references
4. Test formula in formula field editor

---

## Related Documentation

- [Setup Guide](../docs/setup-guide.md) - Complete setup instructions
- [Architecture](../docs/architecture.md) - System design
- [Agent 1A README](../agents/01-competitive-intel-monitor/README.md) - Agent details

---

**Last Updated**: November 6, 2025
**Base Version**: 1.0
**Maintained by**: GTM Operations Team
