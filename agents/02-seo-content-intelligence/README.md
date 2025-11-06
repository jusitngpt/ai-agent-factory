# Agent 2: SEO & Content Intelligence

**Status**: 📋 Ready for Implementation
**Target Launch**: Q1 2026
**Version**: 1.0 (Complete Specification)

## Overview

The SEO & Content Intelligence Agent automates content optimization and SEO strategy by analyzing search trends, identifying content gaps, and providing data-driven recommendations for content creation and optimization.

## Core Workflows

### Workflow 2A: Keyword Research & Gap Analysis

**Purpose**: Discover high-value keywords and identify content gaps vs competitors

**Trigger**:
- Manual: Airtable form submission
- Scheduled: Weekly analysis for tracked keywords
- API: Webhook from CMS

**Estimated Execution Time**: 5-8 minutes
**Cost per Run**: $0.40-0.60

---

## n8n Workflow Design: Keyword Research

### Node Structure

```
Webhook Trigger
    ↓
[1] Set Variables
    ↓
[2] Update Airtable Status → "Processing"
    ↓
[3] Slack Notification (Started)
    ↓
[4] Perplexity: Keyword Research
    ↓
[5] Get Search Volume (SEO API)
    ↓
[6] Competitor Content Analysis (Perplexity)
    ↓
[7] Claude: Gap Analysis
    ↓
[8] Gemini: Priority Scoring
    ↓
[9] Claude: Content Recommendations
    ↓
[10] Save to Airtable (Multiple tables)
    ↓
[11] Update Status → "Complete"
    ↓
[12] Slack Notification (Results)
```

### Detailed Node Specifications

#### Node 1: Set Variables
```javascript
// Extract input parameters
{
  "topic": "{{ $json.body.topic }}",
  "target_audience": "{{ $json.body.target_audience || 'B2B SaaS buyers' }}",
  "competitors": "{{ $json.body.competitors }}",
  "request_id": "{{ $json.body.request_id }}",
  "content_type": "{{ $json.body.content_type || 'blog post' }}"
}
```

#### Node 2: Update Airtable Status
- **Node Type**: Airtable
- **Operation**: Update
- **Table**: SEO Research Requests
- **Record ID**: `{{ $node["Set Variables"].json.request_id }}`
- **Fields**:
  - Status: "Processing"
  - Started At: `{{ $now }}`

#### Node 3: Slack Notification (Started)
- **Node Type**: HTTP Request
- **Method**: POST
- **URL**: Slack webhook URL
- **Body**:
```json
{
  "text": "🔍 SEO Research started: {{ $node['Set Variables'].json.topic }}",
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*SEO Keyword Research Started*\n📊 Topic: {{ $node['Set Variables'].json.topic }}\n🎯 Target: {{ $node['Set Variables'].json.target_audience }}"
      }
    }
  ]
}
```

#### Node 4: Perplexity - Keyword Research
- **Node Type**: HTTP Request (Perplexity API)
- **Model**: sonar-pro
- **Prompt**:
```
Research SEO keywords for the topic: "{{ $node['Set Variables'].json.topic }}"

Target Audience: {{ $node['Set Variables'].json.target_audience }}
Content Type: {{ $node['Set Variables'].json.content_type }}

Provide:

1. PRIMARY KEYWORDS (3-5)
   - Main keywords with high search intent
   - Include search volume estimates
   - Competition level (high/medium/low)

2. SECONDARY KEYWORDS (5-10)
   - Supporting keywords
   - Long-tail variations
   - Related terms with good volume

3. QUESTION KEYWORDS (5-8)
   - "How to..." queries
   - "What is..." queries
   - "Best..." queries
   - Other question formats

4. SEARCH INTENT ANALYSIS
   - Informational vs transactional
   - User pain points
   - Content expectations

5. TRENDING TOPICS
   - Recent surge in interest
   - Seasonal trends
   - Emerging subtopics

Cite recent data sources and include URLs.
```

#### Node 5: Get Search Volume (SEO API)
- **Node Type**: HTTP Request
- **API**: SEMrush or DataForSEO API
- **Endpoint**: `/keywords/search-volume`
- **Method**: POST
- **Body**:
```json
{
  "keywords": "{{ $node['Perplexity - Keyword Research'].json.choices[0].message.content.match(/keyword patterns/) }}",
  "location": "us",
  "language": "en"
}
```

**Alternative (Free)**:
- Use Google Trends API
- Parse Google autocomplete suggestions
- Estimate based on Perplexity data

#### Node 6: Competitor Content Analysis
- **Node Type**: HTTP Request (Perplexity API)
- **Model**: sonar-pro
- **Prompt**:
```
Analyze competitor content for: "{{ $node['Set Variables'].json.topic }}"

Competitors to analyze: {{ $node['Set Variables'].json.competitors }}

For each competitor, identify:

1. CONTENT COVERAGE
   - Blog posts, guides, resources
   - Topics they cover extensively
   - Content formats (blog, video, infographic)

2. TOP PERFORMING CONTENT
   - Their most visible content
   - Estimated traffic (based on SERP position)
   - Backlinks and social shares (if visible)

3. CONTENT GAPS THEY HAVE
   - Topics they DON'T cover well
   - Outdated content
   - Thin content areas

4. KEYWORD TARGETING
   - Keywords they rank for
   - Keywords they're targeting but not ranking well

5. CONTENT QUALITY ASSESSMENT
   - Depth of coverage
   - User engagement signals
   - Content freshness

Provide URLs to example content.
```

#### Node 7: Claude - Gap Analysis
- **Node Type**: Anthropic (Claude)
- **Model**: claude-3-5-sonnet-20241022
- **Temperature**: 0.3
- **Max Tokens**: 2000
- **Prompt**:
```
You are an expert SEO content strategist.

Analyze the following keyword research and competitor analysis:

KEYWORD RESEARCH:
{{ $node["Perplexity - Keyword Research"].json.choices[0].message.content }}

SEARCH VOLUME DATA:
{{ $node["Get Search Volume"].json }}

COMPETITOR ANALYSIS:
{{ $node["Competitor Content Analysis"].json.choices[0].message.content }}

Provide a comprehensive CONTENT GAP ANALYSIS:

## OPPORTUNITIES IDENTIFIED

### High-Priority Gaps (Top 3-5)
For each, explain:
- What keyword/topic opportunity
- Why competitors are weak here
- Estimated difficulty (Easy/Medium/Hard)
- Potential traffic impact (High/Medium/Low)

### Medium-Priority Gaps (5-7)
Brief description of additional opportunities

### Low-Priority Gaps (3-5)
Worth considering but lower impact

## COMPETITIVE ADVANTAGES TO LEVERAGE

List 3-5 ways to differentiate our content:
- Unique angles competitors miss
- Depth/quality improvements
- Format innovations
- Better user experience

## QUICK WINS

Identify 3-5 immediate opportunities:
- Low competition keywords
- Easy to rank topics
- Fast content to produce

## CONTENT STRATEGY RECOMMENDATIONS

Provide 5-7 specific recommendations:
- Content types to create
- Topics to prioritize
- Keywords to target
- Angles to take

Focus on actionable insights.
```

#### Node 8: Gemini - Priority Scoring
- **Node Type**: Google Gemini
- **Model**: gemini-2.0-flash-exp
- **Temperature**: 0.1
- **Response Type**: JSON
- **Prompt**:
```
Score each content opportunity from the following analysis:

{{ $node["Claude - Gap Analysis"].json.content[0].text }}

Output a JSON array of opportunities with scores:

[
  {
    "opportunity": "Brief description",
    "keyword": "Primary keyword",
    "difficulty_score": 1-10 (1=easy, 10=hard),
    "traffic_potential": 1-10 (1=low, 10=high),
    "competition_score": 1-10 (1=low competition, 10=high),
    "priority_score": 1-100 (calculated: (traffic_potential * 10) - (difficulty_score * 5) - (competition_score * 2)),
    "quick_win": true/false (priority_score > 60 AND difficulty < 5),
    "estimated_monthly_traffic": number,
    "content_type": "blog post" | "guide" | "comparison" | "tutorial",
    "time_to_rank": "1-2 weeks" | "1-2 months" | "3-6 months"
  }
]

Sort by priority_score descending.
Return ONLY the JSON array.
```

#### Node 9: Claude - Content Recommendations
- **Node Type**: Anthropic (Claude)
- **Model**: claude-3-5-sonnet-20241022
- **Temperature**: 0.4
- **Max Tokens**: 2500
- **Prompt**:
```
Based on this SEO analysis:

GAP ANALYSIS:
{{ $node["Claude - Gap Analysis"].json.content[0].text }}

OPPORTUNITY SCORES:
{{ $node["Gemini - Priority Scoring"].json }}

Create DETAILED CONTENT RECOMMENDATIONS for the top 5 opportunities:

For each opportunity, provide:

## [Opportunity Title]

**Target Keyword**: [primary keyword]
**Content Type**: [blog post/guide/comparison/etc]
**Estimated Effort**: [hours to create]
**Expected Results**: [traffic/leads estimate]

### Content Brief

**Title Options** (3 variations):
1. [SEO-optimized title]
2. [Click-worthy title]
3. [Question-format title]

**Meta Description** (155 chars):
[Compelling meta description with target keyword]

**Outline**:
1. Introduction (100-150 words)
   - Hook
   - Problem statement
   - What reader will learn

2. Main Section 1: [H2 heading]
   - Key points to cover
   - Keywords to include naturally

3. Main Section 2: [H2 heading]
   - Key points to cover
   - Internal links to suggest

4. Main Section 3: [H2 heading]
   - Key points to cover
   - External sources to reference

5. Conclusion (100-150 words)
   - Summary
   - Call-to-action

**Keywords to Target**:
- Primary: [keyword]
- Secondary: [2-3 keywords]
- Long-tail: [3-5 phrases]

**Internal Linking Opportunities**:
- Link to [existing content]
- Link from [other pages]

**Competitive Angle**:
How to differentiate from competitors

**Success Metrics**:
- Target ranking: Position 1-5
- Estimated traffic: [number] visits/month
- Timeline to rank: [timeframe]

---

Provide actionable, specific guidance for content creators.
```

#### Node 10: Save to Airtable (Multiple Operations)

**10a. Save Keywords**
- **Table**: SEO Keywords
- **Operation**: Create (bulk)
- **Records**: Parse from Gemini output
```javascript
// Map each keyword opportunity
const opportunities = JSON.parse($node["Gemini - Priority Scoring"].json);
return opportunities.map(opp => ({
  "Keyword": opp.keyword,
  "Topic": "{{ $node['Set Variables'].json.topic }}",
  "Priority Score": opp.priority_score,
  "Difficulty": opp.difficulty_score,
  "Traffic Potential": opp.traffic_potential,
  "Competition": opp.competition_score,
  "Quick Win": opp.quick_win,
  "Est. Monthly Traffic": opp.estimated_monthly_traffic,
  "Content Type": opp.content_type,
  "Time to Rank": opp.time_to_rank,
  "Status": "Identified"
}));
```

**10b. Save Content Recommendations**
- **Table**: Content Recommendations
- **Operation**: Create
```javascript
{
  "Request": "{{ $node['Set Variables'].json.request_id }}",
  "Title": "Content Recommendations for {{ $node['Set Variables'].json.topic }}",
  "Full Recommendations": "{{ $node['Claude - Content Recommendations'].json.content[0].text }}",
  "Gap Analysis": "{{ $node['Claude - Gap Analysis'].json.content[0].text }}",
  "Top 5 Opportunities": "{{ JSON.stringify($node['Gemini - Priority Scoring'].json.slice(0, 5)) }}",
  "Generated Date": "{{ $now }}"
}
```

**10c. Update Research Request**
- **Table**: SEO Research Requests
- **Operation**: Update
- **Record ID**: `{{ $node['Set Variables'].json.request_id }}`
```javascript
{
  "Status": "Complete",
  "Completed At": "{{ $now }}",
  "Keywords Found": "{{ $node['Gemini - Priority Scoring'].json.length }}",
  "Quick Wins": "{{ $node['Gemini - Priority Scoring'].json.filter(o => o.quick_win).length }}",
  "Cost": "{{ calculateCost() }}"
}
```

#### Node 11: Slack Notification (Results)
- **Node Type**: HTTP Request
- **Method**: POST
- **URL**: Slack webhook URL
- **Body**:
```json
{
  "text": "✅ SEO Research complete: {{ $node['Set Variables'].json.topic }}",
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*SEO Keyword Research Complete*\n📊 Topic: {{ $node['Set Variables'].json.topic }}\n\n*Results:*\n• Keywords identified: {{ $node['Gemini - Priority Scoring'].json.length }}\n• Quick wins: {{ $node['Gemini - Priority Scoring'].json.filter(o => o.quick_win).length }}\n• High-priority opportunities: {{ $node['Gemini - Priority Scoring'].json.filter(o => o.priority_score > 70).length }}"
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Top Opportunity:*\n`{{ $node['Gemini - Priority Scoring'].json[0].keyword }}`\nPriority Score: {{ $node['Gemini - Priority Scoring'].json[0].priority_score }}/100\nEstimated Traffic: {{ $node['Gemini - Priority Scoring'].json[0].estimated_monthly_traffic }}/month"
      }
    },
    {
      "type": "actions",
      "elements": [
        {
          "type": "button",
          "text": {
            "type": "plain_text",
            "text": "View in Airtable"
          },
          "url": "https://airtable.com/[BASE_ID]/[TABLE_ID]"
        }
      ]
    }
  ]
}
```

#### Error Handling Node
```
IF any step fails:
1. Catch error
2. Log to Airtable (Error Log table)
3. Update request status to "Failed"
4. Send Slack alert with error details
5. Retry logic:
   - API timeouts: Retry 3x
   - Rate limits: Wait and retry
   - Invalid responses: Skip and continue
```

---

## Airtable Schema for Agent 2

### Table 1: SEO Research Requests

| Field Name | Type | Configuration | Description |
|------------|------|---------------|-------------|
| Request ID | Autonumber | - | Primary key |
| Topic | Single line text | Required | Main topic/keyword seed |
| Target Audience | Single line text | Default: "B2B SaaS buyers" | Audience context |
| Competitors | Long text | - | Competitor URLs (one per line) |
| Content Type | Single select | Options: Blog Post, Guide, Comparison, Tutorial, Case Study | Desired content format |
| Status | Single select | Pending, Processing, Complete, Failed | Current status |
| Requested By | Single line text | - | User email/name |
| Created Date | Created time | - | Auto-generated |
| Started At | Date & time | - | Processing start time |
| Completed At | Date & time | - | Processing end time |
| Keywords Found | Number | - | Total keywords identified |
| Quick Wins | Number | - | Number of quick win opportunities |
| Cost | Currency | - | Total API cost |
| Link to Keywords | Link to records | → SEO Keywords | All keywords found |
| Link to Recommendations | Link to records | → Content Recommendations | Generated recommendations |
| Notes | Long text | - | Additional context |

**Views**:
- Active Requests: Status = "Pending" OR "Processing"
- Completed Research: Status = "Complete", sort by Completed At desc
- By Topic: Group by Topic

---

### Table 2: SEO Keywords

| Field Name | Type | Configuration | Description |
|------------|------|---------------|-------------|
| Keyword ID | Autonumber | - | Primary key |
| Keyword | Single line text | Required | The actual keyword phrase |
| Topic | Single line text | - | Related topic/category |
| Request | Link to records | ← SEO Research Requests | Source request |
| Priority Score | Number | 0-100 | Overall priority |
| Difficulty | Number | 1-10 | Ranking difficulty |
| Traffic Potential | Number | 1-10 | Traffic opportunity |
| Competition | Number | 1-10 | Competition level |
| Quick Win | Checkbox | - | Is this a quick win? |
| Est. Monthly Traffic | Number | - | Estimated monthly searches |
| Content Type | Single select | Blog, Guide, Comparison, Tutorial, Video, Infographic | Recommended format |
| Time to Rank | Single select | 1-2 weeks, 1-2 months, 3-6 months, 6+ months | Expected timeline |
| Status | Single select | Identified, In Progress, Content Created, Ranking, Archived | Current status |
| Assigned To | Single line text | - | Content creator |
| Content Link | URL | - | Link to created content |
| Current Ranking | Number | - | Current SERP position (if tracking) |
| Target Ranking | Number | Default: 5 | Goal position |
| Created Date | Created time | - | When keyword was identified |
| Last Checked | Date | - | Last ranking check |
| Tags | Multiple select | Dynamic | Custom categorization |

**Formulas**:

**Priority Label**:
```
IF({Priority Score} >= 80, "🔥 Critical",
  IF({Priority Score} >= 60, "⭐ High",
    IF({Priority Score} >= 40, "📊 Medium", "📋 Low")
  )
)
```

**Effort Estimate**:
```
IF({Quick Win}, "⚡ 1-2 hours",
  IF({Difficulty} <= 3, "✏️ 2-4 hours",
    IF({Difficulty} <= 6, "📝 4-8 hours", "📚 8+ hours")
  )
)
```

**Views**:
- Quick Wins: Quick Win = true, sort by Priority Score desc
- High Priority: Priority Score >= 70
- By Status: Group by Status
- By Topic: Group by Topic
- Content Pipeline: Status IN ("In Progress", "Content Created")

---

### Table 3: Content Recommendations

| Field Name | Type | Configuration | Description |
|------------|------|---------------|-------------|
| Recommendation ID | Autonumber | - | Primary key |
| Request | Link to records | ← SEO Research Requests | Source request |
| Title | Single line text | Required | Recommendation title |
| Full Recommendations | Long text | Rich text enabled | Complete output from Claude |
| Gap Analysis | Long text | Rich text enabled | Gap analysis from Claude |
| Top 5 Opportunities | Long text | JSON format | Structured opportunity data |
| Generated Date | Created time | - | Creation timestamp |
| Status | Single select | Draft, Under Review, Approved, In Production | Current status |
| Priority | Single select | Low, Medium, High, Critical | Overall priority |
| Assigned To | Single line text | - | Team member responsible |
| Due Date | Date | - | Content creation deadline |
| Notes | Long text | - | Additional notes |
| Link to Content | URL | - | Link to published content |

**Views**:
- All Recommendations: Default view
- By Status: Group by Status
- By Priority: Filter High/Critical, sort by Generated Date
- Under Review: Status = "Under Review"

---

### Table 4: Content Inventory (Optional)

| Field Name | Type | Configuration | Description |
|------------|------|---------------|-------------|
| Content ID | Autonumber | - | Primary key |
| Title | Single line text | Required | Content title |
| URL | URL | Required | Published URL |
| Content Type | Single select | Blog Post, Guide, Landing Page, Case Study, Video | Content format |
| Target Keyword | Link to records | → SEO Keywords | Primary keyword |
| Secondary Keywords | Link to records | → SEO Keywords | Supporting keywords |
| Published Date | Date | - | Publication date |
| Author | Single line text | - | Content creator |
| Status | Single select | Published, Needs Update, Archived | Current status |
| Last Updated | Date | - | Last modification date |
| Word Count | Number | - | Total words |
| Current Ranking | Rollup | From SEO Keywords, Current Ranking, MIN | Best ranking position |
| Est. Monthly Traffic | Rollup | From SEO Keywords, Est. Monthly Traffic, SUM | Total traffic potential |
| Performance Notes | Long text | - | Traffic, engagement notes |

**Views**:
- All Content: Default
- Top Performers: Sort by Est. Monthly Traffic desc
- Needs Update: Status = "Needs Update"
- By Type: Group by Content Type

---

## Workflow 2B: SERP Monitoring (Future)

**Purpose**: Track keyword rankings over time

**Trigger**: Scheduled (daily at 2 AM)

**Brief Design**:
```
1. Fetch all "Ranking" keywords from Airtable
2. For each keyword (batched):
   - Query SERP API for current position
   - Compare to previous position
   - Calculate change
3. Update Airtable with new rankings
4. If significant changes (±5 positions):
   - Send Slack alert
   - Flag for investigation
5. Weekly rollup report to team
```

---

## LLM Prompt Library

### 2A.KEYWORD_RESEARCH.v1.0
- **Location**: Node 4
- **Model**: Perplexity Sonar Pro
- **Tokens**: ~500 input, ~2000 output
- **Cost**: ~$0.10

### 2A.COMPETITOR_CONTENT.v1.0
- **Location**: Node 6
- **Model**: Perplexity Sonar Pro
- **Tokens**: ~600 input, ~2500 output
- **Cost**: ~$0.12

### 2A.GAP_ANALYSIS.v1.0
- **Location**: Node 7
- **Model**: Claude 3.5 Sonnet
- **Tokens**: ~3000 input, ~2000 output
- **Cost**: ~$0.12

### 2A.PRIORITY_SCORING.v1.0
- **Location**: Node 8
- **Model**: Gemini 2.0 Flash
- **Tokens**: ~2000 input, ~800 output
- **Cost**: ~$0.02

### 2A.CONTENT_BRIEF.v1.0
- **Location**: Node 9
- **Model**: Claude 3.5 Sonnet
- **Tokens**: ~3500 input, ~2500 output
- **Cost**: ~$0.15

**Total Cost per Analysis**: ~$0.51

---

## Cost Optimization

### Current Cost Breakdown
```
Perplexity (2 calls):  $0.22 (43%)
Claude (2 calls):      $0.27 (53%)
Gemini (1 call):       $0.02 (4%)
─────────────────────────────
Total:                 $0.51
```

### Optimization Opportunities
1. **Batch processing**: Run multiple topics together (save 20%)
2. **Cache prompts**: Reuse system prompts (save 30-40% with Anthropic caching)
3. **Gemini for simpler tasks**: Use Gemini instead of Claude where possible (save 80%)

---

## Testing & Validation

### Test Cases

**Test 1: Standard Topic**
- Input: "AI marketing automation for B2B SaaS"
- Expected: 20+ keywords, 5+ quick wins, detailed content briefs
- Success Criteria: Priority scores reasonable, recommendations actionable

**Test 2: Niche Topic**
- Input: "Kubernetes security compliance"
- Expected: Fewer keywords but highly specific
- Success Criteria: Competitors accurately identified, gaps valid

**Test 3: Broad Topic**
- Input: "Digital marketing"
- Expected: Many keywords, needs prioritization
- Success Criteria: Proper segmentation by subtopic

---

## Integration Points

### WordPress/CMS Integration (Future)
```
n8n Workflow:
1. New keyword marked "In Progress" in Airtable
2. Fetch content brief
3. Send to CMS as draft post
4. Populate meta fields (title, description, keywords)
5. Notify content creator
```

### Slack Commands (Future)
```
/seo-research [topic]
→ Triggers workflow
→ Returns results in thread
```

---

## Success Metrics

Track in Airtable:
- Keywords identified per analysis
- Quick wins percentage (target: >20%)
- Average priority score
- Time to complete analysis
- Cost per keyword
- Content creation rate
- Ranking improvements (when tracking)

---

**Implementation Status**: Ready for development
**Estimated Build Time**: 12-16 hours
**Prerequisites**: SEO API access (SEMrush/DataForSEO), Airtable base setup
**Next Steps**: Set up Airtable tables, configure API credentials, build workflow in n8n
