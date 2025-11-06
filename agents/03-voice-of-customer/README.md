# Agent 3: Voice of Customer Analysis

**Status**: 📋 Ready for Implementation
**Target Launch**: Q2 2026
**Version**: 1.0 (Complete Specification)

## Overview

The Voice of Customer Analysis Agent aggregates and analyzes customer feedback from multiple sources (reviews, support tickets, social media) to extract actionable insights, sentiment trends, and feature requests.

## Core Workflows

### Workflow 3A: Review Aggregation & Analysis

**Purpose**: Collect and analyze customer reviews from G2, Capterra, and other platforms

**Trigger**:
- Scheduled: Daily at 6 AM (check for new reviews)
- Manual: Airtable button or form submission
- API: Webhook when new review detected

**Estimated Execution Time**: 8-12 minutes (batch processing)
**Cost per Run**: $0.80-1.20 (depends on review volume)

---

## n8n Workflow Design: Review Analysis

### Node Structure

```
Cron Schedule Trigger (Daily 6 AM)
    ↓
[1] Fetch Latest Review Sync Date from Airtable
    ↓
[2] G2 API: Fetch New Reviews
    ↓
[3] Capterra API/Scraper: Fetch New Reviews
    ↓
[4] Trustpilot API: Fetch New Reviews
    ↓
[5] Merge All Reviews
    ↓
[6] Loop: Process Each Review
    │   ↓
    │   [6a] Claude: Sentiment Analysis
    │   ↓
    │   [6b] Claude: Extract Themes & Topics
    │   ↓
    │   [6c] Claude: Identify Feature Requests
    │   ↓
    │   [6d] Gemini: Classify & Tag
    │   ↓
    │   [6e] Save Review to Airtable
    ↓
[7] Aggregate Analysis (All Reviews)
    ↓
[8] Claude: Generate Insights Summary
    ↓
[9] Gemini: Trend Analysis & Scoring
    ↓
[10] Save Summary to Airtable
    ↓
[11] Send Slack Notification (Daily Digest)
```

### Detailed Node Specifications

#### Node 1: Fetch Latest Sync Date
- **Node Type**: Airtable
- **Operation**: List records
- **Table**: Review Sync Log
- **Formula**: `{Platform} = '[Platform Name]'`
- **Sort**: Last Sync Date (descending)
- **Max Records**: 1

**Purpose**: Get the last sync timestamp to fetch only new reviews

#### Node 2: G2 API - Fetch New Reviews
- **Node Type**: HTTP Request
- **API**: G2 Reviews API
- **Method**: GET
- **Endpoint**: `/api/v1/products/{product_id}/reviews`
- **Query Parameters**:
```json
{
  "since": "{{ $node['Fetch Latest Sync Date'].json.last_sync_date }}",
  "per_page": 100,
  "include": "reviewer,rating,comment,pros,cons,date"
}
```

**Headers**:
```
Authorization: Bearer {{ $credentials.g2_api_key }}
Content-Type: application/json
```

**Output Schema**:
```json
{
  "reviews": [
    {
      "id": "string",
      "rating": 1-5,
      "title": "string",
      "comment": "string",
      "pros": "string",
      "cons": "string",
      "reviewer_name": "string",
      "reviewer_company": "string",
      "reviewer_role": "string",
      "date": "ISO date",
      "helpful_count": number
    }
  ]
}
```

#### Node 3: Capterra API/Scraper - Fetch New Reviews

**Option A: API (if available)**
- Similar to G2 integration

**Option B: Web Scraping** (if no API)
- **Node Type**: HTTP Request + HTML parsing
- **Tool**: Cheerio (n8n HTML extract node)
- **URL**: `https://www.capterra.com/p/{product_id}/reviews/`
- **Selectors**:
  - Review: `.review-item`
  - Rating: `.star-rating`
  - Title: `.review-title`
  - Comment: `.review-comment`
  - Date: `.review-date`

**Note**: Be respectful of rate limits and robots.txt

#### Node 4: Trustpilot API - Fetch New Reviews
- **Node Type**: HTTP Request
- **API**: Trustpilot Business API
- **Method**: GET
- **Endpoint**: `/v1/product-reviews/business-units/{business_unit_id}`
- **Parameters**: Similar to G2

#### Node 5: Merge All Reviews
- **Node Type**: Merge (n8n)
- **Mode**: Append
- **Purpose**: Combine reviews from all platforms into single stream

**Add Platform Identifier**:
```javascript
// For each review, add source platform
return {
  ...review,
  platform: 'G2' | 'Capterra' | 'Trustpilot',
  source_url: constructURL(review),
  fetched_at: new Date().toISOString()
}
```

#### Node 6: Loop - Process Each Review
- **Node Type**: Loop Over Items
- **Input**: Merged reviews
- **Process**: Each review individually

##### Node 6a: Claude - Sentiment Analysis
- **Node Type**: Anthropic (Claude)
- **Model**: claude-3-5-sonnet-20241022
- **Temperature**: 0.2
- **Max Tokens**: 500
- **Prompt**:
```
Analyze the sentiment of this customer review:

REVIEW DETAILS:
Platform: {{ $json.platform }}
Rating: {{ $json.rating }}/5
Title: {{ $json.title }}
Comment: {{ $json.comment }}
Pros: {{ $json.pros }}
Cons: {{ $json.cons }}

Provide:

1. OVERALL SENTIMENT
   Score: 1-10 (1=very negative, 10=very positive)
   Label: Detractor, Passive, or Promoter

2. SENTIMENT BREAKDOWN
   - Product: positive/neutral/negative (score 1-10)
   - Support: positive/neutral/negative (score 1-10)
   - Value: positive/neutral/negative (score 1-10)
   - Ease of Use: positive/neutral/negative (score 1-10)

3. EMOTIONAL TONE
   Primary emotion: frustrated, satisfied, excited, disappointed, neutral

4. KEY SENTIMENT DRIVERS
   What's driving the positive or negative sentiment? (2-3 bullet points)

Return as JSON:
{
  "overall_sentiment_score": 1-10,
  "nps_category": "Detractor"|"Passive"|"Promoter",
  "product_sentiment": {"label": "positive", "score": 8},
  "support_sentiment": {"label": "neutral", "score": 6},
  "value_sentiment": {"label": "positive", "score": 7},
  "ease_of_use_sentiment": {"label": "positive", "score": 9},
  "primary_emotion": "satisfied",
  "sentiment_drivers": ["Easy onboarding", "Great customer support"]
}
```

##### Node 6b: Claude - Extract Themes & Topics
- **Node Type**: Anthropic (Claude)
- **Model**: claude-3-5-sonnet-20241022
- **Temperature**: 0.3
- **Max Tokens**: 400
- **Prompt**:
```
Extract key themes and topics from this review:

{{ $json.comment }}
Pros: {{ $json.pros }}
Cons: {{ $json.cons }}

Identify:

1. PRODUCT FEATURES MENTIONED (specific features discussed)
2. USE CASES (how they're using the product)
3. PAIN POINTS (problems or frustrations)
4. POSITIVE HIGHLIGHTS (what they love)
5. COMPARISON MENTIONS (competitors mentioned)

Return as JSON:
{
  "features_mentioned": ["feature1", "feature2"],
  "use_cases": ["use case description"],
  "pain_points": ["pain point 1", "pain point 2"],
  "positive_highlights": ["highlight 1"],
  "competitor_mentions": ["Competitor Name"] or []
}
```

##### Node 6c: Claude - Identify Feature Requests
- **Node Type**: Anthropic (Claude)
- **Model**: claude-3-5-sonnet-20241022
- **Temperature**: 0.3
- **Max Tokens**: 300
- **Prompt**:
```
Identify any feature requests or product improvement suggestions in this review:

{{ $json.comment }}
Cons: {{ $json.cons }}

Look for:
- "I wish it had..."
- "It would be great if..."
- "Missing feature..."
- "Should add..."
- Feature comparisons with competitors

Return as JSON:
{
  "has_feature_request": true|false,
  "feature_requests": [
    {
      "request": "description of requested feature",
      "priority": "high"|"medium"|"low",
      "category": "integration"|"ui/ux"|"functionality"|"performance"|"other"
    }
  ],
  "improvement_suggestions": ["suggestion 1", "suggestion 2"]
}
```

##### Node 6d: Gemini - Classify & Tag
- **Node Type**: Google Gemini
- **Model**: gemini-2.0-flash-exp
- **Temperature**: 0.1
- **Response Type**: JSON
- **Prompt**:
```
Classify and tag this review based on the analysis:

Review Data: {{ $json }}
Sentiment Analysis: {{ $node['Claude - Sentiment Analysis'].json }}
Themes: {{ $node['Claude - Extract Themes'].json }}
Feature Requests: {{ $node['Claude - Feature Requests'].json }}

Return JSON:
{
  "primary_category": "Product Features"|"Customer Support"|"Pricing"|"Implementation"|"Performance"|"Integration"|"Other",
  "sub_categories": ["sub category 1", "sub category 2"],
  "tags": ["tag1", "tag2", "tag3"],
  "user_persona": "Enterprise Admin"|"SMB Owner"|"Individual User"|"IT Manager"|"Marketing Manager"|"Developer",
  "priority_level": "high"|"medium"|"low",
  "requires_action": true|false,
  "action_type": "product_team"|"support"|"sales"|"marketing"|"none"
}
```

##### Node 6e: Save Review to Airtable
- **Node Type**: Airtable
- **Operation**: Create
- **Table**: Customer Reviews
```javascript
{
  "Review ID": "{{ $json.id }}",
  "Platform": "{{ $json.platform }}",
  "Rating": {{ $json.rating }},
  "Review Title": "{{ $json.title }}",
  "Review Text": "{{ $json.comment }}",
  "Pros": "{{ $json.pros }}",
  "Cons": "{{ $json.cons }}",
  "Reviewer Name": "{{ $json.reviewer_name }}",
  "Reviewer Company": "{{ $json.reviewer_company }}",
  "Reviewer Role": "{{ $json.reviewer_role }}",
  "Review Date": "{{ $json.date }}",
  "Source URL": "{{ $json.source_url }}",
  "Fetched At": "{{ $json.fetched_at }}",

  // Sentiment fields
  "Sentiment Score": {{ $node['Claude - Sentiment Analysis'].json.overall_sentiment_score }},
  "NPS Category": "{{ $node['Claude - Sentiment Analysis'].json.nps_category }}",
  "Primary Emotion": "{{ $node['Claude - Sentiment Analysis'].json.primary_emotion }}",
  "Product Sentiment": {{ $node['Claude - Sentiment Analysis'].json.product_sentiment.score }},
  "Support Sentiment": {{ $node['Claude - Sentiment Analysis'].json.support_sentiment.score }},

  // Themes
  "Features Mentioned": {{ $node['Claude - Extract Themes'].json.features_mentioned }},
  "Pain Points": {{ $node['Claude - Extract Themes'].json.pain_points }},
  "Positive Highlights": {{ $node['Claude - Extract Themes'].json.positive_highlights }},
  "Competitor Mentions": {{ $node['Claude - Extract Themes'].json.competitor_mentions }},

  // Feature Requests
  "Has Feature Request": {{ $node['Claude - Feature Requests'].json.has_feature_request }},
  "Feature Requests": "{{ JSON.stringify($node['Claude - Feature Requests'].json.feature_requests) }}",

  // Classification
  "Primary Category": "{{ $node['Gemini - Classify'].json.primary_category }}",
  "Tags": {{ $node['Gemini - Classify'].json.tags }},
  "User Persona": "{{ $node['Gemini - Classify'].json.user_persona }}",
  "Priority Level": "{{ $node['Gemini - Classify'].json.priority_level }}",
  "Requires Action": {{ $node['Gemini - Classify'].json.requires_action }},
  "Action Type": "{{ $node['Gemini - Classify'].json.action_type }}",

  "Status": "New"
}
```

#### Node 7: Aggregate Analysis
- **Node Type**: Function (JavaScript)
- **Purpose**: Aggregate all processed reviews for summary

```javascript
const reviews = $items().map(item => item.json);

return [{
  json: {
    total_reviews: reviews.length,
    avg_rating: reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length,
    avg_sentiment: reviews.reduce((sum, r) => sum + r['Sentiment Score'], 0) / reviews.length,
    nps_breakdown: {
      promoters: reviews.filter(r => r['NPS Category'] === 'Promoter').length,
      passives: reviews.filter(r => r['NPS Category'] === 'Passive').length,
      detractors: reviews.filter(r => r['NPS Category'] === 'Detractor').length
    },
    feature_requests_count: reviews.filter(r => r['Has Feature Request']).length,
    high_priority_reviews: reviews.filter(r => r['Priority Level'] === 'high').length,
    reviews_by_platform: {
      G2: reviews.filter(r => r.Platform === 'G2').length,
      Capterra: reviews.filter(r => r.Platform === 'Capterra').length,
      Trustpilot: reviews.filter(r => r.Platform === 'Trustpilot').length
    },
    reviews_data: reviews
  }
}];
```

#### Node 8: Claude - Generate Insights Summary
- **Node Type**: Anthropic (Claude)
- **Model**: claude-3-5-sonnet-20241022
- **Temperature**: 0.4
- **Max Tokens**: 2000
- **Prompt**:
```
Analyze these customer reviews and generate actionable insights:

REVIEW SUMMARY:
Total Reviews: {{ $json.total_reviews }}
Average Rating: {{ $json.avg_rating }}/5
Average Sentiment: {{ $json.avg_sentiment }}/10

NPS Breakdown:
- Promoters: {{ $json.nps_breakdown.promoters }}
- Passives: {{ $json.nps_breakdown.passives }}
- Detractors: {{ $json.nps_breakdown.detractors }}

Feature Requests: {{ $json.feature_requests_count }}
High Priority Issues: {{ $json.high_priority_reviews }}

DETAILED REVIEW DATA:
{{ JSON.stringify($json.reviews_data, null, 2) }}

Provide:

## EXECUTIVE SUMMARY
2-3 paragraphs summarizing overall customer sentiment and key themes from this batch of reviews.

## TOP INSIGHTS (5-7 key findings)
- Most important discoveries
- Changes in sentiment or trends
- Critical issues raised
- Competitive insights

## FEATURE REQUESTS ANALYSIS
Top requested features (ranked by frequency and importance):
1. [Feature name] - mentioned X times, priority: high/medium/low
2. ...

## PAIN POINTS REQUIRING ACTION
Critical issues that need immediate attention:
1. [Issue] - Severity, Affected users, Recommended action
2. ...

## POSITIVE THEMES
What customers love (to amplify in marketing):
- Theme 1
- Theme 2

## COMPETITIVE INSIGHTS
Competitor mentions and comparisons:
- What competitors are doing well
- Where we have advantages

## RECOMMENDED ACTIONS
Specific, prioritized recommendations for:
- Product team (top 3)
- Customer success team (top 2)
- Marketing team (top 2)
- Sales team (top 2)
```

#### Node 9: Gemini - Trend Analysis & Scoring
- **Node Type**: Google Gemini
- **Model**: gemini-2.0-flash-exp
- **Temperature**: 0.2
- **Response Type**: JSON
- **Prompt**:
```
Analyze trends and score key metrics from these reviews:

{{ $node['Claude - Insights Summary'].json }}

Aggregate Data:
{{ $node['Aggregate Analysis'].json }}

Return JSON:
{
  "overall_health_score": 1-100 (based on sentiment, NPS, trends),
  "trend_direction": "improving"|"stable"|"declining",
  "risk_level": "low"|"medium"|"high",
  "top_themes": [
    {
      "theme": "theme name",
      "mentions": count,
      "sentiment": "positive"|"negative"|"neutral",
      "trend": "increasing"|"stable"|"decreasing"
    }
  ],
  "urgent_issues": [
    {
      "issue": "description",
      "severity": 1-10,
      "affected_users": estimate
    }
  ],
  "opportunities": [
    {
      "opportunity": "description",
      "potential_impact": "high"|"medium"|"low"
    }
  ]
}
```

#### Node 10: Save Summary to Airtable
- **Table**: Review Analysis Summary
- **Operation**: Create
```javascript
{
  "Analysis Date": "{{ $now }}",
  "Period Start": "{{ $node['Fetch Latest Sync Date'].json.last_sync_date }}",
  "Period End": "{{ $now }}",
  "Total Reviews Analyzed": {{ $node['Aggregate Analysis'].json.total_reviews }},
  "Average Rating": {{ $node['Aggregate Analysis'].json.avg_rating }},
  "Average Sentiment": {{ $node['Aggregate Analysis'].json.avg_sentiment }},
  "NPS Promoters": {{ $node['Aggregate Analysis'].json.nps_breakdown.promoters }},
  "NPS Passives": {{ $node['Aggregate Analysis'].json.nps_breakdown.passives }},
  "NPS Detractors": {{ $node['Aggregate Analysis'].json.nps_breakdown.detractors }},
  "Health Score": {{ $node['Gemini - Trend Analysis'].json.overall_health_score }},
  "Trend Direction": "{{ $node['Gemini - Trend Analysis'].json.trend_direction }}",
  "Risk Level": "{{ $node['Gemini - Trend Analysis'].json.risk_level }}",
  "Insights Summary": "{{ $node['Claude - Insights Summary'].json }}",
  "Top Themes": "{{ JSON.stringify($node['Gemini - Trend Analysis'].json.top_themes) }}",
  "Urgent Issues": "{{ JSON.stringify($node['Gemini - Trend Analysis'].json.urgent_issues) }}",
  "Feature Requests Count": {{ $node['Aggregate Analysis'].json.feature_requests_count }}
}
```

#### Node 11: Slack Notification - Daily Digest
- **Node Type**: HTTP Request
- **Method**: POST
- **URL**: Slack webhook URL
- **Body**:
```json
{
  "text": "📊 Daily Voice of Customer Analysis",
  "blocks": [
    {
      "type": "header",
      "text": {
        "type": "plain_text",
        "text": "📊 Voice of Customer - Daily Digest"
      }
    },
    {
      "type": "section",
      "fields": [
        {"type": "mrkdwn", "text": "*Reviews Analyzed:*\n{{ $node['Aggregate Analysis'].json.total_reviews }}"},
        {"type": "mrkdwn", "text": "*Avg Rating:*\n⭐ {{ Math.round($node['Aggregate Analysis'].json.avg_rating * 10) / 10 }}/5"},
        {"type": "mrkdwn", "text": "*Health Score:*\n{{ $node['Gemini - Trend Analysis'].json.overall_health_score }}/100"},
        {"type": "mrkdwn", "text": "*Trend:*\n{{ $node['Gemini - Trend Analysis'].json.trend_direction === 'improving' ? '📈' : $node['Gemini - Trend Analysis'].json.trend_direction === 'declining' ? '📉' : '➡️' }} {{ $node['Gemini - Trend Analysis'].json.trend_direction }}"}
      ]
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*NPS Breakdown*\n🟢 Promoters: {{ $node['Aggregate Analysis'].json.nps_breakdown.promoters }}\n🟡 Passives: {{ $node['Aggregate Analysis'].json.nps_breakdown.passives }}\n🔴 Detractors: {{ $node['Aggregate Analysis'].json.nps_breakdown.detractors }}"
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Top Insights*\n{{ $node['Claude - Insights Summary'].json.match(/## TOP INSIGHTS[\\s\\S]*?(?=##|$)/)[0].substring(0, 500) }}..."
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*⚠️ Urgent Issues:* {{ $node['Gemini - Trend Analysis'].json.urgent_issues.length }}\n*💡 Feature Requests:* {{ $node['Aggregate Analysis'].json.feature_requests_count }}"
      }
    },
    {
      "type": "actions",
      "elements": [
        {
          "type": "button",
          "text": {"type": "plain_text", "text": "View Full Analysis"},
          "url": "https://airtable.com/[BASE_ID]/[VIEW_ID]"
        },
        {
          "type": "button",
          "text": {"type": "plain_text", "text": "View Reviews"},
          "url": "https://airtable.com/[BASE_ID]/[REVIEWS_TABLE]"
        }
      ]
    }
  ]
}
```

---

## Airtable Schema for Agent 3

### Table 1: Customer Reviews

| Field Name | Type | Configuration | Description |
|------------|------|---------------|-------------|
| Review ID | Single line text | Primary, Required | Unique ID from platform |
| Platform | Single select | G2, Capterra, Trustpilot, App Store, Play Store | Review source |
| Rating | Number | 1-5, Required | Star rating |
| Review Title | Single line text | - | Review headline |
| Review Text | Long text | Required | Full review content |
| Pros | Long text | - | Positive aspects |
| Cons | Long text | - | Negative aspects |
| Reviewer Name | Single line text | - | Customer name |
| Reviewer Company | Single line text | - | Company name |
| Reviewer Role | Single line text | - | Job title |
| Review Date | Date | Required | Original review date |
| Source URL | URL | - | Link to original review |
| Fetched At | Date & time | Auto | When we retrieved it |
| **Sentiment Analysis** | | | |
| Sentiment Score | Number | 1-10 | Overall sentiment |
| NPS Category | Single select | Detractor, Passive, Promoter | NPS classification |
| Primary Emotion | Single select | Frustrated, Satisfied, Excited, Disappointed, Neutral | Emotional tone |
| Product Sentiment | Number | 1-10 | Product-specific sentiment |
| Support Sentiment | Number | 1-10 | Support-specific sentiment |
| Value Sentiment | Number | 1-10 | Value/pricing sentiment |
| Ease of Use Sentiment | Number | 1-10 | Usability sentiment |
| **Themes & Topics** | | | |
| Features Mentioned | Multiple select | Dynamic | Product features discussed |
| Pain Points | Multiple select | Dynamic | Issues mentioned |
| Positive Highlights | Multiple select | Dynamic | What they love |
| Competitor Mentions | Multiple select | Dynamic | Competitors referenced |
| **Feature Requests** | | | |
| Has Feature Request | Checkbox | - | Contains feature request? |
| Feature Requests | Long text | JSON format | Detailed feature requests |
| **Classification** | | | |
| Primary Category | Single select | Product Features, Support, Pricing, Implementation, Performance, Integration, Other | Main topic |
| Sub Categories | Multiple select | Dynamic | Additional categories |
| Tags | Multiple select | Dynamic | Custom tags |
| User Persona | Single select | Enterprise Admin, SMB Owner, Individual User, IT Manager, Marketing Manager, Developer | User type |
| Priority Level | Single select | High, Medium, Low | Review priority |
| Requires Action | Checkbox | - | Needs follow-up? |
| Action Type | Single select | Product Team, Support, Sales, Marketing, None | Who should act? |
| **Status Tracking** | | | |
| Status | Single select | New, Under Review, Actioned, Archived | Current status |
| Assigned To | Single line text | - | Team member |
| Notes | Long text | - | Internal notes |
| Action Taken | Long text | - | What was done |

**Formulas**:

**Days Since Review**:
```
DATETIME_DIFF(NOW(), {Review Date}, 'days')
```

**Sentiment Label**:
```
IF({Sentiment Score} >= 8, "😊 Positive",
  IF({Sentiment Score} >= 5, "😐 Neutral", "😞 Negative")
)
```

**Views**:
- New Reviews: Status = "New", sort by Fetched At desc
- High Priority: Priority Level = "High"
- Detractors: NPS Category = "Detractor", sort by Review Date desc
- Feature Requests: Has Feature Request = true
- By Platform: Group by Platform
- Requires Action: Requires Action = true, Status = "New"
- By Persona: Group by User Persona

---

### Table 2: Review Analysis Summary

| Field Name | Type | Configuration | Description |
|------------|------|---------------|-------------|
| Analysis ID | Autonumber | - | Primary key |
| Analysis Date | Date | Required | When analysis ran |
| Period Start | Date | - | Analysis period start |
| Period End | Date | - | Analysis period end |
| Total Reviews Analyzed | Number | - | Review count |
| Average Rating | Number | Decimal, 1-5 | Avg star rating |
| Average Sentiment | Number | Decimal, 1-10 | Avg sentiment score |
| **NPS Metrics** | | | |
| NPS Promoters | Number | - | Count of promoters |
| NPS Passives | Number | - | Count of passives |
| NPS Detractors | Number | - | Count of detractors |
| NPS Score | Formula | See below | Calculated NPS |
| **Trend Metrics** | | | |
| Health Score | Number | 1-100 | Overall health |
| Trend Direction | Single select | Improving, Stable, Declining | Trend indicator |
| Risk Level | Single select | Low, Medium, High | Risk assessment |
| **Content** | | | |
| Insights Summary | Long text | Rich text | Full insights from Claude |
| Top Themes | Long text | JSON | Theme analysis |
| Urgent Issues | Long text | JSON | Critical issues |
| Feature Requests Count | Number | - | Total feature requests |
| Reviews Link | Link to records | → Customer Reviews | All analyzed reviews |

**Formulas**:

**NPS Score**:
```
IF(
  {Total Reviews Analyzed} > 0,
  ROUND(
    ({NPS Promoters} - {NPS Detractors}) / {Total Reviews Analyzed} * 100,
    0
  ),
  0
)
```

**Health Indicator**:
```
IF({Health Score} >= 80, "🟢 Excellent",
  IF({Health Score} >= 60, "🟡 Good",
    IF({Health Score} >= 40, "🟠 Needs Attention", "🔴 Critical")
  )
)
```

**Views**:
- All Analyses: Default, sort by Analysis Date desc
- Recent Trends: Last 30 days
- Low Health Scores: Health Score < 60
- Declining Trend: Trend Direction = "Declining"

---

### Table 3: Feature Requests Tracker

| Field Name | Type | Configuration | Description |
|------------|------|---------------|-------------|
| Request ID | Autonumber | - | Primary key |
| Feature Request | Long text | Required | Description |
| Category | Single select | Integration, UI/UX, Functionality, Performance, Mobile, API, Other | Request type |
| Priority | Single select | Critical, High, Medium, Low | Importance |
| Mention Count | Number | Default: 1 | How many times mentioned |
| First Mentioned | Date | - | First occurrence |
| Last Mentioned | Date | - | Most recent occurrence |
| Related Reviews | Link to records | → Customer Reviews | All mentioning reviews |
| Status | Single select | New, Under Consideration, Planned, In Development, Released, Won't Do | Current status |
| Product Team Notes | Long text | - | Internal notes |
| Target Release | Single line text | - | Planned version/quarter |
| Impact Estimate | Single select | High, Medium, Low | Potential impact |

**Views**:
- Top Requests: Sort by Mention Count desc
- Critical Priority: Priority IN ("Critical", "High")
- New Requests: Status = "New"
- In Progress: Status IN ("Planned", "In Development")
- By Category: Group by Category

---

### Table 4: Sentiment Trends (Optional)

Track sentiment over time for dashboarding.

| Field Name | Type | Configuration | Description |
|------------|------|---------------|-------------|
| Date | Date | Required | Date |
| Average Rating | Number | - | Daily avg rating |
| Average Sentiment | Number | - | Daily avg sentiment |
| Review Count | Number | - | Reviews that day |
| NPS Score | Number | - | Daily NPS |
| Health Score | Number | - | Daily health score |

---

## Workflow 3B: Competitor Review Monitoring (Future)

**Purpose**: Monitor competitor reviews to identify opportunities

**Design**:
```
1. Fetch competitor reviews (same sources)
2. Analyze sentiment and themes
3. Compare with our reviews
4. Identify opportunities where competitors weak
5. Alert team to opportunities
```

---

## LLM Prompt Library

### 3A.SENTIMENT_ANALYSIS.v1.0
- **Model**: Claude 3.5 Sonnet
- **Tokens**: ~400 input, ~200 output
- **Cost**: ~$0.02 per review

### 3A.THEME_EXTRACTION.v1.0
- **Model**: Claude 3.5 Sonnet
- **Tokens**: ~350 input, ~250 output
- **Cost**: ~$0.02 per review

### 3A.FEATURE_REQUESTS.v1.0
- **Model**: Claude 3.5 Sonnet
- **Tokens**: ~300 input, ~200 output
- **Cost**: ~$0.015 per review

### 3A.CLASSIFICATION.v1.0
- **Model**: Gemini 2.0 Flash
- **Tokens**: ~500 input, ~150 output
- **Cost**: ~$0.005 per review

### 3A.INSIGHTS_SUMMARY.v1.0
- **Model**: Claude 3.5 Sonnet
- **Tokens**: ~4000 input, ~2000 output
- **Cost**: ~$0.20 per batch

### 3A.TREND_ANALYSIS.v1.0
- **Model**: Gemini 2.0 Flash
- **Tokens**: ~2500 input, ~500 output
- **Cost**: ~$0.02 per batch

**Cost per Review**: ~$0.075
**Cost per Daily Run** (20 reviews): ~$1.70

---

## Success Metrics

- Reviews processed per day
- Average sentiment score trend
- NPS score trend
- Feature request identification rate
- Time to action on critical issues
- Product team adoption rate

---

**Implementation Status**: Ready for development
**Estimated Build Time**: 16-20 hours
**Prerequisites**: Review platform API access, Airtable setup
**Next Steps**: Obtain API credentials for G2/Capterra, build workflow
