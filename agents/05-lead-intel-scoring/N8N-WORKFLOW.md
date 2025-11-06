# Agent 5: Lead Intelligence & Scoring - n8n Workflow Specification

## Overview

Complete n8n workflow design for automated lead enrichment, intelligence gathering, and predictive scoring. Integrates with Agent 1A for company research and CRM systems for bi-directional sync.

## Workflow Architecture

```
CRM Webhook / Schedule Trigger
    ↓
[1] Fetch New/Updated Leads from CRM
    ↓
[2] Filter: Needs Enrichment
    ↓
[3] Loop: Process Each Lead
    │   ↓
    │   [3a] Validate & Normalize Data
    │   ↓
    │   [3b] Enrich with Clearbit/ZoomInfo API
    │   ↓
    │   [3c] Trigger Agent 1A (Company Research)
    │   ↓
    │   [3d] LinkedIn Sales Navigator Lookup
    │   ↓
    │   [3e] News & Trigger Events (Perplexity)
    │   ↓
    │   [3f] Claude: Fit Analysis
    │   ↓
    │   [3g] Gemini: Calculate Scores
    │   ↓
    │   [3h] Claude: Generate Insights & Talking Points
    │   ↓
    │   [3i] Save to Airtable
    ↓
[4] Sync High-Priority Leads to CRM
    ↓
[5] Create Sales Tasks (for Tier 1 leads)
    ↓
[6] Slack Notification (Daily Digest)
```

## Detailed Node Specifications

### Node 1: Fetch New Leads from CRM

**Salesforce Integration**:
```javascript
// n8n Salesforce node
{
  "resource": "lead",
  "operation": "getAll",
  "conditions": {
    "logic": "and",
    "conditions": [
      {
        "field": "Status",
        "operator": "equal",
        "value": "New"
      },
      {
        "field": "LeadScore",
        "operator": "isNull"
      },
      {
        "field": "CreatedDate",
        "operator": "greaterThan",
        "value": "LAST_N_DAYS:7"
      }
    ]
  },
  "fields": [
    "Id", "FirstName", "LastName", "Email", "Company",
    "Title", "Phone", "Website", "Industry",
    "LeadSource", "AnnualRevenue", "NumberOfEmployees"
  ]
}
```

**HubSpot Integration**:
```javascript
// HTTP Request to HubSpot API
{
  "method": "GET",
  "url": "https://api.hubapi.com/crm/v3/objects/contacts",
  "qs": {
    "properties": "email,company,jobtitle,lifecyclestage",
    "filterGroups": [{
      "filters": [{
        "propertyName": "lifecyclestage",
        "operator": "EQ",
        "value": "lead"
      }, {
        "propertyName": "hs_lead_status",
        "operator": "EQ",
        "value": "NEW"
      }]
    }]
  },
  "headers": {
    "Authorization": "Bearer {{ $credentials.hubspot_api_key }}"
  }
}
```

### Node 2: Filter - Needs Enrichment

**Logic**:
```javascript
// Filter leads that need enrichment
const leads = $input.all();

return leads.filter(lead => {
  const data = lead.json;

  // Needs enrichment if missing key data
  const needsEnrichment = (
    !data.industry ||
    !data.company_size ||
    !data.annual_revenue ||
    !data.technographic_data ||
    data.last_enriched_date < Date.now() - (30 * 24 * 60 * 60 * 1000) // 30 days old
  );

  // Or if explicitly marked for re-scoring
  const needsRescoring = data.enrichment_status === 'pending';

  return needsEnrichment || needsRescoring;
});
```

### Node 3: Loop - Process Each Lead

#### Node 3a: Validate & Normalize Data

```javascript
const lead = $input.first().json;

// Normalize company name
const normalizeCompany = (name) => {
  return name
    .replace(/\b(Inc|LLC|Ltd|Corp|Corporation|Company|Co)\b\.?/gi, '')
    .trim()
    .toLowerCase();
};

// Normalize email domain
const extractDomain = (email) => {
  if (!email) return null;
  const match = email.match(/@(.+)$/);
  return match ? match[1].toLowerCase() : null;
};

// Validate required fields
const isValid = lead.company && (lead.email || lead.domain);

return [{
  json: {
    ...lead,
    company_normalized: normalizeCompany(lead.company),
    email_domain: extractDomain(lead.email),
    validation_status: isValid ? 'valid' : 'missing_data',
    processed_at: new Date().toISOString()
  }
}];
```

#### Node 3b: Enrich with Clearbit/ZoomInfo API

**Clearbit Enrichment**:
```javascript
// HTTP Request to Clearbit Enrichment API
{
  "method": "GET",
  "url": "https://person.clearbit.com/v2/combined/find",
  "qs": {
    "email": "{{ $json.email }}"
  },
  "headers": {
    "Authorization": "Bearer {{ $credentials.clearbit_api_key }}"
  }
}

// Response provides:
// - Person: name, title, seniority, role
// - Company: name, domain, industry, employees, revenue, tech stack
```

**ZoomInfo Alternative**:
```javascript
// HTTP Request to ZoomInfo API
{
  "method": "POST",
  "url": "https://api.zoominfo.com/enrich/contact",
  "headers": {
    "Authorization": "Bearer {{ $credentials.zoominfo_api_key }}",
    "Content-Type": "application/json"
  },
  "body": {
    "matchPersonInput": [{
      "emailAddress": "{{ $json.email }}",
      "companyName": "{{ $json.company }}"
    }]
  }
}
```

**Merge Enrichment Data**:
```javascript
const lead = $node['Validate Data'].json;
const enrichment = $node['Clearbit Enrichment'].json;

return [{
  json: {
    ...lead,
    // Person data
    full_name: enrichment.person?.name?.fullName || lead.name,
    title: enrichment.person?.employment?.title || lead.title,
    seniority: enrichment.person?.employment?.seniority,
    role: enrichment.person?.employment?.role,
    linkedin_url: enrichment.person?.linkedin?.handle,

    // Company data
    company_domain: enrichment.company?.domain || lead.email_domain,
    company_name: enrichment.company?.name || lead.company,
    industry: enrichment.company?.category?.industry,
    sub_industry: enrichment.company?.category?.subIndustry,
    company_size: enrichment.company?.metrics?.employees,
    annual_revenue: enrichment.company?.metrics?.annualRevenue,
    founded_year: enrichment.company?.foundedYear,
    company_location: enrichment.company?.location,

    // Technographic
    tech_stack: enrichment.company?.tech || [],

    // Enrichment metadata
    enrichment_source: 'clearbit',
    enrichment_date: new Date().toISOString(),
    enrichment_confidence: enrichment.confidence || 'medium'
  }
}];
```

#### Node 3c: Trigger Agent 1A (Company Research)

**Call Agent 1A Webhook**:
```javascript
// HTTP Request to Agent 1A
{
  "method": "POST",
  "url": "https://your-n8n-instance.com/webhook/agent-1a-research",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": {
    "company_name": "{{ $json.company_name }}",
    "research_focus": "Lead qualification: company overview, competitive position, growth signals, technology adoption",
    "priority": "medium",
    "source": "agent_5_lead_scoring"
  }
}

// Wait for response (or poll Airtable for completion)
```

**Poll for Agent 1A Results** (if async):
```javascript
// Loop with wait until research complete
let attempts = 0;
const maxAttempts = 20; // 10 minutes max

while (attempts < maxAttempts) {
  const result = await fetchAirtableRecord(requestId);

  if (result.status === 'Complete') {
    return result;
  }

  await sleep(30000); // Wait 30 seconds
  attempts++;
}

throw new Error('Agent 1A research timeout');
```

#### Node 3d: LinkedIn Sales Navigator Lookup

**LinkedIn API** (if available):
```javascript
// Note: LinkedIn Sales Navigator API is restricted
// Alternative: Use scraping service or manual enrichment

// Example with third-party LinkedIn API service
{
  "method": "GET",
  "url": "https://linkedin-api-service.com/profile",
  "qs": {
    "email": "{{ $json.email }}",
    "company": "{{ $json.company_name }}"
  },
  "headers": {
    "Authorization": "Bearer {{ $credentials.linkedin_api_key }}"
  }
}

// Returns:
// - Profile URL
// - Current position
// - Company details
// - Connections/network size
// - Recent activity
```

#### Node 3e: News & Trigger Events (Perplexity)

**Detect Buying Signals**:
```
Prompt for Perplexity:

Research recent news and trigger events for: {{ $json.company_name }}

Focus on buying signals and timing indicators:

1. FUNDING & FINANCIAL
   - Recent funding rounds (last 6 months)
   - IPO or acquisition news
   - Financial performance updates

2. GROWTH SIGNALS
   - Hiring activity (especially in relevant departments)
   - Office expansions
   - Market expansion announcements

3. TECHNOLOGY & PRODUCT
   - Product launches
   - Technology stack changes
   - Digital transformation initiatives

4. LEADERSHIP CHANGES
   - New executives (especially CTO, CMO, VP Sales)
   - Organizational changes
   - Strategic pivots

5. COMPETITIVE ACTIVITY
   - Competitor wins/losses
   - Market position changes
   - Industry awards

6. PAIN POINTS
   - Public challenges mentioned
   - Customer complaints
   - Regulatory issues

For each finding, assess:
- Relevance to our solution (1-10)
- Urgency/timing (immediate, 1-3 months, 3-6 months)
- Suggested talking points

Return as structured data with sources.
```

#### Node 3f: Claude - Fit Analysis

**ICP Fit Assessment**:
```
You are a B2B sales qualification expert. Analyze this lead's fit with our Ideal Customer Profile.

LEAD DATA:
{{ JSON.stringify($json, null, 2) }}

AGENT 1A RESEARCH:
{{ $node['Agent 1A Results'].json.executive_summary }}
{{ $node['Agent 1A Results'].json.key_findings }}

TRIGGER EVENTS:
{{ $node['Perplexity News'].json }}

OUR IDEAL CUSTOMER PROFILE:
- Company Size: 200-2000 employees
- Industries: B2B SaaS, Fintech, E-commerce
- Annual Revenue: $10M - $500M
- Technology: Modern stack (Cloud, APIs)
- Growth Stage: Series B+ or profitable
- Pain Points: [List your target pain points]

EVALUATE FIT ACROSS DIMENSIONS:

## FIRMOGRAPHIC FIT (0-100)
- Company size match
- Industry alignment
- Revenue range
- Geographic fit
- Growth stage

## TECHNOGRAPHIC FIT (0-100)
- Technology stack compatibility
- Digital maturity
- Integration requirements
- Technical decision-maker access

## BEHAVIORAL FIT (0-100)
- Engagement signals
- Website visits
- Content downloads
- Previous interactions

## TIMING FIT (0-100)
- Trigger events present
- Budget cycle alignment
- Urgency indicators
- Competitive displacement opportunity

## STRATEGIC FIT (0-100)
- Use case alignment
- Value proposition match
- Competitive landscape
- Expansion potential

For each dimension:
- Score (0-100)
- Key factors (positive & negative)
- Confidence level

Return as JSON:
{
  "firmographic_fit": {"score": 85, "factors": [...], "confidence": "high"},
  "technographic_fit": {"score": 75, "factors": [...], "confidence": "medium"},
  "behavioral_fit": {"score": 60, "factors": [...], "confidence": "medium"},
  "timing_fit": {"score": 90, "factors": [...], "confidence": "high"},
  "strategic_fit": {"score": 80, "factors": [...], "confidence": "high"},
  "overall_fit_score": 78,
  "disqualifiers": ["reason1", "reason2"],
  "key_strengths": ["strength1", "strength2"],
  "concerns": ["concern1", "concern2"]
}
```

#### Node 3g: Gemini - Calculate Scores

**Multi-Dimensional Scoring**:
```
Calculate lead scores based on this analysis:

FIT ANALYSIS:
{{ $node['Claude Fit Analysis'].json }}

ENRICHMENT DATA:
{{ $json }}

Calculate three scores:

1. FIT SCORE (0-100)
   Weighted average:
   - Firmographic fit: 25%
   - Technographic fit: 20%
   - Behavioral fit: 15%
   - Timing fit: 20%
   - Strategic fit: 20%

2. INTENT SCORE (0-100)
   Based on:
   - Website engagement: 30%
   - Content interactions: 25%
   - Trigger events: 25%
   - Competitive research: 10%
   - Direct inquiries: 10%

3. PRIORITY SCORE (0-100)
   Formula: (Fit Score × 0.6) + (Intent Score × 0.4)

TIER CLASSIFICATION:
- Tier 1 (Hot): Priority >= 80
- Tier 2 (Warm): Priority 60-79
- Tier 3 (Nurture): Priority 40-59
- Tier 4 (Disqualify): Priority < 40

RECOMMENDED ACTION:
- Tier 1: Immediate outreach, assign to AE
- Tier 2: SDR qualified outreach
- Tier 3: Marketing nurture
- Tier 4: Disqualify or long-term nurture

Return as JSON:
{
  "fit_score": number,
  "intent_score": number,
  "priority_score": number,
  "tier": "1|2|3|4",
  "tier_label": "Hot|Warm|Nurture|Disqualify",
  "recommended_action": "string",
  "recommended_owner": "AE|SDR|Marketing|None",
  "follow_up_timing": "immediate|this_week|this_month|later",
  "score_breakdown": {
    "firmographic": number,
    "technographic": number,
    "behavioral": number,
    "timing": number,
    "strategic": number
  }
}
```

#### Node 3h: Claude - Generate Insights & Talking Points

**Sales Intelligence**:
```
Generate sales intelligence and talking points for this lead:

LEAD: {{ $json.full_name }} at {{ $json.company_name }}
TIER: {{ $node['Gemini Scoring'].json.tier_label }}
FIT SCORE: {{ $node['Gemini Scoring'].json.fit_score }}/100

RESEARCH INSIGHTS:
{{ $node['Agent 1A Results'].json }}

TRIGGER EVENTS:
{{ $node['Perplexity News'].json }}

FIT ANALYSIS:
{{ $node['Claude Fit Analysis'].json }}

Generate:

## EXECUTIVE SUMMARY (2-3 sentences)
Quick snapshot for sales rep - why this lead matters and key approach.

## KEY INSIGHTS (3-5 bullets)
Most important intelligence:
- Company situation/context
- Why now (timing)
- Competitive landscape
- Decision-maker dynamics

## RECOMMENDED APPROACH
Best strategy for this lead:
- Outreach channel (email, LinkedIn, phone)
- Key message/angle
- Value proposition to lead with
- References to use (similar customers, use cases)

## TALKING POINTS (5-7 points)
Specific points to mention in conversation:
- Personalized to their situation
- Reference recent company news/changes
- Connect to pain points
- Differentiate from competitors
- Call out relevant capabilities

## POTENTIAL OBJECTIONS & RESPONSES
Anticipate 3-4 likely objections with suggested responses.

## NEXT STEPS
Recommended action plan:
1. [First action with timeline]
2. [Second action]
3. [Third action]

## RESEARCH SOURCES
- [Source 1 URL]
- [Source 2 URL]
...

Format for easy consumption by sales team.
```

#### Node 3i: Save to Airtable

**Table**: Lead Intelligence
```javascript
{
  "CRM Lead ID": "{{ $json.crm_id }}",
  "Email": "{{ $json.email }}",
  "Full Name": "{{ $json.full_name }}",
  "Title": "{{ $json.title }}",
  "Company Name": "{{ $json.company_name }}",
  "Company Domain": "{{ $json.company_domain }}",
  "Industry": "{{ $json.industry }}",
  "Company Size": {{ $json.company_size }},
  "Annual Revenue": {{ $json.annual_revenue }},

  // Scores
  "Fit Score": {{ $node['Gemini Scoring'].json.fit_score }},
  "Intent Score": {{ $node['Gemini Scoring'].json.intent_score }},
  "Priority Score": {{ $node['Gemini Scoring'].json.priority_score }},
  "Tier": "{{ $node['Gemini Scoring'].json.tier }}",
  "Tier Label": "{{ $node['Gemini Scoring'].json.tier_label }}",

  // Intelligence
  "Executive Summary": "{{ $node['Claude Insights'].json.executive_summary }}",
  "Key Insights": "{{ JSON.stringify($node['Claude Insights'].json.key_insights) }}",
  "Talking Points": "{{ JSON.stringify($node['Claude Insights'].json.talking_points) }}",
  "Recommended Approach": "{{ $node['Claude Insights'].json.recommended_approach }}",
  "Trigger Events": "{{ JSON.stringify($node['Perplexity News'].json.trigger_events) }}",

  // Metadata
  "Enrichment Date": "{{ $now }}",
  "Last Scored": "{{ $now }}",
  "Research Link": "{{ link to Agent 1A results }}",
  "Assigned To": "{{ $node['Gemini Scoring'].json.recommended_owner }}",
  "Follow Up Timing": "{{ $node['Gemini Scoring'].json.follow_up_timing }}",
  "Status": "Enriched"
}
```

### Node 4: Sync High-Priority Leads to CRM

**Salesforce Update**:
```javascript
// Update lead in Salesforce with scores and intelligence
{
  "resource": "lead",
  "operation": "update",
  "leadId": "{{ $json.crm_id }}",
  "fields": {
    "LeadScore": {{ $json.priority_score }},
    "Tier__c": "{{ $json.tier }}",
    "FitScore__c": {{ $json.fit_score }},
    "IntentScore__c": {{ $json.intent_score }},
    "AI_Insights__c": "{{ $json.executive_summary }}",
    "TalkingPoints__c": "{{ $json.talking_points }}",
    "LastEnrichmentDate__c": "{{ $now }}",
    "Status": "{{ $json.tier === '1' ? 'Working - Contacted' : 'Open - Not Contacted' }}"
  }
}
```

### Node 5: Create Sales Tasks (Tier 1 Leads)

**For Hot Leads Only**:
```javascript
// Create task in CRM for Tier 1 leads
if ($json.tier === '1') {
  return [{
    json: {
      "resource": "task",
      "operation": "create",
      "fields": {
        "WhoId": "{{ $json.crm_id }}",
        "Subject": "High-Priority Lead: {{ $json.company_name }} - {{ $json.full_name }}",
        "Priority": "High",
        "Status": "Not Started",
        "ActivityDate": "{{ date_add(now, 'days', 1) }}", // Tomorrow
        "Description": `
          Tier 1 Lead - Immediate Action Required

          Company: {{ $json.company_name }}
          Contact: {{ $json.full_name }} ({{ $json.title }})
          Priority Score: {{ $json.priority_score }}/100

          WHY NOW:
          {{ $json.trigger_events[0] }}

          RECOMMENDED APPROACH:
          {{ $json.recommended_approach }}

          KEY TALKING POINTS:
          {{ $json.talking_points.slice(0, 3).join('\n') }}

          Full intelligence: [Link to Airtable]
        `
      }
    }
  }];
}
```

### Node 6: Slack Notification

**Daily Digest**:
```json
{
  "text": "📊 Lead Intelligence Daily Digest",
  "blocks": [
    {
      "type": "header",
      "text": {
        "type": "plain_text",
        "text": "🎯 Lead Intelligence & Scoring - Daily Report"
      }
    },
    {
      "type": "section",
      "fields": [
        {"type": "mrkdwn", "text": "*Leads Processed:*\n{{ total_leads }}"},
        {"type": "mrkdwn", "text": "*Tier 1 (Hot):*\n🔥 {{ tier_1_count }}"},
        {"type": "mrkdwn", "text": "*Tier 2 (Warm):*\n⭐ {{ tier_2_count }}"},
        {"type": "mrkdwn", "text": "*Avg Priority Score:*\n{{ avg_priority_score }}/100"}
      ]
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*🔥 Top 3 Hot Leads:*\n{{ top_leads.map(l => `• ${l.company} - ${l.name} (Score: ${l.score})`).join('\n') }}"
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*📈 Key Trigger Events Today:*\n{{ trigger_events.slice(0, 3).join('\n') }}"
      }
    },
    {
      "type": "actions",
      "elements": [
        {
          "type": "button",
          "text": {"type": "plain_text", "text": "View All Leads"},
          "url": "https://airtable.com/[BASE_ID]/[TABLE_ID]"
        },
        {
          "type": "button",
          "text": {"type": "plain_text", "text": "Hot Leads Only"},
          "url": "https://airtable.com/[BASE_ID]/[VIEW_ID]"
        }
      ]
    }
  ]
}
```

---

## Error Handling

### Enrichment API Failures
```javascript
try {
  const enrichment = await clearbitEnrich(email);
  return enrichment;
} catch (error) {
  if (error.status === 404) {
    // Person not found, use basic data
    console.log('Enrichment not found, using basic data');
    return basicLeadData;
  } else if (error.status === 422) {
    // Invalid email
    return { error: 'invalid_email', skip: true };
  } else {
    // API error, retry
    return { error: 'api_error', retry: true };
  }
}
```

### Agent 1A Timeout
```javascript
// If Agent 1A doesn't complete in 5 minutes, continue without it
const TIMEOUT = 5 * 60 * 1000; // 5 minutes

const researchPromise = waitForAgent1A(requestId);
const timeoutPromise = new Promise((_, reject) =>
  setTimeout(() => reject(new Error('timeout')), TIMEOUT)
);

try {
  const research = await Promise.race([researchPromise, timeoutPromise]);
  return research;
} catch (error) {
  if (error.message === 'timeout') {
    console.log('Agent 1A timeout, proceeding without full research');
    return { status: 'incomplete', data: basicCompanyData };
  }
  throw error;
}
```

---

## Performance Optimization

### Batch Processing
```javascript
// Process leads in batches of 10
const BATCH_SIZE = 10;
const leads = $input.all();

const batches = [];
for (let i = 0; i < leads.length; i += BATCH_SIZE) {
  batches.push(leads.slice(i, i + BATCH_SIZE));
}

// Process each batch with 2-minute delay between batches
for (const batch of batches) {
  await processBatch(batch);
  await sleep(120000); // 2 min cooldown
}
```

### Caching
```javascript
// Cache company research for 30 days
const cacheKey = `company:${companyNormalized}`;
const cached = await getFromCache(cacheKey);

if (cached && cached.age < 30 * 24 * 60 * 60 * 1000) {
  console.log('Using cached research');
  return cached.data;
}

const research = await runAgent1A(company);
await setCache(cacheKey, research, 30 * 24 * 60 * 60 * 1000);
return research;
```

---

## Cost Estimation

**Per Lead**:
- Clearbit enrichment: $0.50-1.00 (or free tier)
- Agent 1A research: $0.20-0.30
- Perplexity news: $0.05
- Claude fit analysis: $0.08
- Gemini scoring: $0.02
- Claude insights: $0.10

**Total: $0.95-1.55 per lead**

**Monthly** (100 leads):
- $95-155/month

**Optimization**:
- Skip Agent 1A for small companies: Save $0.25
- Cache company research: Save 50-70% on duplicates
- Use free enrichment tiers: Save $0.50-1.00

---

**Implementation Time**: 20-24 hours
**Prerequisites**: CRM access, enrichment API, Agent 1A deployed
**Next Steps**: Set up CRM integration, configure scoring model, test workflow
