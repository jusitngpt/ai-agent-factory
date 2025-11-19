# Agent-2 SEO Intelligence V2 - n8n Workflow Technical Specification

## Overview

**Workflow Name:** Agent-2 SEO Intelligence V2
**Workflow ID:** KZfgyKJr4biAMcrO
**Total Nodes:** 9
**Execution Model:** Sequential with loop processing
**Average Execution Time:** 15-25 minutes (5 competitors)
**Trigger Type:** Schedule (Weekly - Mondays 9:00 AM)

---

## Workflow Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Agent-2 SEO Intelligence V2                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  [1] Schedule Trigger (Weekly)                                       │
│         │                                                             │
│         ▼                                                             │
│  [2] Competitor Array Setup (Code Node)                              │
│         │                                                             │
│         ▼                                                             │
│  [3] Split Into Batches (Loop Controller)                            │
│         │                                                             │
│         ▼                                                             │
│  [4] Extract Competitor Info (Code Node)                             │
│         │                                                             │
│         ▼                                                             │
│  [5] SEO Research (Perplexity Sonar Pro)                             │
│         │                                                             │
│         ▼                                                             │
│  [6] Strategic Analysis (Gemini 2.5 Pro)                             │
│         │                                                             │
│         ▼                                                             │
│  [7] Extract JSON (Information Extractor)                            │
│         │                                                             │
│         ▼                                                             │
│  [8] Save to Airtable (Create Record)                                │
│         │                                                             │
│         └──→ Loop back to [3] for next competitor                    │
│                                                                       │
│  [9] Completion Notification (Slack)                                 │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Node Specifications

### Node 1: Schedule Trigger - Weekly SEO Analysis

**Type:** `n8n-nodes-base.scheduleTrigger`
**Purpose:** Initiates weekly SEO competitive analysis every Monday morning

**Configuration:**
```json
{
  "rule": {
    "interval": [
      {
        "field": "weeks",
        "weeksInterval": 1,
        "daysOfWeek": [
          {
            "day": "Monday"
          }
        ],
        "hoursInterval": 1,
        "hour": 9,
        "minute": 0
      }
    ]
  },
  "triggerTimes": {
    "mode": "everyWeek",
    "hour": 9,
    "minute": 0,
    "weekday": "Monday",
    "timezone": "America/New_York"
  }
}
```

**Output:**
```json
{
  "timestamp": "2025-11-19T09:00:00.000Z",
  "timezone": "America/New_York"
}
```

**Notes:**
- Runs every Monday at 9:00 AM ET
- Allows 15-25 minutes for completion before business hours
- Can be adjusted for different timezones
- Manual execution available for testing

---

### Node 2: Competitor SEO Array Setup

**Type:** `n8n-nodes-base.code`
**Purpose:** Creates structured array of competitors for SEO analysis

**Code:**
```javascript
return [
  {
    json: {
      competitors: [
        {
          name: "Selenium",
          website: "https://www.selenium.dev/",
          focus_areas: ["web automation", "browser testing", "open source"],
          primary_keywords: ["selenium webdriver", "selenium grid", "selenium ide"],
          content_hub: "https://www.selenium.dev/blog/"
        },
        {
          name: "Cypress",
          website: "https://www.cypress.io/",
          focus_areas: ["e2e testing", "developer experience", "modern web"],
          primary_keywords: ["cypress testing", "cypress io", "javascript testing"],
          content_hub: "https://www.cypress.io/blog/"
        },
        {
          name: "Playwright",
          website: "https://playwright.dev/",
          focus_areas: ["cross-browser testing", "automation", "microsoft"],
          primary_keywords: ["playwright testing", "playwright automation", "browser automation"],
          content_hub: "https://playwright.dev/blog/"
        },
        {
          name: "TestCafe",
          website: "https://testcafe.io/",
          focus_areas: ["node.js testing", "no webdriver", "easy setup"],
          primary_keywords: ["testcafe", "testcafe automation", "javascript e2e"],
          content_hub: "https://testcafe.io/blog/"
        },
        {
          name: "Puppeteer",
          website: "https://pptr.dev/",
          focus_areas: ["headless chrome", "web scraping", "automation"],
          primary_keywords: ["puppeteer", "headless chrome", "puppeteer automation"],
          content_hub: "https://pptr.dev/blog/"
        }
      ],
      analysis_date: new Date().toISOString(),
      analysis_type: "weekly_seo_intelligence"
    }
  }
];
```

**Output Structure:**
```json
{
  "competitors": [
    {
      "name": "string",
      "website": "string (URL)",
      "focus_areas": ["string"],
      "primary_keywords": ["string"],
      "content_hub": "string (URL)"
    }
  ],
  "analysis_date": "ISO 8601 timestamp",
  "analysis_type": "weekly_seo_intelligence"
}
```

**Customization Points:**
- Add/remove competitors from array
- Modify focus areas for each competitor
- Update primary keywords for tracking
- Change content hub URLs for monitoring

---

### Node 3: Split Into Batches (Loop Controller)

**Type:** `n8n-nodes-base.splitInBatches`
**Purpose:** Processes competitors sequentially to manage API rate limits and costs

**Configuration:**
```json
{
  "batchSize": 1,
  "options": {
    "reset": false
  }
}
```

**Behavior:**
- Processes 1 competitor at a time
- Loops back for each competitor in array
- Prevents parallel execution (rate limit protection)
- Maintains execution context between iterations

**Loop Flow:**
```
Iteration 1: Competitor 1 → Nodes 4-8 → Save to Airtable
Iteration 2: Competitor 2 → Nodes 4-8 → Save to Airtable
Iteration 3: Competitor 3 → Nodes 4-8 → Save to Airtable
Iteration 4: Competitor 4 → Nodes 4-8 → Save to Airtable
Iteration 5: Competitor 5 → Nodes 4-8 → Save to Airtable
All Complete → Node 9 (Slack Notification)
```

---

### Node 4: Extract Competitor Info

**Type:** `n8n-nodes-base.code`
**Purpose:** Extracts individual competitor data from batch for analysis

**Code:**
```javascript
const competitor = $input.item.json.competitors[$node["Split Into Batches"].context.currentIndex];

return {
  json: {
    competitor_name: competitor.name,
    competitor_website: competitor.website,
    focus_areas: competitor.focus_areas.join(", "),
    primary_keywords: competitor.primary_keywords.join(", "),
    content_hub: competitor.content_hub,
    analysis_timestamp: new Date().toISOString()
  }
};
```

**Output Example:**
```json
{
  "competitor_name": "Selenium",
  "competitor_website": "https://www.selenium.dev/",
  "focus_areas": "web automation, browser testing, open source",
  "primary_keywords": "selenium webdriver, selenium grid, selenium ide",
  "content_hub": "https://www.selenium.dev/blog/",
  "analysis_timestamp": "2025-11-19T09:01:23.456Z"
}
```

**Context Variables:**
- `$node["Split Into Batches"].context.currentIndex` - Current loop iteration
- `$input.item.json.competitors` - Full competitor array
- Extracts single competitor object per iteration

---

### Node 5: SEO Research via Perplexity

**Type:** `@n8n/n8n-nodes-langchain.lmChatPerplexity`
**Purpose:** Conducts real-time SEO competitive research using Perplexity Sonar Pro

**Configuration:**
```json
{
  "model": "sonar-pro",
  "options": {
    "temperature": 0.3,
    "maxTokens": 4000,
    "returnCitations": true,
    "returnRelatedQuestions": true,
    "searchRecencyFilter": "month",
    "topK": 10
  }
}
```

**Prompt Template:**
```
You are an SEO competitive intelligence analyst. Conduct comprehensive SEO research for the following competitor:

**Competitor:** {{$json.competitor_name}}
**Website:** {{$json.competitor_website}}
**Focus Areas:** {{$json.focus_areas}}
**Primary Keywords:** {{$json.primary_keywords}}
**Content Hub:** {{$json.content_hub}}

Perform deep SEO analysis covering these dimensions:

## 1. Content Strategy Analysis
- What types of content are they publishing? (blogs, guides, tutorials, case studies, videos)
- What is their content publishing frequency and consistency?
- What content formats perform best for them?
- What is the depth and quality of their content?
- What topics are they covering most extensively?

## 2. SEO Performance Metrics
- What is their estimated organic traffic and visibility?
- What are their top-performing pages and topics?
- What keywords are they ranking for in top 10 positions?
- What is their domain authority and backlink profile strength?
- What SERP features do they own? (featured snippets, PAA, etc.)

## 3. Content Quality Assessment
- How comprehensive and detailed is their content?
- What multimedia elements do they use? (images, videos, infographics)
- How well is their content optimized for user intent?
- What is their content freshness and update strategy?
- How do they structure their content for readability and SEO?

## 4. Competitive SEO Positioning
- What unique content angles or perspectives do they take?
- What are their content strengths compared to the market?
- What gaps or weaknesses exist in their SEO strategy?
- What emerging trends are they capitalizing on?
- What content opportunities are they missing?

## 5. Technical SEO Observations
- Site speed and Core Web Vitals performance
- Mobile optimization and responsive design
- Schema markup and structured data usage
- Internal linking strategy
- URL structure and site architecture

**Research Requirements:**
- Focus on last 30 days of activity for recency
- Include specific examples with URLs where possible
- Provide quantitative metrics when available
- Cite all sources for verification
- Identify 5-7 specific content gap opportunities

Return comprehensive research findings with specific examples and citations.
```

**API Parameters:**
- **Model:** `sonar-pro` (real-time web access)
- **Temperature:** 0.3 (balanced creativity/accuracy)
- **Max Tokens:** 4000 (comprehensive research)
- **Search Recency:** Last 30 days
- **Citations:** Enabled (source verification)

**Output Structure:**
```json
{
  "research_findings": "comprehensive SEO analysis text",
  "citations": [
    {
      "url": "string",
      "title": "string",
      "snippet": "string"
    }
  ],
  "related_questions": ["string"],
  "token_usage": {
    "prompt": 850,
    "completion": 3200,
    "total": 4050
  }
}
```

**Cost Per Execution:**
- Sonar Pro: ~$0.05-$0.08 per competitor
- Average: ~$0.35 for 5 competitors

---

### Node 6: Strategic Analysis via Gemini

**Type:** `@n8n/n8n-nodes-langchain.lmChatGoogleGemini`
**Purpose:** Synthesizes research into strategic SEO intelligence and action items

**Configuration:**
```json
{
  "modelName": "gemini-2.0-flash-exp",
  "options": {
    "temperature": 0.4,
    "maxOutputTokens": 8000,
    "topP": 0.95,
    "topK": 40
  }
}
```

**Prompt Template:**
```
You are Katalon's SEO Strategy Director. Analyze the following SEO competitive intelligence and provide strategic insights and recommendations.

**Competitor:** {{$json.competitor_name}}
**Analysis Date:** {{$json.analysis_timestamp}}

**Raw SEO Research:**
{{$node["SEO Research via Perplexity"].json.research_findings}}

**Your Task:**
Synthesize this research into actionable SEO intelligence for Katalon's content and marketing teams.

**Required Output Structure (JSON format):**

{
  "executive_summary": "2-3 paragraph summary of key findings and strategic implications",

  "content_strategy_insights": {
    "overview": "Summary of competitor's content approach",
    "content_types": ["list of content types they use"],
    "publishing_frequency": "Description of their cadence",
    "top_performing_topics": ["5-7 topics that drive their traffic"],
    "content_depth_score": "rating 1-10 with brief justification"
  },

  "seo_performance_analysis": {
    "organic_visibility": "Assessment of their search visibility",
    "top_ranking_keywords": ["10-15 keywords they rank well for"],
    "domain_authority_estimate": "DA score or range if available",
    "serp_features_owned": ["featured snippets, PAA, etc."],
    "traffic_estimate": "Monthly organic traffic estimate"
  },

  "content_gaps_identified": [
    {
      "gap_number": 1,
      "opportunity_title": "Specific content gap or opportunity",
      "description": "Detailed explanation of the gap",
      "potential_impact": "High/Medium/Low",
      "recommended_content_type": "Blog, Guide, Video, etc.",
      "target_keywords": ["relevant keywords for this gap"],
      "effort_estimate": "Hours or complexity level"
    }
  ],

  "strategic_recommendations": {
    "top_5_content_tactics": [
      {
        "tactic": "Specific actionable recommendation",
        "rationale": "Why this matters based on competitive analysis",
        "priority": "High/Medium/Low",
        "expected_outcome": "What success looks like"
      }
    ],
    "top_5_seo_tactics": [
      {
        "tactic": "Specific technical or on-page SEO recommendation",
        "rationale": "Why this matters",
        "priority": "High/Medium/Low",
        "expected_outcome": "What success looks like"
      }
    ]
  },

  "competitive_threats": [
    {
      "threat": "Specific competitive threat or area where they're winning",
      "severity": "High/Medium/Low",
      "recommended_response": "How Katalon should respond"
    }
  ],

  "competitive_advantages_katalon_can_exploit": [
    {
      "advantage": "Area where competitor is weak or absent",
      "opportunity": "How Katalon can capitalize",
      "quick_win_potential": "Yes/No"
    }
  ],

  "key_metrics": {
    "analysis_confidence": "High/Medium/Low",
    "data_freshness": "Recency of data analyzed",
    "strategic_priority_score": "1-100 rating of overall importance",
    "recommended_review_frequency": "Weekly/Monthly/Quarterly"
  }
}

**Analysis Guidelines:**
- Be specific with examples and data points
- Identify 5-7 high-value content gaps
- Provide 5 content tactics + 5 SEO tactics (10 total recommendations)
- Include both defensive (threats) and offensive (opportunities) strategies
- Focus on actionable insights the team can implement immediately
- Rate strategic priority (1-100) based on potential impact and feasibility

Return ONLY the JSON object. No additional text or markdown.
```

**API Parameters:**
- **Model:** `gemini-2.0-flash-exp` (128K context, fast inference)
- **Temperature:** 0.4 (balanced analysis)
- **Max Tokens:** 8000 (comprehensive output)

**Expected Output Size:**
- Average: 4,000-6,000 tokens
- Contains complete strategic analysis in JSON format

**Cost Per Execution:**
- Gemini 2.0 Flash: ~$0.10-$0.15 per competitor
- Average: ~$0.60 for 5 competitors

---

### Node 7: Extract Structured JSON

**Type:** `@n8n/n8n-nodes-langchain.informationExtractor`
**Purpose:** Validates and extracts clean JSON from Gemini's response

**Configuration:**
```json
{
  "jsonSchema": {
    "type": "object",
    "required": [
      "executive_summary",
      "content_strategy_insights",
      "seo_performance_analysis",
      "content_gaps_identified",
      "strategic_recommendations",
      "key_metrics"
    ],
    "properties": {
      "executive_summary": {"type": "string"},
      "content_strategy_insights": {
        "type": "object",
        "properties": {
          "overview": {"type": "string"},
          "content_types": {"type": "array", "items": {"type": "string"}},
          "publishing_frequency": {"type": "string"},
          "top_performing_topics": {"type": "array", "items": {"type": "string"}},
          "content_depth_score": {"type": "string"}
        }
      },
      "seo_performance_analysis": {
        "type": "object",
        "properties": {
          "organic_visibility": {"type": "string"},
          "top_ranking_keywords": {"type": "array", "items": {"type": "string"}},
          "domain_authority_estimate": {"type": "string"},
          "serp_features_owned": {"type": "array", "items": {"type": "string"}},
          "traffic_estimate": {"type": "string"}
        }
      },
      "content_gaps_identified": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "gap_number": {"type": "number"},
            "opportunity_title": {"type": "string"},
            "description": {"type": "string"},
            "potential_impact": {"type": "string", "enum": ["High", "Medium", "Low"]},
            "recommended_content_type": {"type": "string"},
            "target_keywords": {"type": "array", "items": {"type": "string"}},
            "effort_estimate": {"type": "string"}
          }
        }
      },
      "strategic_recommendations": {
        "type": "object",
        "properties": {
          "top_5_content_tactics": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "tactic": {"type": "string"},
                "rationale": {"type": "string"},
                "priority": {"type": "string", "enum": ["High", "Medium", "Low"]},
                "expected_outcome": {"type": "string"}
              }
            }
          },
          "top_5_seo_tactics": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "tactic": {"type": "string"},
                "rationale": {"type": "string"},
                "priority": {"type": "string", "enum": ["High", "Medium", "Low"]},
                "expected_outcome": {"type": "string"}
              }
            }
          }
        }
      },
      "competitive_threats": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "threat": {"type": "string"},
            "severity": {"type": "string", "enum": ["High", "Medium", "Low"]},
            "recommended_response": {"type": "string"}
          }
        }
      },
      "competitive_advantages_katalon_can_exploit": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "advantage": {"type": "string"},
            "opportunity": {"type": "string"},
            "quick_win_potential": {"type": "string", "enum": ["Yes", "No"]}
          }
        }
      },
      "key_metrics": {
        "type": "object",
        "properties": {
          "analysis_confidence": {"type": "string", "enum": ["High", "Medium", "Low"]},
          "data_freshness": {"type": "string"},
          "strategic_priority_score": {"type": "number", "minimum": 1, "maximum": 100},
          "recommended_review_frequency": {"type": "string"}
        }
      }
    }
  },
  "options": {
    "strictValidation": true,
    "removeInvalidFields": false
  }
}
```

**Error Handling:**
- Validates all required fields present
- Ensures enum values match specifications
- Verifies array structures and nested objects
- Fails workflow if validation errors occur (prevents bad data)

**Output:**
Clean, validated JSON matching exact schema requirements for Airtable storage.

---

### Node 8: Save to Airtable

**Type:** `n8n-nodes-base.airtable`
**Operation:** Create Record
**Purpose:** Persists SEO intelligence to Competitor SEO Analysis table

**Configuration:**
```json
{
  "operation": "create",
  "application": "{{AIRTABLE_BASE_ID}}",
  "table": "Competitor SEO Analysis",
  "options": {
    "typecast": true,
    "returnFields": ["id", "Competitor Name", "Analysis Date"]
  }
}
```

**Field Mappings:**
```json
{
  "Competitor Name": "={{$json.competitor_name}}",
  "Analysis Date": "={{$json.analysis_timestamp}}",
  "Executive Summary": "={{$json.executive_summary}}",
  "Content Strategy Overview": "={{$json.content_strategy_insights.overview}}",
  "Content Types": "={{$json.content_strategy_insights.content_types.join(', ')}}",
  "Top Performing Topics": "={{$json.content_strategy_insights.top_performing_topics.join(', ')}}",
  "Content Depth Score": "={{$json.content_strategy_insights.content_depth_score}}",
  "Organic Visibility": "={{$json.seo_performance_analysis.organic_visibility}}",
  "Top Keywords": "={{$json.seo_performance_analysis.top_ranking_keywords.join(', ')}}",
  "Domain Authority": "={{$json.seo_performance_analysis.domain_authority_estimate}}",
  "SERP Features": "={{$json.seo_performance_analysis.serp_features_owned.join(', ')}}",
  "Traffic Estimate": "={{$json.seo_performance_analysis.traffic_estimate}}",
  "Content Gaps (JSON)": "={{JSON.stringify($json.content_gaps_identified, null, 2)}}",
  "Content Tactics (JSON)": "={{JSON.stringify($json.strategic_recommendations.top_5_content_tactics, null, 2)}}",
  "SEO Tactics (JSON)": "={{JSON.stringify($json.strategic_recommendations.top_5_seo_tactics, null, 2)}}",
  "Competitive Threats (JSON)": "={{JSON.stringify($json.competitive_threats, null, 2)}}",
  "Katalon Advantages (JSON)": "={{JSON.stringify($json.competitive_advantages_katalon_can_exploit, null, 2)}}",
  "Strategic Priority Score": "={{$json.key_metrics.strategic_priority_score}}",
  "Analysis Confidence": "={{$json.key_metrics.analysis_confidence}}",
  "Data Freshness": "={{$json.key_metrics.data_freshness}}",
  "Review Frequency": "={{$json.key_metrics.recommended_review_frequency}}",
  "Workflow Execution ID": "={{$workflow.id}}_{{$execution.id}}",
  "Status": "New Analysis"
}
```

**Airtable Response:**
```json
{
  "id": "recXXXXXXXXXXXXXX",
  "fields": {
    "Competitor Name": "Selenium",
    "Analysis Date": "2025-11-19T09:03:45.123Z"
  },
  "createdTime": "2025-11-19T09:03:46.000Z"
}
```

**Notes:**
- Creates one record per competitor
- Long text fields stored as JSON for complex data
- Status automatically set to "New Analysis"
- Execution ID enables debugging

---

### Node 9: Completion Notification (Slack)

**Type:** `n8n-nodes-base.slack`
**Operation:** Send Message
**Purpose:** Notifies team when weekly SEO analysis completes

**Configuration:**
```json
{
  "resource": "message",
  "operation": "post",
  "channel": "#seo-intelligence",
  "authentication": "oAuth2"
}
```

**Message Template:**
```
:mag_right: **Weekly SEO Intelligence Complete**

**Analysis Date:** {{$node["Schedule Trigger"].json.timestamp}}
**Competitors Analyzed:** 5
**Total Execution Time:** {{$workflow.executionTime}} seconds

**Summary:**
✅ Selenium - SEO analysis complete
✅ Cypress - SEO analysis complete
✅ Playwright - SEO analysis complete
✅ TestCafe - SEO analysis complete
✅ Puppeteer - SEO analysis complete

**Key Highlights:**
• {{$node["Split Into Batches"].context.totalRecords}} competitor profiles analyzed
• Average strategic priority: {{$json.average_priority_score}}/100
• New content gaps identified: {{$json.total_content_gaps}}
• High-priority recommendations: {{$json.high_priority_count}}

**View Full Analysis:**
:link: <https://airtable.com/{{AIRTABLE_BASE_ID}}/{{AIRTABLE_TABLE_ID}}|Competitor SEO Analysis Table>

**Next Analysis:** Next Monday, 9:00 AM ET

---
_Workflow: Agent-2 SEO Intelligence V2_
_Execution ID: {{$execution.id}}_
```

**Slack Channel:**
- Primary: `#seo-intelligence`
- Fallback: `#marketing-automation`
- DM: `@seo-lead` (for urgent findings)

**Notification Conditions:**
- Always sends on successful completion
- Includes summary statistics
- Links directly to Airtable view
- Shows execution ID for debugging

---

## Credentials Required

### 1. Perplexity API Credential
- **Type:** HTTP Request Auth
- **Auth Type:** Bearer Token
- **Token:** Perplexity API Key
- **Endpoint:** `https://api.perplexity.ai/chat/completions`
- **Required Scopes:** Sonar Pro access

### 2. Google Gemini API Credential
- **Type:** Google Gemini API
- **Project ID:** Your Google Cloud project
- **API Key:** Gemini API key with access to `gemini-2.0-flash-exp`
- **Required APIs:**
  - Generative Language API
  - Vertex AI API (optional for advanced features)

### 3. Airtable Credential
- **Type:** Airtable API
- **Authentication:** Personal Access Token
- **Base ID:** Your Airtable base
- **Required Permissions:**
  - `data.records:read`
  - `data.records:write`
  - `schema.bases:read`

### 4. Slack Credential
- **Type:** OAuth2
- **Client ID:** Your Slack app client ID
- **Client Secret:** Your Slack app secret
- **Required Scopes:**
  - `chat:write`
  - `channels:read`
  - `chat:write.public`

---

## Environment Variables

```bash
# Perplexity Configuration
PERPLEXITY_API_KEY=pplx-xxxxxxxxxxxxxxxxxxxxx
PERPLEXITY_MODEL=sonar-pro
PERPLEXITY_MAX_TOKENS=4000

# Google Gemini Configuration
GOOGLE_GEMINI_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXX
GEMINI_MODEL=gemini-2.0-flash-exp
GEMINI_MAX_TOKENS=8000

# Airtable Configuration
AIRTABLE_API_KEY=patXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
AIRTABLE_BASE_ID=appXXXXXXXXXXXXXX
AIRTABLE_TABLE_NAME=Competitor SEO Analysis

# Slack Configuration
SLACK_CHANNEL_ID=C01XXXXXXXXXX
SLACK_CHANNEL_NAME=#seo-intelligence

# Workflow Configuration
WORKFLOW_SCHEDULE=0 9 * * 1
WORKFLOW_TIMEZONE=America/New_York
BATCH_SIZE=1
ANALYSIS_RECENCY=month
```

---

## Error Handling

### Node-Level Error Handling

**Continue on Fail:** Disabled for critical nodes
- Nodes 5, 6, 7, 8 (research, analysis, extraction, storage)
- Failure in any stops entire workflow
- Prevents partial/incomplete data

**Continue on Fail:** Enabled for notification
- Node 9 (Slack notification)
- Workflow succeeds even if Slack fails
- Logs error but doesn't block completion

### Retry Configuration

**Perplexity Node (5):**
```json
{
  "retries": 3,
  "retryInterval": 5000,
  "retryBackoff": "exponential"
}
```

**Gemini Node (6):**
```json
{
  "retries": 3,
  "retryInterval": 3000,
  "retryBackoff": "exponential"
}
```

**Airtable Node (8):**
```json
{
  "retries": 2,
  "retryInterval": 2000,
  "retryBackoff": "linear"
}
```

---

## Performance Optimization

### Execution Time Breakdown

| Node | Avg Time | % of Total |
|------|----------|------------|
| Schedule Trigger | <1s | 0% |
| Competitor Setup | <1s | 0% |
| Split Into Batches | <1s | 0% |
| Extract Info | <1s | 0% |
| **Perplexity Research** | **30-60s** | **35%** |
| **Gemini Analysis** | **45-90s** | **60%** |
| JSON Extraction | 1-2s | 1% |
| Airtable Save | 2-3s | 2% |
| Slack Notification | 1-2s | 1% |
| **Total per Competitor** | **3-5 min** | **100%** |

**Total Workflow Time:** 15-25 minutes (5 competitors)

### Optimization Strategies

1. **Batch Size = 1:**
   - Sequential processing prevents rate limits
   - Ensures stable execution
   - Small cost impact vs parallel execution

2. **Perplexity Optimization:**
   - Search recency = 30 days (faster than "all time")
   - Top-K = 10 (balanced quality/speed)
   - Temperature = 0.3 (reduces variability)

3. **Gemini Optimization:**
   - Using `gemini-2.0-flash-exp` (fast inference)
   - Structured JSON output (no parsing overhead)
   - Max tokens = 8000 (prevents overrun)

4. **Caching Strategy:**
   - No caching implemented (SEO data changes weekly)
   - Research must be fresh for accuracy
   - Consider caching for static competitor lists

---

## Cost Analysis

### Per-Execution Costs

| Service | Cost per Competitor | Cost for 5 Competitors |
|---------|---------------------|------------------------|
| Perplexity Sonar Pro | $0.05-$0.08 | $0.25-$0.40 |
| Google Gemini 2.0 Flash | $0.10-$0.15 | $0.50-$0.75 |
| Airtable API | ~$0.001 | ~$0.005 |
| Slack API | Free | Free |
| **Total per Week** | **~$0.15-$0.23** | **~$0.75-$1.15** |

### Monthly Cost Projection

```
Weekly Executions: 4
Competitors per Execution: 5
Cost per Execution: ~$1.00
Monthly Total: ~$4.00
```

**vs. Manual Alternative:**
- SEO Analyst: $50/hour
- Time per Competitor: 1 hour
- Monthly Cost: 5 competitors × 4 weeks × $50 = **$1,000**
- **Savings: $996/month (99.6%)**

---

## Testing and Validation

### Test Execution Checklist

**Pre-Test Setup:**
- [ ] All credentials configured and tested
- [ ] Airtable base created with correct schema
- [ ] Slack channel exists and bot has access
- [ ] Competitor array populated with valid data
- [ ] Schedule trigger disabled (manual execution for testing)

**Test Execution:**
1. Set batch size to 1 (test single competitor first)
2. Manually trigger workflow
3. Monitor execution in n8n UI (Real-time view)
4. Verify Perplexity research completes (~60s)
5. Verify Gemini analysis completes (~90s)
6. Check JSON extraction for validation errors
7. Confirm Airtable record created with all fields
8. Verify Slack notification sent

**Post-Test Validation:**
- [ ] Airtable record has all 20+ fields populated
- [ ] Executive summary is coherent and actionable
- [ ] Content gaps array has 5-7 items
- [ ] Strategic recommendations have 10 items (5 content + 5 SEO)
- [ ] Priority score is between 1-100
- [ ] Slack notification formatting correct
- [ ] Execution time within expected range (3-5 min per competitor)

### Sample Test Data

**Test Competitor:**
```json
{
  "name": "Selenium",
  "website": "https://www.selenium.dev/",
  "focus_areas": ["web automation", "browser testing"],
  "primary_keywords": ["selenium webdriver", "selenium testing"],
  "content_hub": "https://www.selenium.dev/blog/"
}
```

**Expected Execution:**
- Perplexity: 45-60 seconds
- Gemini: 60-90 seconds
- Total: 3-4 minutes
- Airtable record: 1 new record
- Slack: 1 notification

---

## Monitoring and Observability

### Key Metrics to Track

1. **Execution Success Rate**
   - Target: >95% success rate
   - Alert if <90% over 4 weeks

2. **Average Execution Time**
   - Target: 15-25 minutes (5 competitors)
   - Alert if >30 minutes

3. **API Costs**
   - Target: <$5/month
   - Alert if >$10/month

4. **Content Gaps Identified**
   - Target: 5-7 per competitor
   - Track trends over time

5. **Strategic Priority Scores**
   - Track average score per competitor
   - Identify high-priority trends

### Logging Strategy

**Workflow Logs:**
```json
{
  "execution_id": "string",
  "start_time": "ISO timestamp",
  "end_time": "ISO timestamp",
  "total_duration_seconds": "number",
  "competitors_processed": "number",
  "success": "boolean",
  "errors": ["array of error objects"],
  "cost_estimate": "number (dollars)"
}
```

**Node-Level Logs:**
- Perplexity: Token usage, research time, citations count
- Gemini: Token usage, analysis time, JSON validation
- Airtable: Record IDs created, API response times
- Slack: Message delivery status, notification time

---

## Maintenance and Updates

### Weekly Maintenance

- [ ] Review Airtable records for quality
- [ ] Check execution logs for errors
- [ ] Verify Slack notifications delivered
- [ ] Monitor API cost trends

### Monthly Maintenance

- [ ] Update competitor list (add/remove as needed)
- [ ] Review and refine prompts based on output quality
- [ ] Audit strategic recommendations for relevance
- [ ] Update focus areas and primary keywords
- [ ] Review cost efficiency vs. manual alternative

### Quarterly Maintenance

- [ ] Evaluate model performance (consider newer models)
- [ ] Review Airtable schema (add fields if needed)
- [ ] Audit competitor selection (still relevant?)
- [ ] Update SEO analysis framework (new trends?)
- [ ] Review and optimize execution time

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.0 | 2025-11-19 | Initial production release |
| | | - 9-node workflow architecture |
| | | - Perplexity Sonar Pro integration |
| | | - Gemini 2.0 Flash Exp for analysis |
| | | - Comprehensive SEO framework |
| | | - Weekly schedule (Mondays 9 AM) |
| 1.0 | 2025-09-15 | Legacy version (deprecated) |

---

## Related Documentation

- **Business Overview:** [README.md](./README.md)
- **Database Schema:** [AIRTABLE-SCHEMA.md](./AIRTABLE-SCHEMA.md)
- **Implementation Guide:** [IMPLEMENTATION-GUIDE.md](./IMPLEMENTATION-GUIDE.md)
- **Troubleshooting:** [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
- **Workflow JSON:** [/workflows/agent-2-seo-intelligence-v2.json](../../workflows/agent-2-seo-intelligence-v2.json)

---

## Support and Feedback

For issues or questions about this workflow:
1. Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
2. Review n8n execution logs
3. Verify all credentials are active
4. Contact: Katalon Marketing Automation Team

**Last Updated:** 2025-11-19
**Maintained By:** Katalon Marketing Automation Team
**Workflow Status:** ✅ Production Ready
