# Agent 5: Lead Intelligence & Scoring - Airtable Schema

## Table: Lead Intelligence

| Field Name | Type | Configuration | Description |
|------------|------|---------------|-------------|
| Record ID | Autonumber | Primary | Unique ID |
| CRM Lead ID | Single line text | Required, Unique | ID from Salesforce/HubSpot |
| Email | Email | Required | Contact email |
| Full Name | Single line text | - | First + Last name |
| Title | Single line text | - | Job title |
| Company Name | Single line text | Required | Company |
| Company Domain | URL | - | Company website |
| Industry | Single select | Dynamic | Industry category |
| Company Size | Number | - | Employee count |
| Annual Revenue | Currency | - | Company revenue |
| **Scoring** | | | |
| Fit Score | Number | 0-100 | ICP fit score |
| Intent Score | Number | 0-100 | Buying intent score |
| Priority Score | Number | 0-100 | Overall priority |
| Tier | Single select | 1,2,3,4 | Lead tier |
| Tier Label | Single select | Hot, Warm, Nurture, Disqualify | Tier description |
| **Intelligence** | | | |
| Executive Summary | Long text | Rich text | Quick overview |
| Key Insights | Long text | JSON | Main findings |
| Talking Points | Long text | JSON | Sales talking points |
| Recommended Approach | Long text | - | Outreach strategy |
| Trigger Events | Long text | JSON | Recent news/events |
| Tech Stack | Multiple select | Dynamic | Technologies used |
| **Metadata** | | | |
| Enrichment Date | Date & time | Auto | When enriched |
| Last Scored | Date & time | Auto | Last scoring date |
| Research Link | Link to records | → Agent 1A results | Company research |
| Assigned To | Single select | AE, SDR, Marketing, None | Owner |
| Follow Up Timing | Single select | Immediate, This Week, This Month, Later | Urgency |
| Status | Single select | New, Enriched, Contacted, Qualified, Disqualified | Current status |
| CRM Sync Status | Single select | Pending, Synced, Failed | Sync state |

**Formulas**:

```
Tier Emoji = SWITCH({Tier}, '1', '🔥', '2', '⭐', '3', '📊', '4', '❄️', '❓')

Days Since Enrichment = DATETIME_DIFF(NOW(), {Enrichment Date}, 'days')

Priority Label = IF({Priority Score} >= 80, '🔥 Urgent',
  IF({Priority Score} >= 60, '⚡ High',
    IF({Priority Score} >= 40, '📈 Medium', '📉 Low')))
```

**Views**:
- Hot Leads (Tier 1): Tier = "1", Status != "Disqualified"
- This Week Follow-ups: Follow Up Timing = "This Week"
- Needs Assignment: Assigned To is empty, Tier IN ("1", "2")
- By Industry: Group by Industry
- Recent Enrichments: Sort by Enrichment Date desc

---

## Table: Scoring History

Track score changes over time.

| Field Name | Type | Configuration | Description |
|------------|------|---------------|-------------|
| History ID | Autonumber | - | Primary key |
| Lead | Link to records | ← Lead Intelligence | Related lead |
| Score Date | Date & time | Required | When scored |
| Fit Score | Number | 0-100 | Fit score at time |
| Intent Score | Number | 0-100 | Intent score at time |
| Priority Score | Number | 0-100 | Priority at time |
| Tier | Single select | 1,2,3,4 | Tier at time |
| Score Change | Formula | Calculate change | Difference from previous |
| Reason | Long text | - | Why score changed |

**Formula (Score Change)**:
```
{Priority Score} - LAST(Scoring History, {Priority Score})
```

