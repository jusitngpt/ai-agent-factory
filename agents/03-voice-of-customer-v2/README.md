# Agent-3 Voice of Customer V2 - README

## Overview

**Agent-3 Voice of Customer V2** is an intelligent automation workflow that monitors and analyzes customer sentiment from major software review platforms (G2, Capterra, TrustRadius) for Katalon and its top competitors. Running monthly, this agent provides comprehensive voice-of-customer intelligence, identifying competitive strengths, weaknesses, customer pain points, and opportunities for product and messaging improvements.

**Workflow ID:** TEyv2qC5T0lv71Fe
**Status:** ✅ Active
**Trigger:** Monthly (1st of each month, 10:00 AM)
**Primary LLMs:** Perplexity Sonar Pro + Google Gemini 2.5 Pro

---

## Quick Stats

| Metric | Value |
|--------|-------|
| **Nodes** | 12 |
| **Competitors Monitored** | 5 (configurable) |
| **Review Platforms** | 3 (G2, Capterra, TrustRadius) |
| **Average Execution Time** | 20-30 minutes (all competitors) |
| **Cost Per Execution** | ~$0.90-$1.50 |
| **Trigger Type** | Schedule (Monthly - 1st, 10 AM) |
| **Primary Use Case** | Competitive sentiment analysis |
| **Data Retention** | 12 months (rolling) |

---

## Business Value

### Problem Statement

Understanding customer sentiment across review platforms is critical for:
- **Product Development:** Identifying feature gaps and pain points
- **Competitive Positioning:** Understanding where competitors excel or fail
- **Messaging & Marketing:** Crafting resonant value propositions
- **Sales Enablement:** Arming sales with competitive battle cards
- **Customer Success:** Proactively addressing common issues

**Manual Alternative:**
- Analyst manually reviews 5 competitors × 3 platforms = 15 sources
- Reads 50-100+ reviews per competitor
- Synthesizes sentiment, themes, and competitive insights
- Time required: **15-20 hours per month**
- Cost: **$750-$1,000/month** at $50/hour analyst rate

### Automated Solution

Agent-3 V2 automates this entire process:
- **Perplexity Sonar Pro** conducts real-time research across review platforms
- **Gemini 2.5 Pro** synthesizes sentiment, identifies themes, and extracts strategic insights
- **Airtable** stores structured intelligence for easy analysis
- **Slack** notifies team when analysis complete

**Time Required:** 30 minutes supervision/month
**Cost:** ~$1.50/month (API costs)
**Savings:** $748.50-$998.50/month (99.8% cost reduction)

---

## Key Features

### 1. Multi-Platform Sentiment Analysis

Aggregates customer feedback from:
- **G2:** Leading B2B software review platform
- **Capterra:** Gartner-owned review platform
- **TrustRadius:** Unbiased B2B reviews platform

**Sentiment Metrics:**
- Overall rating (1-5 stars)
- Rating trends (improving/declining/stable)
- Review volume and recency
- Verified vs. incentivized reviews

### 2. Competitive Intelligence

Analyzes 5 key competitors:
- Selenium (open-source leader)
- Cypress (modern e2e testing)
- Playwright (Microsoft-backed)
- TestCafe (Node.js testing)
- BrowserStack (cloud testing platform)

**Competitive Insights:**
- What customers love about competitors
- What customers complain about
- Feature gaps Katalon can exploit
- Messaging angles that resonate

### 3. Theme Extraction

Uses AI to identify recurring themes across hundreds of reviews:
- **Positive Themes:** Praised features, standout strengths
- **Negative Themes:** Pain points, frustrations, missing features
- **Neutral Themes:** Common mentions without strong sentiment

**Example Themes:**
- "Easy to use for non-technical users"
- "Steep learning curve for advanced features"
- "Great customer support responsiveness"
- "Lacks integration with tool X"

### 4. Strategic Recommendations

Gemini 2.5 Pro synthesizes research into actionable recommendations:
- **Product Priorities:** Features to build based on gaps
- **Messaging Opportunities:** Competitive angles to emphasize
- **Customer Success Tactics:** Common issues to proactively address
- **Sales Enablement:** Battle card talking points

### 5. Trend Tracking

Historical data enables month-over-month trend analysis:
- Sentiment shifts (improving/worsening)
- Emerging themes (new complaints/praises)
- Competitive positioning changes
- Review volume trends

---

## Use Cases

### Product Management

**Scenario:** Product team planning Q1 roadmap

**How Agent-3 Helps:**
1. Reviews Agent-3 output for competitor weaknesses
2. Identifies top 3 "missing features" themes
3. Cross-references with Katalon user requests
4. Prioritizes features that address competitive gaps

**Outcome:** Data-driven roadmap aligned with market needs

---

### Competitive Marketing

**Scenario:** Marketing creating "Katalon vs. Competitor" comparison pages

**How Agent-3 Helps:**
1. Analyzes competitor negative themes (pain points)
2. Identifies Katalon advantages (positive themes competitors lack)
3. Extracts customer quotes for social proof
4. Informs messaging angles

**Outcome:** Compelling comparison content based on real customer sentiment

---

### Sales Enablement

**Scenario:** Sales team facing objection "Competitor X has better reviews"

**How Agent-3 Helps:**
1. Provides context: Overall ratings + review volume
2. Highlights competitor weaknesses (negative themes)
3. Arms sales with specific talking points
4. Suggests questions to uncover fit

**Outcome:** Sales confidently handles competitive objections

---

### Customer Success

**Scenario:** Customer Success wants to reduce churn

**How Agent-3 Helps:**
1. Identifies common pain points (negative themes)
2. Reveals what customers value most (positive themes)
3. Shows where competitors fail (opportunities to retain)
4. Informs proactive outreach strategy

**Outcome:** Reduced churn through proactive issue resolution

---

## Architecture

### Workflow Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                   Agent-3 Voice of Customer V2                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  [1] Schedule Trigger (Monthly - 1st at 10 AM)                       │
│         │                                                             │
│         ▼                                                             │
│  [2] Competitor Array Setup (Code Node)                              │
│         │                                                             │
│         ▼                                                             │
│  [3] Split Into Batches (Loop: 1 competitor at a time)               │
│         │                                                             │
│         ▼                                                             │
│  [4] Extract Competitor Info (Code Node)                             │
│         │                                                             │
│         ▼                                                             │
│  [5] VOC Research (Perplexity Sonar Pro)                             │
│         │  └─→ Searches G2, Capterra, TrustRadius                    │
│         │      Aggregates reviews, ratings, sentiment                │
│         ▼                                                             │
│  [6] Sentiment Analysis (Gemini 2.5 Pro)                             │
│         │  └─→ Extracts themes, competitive insights                 │
│         │      Generates strategic recommendations                   │
│         ▼                                                             │
│  [7] Extract Structured JSON (Information Extractor)                 │
│         │  └─→ Validates schema, cleans output                       │
│         ▼                                                             │
│  [8] Save to Airtable (Competitor VOC Analysis table)                │
│         │                                                             │
│         └──→ Loop back to [3] for next competitor                    │
│                                                                       │
│  [9] Aggregate Summary (Code Node)                                   │
│         │  └─→ Calculate avg sentiment, top themes                   │
│         ▼                                                             │
│  [10] Completion Notification (Slack)                                │
│          └─→ Summary stats + link to Airtable                        │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **Monthly Trigger** → Initiates analysis on 1st of month
2. **Competitor Setup** → Loads 5 competitor profiles with review platform URLs
3. **Loop Processing** → Analyzes 1 competitor at a time (prevents rate limits)
4. **VOC Research** → Perplexity searches review platforms, aggregates findings
5. **Sentiment Analysis** → Gemini extracts themes, sentiment, strategic insights
6. **JSON Extraction** → Validates and structures output for Airtable
7. **Data Storage** → Saves to Airtable for historical tracking
8. **Summary Aggregation** → Calculates cross-competitor metrics
9. **Team Notification** → Slack alert with summary and Airtable link

---

## AI Analysis Framework

### Perplexity Research Dimensions (Node 5)

**Review Platform Coverage:**
- G2 reviews (last 6 months)
- Capterra reviews (last 6 months)
- TrustRadius reviews (last 6 months)

**Data Collected:**
```
For each competitor:
1. Overall Rating (1-5 stars)
2. Total Review Count
3. Recent Review Count (last 6 months)
4. Rating Trend (improving/declining/stable)
5. Verified Review Percentage
6. Top Positive Themes (5-7 themes)
7. Top Negative Themes (5-7 themes)
8. Representative Positive Quotes (3-5)
9. Representative Negative Quotes (3-5)
10. Feature Mentions (most praised/criticized)
11. Comparison to Katalon (if mentioned)
12. Reviewer Personas (company size, role)
```

**Search Recency:** Last 6 months (fresh, relevant feedback)

### Gemini Analysis Output (Node 6)

**Structured Intelligence:**
```json
{
  "executive_summary": "2-3 paragraph strategic overview",

  "sentiment_overview": {
    "overall_rating": "4.2/5",
    "rating_trend": "Improving (+0.3 vs 6 months ago)",
    "review_volume": "250 reviews (150 in last 6 months)",
    "sentiment_distribution": {
      "positive": "65%",
      "neutral": "20%",
      "negative": "15%"
    }
  },

  "positive_themes": [
    {
      "theme": "Easy to use for beginners",
      "mention_frequency": "High (45% of reviews)",
      "representative_quotes": ["quote 1", "quote 2"],
      "strategic_implication": "Strong onboarding reduces time-to-value"
    }
  ],

  "negative_themes": [
    {
      "theme": "Limited advanced customization",
      "mention_frequency": "Medium (25% of reviews)",
      "representative_quotes": ["quote 1", "quote 2"],
      "strategic_implication": "Opportunity for Katalon to position as more flexible"
    }
  ],

  "competitive_insights": {
    "strengths_vs_katalon": ["strength 1", "strength 2"],
    "weaknesses_vs_katalon": ["weakness 1", "weakness 2"],
    "opportunities_for_katalon": ["opp 1", "opp 2"]
  },

  "strategic_recommendations": {
    "product_priorities": [
      {
        "recommendation": "Add feature X based on competitor weakness",
        "rationale": "30% of negative reviews mention missing feature X",
        "priority": "High",
        "expected_impact": "Close competitive gap, address 30% of objections"
      }
    ],
    "messaging_opportunities": [
      {
        "angle": "Position Katalon as 'easy to learn, powerful to scale'",
        "rationale": "Competitors either easy OR powerful, not both",
        "target_audience": "Teams with mixed technical skills",
        "expected_outcome": "Differentiate in crowded market"
      }
    ],
    "customer_success_tactics": [
      {
        "tactic": "Proactive training on feature Y",
        "rationale": "25% of competitor negative reviews cite feature Y confusion",
        "implementation": "Add to onboarding checklist",
        "expected_outcome": "Prevent churn from learning curve"
      }
    ]
  },

  "reviewer_insights": {
    "common_personas": ["QA Manager at mid-size SaaS", "Developer at enterprise"],
    "company_size_distribution": "60% SMB, 30% Mid-Market, 10% Enterprise",
    "key_use_cases": ["Web app testing", "Regression testing", "CI/CD integration"]
  },

  "key_metrics": {
    "analysis_confidence": "High",
    "data_freshness": "Last 6 months",
    "strategic_priority_score": "85/100",
    "recommended_review_frequency": "Monthly"
  }
}
```

---

## Cost Analysis

### Per-Execution Costs

| Component | Cost per Competitor | Cost for 5 Competitors |
|-----------|---------------------|------------------------|
| Perplexity Sonar Pro | $0.08-$0.12 | $0.40-$0.60 |
| Google Gemini 2.5 Pro | $0.10-$0.18 | $0.50-$0.90 |
| Airtable API | ~$0.001 | ~$0.005 |
| Slack API | Free | Free |
| **Total per Month** | **~$0.18-$0.30** | **~$0.90-$1.50** |

### Monthly Cost Projection

```
Monthly Executions: 1 (1st of month)
Competitors per Execution: 5
Cost per Execution: ~$1.20

Monthly Total: ~$1.20
Annual Total: ~$14.40
```

### ROI Comparison

**Manual Analysis:**
- Market Research Analyst: $50/hour
- Time per competitor: 3-4 hours (read reviews, synthesize)
- Total time: 15-20 hours/month
- **Monthly cost: $750-$1,000**

**Agent-3 V2 Automation:**
- Execution time: 20-30 minutes
- Supervision time: 30 minutes/month
- API costs: ~$1.20/month
- **Monthly cost: ~$26.20** (25 min @ $50/hr + $1.20 API)

**Savings:**
- **$723.80-$973.80/month** (96-97% reduction)
- **8,686-11,686% ROI**

---

## Sample Output

### Executive Summary Example

```
Selenium maintains strong overall ratings (4.3/5 across platforms) driven by its
mature ecosystem and extensive community support. However, sentiment analysis reveals
a growing divergence: experienced developers praise its flexibility and wide browser
support, while newer users cite a steep learning curve and complex setup as major
barriers. 65% of negative reviews (last 6 months) mention "difficult for beginners"
or "requires significant coding knowledge."

Key competitive threat: Selenium's brand recognition and free/open-source model create
strong top-of-funnel advantage. However, 40% of reviews comparing Selenium to
commercial alternatives highlight frustration with maintenance overhead and lack of
built-in features (reporting, parallel execution, visual testing).

Primary opportunity for Katalon: Position as "Selenium, but enterprise-ready" -
highlighting ease of use for mixed-skill teams, built-in advanced features, and
reduced maintenance burden. Target messaging at teams currently struggling with
Selenium's learning curve (SMB QA teams, organizations transitioning from manual
testing).
```

### Theme Examples

**Positive Themes (Selenium):**
```
1. "Extensive browser and platform support" (60% of positive reviews)
   - Quotes: "Works with every browser we need", "Best cross-browser testing tool"
   - Implication: Table stakes - Katalon must match browser coverage

2. "Large community and resources" (55% of positive reviews)
   - Quotes: "Tons of tutorials and Stack Overflow answers", "Easy to find help"
   - Implication: Invest in community building, documentation

3. "Free and open source" (50% of positive reviews)
   - Quotes: "No licensing costs", "Can customize anything"
   - Implication: Emphasize Katalon's free tier, highlight value of paid features
```

**Negative Themes (Selenium):**
```
1. "Steep learning curve, requires coding" (65% of negative reviews)
   - Quotes: "Too hard for our manual testers", "Weeks to become productive"
   - Implication: ✅ Katalon advantage - low-code Studio, recorder

2. "No built-in reporting or test management" (40% of negative reviews)
   - Quotes: "Have to build everything yourself", "Reporting is a pain"
   - Implication: ✅ Katalon advantage - Analytics, TestOps integration

3. "Maintenance overhead and flaky tests" (35% of negative reviews)
   - Quotes: "Tests break with every UI change", "Spend more time fixing than writing"
   - Implication: ✅ Katalon opportunity - self-healing, smart wait strategies
```

---

## Integration Points

### Airtable

**Table:** Competitor VOC Analysis
**Records Created:** 5 per month (1 per competitor)
**Data Structure:** 25+ fields including sentiment metrics, themes, recommendations

**Key Fields:**
- Competitor Name
- Analysis Date
- Overall Rating
- Rating Trend
- Positive Themes (JSON)
- Negative Themes (JSON)
- Competitive Insights (JSON)
- Strategic Recommendations (JSON)
- Strategic Priority Score

**Usage:**
- Historical trend analysis
- Cross-competitor benchmarking
- Product roadmap planning
- Sales battle card updates

### Slack

**Channel:** #voice-of-customer OR #competitive-intelligence
**Notification Frequency:** Monthly (after execution completes)
**Content:**
- Summary statistics (avg rating, total reviews)
- Top themes across all competitors
- High-priority insights
- Link to Airtable for full details

**Example Notification:**
```
:mega: Voice of Customer Analysis Complete - November 2025

📊 Summary:
• 5 competitors analyzed
• Avg rating: 4.1/5 (stable vs. October)
• 1,250 total reviews analyzed (last 6 months)

🔝 Top Themes (Positive):
1. Easy to use / Low learning curve (Cypress, TestCafe)
2. Fast execution / Developer productivity (Playwright, Cypress)
3. Great documentation (Playwright)

🔻 Top Themes (Negative):
1. Limited browser support (Cypress: 35% of negative reviews)
2. Steep learning curve (Selenium: 65% of negative reviews)
3. Poor debugging experience (TestCafe: 25% of negative reviews)

🎯 Key Opportunity:
"Easy for beginners, powerful for experts" positioning - competitors struggle
to balance ease-of-use with advanced capabilities. Katalon can own this space.

📋 View Full Analysis: [Airtable Link]

Next Analysis: December 1, 2025 at 10 AM
```

### Product Management Tools

**Potential Integrations:**
- Export themes to Productboard (feature requests)
- Link to Jira epics (competitive feature gaps)
- Feed into quarterly roadmap planning docs
- Inform OKRs and success metrics

---

## Maintenance Requirements

### Monthly (5-10 minutes)

**After Each Execution:**
- [ ] Review Slack notification
- [ ] Spot-check 1-2 Airtable records
- [ ] Verify data quality (ratings, themes)
- [ ] Share key insights with stakeholders

### Quarterly (30-45 minutes)

**Review and Optimize:**
- [ ] Update competitor list (add/remove if market changes)
- [ ] Refresh review platform URLs
- [ ] Analyze 3-month trends (are ratings improving/declining?)
- [ ] Update prompts based on data quality feedback
- [ ] Review API costs vs. budget

### Annually (1-2 hours)

**Strategic Review:**
- [ ] Evaluate competitor selection (still relevant?)
- [ ] Assess ROI (time/cost savings, insights generated)
- [ ] Consider adding new review platforms
- [ ] Evaluate newer LLM models (Gemini updates)
- [ ] Present year-over-year trends to leadership

---

## Success Metrics

### Technical Metrics

- **Execution Success Rate:** >95% (no API failures)
- **Execution Time:** <30 minutes for 5 competitors
- **Data Quality:** >90% "High" analysis confidence scores
- **Cost:** <$2/month

### Business Metrics

- **Insights Generated:** 25-35 strategic recommendations/month
- **Theme Coverage:** 30-50 unique themes identified/month
- **Stakeholder Engagement:** >50% of analyses reviewed within 1 week
- **Action Items Generated:** 5-10 product/messaging actions/month

### Impact Metrics (Long-term)

- **Product Roadmap Influence:** 20%+ of roadmap items informed by VOC
- **Competitive Win Rate:** Track correlation with VOC-informed messaging
- **Customer Satisfaction:** Monitor Katalon's review sentiment vs. competitors
- **Time Savings:** 15-20 hours/month vs. manual research

---

## Getting Started

### Prerequisites

- n8n instance (v1.0+)
- Airtable account with base access
- Slack workspace with bot permissions
- Perplexity API key (Sonar Pro access)
- Google Gemini API key (2.5 Pro access)

### Quick Setup

1. **Create Airtable Base** (15 min)
   - Use schema from [AIRTABLE-SCHEMA.md](./AIRTABLE-SCHEMA.md)
   - Create "Competitor VOC Analysis" table
   - Configure 25 fields

2. **Configure Slack** (10 min)
   - Create #voice-of-customer channel
   - Set up Slack bot with OAuth
   - Add bot to channel

3. **Set Up n8n Credentials** (10 min)
   - Perplexity API
   - Google Gemini API
   - Airtable Personal Access Token
   - Slack OAuth2

4. **Import Workflow** (5 min)
   - Import JSON from `/workflows/agent-3-voice-of-customer-v2.json`
   - Update credentials
   - Configure competitor list

5. **Test Execution** (30 min)
   - Run with 1 competitor first
   - Verify Airtable record created
   - Check Slack notification
   - Validate data quality

6. **Activate** (2 min)
   - Enable monthly schedule
   - Set next execution: 1st of next month, 10 AM

**Total Setup Time:** ~70 minutes

**Full implementation guide:** [IMPLEMENTATION-GUIDE.md](./IMPLEMENTATION-GUIDE.md)

---

## Troubleshooting

Common issues and solutions:

**Issue:** "Not enough recent reviews found"
- **Solution:** Expand search recency from 6 months → 12 months
- **Alternative:** Add more review platforms (Software Advice, GetApp)

**Issue:** Perplexity timeout
- **Solution:** Reduce max tokens (4000 → 3000), increase node timeout

**Issue:** Gemini safety filter blocks content
- **Solution:** Adjust safety settings, sanitize competitor names in prompts

**Issue:** Low analysis confidence scores
- **Solution:** Improve competitor review platform URLs, enhance Perplexity prompt specificity

**Full troubleshooting guide:** [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

---

## Related Documentation

- **Technical Specifications:** [N8N-WORKFLOW.md](./N8N-WORKFLOW.md)
- **Database Schema:** [AIRTABLE-SCHEMA.md](./AIRTABLE-SCHEMA.md)
- **Implementation Guide:** [IMPLEMENTATION-GUIDE.md](./IMPLEMENTATION-GUIDE.md)
- **Troubleshooting:** [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
- **Workflow JSON:** [/workflows/agent-3-voice-of-customer-v2.json](../../workflows/agent-3-voice-of-customer-v2.json)

---

## Changelog

### Version 2.0 (Current)
- **Released:** 2025-11-19
- **Changes:**
  - Upgraded to Gemini 2.5 Pro (from 1.5)
  - Added TrustRadius platform coverage
  - Enhanced theme extraction (JSON structured output)
  - Improved strategic recommendations framework
  - Monthly schedule (was quarterly)
  - 12-node architecture (refined from V1)

### Version 1.0 (Legacy)
- **Released:** 2025-06-01
- **Deprecated:** 2025-11-15
- **Status:** Historical reference only

---

## Support

**Primary Contact:** Katalon Marketing Automation Team

**Issues:** Open GitHub issue in ai-agent-factory repository

**Documentation Updates:** Submit pull request with changes

---

**Last Updated:** 2025-11-19
**Version:** 2.0
**Status:** ✅ Production Ready
**Maintained By:** Katalon Marketing Automation Team
