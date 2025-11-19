# AI Agent Request Analysis - Airtable Schema

**Base**: Katalon Agent Factory
**Base ID**: `appELRlEUB59eOw3q`
**Last Updated**: November 19, 2025

---

## Overview

The AI Agent Request Analysis workflow uses **1 primary table** in Airtable to manage the complete lifecycle of agent requests from submission through analysis and prioritization.

---

## Table 1: AI Agent Requests

**Table ID**: `tblXpXyzvOrNdqkqE`
**Purpose**: Stores all incoming AI agent proposals and their ICE analysis results
**Access**: Read/Write by workflow, Read by team members

### Fields

#### **id** (Record ID)
- **Type**: Primary Key (Auto-generated)
- **Format**: `recXXXXXXXXXXXXXX` (17 characters)
- **Purpose**: Unique identifier for each request
- **Editable**: No (system-generated)
- **Required**: Yes (automatic)

---

#### **Requestor Name** (Single Line Text)
- **Field ID**: `Requestor Name`
- **Type**: Single line text
- **Purpose**: Name of the person submitting the agent request
- **Editable**: Yes
- **Required**: Yes
- **Max Length**: 255 characters
- **Example**: `"Sarah Johnson"`
- **Validation**: None
- **Notes**: Used in Slack notifications to credit requestor

---

#### **Requestor Department** (Single Line Text)
- **Field ID**: `Requestor Department`
- **Type**: Single line text
- **Purpose**: Department or team of the requestor
- **Editable**: Yes
- **Required**: Yes
- **Max Length**: 255 characters
- **Example**: `"Product Marketing"`
- **Validation**: None
- **Notes**: Helps track which teams are most active with requests

---

#### **AI Agent Request** (Single Line Text)
- **Field ID**: `AI Agent Request`
- **Type**: Single line text
- **Purpose**: Short name/title for the proposed agent
- **Editable**: Yes
- **Required**: Yes
- **Max Length**: 255 characters
- **Example**: `"Competitor Pricing Monitor"`
- **Validation**: None
- **Notes**: Should be concise and descriptive

---

#### **Description of AI Agent** (Long Text)
- **Field ID**: `Description of AI Agent`
- **Type**: Long text (multi-line)
- **Purpose**: Detailed description of what the agent should do
- **Editable**: Yes
- **Required**: Yes
- **Max Length**: Unlimited
- **Example**:
  ```
  This agent should monitor competitor pricing pages daily and alert us when prices change by more than 5%. It should track:
  - Main product pricing
  - Enterprise tier pricing
  - Promotional discounts
  - Add-on services pricing

  The agent should send alerts via Slack with screenshots and price comparison data.
  ```
- **Validation**: None
- **Notes**: More detail = better analysis from Claude

---

#### **Data Sources** (Multiple Select)
- **Field ID**: `Data Sources`
- **Type**: Multiple select
- **Purpose**: Which data sources the agent will use
- **Editable**: Yes
- **Required**: Yes
- **Options**:
  - `Airtable`
  - `Google Drive`
  - `Email/Gmail`
  - `Social Media`
  - `Web Scraping`
  - `APIs`
  - `RSS Feeds`
  - `Database`
  - `Slack`
  - `Other`
- **Example**: `["APIs", "Web Scraping"]`
- **Validation**: At least one option must be selected
- **Notes**: Helps Claude assess feasibility and complexity

---

#### **Trigger or On Demand** (Single Select)
- **Field ID**: `Trigger or On Demand`
- **Type**: Single select
- **Purpose**: How the agent will be invoked
- **Editable**: Yes
- **Required**: Yes
- **Options**:
  - `Trigger-based` - Runs automatically on schedule or event
  - `On-Demand` - Manually triggered by user action
- **Example**: `"Trigger-based"`
- **Validation**: Must select one option
- **Notes**: Affects ease score (triggers are usually easier)

---

#### **KPI or OKR alignment** (Long Text)
- **Field ID**: `KPI or OKR alignment`
- **Type**: Long text
- **Purpose**: Which business metrics this agent will improve
- **Editable**: Yes
- **Required**: Yes
- **Max Length**: Unlimited
- **Example**: `"Supports Q4 OKR: 'Increase competitive intelligence visibility by 50%'"`
- **Validation**: None
- **Notes**: Critical for Impact score assessment

---

#### **Potential Impact** (Long Text)
- **Field ID**: `Potential Impact`
- **Type**: Long text
- **Purpose**: Expected business outcomes and benefits
- **Editable**: Yes
- **Required**: Yes
- **Max Length**: Unlimited
- **Example**:
  ```
  - Reduce response time to competitor pricing changes from 1 week to 1 day
  - Enable sales team to price competitively on 100% of deals
  - Estimated $50K additional revenue per quarter from better pricing
  ```
- **Validation**: None
- **Notes**: Should quantify impact where possible

---

#### **Request Date** (Created Time)
- **Field ID**: `Request Date`
- **Type**: Created time (auto-populated)
- **Format**: ISO 8601 timestamp
- **Purpose**: Timestamp when request was created
- **Editable**: No (system-managed)
- **Required**: Yes (automatic)
- **Example**: `"2025-11-19T10:30:00.000Z"`
- **Notes**: Used as trigger field for workflow

---

#### **ICE Rating** (Single Line Text)
- **Field ID**: `ICE Rating`
- **Type**: Single line text
- **Purpose**: Priority category assigned by Claude
- **Editable**: No (workflow-populated)
- **Required**: No (filled by workflow)
- **Max Length**: 255 characters
- **Example**: `"1 - High Impact, Low Effort"`
- **Valid Values**:
  - `"1 - High Impact, Low Effort"`
  - `"2 - High Impact High Effort"`
  - `"2 - Low Impact Low Effort"`
  - `"3 - Low Impact High Effort"`
- **Notes**: Primary field for prioritization

---

#### **Reason for ICE Rating** (Long Text)
- **Field ID**: `Reason for ICE Rating`
- **Type**: Long text
- **Purpose**: Detailed justification from Claude analysis
- **Editable**: No (workflow-populated)
- **Required**: No (filled by workflow)
- **Max Length**: Unlimited
- **Example**:
  ```
  Impact Score: 9/10
  This agent addresses a critical competitive intelligence gap. The potential to reduce pricing response time from 1 week to 1 day represents significant strategic value. The estimated $50K quarterly revenue impact is conservative and measurable.

  Confidence Score: 8/10
  Similar pricing monitor agents have been successfully implemented by competitors. The data sources (web scraping, APIs) are well-established. The main uncertainty is maintenance overhead if competitor sites change frequently.

  Ease Score: 7/10
  The technical implementation is straightforward using existing n8n patterns. Web scraping adds some complexity, but can leverage existing libraries. Integration with Slack is trivial. Estimated development time: 3-5 days.

  ICE Score = (9 × 8 × 7) / 100 = 5.04 → Category 2 (High Impact, High Effort)

  However, given the strategic importance and reasonable development timeline, this request should be prioritized for Q1 implementation.
  ```
- **Notes**: Contains numerical calculations and detailed reasoning

---

#### **Recommended Agentic Workflow** (Long Text)
- **Field ID**: `Recommended Agentic Workflow`
- **Type**: Long text
- **Purpose**: Technical implementation blueprint from Claude
- **Editable**: No (workflow-populated)
- **Required**: No (filled by workflow)
- **Max Length**: Unlimited
- **Example**:
  ```
  **Recommended n8n Workflow Architecture:**

  1. **Trigger: Schedule Trigger**
     - Frequency: Daily at 6 AM UTC
     - Allows overnight price changes to be caught before business hours

  2. **Node: HTTP Request (Web Scraper)**
     - Target URLs: [List of competitor pricing pages]
     - Extract pricing data using CSS selectors
     - Fallback: Puppeteer for JavaScript-rendered pages

  3. **Node: Airtable - Fetch Historical Prices**
     - Table: Competitor_Pricing_History
     - Get yesterday's prices for comparison

  4. **Node: Code - Calculate Price Deltas**
     - Compare current vs. historical prices
     - Calculate percentage changes
     - Flag changes > 5% threshold

  5. **Node: IF - Filter Significant Changes**
     - Continue only if changes exceed threshold

  6. **Node: Screenshot Tool**
     - Capture visual evidence of pricing page
     - Store in Google Drive or Airtable attachments

  7. **Node: Airtable - Save New Prices**
     - Update Competitor_Pricing_History table
     - Log all price points for trend analysis

  8. **Node: Claude AI - Generate Alert Summary**
     - Analyze pricing changes for strategic implications
     - Generate executive summary

  9. **Node: Slack - Send Alert**
     - Post to #pricing-intel channel
     - Include screenshots, price deltas, AI summary
     - Tag relevant team members

  **Estimated Development Time:** 3-5 days
  **Ongoing Maintenance:** ~1 hour/month (update selectors if sites change)
  **Dependencies:** Airtable base setup, Slack channel configuration
  ```
- **Notes**: Provides actionable technical blueprint for engineering

---

## Table Configuration

### Views

The table supports multiple views for different use cases:

#### **All Requests** (Default)
- **Type**: Grid view
- **Filters**: None
- **Sorting**: Request Date (newest first)
- **Purpose**: See all submissions chronologically

#### **Pending Analysis**
- **Type**: Grid view
- **Filters**: `ICE Rating` is empty
- **Sorting**: Request Date (oldest first)
- **Purpose**: See requests awaiting workflow analysis

#### **High Priority** (Hot Leads)
- **Type**: Grid view
- **Filters**: `ICE Rating` contains "1 - High Impact, Low Effort"
- **Sorting**: Request Date (newest first)
- **Purpose**: Quick wins to implement immediately
- **Color Coding**: Red background

#### **Strategic Investments**
- **Type**: Grid view
- **Filters**: `ICE Rating` contains "2 - High Impact High Effort"
- **Sorting**: Request Date (newest first)
- **Purpose**: Important but complex projects to schedule
- **Color Coding**: Orange background

#### **Backlog**
- **Type**: Grid view
- **Filters**: `ICE Rating` contains "2 - Low Impact Low Effort" OR "3 - Low Impact High Effort"
- **Sorting**: Request Date (newest first)
- **Purpose**: Lower priority items
- **Color Coding**: Gray background

#### **By Department**
- **Type**: Grouped view
- **Grouping**: By `Requestor Department`
- **Sorting**: Request Date (newest first)
- **Purpose**: See which departments are submitting most requests

---

## Formulas & Computed Fields

### Optional Enhancement: Priority Score (Numerical)

You can add a computed field to convert ICE ratings to numbers:

```javascript
// Formula for Priority_Score field (Number)
IF(
  {ICE Rating} = "1 - High Impact, Low Effort",
  4,
  IF(
    {ICE Rating} = "2 - High Impact High Effort",
    3,
    IF(
      {ICE Rating} = "2 - Low Impact Low Effort",
      2,
      IF(
        {ICE Rating} = "3 - Low Impact High Effort",
        1,
        0
      )
    )
  )
)
```

**Purpose**: Enables numerical sorting and filtering

---

### Optional Enhancement: Days Since Request

```javascript
// Formula for Days_Since_Request field (Number)
DATETIME_DIFF(NOW(), {Request Date}, 'days')
```

**Purpose**: Track how long requests have been pending

---

### Optional Enhancement: Status Badge

```javascript
// Formula for Status_Badge field (Single Line Text)
IF(
  {ICE Rating},
  "✅ Analyzed",
  IF(
    DATETIME_DIFF(NOW(), {Request Date}, 'days') > 7,
    "⚠️ Pending (Overdue)",
    "⏳ Pending"
  )
)
```

**Purpose**: Visual status indicator

---

## Automations

### Optional: Stale Request Alerts

**Trigger**: When record enters view "Pending Analysis" AND `Days Since Request` > 7
**Action**: Send Slack notification to #agent-requests
**Message**: "Agent request from {Requestor Name} has been pending for {Days Since Request} days"

**Purpose**: Ensure requests don't fall through the cracks

---

### Optional: Auto-Prioritize Queue

**Trigger**: When `ICE Rating` is updated
**Action**: Move record to appropriate view (High Priority, Strategic, Backlog)

**Purpose**: Automatic organization

---

## Permissions

### Recommended Access Levels

| Role | Permissions | Purpose |
|------|-------------|---------|
| **All Team Members** | Create, Read | Submit new requests, view all requests |
| **Product Team** | Create, Read, Comment | Manage backlog, add notes |
| **Engineering** | Read | See technical blueprints |
| **Leadership** | Read | Monitor request pipeline |
| **Workflow Service Account** | Read, Update | n8n automation |

### Field-Level Permissions

- **Editable by Users**: All input fields (Requestor Name through Potential Impact)
- **Read-Only for Users**: ICE Rating, Reason for ICE Rating, Recommended Workflow
- **Editable by Workflow Only**: ICE Rating, Reason for ICE Rating, Recommended Workflow

---

## Data Validation

### Input Validation (Form)

If using Airtable forms for submission:

```
Required fields:
- Requestor Name
- Requestor Department
- AI Agent Request
- Description of AI Agent
- Data Sources (at least one)
- Trigger or On Demand
- KPI or OKR alignment
- Potential Impact

Optional fields:
- None (all fields required for quality analysis)
```

---

## Migration & Setup

### Initial Setup

1. Create Airtable base: "Katalon Agent Factory"
2. Create table: "AI Agent Requests"
3. Add all fields as specified above
4. Configure views
5. Set up permissions
6. Create Airtable Personal Access Token
7. Test with sample record

### Sample Record

```json
{
  "Requestor Name": "Sarah Johnson",
  "Requestor Department": "Product Marketing",
  "AI Agent Request": "Competitor Pricing Monitor",
  "Description of AI Agent": "Daily monitoring of competitor pricing with 5% change alerts",
  "Data Sources": ["APIs", "Web Scraping"],
  "Trigger or On Demand": "Trigger-based",
  "KPI or OKR alignment": "Q4 OKR: Increase competitive intelligence visibility",
  "Potential Impact": "Reduce pricing response time from 1 week to 1 day, estimated $50K revenue impact"
}
```

---

## Backup & Maintenance

### Backup Strategy

- **Frequency**: Daily automated backup (Airtable feature)
- **Retention**: 90 days
- **Export**: Monthly CSV export to Google Drive

### Maintenance Tasks

- **Weekly**: Review for stale requests
- **Monthly**: Archive completed/rejected requests
- **Quarterly**: Audit ICE score accuracy vs actual outcomes

---

## Troubleshooting

### Common Issues

**Issue**: Workflow not triggering
**Cause**: `Request Date` field changed or record edited
**Solution**: Check trigger field configuration, ensure using "Created Time" field

**Issue**: ICE Rating not populating
**Cause**: Workflow execution failed
**Solution**: Check n8n execution log, verify API credentials

**Issue**: Duplicate requests
**Cause**: No de-duplication logic
**Solution**: Add unique constraint on `AI Agent Request` field (optional)

---

## API Access

### Airtable API Endpoints

**Base URL**: `https://api.airtable.com/v0/appELRlEUB59eOw3q`

**List Records**:
```bash
GET /tblXpXyzvOrNdqkqE
Headers:
  Authorization: Bearer YOUR_PERSONAL_ACCESS_TOKEN
```

**Create Record**:
```bash
POST /tblXpXyzvOrNdqkqE
Headers:
  Authorization: Bearer YOUR_PERSONAL_ACCESS_TOKEN
  Content-Type: application/json
Body:
{
  "fields": {
    "Requestor Name": "John Doe",
    ...
  }
}
```

**Update Record**:
```bash
PATCH /tblXpXyzvOrNdqkqE/recXXXXXXXXXXXXXX
Headers:
  Authorization: Bearer YOUR_PERSONAL_ACCESS_TOKEN
  Content-Type: application/json
Body:
{
  "fields": {
    "ICE Rating": "1 - High Impact, Low Effort",
    ...
  }
}
```

---

## Cost Considerations

### Airtable Pricing

- **Free Tier**: 1,200 records per base (sufficient for most use cases)
- **Plus Tier**: $20/user/month (unlimited records, 50GB attachments)
- **Pro Tier**: $45/user/month (advanced features, 100GB attachments)

### API Limits

- **Free**: 5 requests/second per base
- **Plus/Pro**: Same (5 requests/second)
- **Note**: Workflow makes ~2 API calls per request (trigger + update), well within limits

---

## Security & Compliance

### Data Sensitivity

- **PII**: Yes (Requestor Name, Email if added)
- **Business Sensitive**: Yes (strategic agent proposals)
- **Recommended**: Restrict base access to internal team only

### GDPR Considerations

- **Right to Erasure**: Manually delete records on request
- **Data Retention**: Define retention policy (suggest 2 years)
- **Access Logs**: Enable Airtable audit logs (Enterprise plan)

---

## Related Tables

While this workflow uses only 1 table, these related tables may exist in the same base:

- **Research Results** (Agent 1A outputs)
- **RSS Feed Items** (Agent 1B outputs)
- **Competitor SEO Analysis** (Agent 2 outputs)
- **Competitor Sentiment Analysis** (Agent 3 outputs)
- **Lead Scoring Queue** (Agent 5 inputs)
- **Lead Scoring Results** (Agent 5 outputs)

---

**Schema Version**: 1.0
**Last Updated**: November 19, 2025
**Status**: Production
