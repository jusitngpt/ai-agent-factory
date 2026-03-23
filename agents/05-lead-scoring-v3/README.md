# Agent 5 Lead Scoring V3 - README

## Overview

**Agent 5 Lead Scoring V3** intelligently qualifies and scores inbound leads using AI-powered analysis. Triggered when new leads enter Airtable (from website forms, LinkedIn ads, etc.), this workflow analyzes company data, web presence, and fit signals to assign priority scores, recommended actions, and routing to the right sales team.

**Workflow ID:** SUAWI4IOqnU62yhJ
**Status:** ✅ Active
**Trigger:** Airtable record created (real-time)
**Primary LLM:** Google Gemini 2.5 Pro

---

## Quick Stats

| Metric | Value |
|--------|-------|
| **Nodes** | 10 |
| **Trigger Type** | Airtable (record created) |
| **Average Execution Time** | 15-30 seconds per lead |
| **Cost Per Lead** | ~$0.02-$0.04 |
| **Processing Capacity** | 1,000+ leads/month |
| **Scoring Dimensions** | 8 factors |
| **Output** | Priority score (0-100), routing, next actions |

---

## Business Value

### Problem: Manual Lead Qualification is Slow and Inconsistent

**Challenges:**
- Sales reps spend 2-3 hours/day qualifying leads manually
- Inconsistent scoring criteria across team
- High-value leads lost in noise
- Slow response times (24-48 hours)
- No data-driven prioritization

**Manual Process:**
1. Lead fills form → Enters CRM/Airtable
2. SDR reviews lead (5-10 min per lead)
3. SDR googles company, checks website
4. SDR assigns priority subjectively
5. Lead queued for outreach (often 24+ hours later)

**Cost:** 20 leads/day × 7 minutes × $30/hr SDR = **$70/day** or **$1,400/month**

### Automated Solution: Agent 5 V3

**Workflow:**
1. Lead created in Airtable → Instant trigger
2. Gemini analyzes company, industry, size, role, intent signals
3. Multi-dimensional scoring (0-100)
4. Automatic routing (Enterprise, SMB, Nurture)
5. Recommended next actions
6. Slack notification to assigned rep

**Benefits:**
- ⚡ **Real-time:** Scored within 30 seconds of lead creation
- 📊 **Consistent:** Same criteria applied to every lead
- 🎯 **Accurate:** AI identifies high-value signals humans miss
- 💰 **Cost-effective:** ~$0.03/lead vs $3.50 manual
- 📈 **Scalable:** Handles 1,000s of leads without additional headcount

**ROI:**
- Time savings: 95% reduction (7 min → 0.5 min supervision)
- Cost savings: $1,360/month ($1,400 manual - $40 automated)
- Revenue impact: 30% faster response time → 15-20% higher conversion

---

## Key Features

### 1. Multi-Dimensional Scoring (8 Factors)

**Company Fit (25 points):**
- Industry match (SaaS, fintech, e-commerce = high fit)
- Company size (50-500 employees = sweet spot)
- Tech stack indicators (uses Selenium, Jenkins, testing tools)

**Role Fit (20 points):**
- Decision-maker (VP, Director = high)
- Practitioner (QA Manager, Test Lead = medium)
- Individual contributor (QA Engineer = lower)

**Intent Signals (20 points):**
- Form source (demo request > whitepaper download)
- Message content (mentions competitor, timeline, budget)
- Urgency indicators ("need solution ASAP", "evaluating now")

**Engagement Level (10 points):**
- Website activity (pages viewed, time on site)
- Content downloaded
- Multiple touchpoints

**Geographic Fit (10 points):**
- Target markets (North America, Europe = high)
- Emerging markets (varies by strategy)

**Budget Indicators (10 points):**
- Company funding/revenue signals
- Team size (proxy for budget)
- Current tool mentions (paying for competitors)

**Strategic Value (5 points):**
- Notable brand (case study potential)
- High-growth company
- Expansion opportunity

**Data Quality (bonus/penalty ±5):**
- Complete vs incomplete data
- Business email vs personal email
- Valid company domain

**Total Score:** 0-100

---

### 2. Intelligent Routing

**Enterprise Track (Score 75-100):**
- Assigned to: Senior AE
- SLA: Contact within 4 hours
- Approach: Personalized outreach, demo offer
- Notification: Slack DM to assigned AE

**SMB Track (Score 50-74):**
- Assigned to: SMB sales team (round-robin)
- SLA: Contact within 24 hours
- Approach: Product-led demo, self-serve trial
- Notification: Slack channel #smb-leads

**Nurture Track (Score 0-49):**
- Assigned to: Marketing automation
- Action: Add to nurture sequence
- Approach: Educational content, case studies
- Notification: None (automated nurture)

---

### 3. Recommended Next Actions

**High-Priority Actions (Score 75+):**
```
1. Immediate personalized outreach (phone + email)
2. Research company background (LinkedIn, website)
3. Identify champion and economic buyer
4. Prepare custom demo environment
5. Offer executive briefing or technical deep-dive
```

**Medium-Priority Actions (Score 50-74):**
```
1. Send personalized email within 24 hours
2. Offer self-serve trial + onboarding call
3. Share relevant case study (similar industry/size)
4. Schedule demo for next available slot
```

**Nurture Actions (Score 0-49):**
```
1. Add to nurture drip campaign
2. Send industry-specific content
3. Tag for future re-engagement
4. Monitor engagement for score increase
```

---

## Sample Output

### High-Score Lead Example (Score: 88)

```json
{
  "lead_score": 88,
  "routing": "Enterprise",
  "assigned_to": "Sarah Chen (Sr. AE)",

  "scoring_breakdown": {
    "company_fit": 23,  // SaaS company, 250 employees, uses Selenium
    "role_fit": 20,      // VP of Engineering
    "intent_signals": 18, // Demo request, mentioned "replacing Selenium"
    "engagement": 8,     // Multiple page views, downloaded whitepaper
    "geographic_fit": 10, // San Francisco, CA (tier 1 market)
    "budget_indicators": 9, // Series B funded, paying for BrowserStack
    "strategic_value": 5,  // High-growth SaaS, potential case study
    "data_quality": -5    // Missing phone number
  },

  "key_signals": [
    "VP-level buyer (decision-maker authority)",
    "Mentioned competitor (BrowserStack) - in active evaluation",
    "Timeline: Q1 decision (high urgency)",
    "Tech stack: Selenium, Jenkins (perfect fit for migration)",
    "Company size: 250 employees (ideal ICP)",
    "Funded: $15M Series B (budget confirmed)"
  ],

  "recommended_actions": [
    "URGENT: Contact within 4 hours (express interest while hot)",
    "Research: Check LinkedIn for mutual connections",
    "Personalize: Reference their Series B, growth trajectory",
    "Offer: Executive briefing with CTO + personalized ROI analysis",
    "Prepare: BrowserStack migration case study"
  ],

  "talking_points": [
    "Selenium expertise: Position Katalon as 'Selenium, enterprise-ready'",
    "Cost savings: Show ROI vs BrowserStack pricing",
    "Migration support: Highlight seamless Selenium script import",
    "Scale: Emphasize handling 250-person team growth"
  ],

  "red_flags": [
    "Missing phone number (lower contact success rate)"
  ]
}
```

**Slack Notification:**
```
🚨 HIGH-PRIORITY LEAD (Score: 88/100)

**Lead:** John Doe, VP Engineering @ Acme SaaS
**Company:** 250 employees, Series B funded SaaS
**Signal:** Demo request, mentions "replacing Selenium" + "Q1 decision"
**Assigned:** @sarah-chen

**Key Info:**
• Using: Selenium + BrowserStack (paying customer)
• Timeline: Q1 (URGENT)
• Budget: Funded ($15M Series B)

**Next Steps:**
✅ Contact within 4 hours
✅ Prepare BrowserStack migration case study
✅ Offer executive briefing

🔗 View in Airtable: [Link]
```

---

## Architecture

```
[Airtable Trigger] → New lead created
        ↓
[Extract Lead Data] → Company, role, form data
        ↓
[Enrich with Gemini] → Company research, scoring
        ↓
[Calculate Score] → Multi-dimensional 0-100
        ↓
[Determine Routing] → Enterprise/SMB/Nurture
        ↓
[Generate Recommendations] → Actions, talking points
        ↓
[Update Airtable] → Write score, routing, recommendations
        ↓
[Slack Notification] → Alert assigned rep (if score > 50)
```

---

## Cost Analysis

**Per-Lead Costs:**
- Gemini 2.5 Pro: ~$0.02-$0.04
- Airtable API: <$0.001
- Slack API: Free
- **Total: ~$0.03/lead**

**Monthly Costs (500 leads):**
- 500 leads × $0.03 = **$15/month**

**vs Manual:**
- SDR time: 500 leads × 7 min × $30/hr = **$1,750/month**
- **Savings: $1,735/month (99% reduction)**

---

## Integration Points

**Airtable:**
- Table: "Leads"
- Trigger: New record created
- Updates: Score, routing, recommendations, status

**Slack:**
- High-priority (75+): DM to assigned AE
- Medium-priority (50-74): #smb-leads channel
- Low-priority (<50): No notification

**Future Integrations:**
- Salesforce (sync scored leads)
- HubSpot (enrich with engagement data)
- Clearbit/ZoomInfo (company enrichment)

---

## Success Metrics

**Technical:**
- 99%+ execution success rate
- <30s average scoring time
- <$0.05 cost per lead

**Business:**
- 30% faster lead response time
- 20% improvement in lead conversion
- 50% increase in rep productivity
- 95% consistency in scoring

---

## Getting Started

**Setup Time:** 45 minutes

1. Configure Airtable (15 min)
2. Set up Gemini API (5 min)
3. Configure Slack (10 min)
4. Import workflow (5 min)
5. Test with sample leads (10 min)

**Full guide:** [IMPLEMENTATION-GUIDE.md](./IMPLEMENTATION-GUIDE.md)

---

## Related Documentation

- [N8N-WORKFLOW.md](./N8N-WORKFLOW.md) - Technical specifications
- [AIRTABLE-SCHEMA.md](./AIRTABLE-SCHEMA.md) - Database schema
- [IMPLEMENTATION-GUIDE.md](./IMPLEMENTATION-GUIDE.md) - Setup instructions
- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - Common issues

---

**Last Updated:** 2025-11-19
**Version:** 3.0
**Status:** ✅ Production Ready
