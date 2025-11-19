# Agent-3 Voice of Customer V2 - n8n Workflow Technical Specification

## Overview

**Workflow ID:** TEyv2qC5T0lv71Fe
**Total Nodes:** 12
**Execution Model:** Sequential loop processing
**Average Execution Time:** 20-30 minutes (5 competitors)
**Trigger:** Monthly (1st at 10:00 AM)

---

## Workflow Architecture

```
Schedule Trigger → Competitor Setup → Loop (5 iterations) → Aggregate → Slack
     ↓                    ↓                    ↓
  (Monthly)        (Competitor Array)    Extract → Perplexity → Gemini → JSON → Airtable
```

---

## Node Specifications

### Node 1: Schedule Trigger - Monthly VOC Analysis

**Type:** `n8n-nodes-base.scheduleTrigger`

**Configuration:**
```json
{
  "rule": {
    "interval": [{
      "field": "months",
      "monthsInterval": 1,
      "dayOfMonth": 1,
      "hour": 10,
      "minute": 0
    }]
  },
  "timezone": "America/New_York"
}
```

---

### Node 2: Competitor VOC Array Setup

**Type:** `n8n-nodes-base.code`

**Code:**
```javascript
return [{
  json: {
    competitors: [
      {
        name: "Selenium",
        review_platforms: {
          g2: "https://www.g2.com/products/selenium/reviews",
          capterra: "https://www.capterra.com/p/133195/Selenium/",
          trustradius: "https://www.trustradius.com/products/selenium/reviews"
        },
        category: "Open Source Testing",
        target_audience: "Developers, QA Engineers"
      },
      {
        name: "Cypress",
        review_platforms: {
          g2: "https://www.g2.com/products/cypress/reviews",
          capterra: "https://www.capterra.com/p/186854/Cypress/",
          trustradius: "https://www.trustradius.com/products/cypress/reviews"
        },
        category: "Modern E2E Testing",
        target_audience: "Frontend Developers"
      },
      {
        name: "Playwright",
        review_platforms: {
          g2: "https://www.g2.com/products/playwright/reviews",
          capterra: "https://www.capterra.com/p/228919/Playwright/",
          trustradius: "https://www.trustradius.com/products/playwright/reviews"
        },
        category: "Cross-Browser Automation",
        target_audience: "Full-Stack Developers"
      },
      {
        name: "TestCafe",
        review_platforms: {
          g2: "https://www.g2.com/products/testcafe/reviews",
          capterra: "https://www.capterra.com/p/167839/TestCafe/",
          trustradius: "https://www.trustradius.com/products/testcafe/reviews"
        },
        category: "Node.js Testing",
        target_audience: "JavaScript Developers"
      },
      {
        name: "BrowserStack",
        review_platforms: {
          g2: "https://www.g2.com/products/browserstack/reviews",
          capterra: "https://www.capterra.com/p/137842/BrowserStack/",
          trustradius: "https://www.trustradius.com/products/browserstack/reviews"
        },
        category: "Cloud Testing Platform",
        target_audience: "QA Teams, DevOps"
      }
    ],
    analysis_date: new Date().toISOString(),
    analysis_type: "monthly_voc_analysis"
  }
}];
```

---

### Node 5: VOC Research via Perplexity

**Type:** `@n8n/n8n-nodes-langchain.lmChatPerplexity`

**Configuration:**
```json
{
  "model": "sonar-pro",
  "options": {
    "temperature": 0.3,
    "maxTokens": 5000,
    "searchRecencyFilter": "month:6"
  }
}
```

**Prompt Template:**
```
Conduct comprehensive voice-of-customer research for {{$json.competitor_name}} across major software review platforms.

**Review Platforms to Analyze:**
- G2: {{$json.g2_url}}
- Capterra: {{$json.capterra_url}}
- TrustRadius: {{$json.trustradius_url}}

**Research Requirements:**

1. OVERALL RATINGS & METRICS
   - Current overall rating (1-5 stars) on each platform
   - Total review count (all-time)
   - Recent review count (last 6 months)
   - Rating trend (improving/stable/declining)
   - Verified review percentage

2. POSITIVE THEMES (Top 5-7)
   For each theme:
   - Theme description
   - Frequency of mention (High/Medium/Low)
   - 2-3 representative customer quotes
   - Feature/capability most praised

3. NEGATIVE THEMES (Top 5-7)
   For each theme:
   - Theme description
   - Frequency of mention (High/Medium/Low)
   - 2-3 representative customer quotes
   - Feature/capability most criticized

4. REVIEWER INSIGHTS
   - Common job titles/roles
   - Company sizes (SMB/Mid-Market/Enterprise)
   - Primary use cases mentioned
   - Industry verticals represented

5. COMPETITIVE MENTIONS
   - How often is Katalon mentioned in their reviews?
   - What comparisons are made?
   - Switching patterns (from/to this tool)

Focus on LAST 6 MONTHS of reviews for recency.
Include specific quotes with attribution where possible.
Provide quantitative data (percentages, counts) when available.
```

---

### Node 6: Sentiment Analysis via Gemini

**Type:** `@n8n/n8n-nodes-langchain.lmChatGoogleGemini`

**Configuration:**
```json
{
  "modelName": "gemini-2.0-flash-exp",
  "options": {
    "temperature": 0.4,
    "maxOutputTokens": 8000
  }
}
```

**Prompt Template:**
```
Analyze the following voice-of-customer research and generate strategic intelligence.

**Competitor:** {{$json.competitor_name}}
**Analysis Date:** {{$json.analysis_timestamp}}

**VOC Research:**
{{$node["VOC Research"].json.research_findings}}

**Generate JSON output with this structure:**

{
  "executive_summary": "2-3 paragraphs: overall sentiment, key findings, strategic implications for Katalon",

  "sentiment_overview": {
    "overall_rating": "X.X/5 (aggregate across platforms)",
    "rating_trend": "Improving/Stable/Declining (with context)",
    "review_volume": "Total reviews (recent count)",
    "verified_percentage": "X%",
    "sentiment_distribution": {
      "positive": "X%",
      "neutral": "X%",
      "negative": "X%"
    }
  },

  "positive_themes": [
    {
      "theme": "Concise theme title",
      "frequency": "High/Medium/Low",
      "mention_percentage": "Estimate % of positive reviews",
      "representative_quotes": ["quote 1", "quote 2", "quote 3"],
      "features_praised": ["feature 1", "feature 2"],
      "strategic_implication": "What this means for Katalon (1-2 sentences)"
    }
  ],

  "negative_themes": [
    {
      "theme": "Concise theme title",
      "frequency": "High/Medium/Low",
      "mention_percentage": "Estimate % of negative reviews",
      "representative_quotes": ["quote 1", "quote 2", "quote 3"],
      "features_criticized": ["feature 1", "feature 2"],
      "strategic_implication": "Opportunity for Katalon (1-2 sentences)"
    }
  ],

  "competitive_insights": {
    "strengths_vs_katalon": [
      {
        "strength": "Specific competitive advantage",
        "evidence": "Customer quotes or data supporting this",
        "threat_level": "High/Medium/Low"
      }
    ],
    "weaknesses_vs_katalon": [
      {
        "weakness": "Specific competitive weakness",
        "evidence": "Customer quotes or data supporting this",
        "opportunity_level": "High/Medium/Low"
      }
    ],
    "katalon_mentioned": "Yes/No - how often and in what context",
    "switching_patterns": "Common paths to/from this competitor"
  },

  "strategic_recommendations": {
    "product_priorities": [
      {
        "recommendation": "Specific product/feature action",
        "rationale": "Based on competitor weakness or customer need",
        "priority": "High/Medium/Low",
        "expected_impact": "Quantify if possible",
        "effort_estimate": "Low/Medium/High"
      }
    ],
    "messaging_opportunities": [
      {
        "angle": "Specific messaging position",
        "target_audience": "Who this resonates with",
        "competitor_vulnerability": "What weakness this exploits",
        "proof_points": "Customer quotes or data to use"
      }
    ],
    "customer_success_tactics": [
      {
        "tactic": "Specific CS/support action",
        "problem_addressed": "Common pain point from reviews",
        "implementation": "How to execute",
        "expected_outcome": "Reduced churn, improved satisfaction, etc."
      }
    ]
  },

  "reviewer_insights": {
    "common_personas": ["Job title/role", "Job title/role"],
    "company_size_distribution": "X% SMB, Y% Mid-Market, Z% Enterprise",
    "primary_use_cases": ["use case 1", "use case 2", "use case 3"],
    "industry_verticals": ["industry 1", "industry 2"]
  },

  "key_metrics": {
    "analysis_confidence": "High/Medium/Low",
    "data_freshness": "Last X months",
    "strategic_priority_score": "1-100 (how important this competitor intelligence is)",
    "recommended_review_frequency": "Monthly/Quarterly"
  }
}

Return ONLY valid JSON. No markdown formatting.
```

---

### Node 8: Save to Airtable

**Type:** `n8n-nodes-base.airtable`

**Field Mappings:**
```json
{
  "Competitor Name": "={{$json.competitor_name}}",
  "Analysis Date": "={{$json.analysis_timestamp}}",
  "Overall Rating": "={{$json.sentiment_overview.overall_rating}}",
  "Rating Trend": "={{$json.sentiment_overview.rating_trend}}",
  "Review Volume": "={{$json.sentiment_overview.review_volume}}",
  "Verified Percentage": "={{$json.sentiment_overview.verified_percentage}}",
  "Sentiment Distribution": "={{JSON.stringify($json.sentiment_overview.sentiment_distribution)}}",
  "Executive Summary": "={{$json.executive_summary}}",
  "Positive Themes (JSON)": "={{JSON.stringify($json.positive_themes, null, 2)}}",
  "Negative Themes (JSON)": "={{JSON.stringify($json.negative_themes, null, 2)}}",
  "Strengths vs Katalon (JSON)": "={{JSON.stringify($json.competitive_insights.strengths_vs_katalon, null, 2)}}",
  "Weaknesses vs Katalon (JSON)": "={{JSON.stringify($json.competitive_insights.weaknesses_vs_katalon, null, 2)}}",
  "Product Priorities (JSON)": "={{JSON.stringify($json.strategic_recommendations.product_priorities, null, 2)}}",
  "Messaging Opportunities (JSON)": "={{JSON.stringify($json.strategic_recommendations.messaging_opportunities, null, 2)}}",
  "CS Tactics (JSON)": "={{JSON.stringify($json.strategic_recommendations.customer_success_tactics, null, 2)}}",
  "Reviewer Personas": "={{$json.reviewer_insights.common_personas.join(', ')}}",
  "Company Size Distribution": "={{$json.reviewer_insights.company_size_distribution}}",
  "Primary Use Cases": "={{$json.reviewer_insights.primary_use_cases.join(', ')}}",
  "Strategic Priority Score": "={{$json.key_metrics.strategic_priority_score}}",
  "Analysis Confidence": "={{$json.key_metrics.analysis_confidence}}",
  "Data Freshness": "={{$json.key_metrics.data_freshness}}",
  "Review Frequency": "={{$json.key_metrics.recommended_review_frequency}}",
  "Workflow Execution ID": "={{$workflow.id}}_{{$execution.id}}",
  "Status": "New Analysis"
}
```

---

### Node 10: Slack Notification

**Message Template:**
```
:mega: **Monthly Voice of Customer Analysis Complete**

**Analysis Date:** {{$node["Schedule Trigger"].json.timestamp}}
**Competitors Analyzed:** 5

**Summary:**
✅ Selenium - 4.3/5 ({{$json.selenium_reviews}} reviews)
✅ Cypress - 4.5/5 ({{$json.cypress_reviews}} reviews)
✅ Playwright - 4.4/5 ({{$json.playwright_reviews}} reviews)
✅ TestCafe - 4.2/5 ({{$json.testcafe_reviews}} reviews)
✅ BrowserStack - 4.6/5 ({{$json.browserstack_reviews}} reviews)

**Avg Rating Across Competitors:** {{$json.avg_rating}}/5

**Top Positive Themes (Cross-Competitor):**
1. {{$json.top_positive_theme_1}}
2. {{$json.top_positive_theme_2}}
3. {{$json.top_positive_theme_3}}

**Top Negative Themes (Cross-Competitor):**
1. {{$json.top_negative_theme_1}}
2. {{$json.top_negative_theme_2}}
3. {{$json.top_negative_theme_3}}

**High Priority Insights:**
• {{$json.high_priority_insight_count}} strategic recommendations
• {{$json.katalon_opportunities}} opportunities identified
• {{$json.competitive_threats}} competitive threats noted

**View Full Analysis:**
:link: <https://airtable.com/{{AIRTABLE_BASE_ID}}/{{AIRTABLE_TABLE_ID}}|Competitor VOC Analysis>

**Next Analysis:** December 1, 2025 at 10 AM

---
_Workflow: Agent-3 Voice of Customer V2_
_Execution ID: {{$execution.id}}_
```

---

## Credentials Required

1. **Perplexity API** - Bearer token
2. **Google Gemini API** - API key
3. **Airtable API** - Personal Access Token
4. **Slack OAuth2** - Bot token with chat:write scope

---

## Performance Metrics

| Node | Avg Time | % of Total |
|------|----------|------------|
| Perplexity Research | 60-90s | 40% |
| Gemini Analysis | 90-120s | 50% |
| Airtable Save | 2-3s | 1% |
| Other | 5-10s | 9% |
| **Total per Competitor** | **4-6 min** | **100%** |

**Total Workflow:** 20-30 minutes (5 competitors)

---

**Last Updated:** 2025-11-19
**Status:** ✅ Production Ready
