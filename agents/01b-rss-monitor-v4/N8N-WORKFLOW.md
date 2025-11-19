# N8N Workflow Technical Specification
## Agent-1B V4: Multi-Feed RSS Monitor

**Workflow ID**: `8HGOmJjpQATXhnzy`
**Version**: 4.0
**Total Nodes**: 12
**Active Status**: Inactive (ready for activation after configuration)

---

## Workflow Overview

This n8n workflow monitors 5 competitor RSS feeds every 24 hours, analyzes new blog posts with AI, extracts structured competitive intelligence, and delivers insights via Airtable and Slack.

### Execution Flow

```
Schedule Trigger (Every 24h)
  → RSS Feed Array Setup (Code)
    → Loop Over Feeds (Split in Batches)
      → Set Current Feed Variables (Set)
        → Fetch RSS Feed (RSS Feed Read)
          → Filter New Posts (Filter - 24h window)
            → AI Analysis (Gemini 2.5 Pro with HTTP Request Tool)
              → Information Extractor (Structured JSON)
                → Create Airtable Record (Airtable)
                  → Slack Notification (Slack)
```

---

## Node-by-Node Specification

### Node 1: Schedule Trigger - Every 24 Hours

**Type**: `n8n-nodes-base.scheduleTrigger`
**Version**: 1.2
**Position**: [256, 32]

**Configuration**:
```json
{
  "parameters": {
    "rule": {
      "interval": [
        {
          "field": "hours",
          "hoursInterval": 24
        }
      ]
    }
  }
}
```

**Purpose**: Triggers the workflow once every 24 hours automatically.

**Schedule Details**:
- **Interval**: Every 24 hours
- **Default Time**: When workflow is first activated
- **Recommended**: Set to run during off-peak hours (e.g., 2:00 AM local time)

**Output**: Single empty execution trigger

---

### Node 2: RSS Feed Array Setup

**Type**: `n8n-nodes-base.code`
**Version**: 2
**Position**: [480, 32]

**Code**:
```javascript
return [
  {
    json: {
      feedUrls: [
        "https://fetchrss.com/feed/aN28Dl7HwYMCaN27bKhc7_Ky.rss",
        "https://fetchrss.com/feed/aN28Dl7HwYMCaOA61AzPYpBy.rss",
        "https://fetchrss.com/feed/aN28Dl7HwYMCaOA7UaPr1IOi.rss",
        "https://fetchrss.com/feed/aN28Dl7HwYMCaN28crJXArfi.rss",
        "https://fetchrss.com/feed/aN28Dl7HwYMCaOA8L1N1KjmC.rss"
      ],
      competitors: [
        "Competitor 1",
        "Competitor 2",
        "Competitor 3",
        "Competitor 4",
        "Competitor 5"
      ]
    }
  }
];
```

**Purpose**: Defines the list of competitor RSS feeds to monitor.

**Configuration Instructions**:
1. Replace placeholder feed URLs with your actual competitor RSS feeds
2. Update competitor names to match (same order as feedUrls)
3. Arrays must have the same length
4. You can add/remove competitors (recommended max: 10 for performance)

**Output**: JSON object with two arrays (feedUrls and competitors)

**Example Real Configuration**:
```javascript
feedUrls: [
  "https://www.selenium.dev/blog/feed.xml",
  "https://testsigma.com/blog/feed/",
  "https://www.browserstack.com/blog/feed/",
  "https://www.ranorex.com/blog/feed/",
  "https://www.tricentis.com/blog/feed/"
],
competitors: [
  "Selenium",
  "Testsigma",
  "BrowserStack",
  "Ranorex",
  "Tricentis"
]
```

---

### Node 3: Loop Over Feeds

**Type**: `n8n-nodes-base.splitInBatches`
**Version**: 3
**Position**: [704, 32]

**Configuration**:
```json
{
  "parameters": {
    "options": {}
  }
}
```

**Purpose**: Processes each competitor feed sequentially in a loop.

**Loop Mechanics**:
- **Batch Size**: 1 (processes one feed at a time)
- **Reset**: Automatically resets after all feeds processed
- **Context**: Maintains `currentRunIndex` for tracking position
- **Error Handling**: If one feed fails, loop continues to next feed

**Output**: Single item per iteration containing all feed data

**Loop Control**:
- Iteration 0: Process feedUrls[0] and competitors[0]
- Iteration 1: Process feedUrls[1] and competitors[1]
- ... continues until all feeds processed

---

### Node 4: Set Current Feed Variables

**Type**: `n8n-nodes-base.set`
**Version**: 3.4
**Position**: [928, 32]

**Configuration**:
```json
{
  "parameters": {
    "assignments": {
      "assignments": [
        {
          "id": "1",
          "name": "currentFeedUrl",
          "value": "={{ $json.feedUrls[$('Loop Over Feeds').context.currentRunIndex] }}",
          "type": "string"
        },
        {
          "id": "2",
          "name": "currentCompetitor",
          "value": "={{ $json.competitors[$('Loop Over Feeds').context.currentRunIndex] }}",
          "type": "string"
        }
      ]
    },
    "options": {}
  }
}
```

**Purpose**: Extracts the current competitor's feed URL and name based on loop iteration.

**Variables Created**:
- **currentFeedUrl**: RSS feed URL for current competitor
- **currentCompetitor**: Display name for current competitor

**Expression Breakdown**:
- `$('Loop Over Feeds').context.currentRunIndex`: Gets current iteration number (0, 1, 2, etc.)
- `$json.feedUrls[...]`: Accesses the feed URL array at current index
- `$json.competitors[...]`: Accesses the competitor name array at current index

**Output**: Two string variables accessible in downstream nodes

---

### Node 5: Fetch RSS Feed

**Type**: `n8n-nodes-base.rssFeedRead`
**Version**: 1
**Position**: [1152, 32]

**Configuration**:
```json
{
  "parameters": {
    "url": "={{ $json.currentFeedUrl }}",
    "options": {}
  }
}
```

**Purpose**: Fetches RSS feed content from the current competitor's blog.

**Input**: `currentFeedUrl` from previous node

**Output**: Array of RSS items, each containing:
```json
{
  "title": "Blog post title",
  "link": "https://competitor.com/blog/post-url",
  "pubDate": "2025-11-19T10:30:00Z",
  "creator": "Author Name",
  "content": "Full HTML content of the post",
  "contentSnippet": "Plain text excerpt",
  "guid": "unique-post-id",
  "isoDate": "2025-11-19T10:30:00.000Z"
}
```

**Standard RSS Fields Captured**:
- `title`: Post headline
- `link`: Canonical URL to the post
- `pubDate`: Publication date/time
- `content`: Full post HTML (if available)
- `contentSnippet`: Plain text summary
- `guid`: Unique identifier

**Error Handling**:
- If feed URL is invalid or unreachable, node fails
- Error message indicates which feed failed
- Loop continues to next competitor

---

### Node 6: Filter New Posts (24h)

**Type**: `n8n-nodes-base.filter`
**Version**: 2
**Position**: [1376, 32]

**Configuration**:
```json
{
  "parameters": {
    "conditions": {
      "dateTime": [
        {
          "value1": "={{ $json.pubDate }}",
          "operation": "afterOrEquals",
          "value2": "={{ $now.minus({days: 1}).toISO() }}"
        }
      ]
    },
    "options": {}
  }
}
```

**Purpose**: Filters RSS items to only include posts published in the last 24 hours.

**Filter Logic**:
- **Condition**: `pubDate >= (current time - 24 hours)`
- **Comparison**: DateTime afterOrEquals operation
- **Value1**: Publication date from RSS feed
- **Value2**: Current time minus 1 day (dynamically calculated)

**Date Calculation Breakdown**:
- `$now`: Current execution time
- `.minus({days: 1})`: Subtract 24 hours
- `.toISO()`: Convert to ISO 8601 format

**Output**:
- **If posts found**: Array of new posts (can be 0 to N items)
- **If no new posts**: Empty array (execution stops for this feed, loop continues)

**Important**: This prevents reprocessing the same posts on subsequent runs.

---

### Node 7: Message a model (Gemini 2.5 Pro)

**Type**: `@n8n/n8n-nodes-langchain.googleGemini`
**Version**: 1
**Position**: [1600, 32]

**Configuration**:
```json
{
  "parameters": {
    "modelId": {
      "__rl": true,
      "value": "models/gemini-2.5-pro",
      "mode": "list",
      "cachedResultName": "models/gemini-2.5-pro"
    },
    "messages": {
      "values": [
        {
          "content": "=Analyze this blog post from competitor {{ $json.title }} and extract strategic insights.\n\nBLOG POST:\nTitle: {{ $json.title }}\nURL: {{ $json.link }}\nDate: {{ $json.pubDate }}\nContent:\n{{ $json.content || $json.contentSnippet }}\n\nPROVIDE ANALYSIS:\n\n# Post Summary\nSummarize the post in 2-3 sentences.\n\n# Strategic Insights\n- What does this reveal about their strategy?\n- What product/feature developments are mentioned?\n- What market positioning signals are present?\n- What customer pain points are they addressing?\n\n# Competitive Intelligence\n- Strengths revealed\n- Weaknesses or gaps identified\n- Opportunities for us\n- Threats to monitor\n\n# Key Takeaways\nList 3-5 actionable insights for our team.\n\nBe specific and focus on competitive intelligence value."
        }
      ]
    },
    "options": {
      "systemMessage": "=You are a competitive intelligence analyst for the Katalon Agent Factory system. Your role is to analyze competitor blog posts and RSS feed items to extract strategic insights, competitive intelligence, and actionable recommendations. [Full system prompt - see detailed version in README.md]"
    }
  }
}
```

**Purpose**: AI-powered competitive intelligence analysis of each blog post.

**Model**: `models/gemini-2.5-pro`

**Credentials**: Google Gemini (PaLM) API account

**System Prompt** (Abbreviated - Full version ~2,500 words):
```
You are a competitive intelligence analyst for the Katalon Agent Factory system.

Analysis Task:
- Analyze competitor blog posts and extract comprehensive competitive intelligence
- Your analysis must be thorough, strategic, and actionable

Analysis Framework:
1. Content Categorization (7 categories)
2. Strategic Intelligence Assessment
3. Competitive Analysis (Strengths, Weaknesses, Opportunities, Threats)
4. Priority & Value Assessment (Score 0-100)
5. Confidence Score (0-100)

Required Output Format: JSON only (no markdown, no explanations)
```

**User Message Template**:
- Competitor name from metadata
- Post title, URL, publication date
- Full content or content snippet
- Structured analysis request

**Connected Tools**:
- **HTTP Request Tool**: Fetches full article content if RSS feed only provides excerpts

**Token Usage** (Estimated per post):
- **Input**: 1,500-2,500 tokens (depends on article length)
- **Output**: 800-1,200 tokens
- **Total**: ~2,300-3,700 tokens per post
- **Cost**: ~$0.006-$0.010 per post

**Output**: Raw AI analysis text (markdown formatted)

---

### Node 8: Information Extractor

**Type**: `@n8n/n8n-nodes-langchain.informationExtractor`
**Version**: 1.2
**Position**: [1952, 32]

**Configuration**:
```json
{
  "parameters": {
    "text": "={{ $json.content.parts[0].text }}",
    "schemaType": "fromJson",
    "jsonSchemaExample": "{ ... }",
    "options": {}
  }
}
```

**Purpose**: Extracts structured JSON data from the AI analysis text.

**Input**: Raw text from Gemini 2.5 Pro analysis

**JSON Schema** (Structured Output):
```json
{
  "rss_item_analysis": {
    "categories": ["Product Launch", "Technical"],
    "priority_score": 85,
    "strategic_value": "High",
    "analysis_notes": "Brief 1-2 sentence summary"
  },
  "research_result": {
    "result_title": "Competitor Name - Post Topic",
    "executive_summary": "2-3 paragraph summary",
    "full_report": "## Post Summary\n\n...\n\n## Strategic Insights\n\n...",
    "key_findings": "• Finding 1\n• Finding 2\n...",
    "competitive_advantages": "Detailed analysis...",
    "weaknesses": "Detailed analysis...",
    "recommendations": "Specific, actionable recommendations...",
    "sources": "Blog Post: {{url}}\nPublished: {{date}}",
    "competitor_names": "{{competitor}}",
    "confidence_score": 85
  }
}
```

**Schema Validation**:
- Ensures all required fields are present
- Validates data types (strings, numbers, arrays)
- Ensures enums match allowed values
- Rejects malformed JSON

**Language Model**: Connected to Google Gemini Chat Model (Node 9)

**Output**: Validated JSON object matching the schema

**Error Handling**:
- If extraction fails, node throws error
- Error includes details about missing/invalid fields
- Can be retried with adjusted prompt

---

### Node 9: Google Gemini Chat Model

**Type**: `@n8n/n8n-nodes-langchain.lmChatGoogleGemini`
**Version**: 1
**Position**: [2032, 256]

**Configuration**:
```json
{
  "parameters": {
    "modelName": "models/gemini-2.5-pro",
    "options": {}
  }
}
```

**Purpose**: Provides the language model for the Information Extractor node.

**Connection**: Linked via AI Language Model connection to Information Extractor (Node 8)

**Model**: `models/gemini-2.5-pro`

**Credentials**: Google Gemini (PaLM) API account (same as Node 7)

**Usage**: Called automatically by Information Extractor for JSON extraction

**Cost**: Included in overall Gemini usage (minimal additional cost)

---

### Node 10: HTTP Request

**Type**: `n8n-nodes-base.httpRequestTool`
**Version**: 4.3
**Position**: [1680, 256]

**Configuration**:
```json
{
  "parameters": {
    "url": "={{ $json.link }}",
    "options": {}
  }
}
```

**Purpose**: Fetches full article content when RSS feed only provides excerpts.

**Connection**: Linked as AI Tool to Message a model (Node 7)

**Usage**: Gemini can invoke this tool automatically if it determines it needs full article content

**Input**: Blog post URL from RSS feed (`$json.link`)

**Output**: Full HTML content of the article

**Headers**: Default user-agent (can be customized)

**Timeout**: 30 seconds (default)

**Error Handling**:
- If URL is unreachable, returns error to AI
- AI can continue analysis with available RSS content

**Note**: This is an **AI Tool**, meaning the AI model decides when to use it, not every execution.

---

### Node 11: Create RSS Feed Item in Airtable

**Type**: `n8n-nodes-base.airtable`
**Version**: 2
**Position**: [2304, 32]

**Configuration**:
```json
{
  "parameters": {
    "operation": "create",
    "base": {
      "__rl": true,
      "value": "appELRlEUB59eOw3q",
      "mode": "list",
      "cachedResultName": "Katalon Agent Factory",
      "cachedResultUrl": "https://airtable.com/appELRlEUB59eOw3q"
    },
    "table": {
      "__rl": true,
      "value": "tblZvl7dTdrofmvPV",
      "mode": "list",
      "cachedResultName": "RSS Feed Items",
      "cachedResultUrl": "https://airtable.com/appELRlEUB59eOw3q/tblZvl7dTdrofmvPV"
    },
    "columns": {
      "mappingMode": "defineBelow",
      "value": {
        "Flagged": false
      }
    }
  }
}
```

**Purpose**: Creates a new record in Airtable with the analyzed blog post data.

**Credentials**: Airtable Personal Access Token account 2

**Base ID**: `appELRlEUB59eOw3q` (**REPLACE WITH YOUR BASE ID**)

**Table ID**: `tblZvl7dTdrofmvPV` (**REPLACE WITH YOUR TABLE ID**)

**Table Name**: "RSS Feed Items"

**Field Mappings** (16 fields - see AIRTABLE-SCHEMA.md for complete details):

| Airtable Field | Source | Expression |
|----------------|--------|------------|
| Item Title | RSS Feed | `{{ $('Fetch RSS Feed').item.json.title }}` |
| Competitor | Loop Variable | `{{ $('Set Current Feed Variables').item.json.currentCompetitor }}` |
| Post URL | RSS Feed | `{{ $('Fetch RSS Feed').item.json.link }}` |
| Published Date | RSS Feed | `{{ $('Fetch RSS Feed').item.json.pubDate }}` |
| Discovered Date | Workflow | `{{ $now }}` |
| Full Content | RSS Feed | `{{ $('Fetch RSS Feed').item.json.content }}` |
| Research Result | AI Analysis | `{{ $json.output.research_result.full_report }}` |
| Categories | AI Analysis | `{{ $json.output.rss_item_analysis.categories }}` |
| Priority Score | AI Analysis | `{{ $json.output.rss_item_analysis.priority_score }}` |
| Strategic Value | AI Analysis | `{{ $json.output.rss_item_analysis.strategic_value }}` |
| Notes | AI Analysis | `{{ $json.output.rss_item_analysis.analysis_notes }}` |
| Analysis Status | Static | "Analyzed" |
| Flagged | Static | false |

**Output**: Airtable record object with all fields and unique record ID

**Error Handling**:
- If base/table ID is wrong, throws authentication error
- If field name doesn't match, throws field validation error
- See TROUBLESHOOTING.md for common issues

---

### Node 12: Slack Notification

**Type**: `n8n-nodes-base.slack`
**Version**: 2.2
**Position**: [2528, 32]

**Configuration**:
```json
{
  "parameters": {
    "authentication": "oAuth2",
    "select": "channel",
    "channelId": {
      "__rl": true,
      "value": "C09TXR2N0CC",
      "mode": "list",
      "cachedResultName": "competitor-monitoring"
    },
    "text": "=📡 Agent 1B found new blog post from {{ $('Set Current Feed Variables').item.json.currentCompetitor }}\n\n📝 {{ $('Fetch RSS Feed').item.json.title }}\n🔗 {{ $('Fetch RSS Feed').item.json.link }}\n📅 Published: {{ $('Fetch RSS Feed').item.json.pubDate }}",
    "otherOptions": {}
  }
}
```

**Purpose**: Sends real-time Slack notification when new competitive intelligence is found.

**Credentials**: Slack OAuth2 account 3

**Channel ID**: `C09TXR2N0CC` (**REPLACE WITH YOUR CHANNEL ID**)

**Channel Name**: "competitor-monitoring" (configurable)

**Message Template**:
```
📡 Agent 1B found new blog post from [Competitor Name]

📝 [Post Title]
🔗 [Post URL]
📅 Published: [Publication Date]
```

**Message Variables**:
- Competitor: From Set Current Feed Variables node
- Title: From Fetch RSS Feed node
- URL: From Fetch RSS Feed node
- Date: From Fetch RSS Feed node

**Authentication**: OAuth2 (requires Slack app with correct scopes)

**Required Scopes**:
- `chat:write` - Send messages
- `channels:read` - Access public channels

**Webhook ID**: `b1444bc0-f4a7-4b80-8663-281642552a94`

**Output**: Slack message confirmation object

---

## Workflow Settings

```json
{
  "settings": {
    "saveExecutionProgress": true,
    "saveManualExecutions": true,
    "saveDataErrorExecution": "all",
    "saveDataSuccessExecution": "all",
    "executionTimeout": 3600,
    "timezone": "UTC",
    "callerPolicy": "workflowsFromSameOwner",
    "availableInMCP": false
  }
}
```

**Key Settings**:
- **Execution Timeout**: 3600 seconds (1 hour) - ample time for processing 5 feeds
- **Save Error Executions**: Yes - critical for debugging
- **Save Success Executions**: Yes - allows review of past analyses
- **Timezone**: UTC (adjust to your timezone if needed)
- **Caller Policy**: Only workflows from same owner can trigger

---

## Connections Map

```
Schedule Trigger → RSS Feed Array Setup
RSS Feed Array Setup → Loop Over Feeds
Loop Over Feeds → Set Current Feed Variables
Loop Over Feeds ⟲ Loop Over Feeds (loop back)
Set Current Feed Variables → Fetch RSS Feed
Fetch RSS Feed → Filter New Posts
Filter New Posts → Message a model
Message a model → Information Extractor
Information Extractor → Create RSS Feed Item
Create RSS Feed Item → Slack Notification
Google Gemini Chat Model ⟶ Information Extractor (AI Language Model)
HTTP Request ⟶ Message a model (AI Tool)
```

**Connection Types**:
- **→** Main data flow
- **⟲** Loop connection (back to same node)
- **⟶** AI tool/model connection (dashed line in UI)

---

## Performance Characteristics

### Execution Time (per run)

| Stage | Time (Estimate) |
|-------|----------------|
| Schedule Trigger | < 1 second |
| RSS Feed Setup | < 1 second |
| Loop Setup | < 1 second |
| **Per Competitor** (×5): | |
| - Set Variables | < 1 second |
| - Fetch RSS | 2-5 seconds |
| - Filter Posts | < 1 second |
| - AI Analysis (Gemini) | 8-15 seconds per post |
| - Extract JSON | 2-4 seconds |
| - Save to Airtable | 1-2 seconds |
| - Send Slack | 1-2 seconds |
| **Total (5 competitors, avg 2 new posts)** | **45-90 seconds** |

### Resource Usage

- **Memory**: ~50-100 MB
- **CPU**: Low (mostly I/O wait for API calls)
- **Network**: ~2-5 MB download per execution
- **Storage**: Minimal (n8n execution history)

### Scalability

- **Current**: 5 competitors
- **Recommended Max**: 10 competitors (execution time ~3-4 minutes)
- **Hard Limit**: 15 competitors (risk timeout at 1 hour)

**To monitor more competitors**: Deploy multiple workflow instances with different feed arrays.

---

## Error Handling

### Graceful Failures

The workflow is designed to continue even if individual components fail:

1. **RSS Feed Unreachable**: Loop continues to next competitor
2. **No New Posts**: Filter returns empty, execution ends gracefully for that feed
3. **AI Analysis Fails**: Error logged, no Airtable record created, loop continues
4. **Airtable Error**: Logged, but Slack notification may still succeed (or vice versa)

### Common Error Scenarios

See **TROUBLESHOOTING.md** for detailed error resolution.

---

## Customization Guide

### Adding More Competitors

**Edit Node 2 (RSS Feed Array Setup)**:
```javascript
feedUrls: [
  // ... existing 5 feeds
  "https://newcompetitor.com/blog/feed/",  // Add new feed
],
competitors: [
  // ... existing 5 names
  "New Competitor",  // Add matching name
]
```

### Changing Schedule

**Edit Node 1 (Schedule Trigger)**:
```json
{
  "field": "hours",
  "hoursInterval": 24  // Change to 12 for twice daily, 48 for every 2 days
}
```

Or use cron expression for specific times:
```json
{
  "field": "cronExpression",
  "expression": "0 2 * * *"  // Every day at 2:00 AM
}
```

### Changing Slack Channel

**Edit Node 12 (Slack Notification)**:
1. Click the channel dropdown
2. Select different channel
3. Or enter channel ID directly

### Adjusting Time Window

**Edit Node 6 (Filter)**:
```javascript
// For 48 hours instead of 24:
$now.minus({days: 2}).toISO()

// For 12 hours:
$now.minus({hours: 12}).toISO()

// For 1 week:
$now.minus({weeks: 1}).toISO()
```

---

## Testing Guide

### Manual Test Execution

1. **Deactivate** the workflow (disable schedule)
2. Click **"Execute Workflow"** button
3. Review execution in bottom panel
4. Check each node for successful execution (green checkmark)
5. Verify Airtable record created
6. Verify Slack message sent

### Test With Single Competitor

**Temporary Edit to Node 2**:
```javascript
feedUrls: [
  "https://fetchrss.com/feed/aN28Dl7HwYMCaN27bKhc7_Ky.rss"  // Only one
],
competitors: [
  "Test Competitor"
]
```

This reduces execution time for faster testing.

### Debugging Individual Nodes

1. **Click node** to select
2. **Click "Execute Node"** (play button icon)
3. Review input/output data
4. Check for error messages

---

## Version History

- **V4.0** (Current): Multi-feed loop architecture, Gemini 2.5 Pro, Information Extractor
- **V3.0**: (Not documented - transition version)
- **V2.0**: Single-feed, basic analysis, manual JSON extraction
- **V1.0**: Original RSS monitor, minimal AI analysis

---

**Documentation**: Complete
**Last Updated**: November 19, 2025
**Maintained By**: KAF Team
