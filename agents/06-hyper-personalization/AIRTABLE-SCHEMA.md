# Agent 6: Hyper-Personalization Engine - Airtable Schema

## Table: Personalized Outreach

Store all personalized outreach content generated for prospects, including email, LinkedIn, and phone scripts.

| Field Name | Type | Configuration | Description |
|------------|------|---------------|-------------|
| Record ID | Autonumber | Primary key | Unique identifier |
| Account ID | Single line text | Required | CRM account/lead ID |
| Contact Name | Single line text | Required | Prospect full name |
| Contact Title | Single line text | - | Job title |
| Contact Email | Email | - | Prospect email |
| Company Name | Single line text | Required | Company name |
| Industry | Single select | Dynamic | Industry category |
| **Generated Content** | | | |
| Email Subject | Single line text | - | Best email subject line |
| Email Body | Long text | - | Best email body variant |
| LinkedIn Message | Long text | - | LinkedIn outreach message |
| Phone Script | Long text | - | Cold call script |
| **All Variants (JSON)** | | | |
| All Subject Lines | Long text | JSON array | All 5 subject line variants |
| All Email Variants | Long text | JSON array | All 3 email body variants |
| **Personalization Details** | | | |
| Personalization Score | Number | 1-10 | Overall quality score |
| Personalization Elements | Multiple select | Dynamic | Hooks used (news, role, tech stack, etc.) |
| Key Insights Used | Long text | - | Insights from Agent 5 |
| Trigger Events | Long text | - | Recent events referenced |
| Recommended Approach | Long text | - | Strategy from analysis |
| **Intelligence Sources** | | | |
| Link to Lead Intel | Link to records | → Lead Intelligence (Agent 5) | Lead scoring data |
| Link to Company Research | Link to records | → Research Results (Agent 1A) | Company research |
| Fit Score | Lookup | From Lead Intel | ICP fit score |
| Priority Score | Lookup | From Lead Intel | Priority score |
| **Metadata** | | | |
| Generated Date | Created time | Auto | Creation timestamp |
| Status | Single select | Draft, Approved, Sent, Responded, Disqualified | Current status |
| Sent Date | Date & time | - | When outreach sent |
| Response Date | Date & time | - | When prospect responded |
| Response Type | Single select | Positive, Negative, Neutral, Meeting Booked, No Response | Response category |
| Sequence Step | Number | - | Which step in sequence (1-5) |
| Channel Used | Single select | Email, LinkedIn, Phone, Multi-channel | Outreach channel |
| Sent By | Single line text | - | SDR/AE name |
| **Performance Tracking** | | | |
| Open Rate | Checkbox | - | Email opened? |
| Link Clicked | Checkbox | - | Link clicked? |
| Replied | Checkbox | - | Prospect replied? |
| Meeting Booked | Checkbox | - | Meeting scheduled? |
| Performance Notes | Long text | - | What worked/didn't work |
| Quality Check | Long text | JSON | Gemini quality scores |

**Formulas**:

**Personalization Grade**:
```
IF(
  {Personalization Score},
  IF({Personalization Score} >= 8, '🔥 Excellent',
    IF({Personalization Score} >= 6, '⭐ Good',
      IF({Personalization Score} >= 4, '👌 Okay', '❌ Low')
    )
  ),
  BLANK()
)
```

**Status Icon**:
```
SWITCH(
  {Status},
  'Draft', '📝',
  'Approved', '✅',
  'Sent', '📤',
  'Responded', '💬',
  'Disqualified', '❌',
  '❓'
)
```

**Outreach Tier** (based on prospect priority):
```
IF(
  {Priority Score},
  IF({Priority Score} >= 80, '🔥 Tier 1',
    IF({Priority Score} >= 60, '⭐ Tier 2',
      IF({Priority Score} >= 40, '📊 Tier 3', '❄️ Tier 4')
    )
  ),
  BLANK()
)
```

**Days Since Generated**:
```
DATETIME_DIFF(NOW(), {Generated Date}, 'days')
```

**Days to Response** (if responded):
```
IF(
  AND({Sent Date}, {Response Date}),
  DATETIME_DIFF({Response Date}, {Sent Date}, 'days'),
  BLANK()
)
```

**Conversion Status**:
```
IF(
  {Meeting Booked}, '🎯 Converted',
  IF({Replied}, '💬 Engaged',
    IF({Link Clicked}, '👀 Interested',
      IF({Open Rate}, '📖 Opened',
        IF({Sent Date}, '📭 Not Opened', '⏳ Not Sent')
      )
    )
  )
)
```

**Subject Line Preview**:
```
LEFT({Email Subject}, 50) & IF(LEN({Email Subject}) > 50, '...', '')
```

**Personalization Elements Count**:
```
IF(
  {Personalization Elements},
  ARRAYJOIN(ARRAYUNIQUE({Personalization Elements}), ', '),
  'No elements tagged'
)
```

**Views**:
- **Awaiting Approval**: Status = "Draft", sort by Personalization Score desc
- **Sent This Week**: Status = "Sent", Sent Date is within this week
- **Awaiting Response**: Status = "Sent", Sent Date > 2 days ago, Response Type is empty
- **Positive Responses**: Response Type IN ("Positive", "Meeting Booked")
- **High Priority Prospects**: Priority Score >= 80
- **By Company**: Group by Company Name
- **By SDR**: Group by Sent By
- **Performance Dashboard**: Status = "Responded", show response metrics
- **Top Performers**: Personalization Score >= 8, Meeting Booked = true

---

## Table: Personalization Analytics

Track performance of personalization strategies to continuously improve content quality.

| Field Name | Type | Configuration | Description |
|------------|------|---------------|-------------|
| Analytics ID | Autonumber | Primary key | Unique identifier |
| Outreach | Link to records | ← Personalized Outreach | Related outreach record |
| Week Number | Number | - | Week of year |
| Month | Single select | Jan, Feb, Mar, ... | Month name |
| **Metrics** | | | |
| Personalization Score | Lookup | From Outreach | Quality score |
| Response Type | Lookup | From Outreach | Response category |
| Days to Response | Lookup | From Outreach | Response time |
| Personalization Elements | Lookup | From Outreach | Elements used |
| Email Subject | Lookup | From Outreach | Subject line used |
| Industry | Lookup | From Outreach | Industry |
| Priority Tier | Lookup | From Outreach | Prospect tier |
| **Success Indicators** | | | |
| Success | Checkbox | - | Meeting booked or positive response? |
| Opened | Checkbox | - | Email opened |
| Clicked | Checkbox | - | Link clicked |
| Replied | Checkbox | - | Prospect replied |

**Formulas**:

**Success Flag**:
```
IF(
  OR(
    {Response Type} = 'Positive',
    {Response Type} = 'Meeting Booked',
    {Meeting Booked}
  ),
  TRUE(),
  FALSE()
)
```

**Week Number**:
```
WEEKNUM({Generated Date})
```

**Month**:
```
DATETIME_FORMAT({Generated Date}, 'MMM')
```

**Views**:
- **Success Analysis**: Success = true, group by Personalization Elements
- **By Week**: Group by Week Number
- **By Industry**: Group by Industry
- **High Performers**: Personalization Score >= 8
- **Response Time Analysis**: Days to Response field, sort asc

---

## Table: Personalization Playbook

Store proven personalization strategies and templates that work well.

| Field Name | Type | Configuration | Description |
|------------|------|---------------|-------------|
| Playbook ID | Autonumber | Primary key | Unique identifier |
| Strategy Name | Single line text | Required | Name of strategy |
| Industry | Multiple select | Dynamic | Industries this works for |
| Persona | Multiple select | C-Level, VP, Director, Manager, IC | Target personas |
| Personalization Type | Single select | News/Event, Role-based, Tech Stack, Pain Point, Social Proof | Type of personalization |
| **Templates** | | | |
| Email Subject Template | Long text | - | Subject line template with variables |
| Email Opening Template | Long text | - | Opening paragraph template |
| LinkedIn Message Template | Long text | - | LinkedIn template |
| Phone Script Opening | Long text | - | Call opening template |
| **Performance** | | | |
| Times Used | Number | - | How many times applied |
| Success Rate | Number | % | Meeting booking rate |
| Avg Response Time | Number | Days | Average days to response |
| Avg Personalization Score | Number | - | Average quality score |
| **Metadata** | | | |
| Active | Checkbox | Default: true | Currently in use? |
| Created Date | Created time | Auto | When created |
| Last Used | Date & time | - | Most recent use |
| Created By | Single line text | - | Who created |
| Notes | Long text | - | Tips for using |

**Formulas**:

**Performance Grade**:
```
IF(
  {Success Rate},
  IF({Success Rate} >= 25, '🔥 Excellent',
    IF({Success Rate} >= 15, '⭐ Good',
      IF({Success Rate} >= 10, '👌 Average', '❄️ Low')
    )
  ),
  'Not enough data'
)
```

**Usage Frequency**:
```
IF(
  {Times Used},
  IF({Times Used} >= 50, '🔥 High Use',
    IF({Times Used} >= 20, '📈 Regular',
      IF({Times Used} >= 5, '📊 Occasional', '🆕 New')
    )
  ),
  BLANK()
)
```

**Days Since Used**:
```
IF(
  {Last Used},
  DATETIME_DIFF(NOW(), {Last Used}, 'days'),
  BLANK()
)
```

**Views**:
- **Active Playbooks**: Active = true, sort by Success Rate desc
- **Top Performers**: Success Rate >= 20%, sort desc
- **By Industry**: Group by Industry
- **By Persona**: Group by Persona
- **Recently Used**: Last Used is within last 30 days
- **Needs Testing**: Times Used < 10

---

## Table: Outreach Sequences

Define multi-touch outreach sequences that leverage personalized content.

| Field Name | Type | Configuration | Description |
|------------|------|---------------|-------------|
| Sequence ID | Autonumber | Primary key | Unique identifier |
| Sequence Name | Single line text | Required | Name of sequence |
| Target Tier | Single select | Tier 1, Tier 2, Tier 3, Tier 4 | Which prospect tier |
| Active | Checkbox | Default: true | Currently active? |
| **Sequence Steps** | | | |
| Step 1 Channel | Single select | Email, LinkedIn, Phone | First touch channel |
| Step 1 Delay | Number | Days | Days after trigger |
| Step 2 Channel | Single select | Email, LinkedIn, Phone | Second touch |
| Step 2 Delay | Number | Days | Days after step 1 |
| Step 3 Channel | Single select | Email, LinkedIn, Phone | Third touch |
| Step 3 Delay | Number | Days | Days after step 2 |
| Step 4 Channel | Single select | Email, LinkedIn, Phone | Fourth touch |
| Step 4 Delay | Number | Days | Days after step 3 |
| Step 5 Channel | Single select | Email, LinkedIn, Phone | Fifth touch |
| Step 5 Delay | Number | Days | Days after step 4 |
| **Performance** | | | |
| Prospects Enrolled | Number | - | Total enrolled |
| Responses | Number | - | Total responses |
| Meetings Booked | Number | - | Meetings scheduled |
| Response Rate | Number | % | Response rate |
| Meeting Rate | Number | % | Meeting booking rate |
| Avg Steps to Response | Number | - | Average steps before response |
| **Metadata** | | | |
| Created Date | Created time | Auto | When created |
| Updated Date | Last modified time | Auto | Last update |
| Notes | Long text | - | Sequence notes |

**Formulas**:

**Response Rate**:
```
IF(
  AND({Prospects Enrolled}, {Prospects Enrolled} > 0),
  ROUND({Responses} / {Prospects Enrolled} * 100, 1),
  BLANK()
)
```

**Meeting Rate**:
```
IF(
  AND({Prospects Enrolled}, {Prospects Enrolled} > 0),
  ROUND({Meetings Booked} / {Prospects Enrolled} * 100, 1),
  BLANK()
)
```

**Sequence Duration**:
```
{Step 1 Delay} + {Step 2 Delay} + {Step 3 Delay} + {Step 4 Delay} + {Step 5 Delay}
```

**Performance Grade**:
```
IF(
  {Meeting Rate},
  IF({Meeting Rate} >= 20, '🔥 Excellent',
    IF({Meeting Rate} >= 10, '⭐ Good',
      IF({Meeting Rate} >= 5, '👌 Average', '❄️ Low')
    )
  ),
  'Not enough data'
)
```

**Touch Pattern**:
```
CONCATENATE(
  {Step 1 Channel}, ' → ',
  {Step 2 Channel}, ' → ',
  {Step 3 Channel}, ' → ',
  {Step 4 Channel}, ' → ',
  {Step 5 Channel}
)
```

**Views**:
- **Active Sequences**: Active = true
- **Top Performers**: Meeting Rate >= 15%, sort desc
- **By Target Tier**: Group by Target Tier
- **Email-Heavy**: Step 1 Channel = "Email", Step 2 Channel = "Email"
- **Multi-Channel**: Uses 2+ different channels

---

## Automation Triggers

### Automation 1: Generate Personalized Outreach

**Trigger**: When record created in "Lead Intelligence" (Agent 5) OR manual request
**Condition**: Priority Score >= 60 (Tier 1-2 leads)
**Action**:
```javascript
// Call n8n webhook for Agent 6
const webhookUrl = 'https://your-n8n-instance.com/webhook/agent-6-personalization';
const requestData = {
  account_id: record.get('CRM Lead ID'),
  company_name: record.get('Company Name'),
  contact_name: record.get('Full Name'),
  contact_title: record.get('Title'),
  contact_email: record.get('Email'),
  fit_score: record.get('Fit Score'),
  priority_score: record.get('Priority Score'),
  key_insights: record.get('Key Insights'),
  trigger_events: record.get('Trigger Events'),
  source: 'agent_5_auto'
};

await fetch(webhookUrl, {
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify(requestData)
});
```

### Automation 2: Update Analytics

**Trigger**: When "Status" changes in "Personalized Outreach"
**Condition**: Status changed to "Responded"
**Action**: Create record in "Personalization Analytics" with performance data

### Automation 3: Update Playbook Performance

**Trigger**: When "Response Type" updated in "Personalized Outreach"
**Condition**: Response Type IN ("Positive", "Meeting Booked")
**Action**: Update success rate in related playbook template

---

## Integration Points

### Outreach.io / Salesloft Integration

Map to outreach platform:
```javascript
{
  "prospect": {
    "email": record.get('Contact Email'),
    "first_name": record.get('Contact Name').split(' ')[0],
    "last_name": record.get('Contact Name').split(' ').slice(1).join(' '),
    "title": record.get('Contact Title'),
    "company": record.get('Company Name')
  },
  "sequence_id": getSequenceForTier(record.get('Priority Score')),
  "custom_1": record.get('Email Subject'),
  "custom_2": record.get('Email Body'),
  "custom_3": record.get('LinkedIn Message')
}
```

### CRM Sync (Salesforce/HubSpot)

Sync personalization data back to CRM:
```javascript
{
  "lead_id": record.get('Account ID'),
  "custom_fields": {
    "Personalization_Score__c": record.get('Personalization Score'),
    "Personalization_Elements__c": record.get('Personalization Elements').join('; '),
    "AI_Generated_Subject__c": record.get('Email Subject'),
    "AI_Recommended_Approach__c": record.get('Recommended Approach'),
    "Personalization_Date__c": record.get('Generated Date')
  }
}
```

---

## Data Quality Rules

### Required Fields for Generation
- Account ID (CRM link)
- Company Name
- Contact Name
- Contact Email OR LinkedIn profile

### Quality Thresholds
- Personalization Score < 4: Flag for manual review
- No personalization elements: Reject, needs more data
- Missing fit score: Generate anyway but note limitation

### Duplicate Prevention
- Don't regenerate for same contact within 30 days
- Alert if contact already has outreach in progress

---

## Data Retention

- **Personalized Outreach**:
  - Draft: Keep 90 days, auto-archive if not approved
  - Sent: Keep indefinitely (historical record)
  - Responded: Keep indefinitely (valuable learning data)
- **Personalization Analytics**: Keep indefinitely (improves AI over time)
- **Personalization Playbook**: Keep indefinitely
- **Outreach Sequences**: Archive inactive sequences after 1 year

---

## Reporting & Dashboards

### Key Metrics to Track

**Volume Metrics**:
- Personalized outreach generated per week
- Approval rate (% approved without edits)
- Average personalization score

**Effectiveness Metrics**:
- Response rate by personalization score
- Meeting booking rate by tier
- Days to response by personalization elements

**Quality Metrics**:
- Personalization score distribution
- Elements used frequency
- Playbook performance comparison

**ROI Metrics**:
- Time saved vs manual personalization
- Cost per personalized outreach
- Meeting booked cost vs industry average

### Sample Airtable Charts

1. **Personalization Score Distribution** (Bar chart)
   - X-axis: Score ranges (1-2, 3-4, 5-6, 7-8, 9-10)
   - Y-axis: Count of records

2. **Response Rate by Elements** (Bar chart)
   - X-axis: Personalization elements
   - Y-axis: Response rate %

3. **Weekly Performance Trend** (Line chart)
   - X-axis: Week number
   - Y-axis: Response rate, Meeting rate

4. **Channel Performance** (Pie chart)
   - Segments: Email, LinkedIn, Phone, Multi-channel
   - Value: Meeting booking rate

---

**Schema Version**: 1.0
**Last Updated**: November 2025
**Maintained by**: GTM Operations Team
**Integration**: Agent 5 (Lead Intel), Agent 1A (Company Research), Outreach.io/Salesloft
