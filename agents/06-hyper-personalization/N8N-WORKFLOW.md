# Agent 6: Hyper-Personalization Engine - n8n Workflow

## Overview

Generate highly personalized outreach content using account intelligence from Agents 1A and 5, recent news, and prospect research.

## Workflow Architecture

```
Manual Trigger / CRM Task Created
    ↓
[1] Fetch Target Account Data
    ↓
[2] Gather Intelligence (Multi-source)
    │   → Agent 5 (Lead scoring + intelligence)
    │   → Agent 1A (Company research)
    │   → LinkedIn (Prospect profile)
    │   → Perplexity (Recent news)
    ↓
[3] Claude: Analyze Personalization Data
    ↓
[4] Generate Content (Multi-variant)
    │   → [4a] Email Subject Lines (5 variants)
    │   → [4b] Email Body (3 variants)
    │   → [4c] LinkedIn Message
    │   → [4d] Phone Script
    ↓
[5] Gemini: Quality Check & Scoring
    ↓
[6] Save to Airtable
    ↓
[7] Send to Outreach/Salesloft (if approved)
```

## Key Nodes

### Node 1: Fetch Target Account Data

```javascript
// Input: Account ID or Lead ID
const accountId = $json.account_id;

// Fetch from CRM
const crmData = await fetchFromCRM(accountId);

// Fetch from Agent 5 (if available)
const leadIntel = await fetchFromAirtable('Lead Intelligence', {
  filter: `{CRM Lead ID} = '${accountId}'`
});

return [{
  json: {
    account_id: accountId,
    company_name: crmData.company,
    contact_name: crmData.name,
    contact_title: crmData.title,
    contact_email: crmData.email,
    industry: crmData.industry,
    // Intelligence from Agent 5
    fit_score: leadIntel?.fit_score,
    priority_score: leadIntel?.priority_score,
    key_insights: leadIntel?.key_insights,
    trigger_events: leadIntel?.trigger_events,
    talking_points: leadIntel?.talking_points
  }
}];
```

### Node 2: Gather Additional Intelligence

**LinkedIn Profile Research**:
```
Prompt for Perplexity:

Research this person on LinkedIn and professional networks:
Name: {{ $json.contact_name }}
Company: {{ $json.company_name }}
Title: {{ $json.contact_title }}

Find:
1. CURRENT ROLE
   - Responsibilities
   - Department/team size
   - Key initiatives

2. CAREER PATH
   - Previous roles
   - Career progression
   - Areas of expertise

3. INTERESTS & ACTIVITY
   - Recent LinkedIn posts/shares
   - Topics they engage with
   - Professional groups

4. PERSONAL CONTEXT
   - Education background
   - Certifications
   - Shared connections (if visible)

5. COMMUNICATION STYLE
   - Professional tone analysis
   - Preferred content types
   - Engagement patterns

Keep focused on professional context only.
```

**Recent Company News**:
```
Prompt for Perplexity:

Find very recent news (last 30 days) about {{ $json.company_name }}:

Priority:
1. Executive changes
2. Product launches
3. Funding/acquisitions
4. Partnerships
5. Awards/recognition
6. Expansion news
7. Challenges/issues

For each item:
- Date
- Brief description
- Relevance to sales outreach (how to reference it)
- Source URL

Focus on items that create natural conversation starters.
```

### Node 3: Claude - Analyze Personalization Data

```
You are a master of B2B sales personalization. Analyze all available data to create a personalization strategy.

CONTACT INFORMATION:
Name: {{ $json.contact_name }}
Title: {{ $json.contact_title }}
Company: {{ $json.company_name }}
Industry: {{ $json.industry }}

INTELLIGENCE (from Agent 5):
Fit Score: {{ $json.fit_score }}/100
Key Insights: {{ $json.key_insights }}
Trigger Events: {{ $json.trigger_events }}
Talking Points: {{ $json.talking_points }}

COMPANY RESEARCH (from Agent 1A):
{{ fetch Agent 1A research summary }}

PROSPECT PROFILE:
{{ $node['LinkedIn Research'].json }}

RECENT NEWS:
{{ $node['Recent News'].json }}

Create a PERSONALIZATION STRATEGY:

## PERSONALIZATION HOOKS (Rank Top 5)
What specific elements to personalize around:
1. [Hook] - Why relevant, how to use
2. [Hook] - Why relevant, how to use
...

## RECOMMENDED MESSAGING ANGLE
Best approach for this prospect:
- Primary value proposition
- Pain point to address
- Proof/social proof to use
- Competitive differentiation

## TONE & STYLE
- Formality level (1-10)
- Technical depth (1-10)
- Recommended style (consultative, direct, story-driven, data-driven)

## DO's & DON'Ts
DO:
- [Specific thing to do]
- [Specific thing to do]

DON'T:
- [Thing to avoid]
- [Thing to avoid]

## TIMING & CONTEXT
- Best time to reach out (based on news/events)
- Urgency level
- Follow-up strategy

## PERSONALIZATION ELEMENTS
For email/message:
- Subject line approach
- Opening line ideas (3-5 options)
- Body structure recommendation
- Closing/CTA approach
- P.S. idea (if appropriate)

Be specific and actionable.
```

### Node 4: Generate Personalized Content

#### 4a: Email Subject Lines (Claude)

```
Generate 5 highly personalized email subject lines for this prospect:

PERSONALIZATION STRATEGY:
{{ $node['Claude Analysis'].json }}

CONTACT: {{ $json.contact_name }} at {{ $json.company_name }}

SUBJECT LINE REQUIREMENTS:
- 40-60 characters
- Personalized (reference company, news, or context)
- Value-driven (clear benefit)
- Curiosity-generating
- Professional tone

VARIANTS TO CREATE:
1. News/Trigger Event based
2. Mutual connection/social proof
3. Direct value proposition
4. Question/curiosity
5. Industry insight/trend

For each subject line, explain why it will resonate.

Return as JSON:
[
  {
    "subject": "string",
    "type": "news|social_proof|value_prop|question|insight",
    "rationale": "why this will work",
    "personalization_score": 1-10
  }
]
```

#### 4b: Email Body (Claude)

```
Write 3 email variants for this prospect:

PERSONALIZATION STRATEGY:
{{ $node['Claude Analysis'].json }}

SUBJECT LINE (use top one):
{{ $node['Subject Lines'].json[0].subject }}

EMAIL REQUIREMENTS:
- Length: 120-180 words
- Highly personalized opening (reference specific context)
- Clear value proposition
- Social proof or credibility builder
- Specific CTA
- Professional but conversational

VARIANT APPROACHES:
1. Problem-Solution: Lead with pain point
2. Insight-Value: Lead with relevant insight/trend
3. Story-Connection: Lead with relevant story/example

For each variant:
- Personalize opening line to their specific situation
- Reference at least 2 personalization hooks
- Include relevant social proof
- End with specific, low-friction CTA

Return as JSON with:
{
  "variant": 1-3,
  "approach": "problem|insight|story",
  "subject": "subject line",
  "body": "email body text",
  "personalization_elements": ["element1", "element2"],
  "personalization_score": 1-10
}
```

#### 4c: LinkedIn Message (Claude)

```
Write a LinkedIn connection request or InMail message:

PERSONALIZATION STRATEGY:
{{ $node['Claude Analysis'].json }}

LINKEDIN MESSAGE REQUIREMENTS:
- Length: 200-300 characters (connection) or 300-500 (InMail)
- Reference something from their profile/posts
- Explain genuine reason for connecting
- Soft CTA (not salesy)
- Professional and respectful

APPROACH:
- Start with specific observation/compliment
- Connect to shared interest or mutual value
- Suggest low-pressure next step

Return as JSON:
{
  "message_type": "connection_request|inmail",
  "message": "text",
  "personalization_elements": ["element1", "element2"],
  "rationale": "why this approach"
}
```

#### 4d: Phone Script (Claude)

```
Create a personalized cold call script:

PERSONALIZATION STRATEGY:
{{ $node['Claude Analysis'].json }}

PHONE SCRIPT STRUCTURE:

**OPENING (10 seconds)**
- Personalized hook
- Permission-based

**CONTEXT (15 seconds)**
- Why calling now
- Relevant reference

**VALUE PROP (20 seconds)**
- Specific benefit
- Social proof

**DISCOVERY QUESTION**
- Open-ended
- Relevant to their situation

**OBJECTION RESPONSES**
- "Not interested" →
- "Send me info" →
- "Bad timing" →

**CLOSE**
- Specific next step
- Date/time suggestion

Make it conversational, not scripted. Include [PAUSE] and [LISTEN] cues.
```

### Node 5: Gemini - Quality Check & Scoring

```
Quality check these personalized messages:

PERSONALIZATION STRATEGY:
{{ $node['Claude Analysis'].json }}

GENERATED CONTENT:
Email Subject Lines: {{ $node['Subject Lines'].json }}
Email Bodies: {{ $node['Email Bodies'].json }}
LinkedIn Message: {{ $node['LinkedIn Message'].json }}

EVALUATE EACH PIECE:

1. PERSONALIZATION QUALITY (1-10)
   - Specific vs generic
   - Relevance to prospect
   - Natural integration

2. VALUE CLARITY (1-10)
   - Clear benefit
   - Compelling proposition
   - Credibility

3. TONE APPROPRIATENESS (1-10)
   - Matches prospect profile
   - Professional level
   - Authenticity

4. CTA EFFECTIVENESS (1-10)
   - Clear next step
   - Low friction
   - Compelling

5. OVERALL SCORE (weighted average)

6. RECOMMENDATIONS
   - What to improve
   - What's working well

Also check for:
- Spelling/grammar errors
- Overly salesy language
- Generic phrases
- Length compliance

Return JSON with scores and recommendations.
```

### Node 6: Save to Airtable

**Table: Personalized Outreach**
```javascript
{
  "Account ID": "{{ $json.account_id }}",
  "Contact Name": "{{ $json.contact_name }}",
  "Company Name": "{{ $json.company_name }}",

  // Best variants
  "Email Subject": "{{ $node['Subject Lines'].json[0].subject }}",
  "Email Body": "{{ $node['Email Bodies'].json[0].body }}",
  "LinkedIn Message": "{{ $node['LinkedIn Message'].json.message }}",
  "Phone Script": "{{ $node['Phone Script'].json }}",

  // All variants (JSON)
  "All Subject Lines": "{{ JSON.stringify($node['Subject Lines'].json) }}",
  "All Email Variants": "{{ JSON.stringify($node['Email Bodies'].json) }}",

  // Metadata
  "Personalization Score": {{ $node['Quality Check'].json.overall_score }},
  "Personalization Elements": {{ $node['Claude Analysis'].json.personalization_hooks }},
  "Generated Date": "{{ $now }}",
  "Status": "Draft",
  "Quality Check": "{{ JSON.stringify($node['Quality Check'].json) }}"
}
```

### Node 7: Outreach Tool Integration

**Outreach.io / Salesloft**:
```javascript
// If approved, send to outreach tool
if ($json.status === 'Approved') {
  // Create sequence
  await createOutreachSequence({
    prospect_email: $json.contact_email,
    sequence_id: 'personalized_outreach',
    steps: [
      {
        type: 'email',
        subject: $json.email_subject,
        body: $json.email_body,
        delay_days: 0
      },
      {
        type: 'linkedin',
        message: $json.linkedin_message,
        delay_days: 2
      },
      {
        type: 'phone',
        script: $json.phone_script,
        delay_days: 4
      }
    ]
  });
}
```

---

## Airtable Schema

### Table: Personalized Outreach

| Field | Type | Description |
|-------|------|-------------|
| Record ID | Autonumber | Primary key |
| Account ID | Single line text | CRM ID |
| Contact Name | Single line text | Prospect name |
| Company Name | Single line text | Company |
| Email Subject | Single line text | Best subject line |
| Email Body | Long text | Best email body |
| LinkedIn Message | Long text | LinkedIn outreach |
| Phone Script | Long text | Call script |
| All Variants | Long text (JSON) | All generated options |
| Personalization Score | Number | 1-10 quality score |
| Personalization Elements | Multiple select | Hooks used |
| Generated Date | Date & time | Creation timestamp |
| Status | Single select | Draft, Approved, Sent, Responded |
| Sent Date | Date & time | When sent |
| Response Date | Date & time | When responded |
| Response Type | Single select | Positive, Negative, Neutral, Meeting Booked |
| Performance Notes | Long text | What worked/didn't |

**Views**:
- Awaiting Approval: Status = "Draft"
- Sent This Week: Sent Date within this week
- High Response Rate: Response Type IN ("Positive", "Meeting Booked")
- By Company: Group by Company Name

---

## Cost Estimation

**Per Personalization**:
- Perplexity (2 calls): $0.10
- Agent 1A/5 data: $0 (already generated)
- Claude analysis: $0.08
- Claude content (4 pieces): $0.20
- Gemini quality check: $0.02

**Total: ~$0.40 per personalized outreach**

---

**Implementation Time**: 16-20 hours
**Prerequisites**: Agents 1A & 5 deployed, CRM integration
**Next Steps**: Test personalization quality, integrate with outreach tools
