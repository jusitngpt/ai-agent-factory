# Agent-1B V4: Multi-Feed RSS Monitor - Competitive Intelligence

**Workflow**: Competitive Intel RSS Monitor
**Version**: 4.0 (Multi-Feed)
**Status**: 📋 Production Ready
**Workflow ID**: `8HGOmJjpQATXhnzy`
**Last Updated**: November 19, 2025

---

## Overview

Agent-1B V4 is an advanced competitive intelligence automation that monitors multiple competitor RSS feeds simultaneously, analyzes new blog posts and content using AI, extracts strategic insights, and delivers actionable intelligence to your team via Slack and Airtable.

### Key Improvements from V2

**V4 Enhancements**:
- ✅ Multi-feed loop architecture (monitor 5+ competitors simultaneously)
- ✅ AI-powered competitive analysis with Gemini 2.5 Pro
- ✅ Structured JSON extraction via Information Extractor
- ✅ HTTP Request Tool integration for full article fetching
- ✅ Enhanced categorization (7 content categories)
- ✅ Priority scoring (0-100) and strategic value assessment
- ✅ Comprehensive Airtable schema with 16 fields
- ✅ Automated Slack notifications with rich context

**V2 Limitations Addressed**:
- V2: Single feed per workflow execution
- V2: Basic text analysis only
- V2: Limited categorization
- V2: Manual priority assessment

---

## Business Value

### Time Savings

- **Manual monitoring**: 30-60 minutes/day across 5 competitors
- **Agent-1B V4**: 100% automated, 24/7 monitoring
- **Time saved**: ~20-40 hours/month per analyst

### Use Cases

**Competitive Intelligence Teams**
- Real-time tracking of competitor product launches
- Feature announcement monitoring
- Strategic positioning analysis
- Content strategy intelligence

**Product Marketing**
- Competitive messaging analysis
- Market trend identification
- Content gap analysis
- Battle card updates

**Sales Enablement**
- Win/loss signal detection
- Competitive advantage identification
- Objection handling insights
- Deal intelligence

**Product Strategy**
- Feature parity tracking
- Market positioning shifts
- Technology adoption signals
- Partnership announcements

---

## Quick Stats

| Metric | Value |
|--------|-------|
| **Nodes** | 12 |
| **Competitors Monitored** | 5 (configurable) |
| **Average Execution Time** | 45-90 seconds (all feeds) |
| **Cost Per Execution** | ~$0.02-$0.04 |
| **Trigger Type** | Schedule (Every 24 hours) |
| **Primary LLM** | Gemini 2.5 Pro |
| **Status** | ✅ Ready for Production |

---

## How It Works

### Workflow Sequence

```
1. Schedule Trigger (Daily @ configured time)
   ↓
2. RSS Feed Array Setup (5 competitor feed URLs)
   ↓
3. Loop Over Feeds (Process each competitor sequentially)
   ↓
4. Set Current Feed Variables (Track competitor name + URL)
   ↓
5. Fetch RSS Feed (Get latest posts)
   ↓
6. Filter New Posts (Last 24 hours only)
   ↓
7. AI Analysis (Gemini 2.5 Pro - competitive intelligence extraction)
   ↓
8. Information Extractor (Structured JSON output)
   ↓
9. Create Airtable Record (Save analysis + metadata)
   ↓
10. Slack Notification (Alert team with summary)
```

### Input Requirements

The workflow is configured with:
- **Competitor RSS Feed URLs**: Array of 5 RSS feed URLs
- **Competitor Names**: Matching array of company names
- **Time Window**: Last 24 hours (configurable)
- **Analysis Depth**: Full competitive intelligence framework

Example Configuration:
```javascript
feedUrls: [
  "https://fetchrss.com/feed/competitor1.rss",
  "https://fetchrss.com/feed/competitor2.rss",
  "https://fetchrss.com/feed/competitor3.rss",
  "https://fetchrss.com/feed/competitor4.rss",
  "https://fetchrss.com/feed/competitor5.rss"
],
competitors: [
  "Competitor 1",
  "Competitor 2",
  "Competitor 3",
  "Competitor 4",
  "Competitor 5"
]
```

### Output Delivered

For each new blog post discovered, the workflow provides:

**Airtable Record Fields**:
- Item Title
- Competitor Name
- Post URL
- Published Date
- Discovered Date
- Full Content
- Categories (Product Launch, Feature Update, etc.)
- Analysis Status
- Priority Score (0-100)
- Research Result (Full AI analysis)
- Strategic Value (High/Medium/Low/None)
- Notes

**Slack Notification**:
- 📡 New blog post alert
- Competitor name
- Post title
- Post URL
- Published date
- Direct Airtable link

---

## Architecture Details

### Node Breakdown

#### 1. Schedule Trigger - Every 24 Hours
- **Type**: Schedule Trigger
- **Frequency**: Every 24 hours
- **Purpose**: Automated daily execution
- **Configuration**: Runs once per day at configured time

#### 2. RSS Feed Array Setup
- **Type**: Code (JavaScript)
- **Purpose**: Define competitor feeds and names
- **Returns**: JSON object with feedUrls and competitors arrays
- **Customization**: Edit arrays to add/remove competitors

#### 3. Loop Over Feeds
- **Type**: Split in Batches
- **Purpose**: Process each competitor feed sequentially
- **Batch Size**: 1 (one feed at a time)
- **Iteration**: Loops until all feeds processed

#### 4. Set Current Feed Variables
- **Type**: Set (Assignments)
- **Purpose**: Extract current competitor's URL and name
- **Variables**:
  - `currentFeedUrl`
  - `currentCompetitor`

#### 5. Fetch RSS Feed
- **Type**: RSS Feed Read
- **Input**: Current feed URL
- **Output**: Array of RSS items (title, link, pubDate, content)

#### 6. Filter New Posts (24h)
- **Type**: Filter
- **Condition**: `pubDate >= now - 24 hours`
- **Purpose**: Only process recently published content
- **Output**: New posts only

#### 7. Message a model (Gemini 2.5 Pro)
- **Type**: Google Gemini
- **Model**: `models/gemini-2.5-pro`
- **Purpose**: AI-powered competitive intelligence analysis
- **System Prompt**: Comprehensive competitive analyst persona
- **Tools**: HTTP Request Tool (for fetching full article if needed)

#### 8. Information Extractor
- **Type**: Information Extractor (Langchain)
- **Purpose**: Extract structured JSON from AI analysis
- **Schema**: rss_item_analysis + research_result
- **Output**: Validated JSON matching Airtable schema

#### 9. Google Gemini Chat Model
- **Type**: Language Model (Chat)
- **Model**: `models/gemini-2.5-pro`
- **Purpose**: Powers the Information Extractor
- **Connection**: Linked to Information Extractor node

#### 10. HTTP Request
- **Type**: HTTP Request Tool
- **Purpose**: AI tool for fetching full article content when needed
- **Connection**: Linked to Message a model node
- **Input**: Blog post URL

#### 11. Create RSS Feed Item in Airtable
- **Type**: Airtable (Create)
- **Table**: RSS Feed Items
- **Fields**: 16 field mappings (see AIRTABLE-SCHEMA.md)
- **Purpose**: Persist analysis for long-term tracking

#### 12. Slack Notification
- **Type**: Slack (Send Message)
- **Channel**: `#competitor-monitoring` (configurable)
- **Message**: Rich notification with post details
- **Purpose**: Real-time team alerting

---

## AI Analysis Framework

The workflow uses a sophisticated competitive intelligence framework:

### Analysis Dimensions

**1. Content Categorization** (7 categories):
- Product Launch
- Feature Update
- Company News
- Technical
- Customer Story
- Industry Insights
- Thought Leadership

**2. Strategic Intelligence Assessment**:
- Product strategy signals
- Market positioning indicators
- Customer pain points addressed
- Technology/approach highlights
- Competitive advantages claimed

**3. Competitive Analysis**:
- **Strengths Revealed**: What they're doing well
- **Weaknesses & Gaps**: Vulnerabilities and limitations
- **Opportunities for Us**: How to capitalize
- **Threats to Monitor**: Competitive risks

**4. Priority & Value Assessment**:
- **Priority Score (0-100)**:
  - 90-100: Critical strategic intelligence
  - 70-89: High value, significant implications
  - 50-69: Moderate value, worth monitoring
  - 30-49: Low priority, general awareness
  - 0-29: Minimal strategic value

- **Strategic Value**: High / Medium / Low / None
  - High: Major launches, strategic shifts, direct threats
  - Medium: Feature updates, market positioning, thought leadership
  - Low: General blog posts, minor updates
  - None: Corporate fluff, irrelevant content

**5. Confidence Score (0-100)**:
- Based on content depth and quality
- Clarity of strategic signals
- Available information
- Certainty of conclusions

---

## Cost Analysis

### Per-Execution Costs

| Component | Usage | Cost (Estimate) |
|-----------|-------|-----------------|
| **Gemini 2.5 Pro** | 1,500-2,500 input tokens per post | ~$0.004-$0.008 per post |
| **HTTP Requests** | 1-2 per post (full article fetch) | Free |
| **Airtable API** | 1 create call per post | Included in plan |
| **Slack API** | 1 message per post | Free |
| **Total Per Post** | | **~$0.004-$0.008** |

### Monthly Operating Costs (Estimated)

Assuming:
- 5 competitors monitored
- Average 2 blog posts per competitor per week
- ~40 new posts per month total

**Monthly Cost**: 40 posts × $0.006 average = **~$0.24/month**

**Cost Comparison**:
- Manual analyst time (5 hours/month @ $50/hr): $250
- Agent-1B V4 automated cost: $0.24
- **Savings**: $249.76/month (99.9% reduction)

---

## Key Features

### 1. Multi-Feed Loop Architecture
- Monitor 5+ competitors simultaneously
- Sequential processing with proper error handling
- Configurable competitor list via code node
- Easy to add/remove feeds

### 2. Intelligent Content Filtering
- 24-hour time window (only new content)
- Prevents duplicate processing
- Efficient resource usage
- Reduces noise

### 3. Comprehensive AI Analysis
- **Full Article Fetching**: HTTP Request Tool gets complete content
- **Structured Extraction**: Information Extractor ensures consistent JSON
- **Strategic Framework**: 5-dimensional analysis (categorization, intelligence, competitive analysis, priority, confidence)
- **Rich Output**: 2-4 paragraphs of actionable insights per post

### 4. Production-Ready Data Storage
- 16-field Airtable schema
- Categories, priorities, strategic value
- Full AI analysis + metadata
- Long-term trend tracking

### 5. Real-Time Alerting
- Slack notifications to team channel
- Rich context (title, URL, competitor, date)
- Direct Airtable link for full analysis
- Configurable channel

---

## Limitations

### Current Constraints

1. **Feed Quality Dependency**: Relies on RSS feed availability and quality
2. **24-Hour Polling**: Not real-time (executes once daily)
3. **Content Depth**: Analysis quality depends on article length and detail
4. **Language**: English-only analysis (multi-language support planned)
5. **Competitor Limit**: Configured for 5 feeds (can be extended but increases execution time)

### Known Issues

1. **Feed Outages**: If competitor RSS feed is down, that iteration fails gracefully
   - **Mitigation**: Loop continues to next competitor

2. **Parsing Errors**: Some RSS feeds have malformed XML
   - **Mitigation**: Error handling in RSS Feed Read node

3. **Token Limits**: Very long articles (>10,000 words) may exceed Gemini token limits
   - **Mitigation**: HTTP Request Tool excerpts content if needed

### Planned Improvements

- [ ] Real-time webhook triggers (instead of 24-hour polling)
- [ ] Multi-language analysis support (Q1 2026)
- [ ] Image analysis for visual content (Q2 2026)
- [ ] Automatic battle card updates (Q2 2026)
- [ ] Trend analysis dashboards (Q3 2026)

---

## Use Case Examples

### Example 1: Product Launch Detection

**Input**: Competitor publishes "Introducing AI-Powered Test Automation"

**AI Analysis Output**:
```json
{
  "rss_item_analysis": {
    "categories": ["Product Launch", "Technical"],
    "priority_score": 92,
    "strategic_value": "High",
    "analysis_notes": "Major product launch with AI capabilities - direct competitive threat"
  },
  "research_result": {
    "result_title": "Competitor X - AI-Powered Test Automation Launch",
    "executive_summary": "Competitor X announced AI-powered test automation...",
    "competitive_advantages": "- First-to-market with AI test generation\n- Claims 10x faster test creation...",
    "weaknesses": "- Limited to web applications only\n- Requires Selenium expertise...",
    "recommendations": "URGENT: Accelerate our AI testing roadmap...",
    "confidence_score": 95
  }
}
```

**Team Action**: Product team reviews within 2 hours, adjusts roadmap priorities

---

### Example 2: Thought Leadership Tracking

**Input**: Competitor publishes "The Future of DevOps in 2026"

**AI Analysis Output**:
```json
{
  "rss_item_analysis": {
    "categories": ["Thought Leadership", "Industry Insights"],
    "priority_score": 55,
    "strategic_value": "Medium",
    "analysis_notes": "Market positioning content - reveals strategic focus areas"
  },
  "research_result": {
    "result_title": "Competitor Y - DevOps Future Predictions",
    "key_findings": "• Focus on AI-ops and automation\n• Emphasis on security-first approach...",
    "messaging_opportunities": "Counter with our security track record and proven AI implementation",
    "confidence_score": 78
  }
}
```

**Team Action**: Marketing team incorporates into Q1 content strategy

---

## Getting Started

See the following documentation for implementation:

- **[N8N-WORKFLOW.md](./N8N-WORKFLOW.md)** - Detailed node-by-node specifications
- **[AIRTABLE-SCHEMA.md](./AIRTABLE-SCHEMA.md)** - Complete database schema
- **[IMPLEMENTATION-GUIDE.md](./IMPLEMENTATION-GUIDE.md)** - Step-by-step setup
- **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)** - Common issues and solutions

---

## Support

**Project**: Katalon Agent Factory (KAF)
**Workflow**: Agent-1B V4 Multi-Feed RSS Monitor
**Status**: ✅ Production Ready
**Documentation**: Complete

For questions or issues, see TROUBLESHOOTING.md or contact the KAF team.

---

**Built with** Gemini 2.5 Pro + n8n + Airtable | **Last Updated** November 19, 2025
