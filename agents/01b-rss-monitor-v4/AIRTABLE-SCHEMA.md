# Airtable Schema Documentation
## Agent-1B V4: Multi-Feed RSS Monitor

**Base Name**: Katalon Agent Factory
**Base ID**: `appELRlEUB59eOw3q` *(Replace with your Base ID)*
**Table Name**: RSS Feed Items
**Table ID**: `tblZvl7dTdrofmvPV` *(Replace with your Table ID)*

---

## Overview

This table stores all competitor blog posts discovered by Agent-1B V4, along with comprehensive AI-powered competitive intelligence analysis for each post.

### Table Purpose

- **Primary Use**: Competitive intelligence repository
- **Data Source**: Automated RSS feed monitoring + AI analysis
- **Update Frequency**: Real-time (as new posts are published)
- **Retention**: Indefinite (recommended: archive after 12 months)

---

## Table Schema

### Complete Field List (16 Fields)

| Field Name | Field Type | Required | Description |
|------------|------------|----------|-------------|
| Item Title | Single Line Text | Yes | Blog post headline/title |
| RSS Feed Source | Multiple Select | No | *Deprecated - Not used in V4* |
| Competitor | Single Line Text | Yes | Competitor company name |
| Post URL | URL | Yes | Canonical link to blog post |
| Published Date | Date & Time | Yes | When post was published by competitor |
| Discovered Date | Date & Time | Yes | When Agent-1B found the post |
| Content Snippet | Long Text | No | RSS excerpt (plain text) |
| Full Content | Long Text | No | Complete article text (HTML or plain) |
| Author | Single Line Text | No | Post author name |
| Categories | Multiple Select | Yes | Content categorization (AI-determined) |
| Analysis Status | Single Select | Yes | Processing workflow status |
| Priority Score | Number (Integer) | Yes | AI-assigned priority (0-100) |
| Research Result | Long Text | Yes | Full competitive intelligence analysis |
| Strategic Value | Single Select | Yes | Business value assessment |
| Flagged | Checkbox | No | Manual flag for follow-up |
| Notes | Long Text | No | Team notes/comments |

---

## Field Specifications

### 1. Item Title
**Type**: Single Line Text
**Required**: Yes
**Max Length**: 255 characters

**Purpose**: Stores the blog post headline/title from RSS feed.

**Source**: `{{ $('Fetch RSS Feed').item.json.title }}`

**Example Values**:
- "Introducing AI-Powered Test Automation"
- "Q4 2025 Product Updates"
- "How DevOps Teams are Scaling Testing"

**Validation**: None

**Use Case**: Primary identifier for posts in list/grid views

---

### 2. RSS Feed Source
**Type**: Multiple Select
**Required**: No

**Status**: ⚠️ **DEPRECATED** - Not used in V4

**Note**: This field exists from V2 but is not populated by V4 workflow. Safe to hide or delete.

---

### 3. Competitor
**Type**: Single Line Text
**Required**: Yes
**Max Length**: 100 characters

**Purpose**: Identifies which competitor published this post.

**Source**: `{{ $('Set Current Feed Variables').item.json.currentCompetitor }}`

**Configured In**: Node 2 (RSS Feed Array Setup) - `competitors` array

**Example Values**:
- "Selenium"
- "Testsigma"
- "BrowserStack"
- "Ranorex"
- "Tricentis"

**Validation**: Must match a value from the `competitors` array in workflow configuration

**Use Case**:
- Filter/group by competitor
- Competitor-specific views
- Trend analysis per competitor

---

### 4. Post URL
**Type**: URL
**Required**: Yes

**Purpose**: Direct link to the original blog post.

**Source**: `{{ $('Fetch RSS Feed').item.json.link }}`

**Example Values**:
- "https://www.selenium.dev/blog/2025/ai-automation/"
- "https://testsigma.com/blog/devops-best-practices/"

**Validation**: Must be valid HTTP/HTTPS URL

**Use Case**:
- Quick access to source content
- Link sharing with team
- Citation in reports

**Display**: Automatically rendered as clickable hyperlink in Airtable

---

### 5. Published Date
**Type**: Date & Time
**Required**: Yes
**Format**: ISO 8601 (YYYY-MM-DDTHH:MM:SSZ)
**Timezone**: UTC

**Purpose**: Original publication timestamp from competitor.

**Source**: `{{ $('Fetch RSS Feed').item.json.pubDate }}`

**Example Values**:
- "2025-11-19T14:30:00Z"
- "2025-11-18T09:15:00Z"

**Validation**: Must be valid ISO 8601 datetime

**Use Case**:
- Chronological sorting
- Time-based filtering (e.g., "Last 7 days")
- Trend analysis (posting frequency)

**Important**: This is when competitor *published* the post, not when we discovered it (see Discovered Date).

---

### 6. Discovered Date
**Type**: Date & Time
**Required**: Yes
**Format**: ISO 8601 (YYYY-MM-DDTHH:MM:SSZ)
**Timezone**: UTC

**Purpose**: When Agent-1B workflow detected this post.

**Source**: `{{ $now }}` (workflow execution time)

**Example Values**:
- "2025-11-19T15:00:00Z" (workflow ran at 3 PM UTC)

**Validation**: Automatically populated

**Use Case**:
- Track detection latency (Discovered Date - Published Date)
- Audit workflow execution history
- Performance monitoring

**Note**: Should always be >= Published Date (though RSS feeds sometimes have incorrect timestamps)

---

### 7. Content Snippet
**Type**: Long Text
**Required**: No
**Max Length**: 100,000 characters

**Purpose**: Plain text excerpt from RSS feed (typically first 200-500 words).

**Source**: RSS feed's `contentSnippet` or `description` field

**Example**:
```
In this post, we explore how modern DevOps teams are leveraging
AI-powered automation to scale their testing efforts. Traditional
approaches to test automation often require...
```

**Validation**: None

**Use Case**:
- Quick preview without opening full post
- Search/filter on keywords
- Fallback if Full Content unavailable

**Note**: Not all RSS feeds provide this field. Some only provide Full Content.

---

### 8. Full Content
**Type**: Long Text
**Required**: No
**Max Length**: 100,000 characters

**Purpose**: Complete article content (HTML or plain text).

**Source**:
- Primary: `{{ $('Fetch RSS Feed').item.json.content }}`
- Fallback: HTTP Request Tool fetches from Post URL

**Example** (HTML):
```html
<h1>Introducing AI-Powered Test Automation</h1>
<p>We're excited to announce...</p>
<img src="..." alt="Product screenshot" />
<h2>Key Features</h2>
<ul><li>AI test generation</li>...</ul>
```

**Validation**: None

**Use Case**:
- Full text search
- Detailed manual review
- AI analysis input (if RSS doesn't provide enough context)

**Note**: May contain HTML tags - use Airtable's rich text formatting to display properly.

---

### 9. Author
**Type**: Single Line Text
**Required**: No
**Max Length**: 100 characters

**Purpose**: Blog post author name.

**Source**: `{{ $('Fetch RSS Feed').item.json.creator }}` or `{{ $('Fetch RSS Feed').item.json.author }}`

**Example Values**:
- "John Smith"
- "Jane Doe, Director of Product"
- "Engineering Team"

**Validation**: None

**Use Case**:
- Track which competitor team members are publishing
- Identify thought leaders
- Pattern analysis (e.g., "CTO always announces major features")

**Note**: Not all RSS feeds provide author information.

---

### 10. Categories
**Type**: Multiple Select
**Required**: Yes
**Options**:
1. Product Launch
2. Feature Update
3. Company News
4. Technical
5. Customer Story
6. Industry Insights
7. Thought Leadership

**Purpose**: AI-determined content classification (can select multiple).

**Source**: `{{ $json.output.rss_item_analysis.categories }}`

**AI Selection Criteria**:
- **Product Launch**: New product announcements, major releases
- **Feature Update**: Enhancements to existing products
- **Company News**: Funding, partnerships, acquisitions, events
- **Technical**: Deep dives, architecture, engineering blogs
- **Customer Story**: Case studies, testimonials, use cases
- **Industry Insights**: Market analysis, trend commentary
- **Thought Leadership**: Opinion pieces, predictions, frameworks

**Example**:
- Post about new AI feature: `["Product Launch", "Technical"]`
- Industry trends article: `["Industry Insights", "Thought Leadership"]`
- Customer case study: `["Customer Story"]`

**Validation**: Must be one or more of the 7 predefined options

**Use Case**:
- Filter by content type
- Trend analysis (e.g., "Competitor X publishes 3x more product launches than us")
- Alert rules (e.g., "Notify immediately for Product Launch category")

---

### 11. Analysis Status
**Type**: Single Select
**Required**: Yes
**Options**:
1. Pending
2. Analyzed
3. Skipped
4. Error

**Purpose**: Tracks workflow processing status.

**Source**: Hardcoded in workflow to "Analyzed" when successfully processed

**Values**:
- **Pending**: *(Not used in V4 - automated workflow)*
- **Analyzed**: AI analysis completed successfully
- **Skipped**: Post filtered out (e.g., older than 24 hours on subsequent runs)
- **Error**: Workflow failed during processing

**Default Value**: "Analyzed" (for all successful V4 executions)

**Use Case**:
- Troubleshooting failed executions
- Quality assurance checks
- Workflow monitoring

---

### 12. Priority Score
**Type**: Number (Integer)
**Required**: Yes
**Min**: 0
**Max**: 100
**Precision**: Whole numbers only

**Purpose**: AI-assigned urgency/importance rating.

**Source**: `{{ $json.output.rss_item_analysis.priority_score }}`

**Scoring Guide** (AI-determined):
- **90-100**: Critical strategic intelligence, immediate action required
- **70-89**: High value, significant competitive implications
- **50-69**: Moderate value, worth monitoring
- **30-49**: Low priority, general awareness
- **0-29**: Minimal strategic value

**Example Scores**:
- Major product launch: 92
- Feature update: 68
- General blog post: 45
- Corporate event announcement: 22

**Validation**: Must be integer between 0-100

**Use Case**:
- Sort by priority
- Create views (e.g., "High Priority" filtered >= 70)
- SLA tracking (e.g., "Review Priority 90+ within 4 hours")
- Alert thresholds

**Formula Field Example** (Priority Category):
```
IF({Priority Score} >= 90, "🔥 Critical",
IF({Priority Score} >= 70, "⚠️ High",
IF({Priority Score} >= 50, "📊 Medium", "📋 Low")))
```

---

### 13. Research Result
**Type**: Long Text
**Required**: Yes
**Max Length**: 100,000 characters
**Format**: Markdown

**Purpose**: Complete AI-generated competitive intelligence analysis.

**Source**: `{{ $json.output.research_result.full_report }}`

**Content Structure**:
```markdown
## Post Summary

[2-3 sentence summary of the blog post]

## Strategic Insights

- What this reveals about their strategy
- Product/feature developments mentioned
- Market positioning signals
- Customer pain points addressed
- Technology or methodology highlights

## Competitive Intelligence

### Strengths Revealed
- Specific strengths and advantages they're demonstrating
- What they're doing well
- Competitive advantages they're claiming

### Weaknesses & Gaps Identified
- Limitations or constraints mentioned
- Gaps in their approach
- Areas where they're vulnerable
- Challenges they're facing

### Opportunities for Us
- How we can capitalize on this intelligence
- Differentiation opportunities
- Market gaps we can exploit
- Counter-positioning strategies

### Threats to Monitor
- Competitive risks this poses
- Areas where they're gaining advantage
- Trends that could impact our position

## Key Takeaways

1. First major actionable insight
2. Second major actionable insight
3. Third major actionable insight
4. Fourth major actionable insight
5. Fifth major actionable insight

## Recommended Actions

- Specific next steps for product team
- Specific next steps for marketing team
- Specific next steps for sales team
- Monitoring or research tasks
```

**Length**: Typically 1,000-3,000 words

**Validation**: None (free-form markdown)

**Use Case**:
- In-depth competitive analysis review
- Share with stakeholders
- Export to reports/presentations
- Search for specific intelligence

**Display Tip**: Use Airtable's "Expand" button to read in a larger modal window.

---

### 14. Strategic Value
**Type**: Single Select
**Required**: Yes
**Options**:
1. High
2. Medium
3. Low
4. None

**Purpose**: Business value assessment (different from Priority Score).

**Source**: `{{ $json.output.rss_item_analysis.strategic_value }}`

**Selection Criteria** (AI-determined):
- **High**: Major product launches, strategic shifts, direct competitive threats
- **Medium**: Feature updates, market positioning, thought leadership
- **Low**: General blog posts, minor updates, industry commentary
- **None**: Corporate fluff, irrelevant content (rare in filtered results)

**Example**:
- New AI product launch: "High"
- Thought leadership on DevOps trends: "Medium"
- Company holiday party announcement: "None"

**Validation**: Must be one of the 4 options

**Use Case**:
- Create "High Strategic Value" view for executive reviews
- Filter out noise ("None" value)
- Prioritize manual review efforts

**Difference from Priority Score**:
- **Priority Score**: Urgency/importance (0-100 scale)
- **Strategic Value**: Long-term business impact (categorical)

---

### 15. Flagged
**Type**: Checkbox
**Required**: No
**Default**: Unchecked (false)

**Purpose**: Manual flag for items requiring follow-up or special attention.

**Source**: Hardcoded to `false` in workflow (unchecked by default)

**Usage**: Team members manually check this box after reviewing

**Use Case**:
- Flag posts for deeper research
- Mark items for battle card updates
- Indicate action items created
- Create "Follow-up Required" view

**Automation Idea**: Set up Airtable automation to notify team when flagged

---

### 16. Notes
**Type**: Long Text
**Required**: No
**Max Length**: 100,000 characters

**Purpose**: Team comments, observations, action items.

**Source**: `{{ $json.output.rss_item_analysis.analysis_notes }}` (AI summary) + manual additions

**AI-Generated Notes**: 1-2 sentence summary of why this post matters

**Manual Notes**: Team members can add their own observations

**Example**:
```
AI: "Major product launch with AI capabilities - direct competitive threat"

[Manual addition by Product Manager]
Action: Review our AI roadmap in next sprint planning.
Competitive angle: They're targeting same customer segment.
Response: Accelerate our AI feature development by 2 sprints.
```

**Validation**: None

**Use Case**:
- Document team discussions
- Track action items
- Link to related internal docs/tickets

---

## Table Views (Recommended)

### View 1: All Items (Default)
**Sort**: Published Date (newest first)
**Filter**: None
**Columns**: All visible

---

### View 2: High Priority Intelligence
**Sort**: Priority Score (highest first)
**Filter**: Priority Score >= 70
**Columns**: Competitor, Item Title, Priority Score, Strategic Value, Categories, Published Date
**Color Coding**:
- Red: Priority >= 90
- Orange: Priority 70-89

---

### View 3: By Competitor
**Group By**: Competitor
**Sort**: Published Date (newest first) within each group
**Filter**: Published Date (last 30 days)
**Columns**: Item Title, Priority Score, Categories, Published Date

---

### View 4: Needs Review
**Filter**:
- Analysis Status = "Analyzed"
- AND Priority Score >= 70
- AND Flagged = Unchecked
**Sort**: Priority Score (highest first)
**Use**: Daily review queue for team

---

### View 5: Product Launches Only
**Filter**: Categories contains "Product Launch"
**Sort**: Published Date (newest first)
**Columns**: Competitor, Item Title, Priority Score, Strategic Value, Published Date, Post URL

---

### View 6: Flagged for Follow-up
**Filter**: Flagged = Checked
**Sort**: Published Date (newest first)
**Columns**: All

---

## Automations (Recommended)

### Automation 1: High Priority Alerts
**Trigger**: When record is created
**Condition**: Priority Score >= 85
**Action**: Send email to competitive-intel@company.com with post details

---

### Automation 2: Weekly Digest
**Trigger**: Scheduled (every Monday 9:00 AM)
**Action**: Send email with summary of all posts from past week

---

### Automation 3: Flag Notification
**Trigger**: When Flagged changes to Checked
**Action**: Notify in Slack #competitive-intel channel

---

## Interface (Recommended)

### Competitive Intelligence Dashboard

**Layout**:
- **Section 1**: Stats
  - Total posts this week
  - High priority count
  - By competitor breakdown
- **Section 2**: High Priority List (Priority >= 70)
- **Section 3**: Recent Activity (last 7 days)
- **Section 4**: By Category Grid

**Access**: Share with Product, Marketing, Sales teams

---

## Data Retention Policy

### Recommended:
- **Keep Active**: Last 6 months (readily accessible)
- **Archive**: 6-12 months ago (separate base)
- **Delete**: > 12 months old (unless flagged)

### Archival Process:
1. Create "RSS Feed Items - Archive" table
2. Monthly automation moves records older than 6 months
3. Original table stays performant

---

## Getting Your Base ID and Table ID

### Method 1: Airtable URL
When viewing your table, the URL is:
```
https://airtable.com/appXXXXXXXXXXXXXX/tblYYYYYYYYYYYYYY/viwZZZZZZZZZZZZZZ
                     ├──────Base ID────┤ ├───Table ID────┤ ├──View ID───┤
```

### Method 2: API Documentation Page
1. Go to https://airtable.com/api
2. Select your base
3. Base ID and Table IDs are shown in code examples

### Method 3: n8n Credential Test
1. Configure Airtable credential in n8n
2. Test connection
3. Browse available bases and tables (IDs displayed in dropdowns)

---

## Field Mapping in n8n

When configuring the Airtable Create node in n8n, use these mappings:

```json
{
  "Item Title": "={{ $('Fetch RSS Feed').item.json.title }}",
  "Competitor": "={{ $('Set Current Feed Variables').item.json.currentCompetitor }}",
  "Post URL": "={{ $('Fetch RSS Feed').item.json.link }}",
  "Published Date": "={{ $('Fetch RSS Feed').item.json.pubDate }}",
  "Discovered Date": "={{ $now }}",
  "Content Snippet": "={{ $('Fetch RSS Feed').item.json.contentSnippet }}",
  "Full Content": "={{ $('Fetch RSS Feed').item.json.content }}",
  "Author": "={{ $('Fetch RSS Feed').item.json.creator }}",
  "Categories": "={{ $json.output.rss_item_analysis.categories }}",
  "Analysis Status": "Analyzed",
  "Priority Score": "={{ $json.output.rss_item_analysis.priority_score }}",
  "Research Result": "={{ $json.output.research_result.full_report }}",
  "Strategic Value": "={{ $json.output.rss_item_analysis.strategic_value }}",
  "Flagged": false,
  "Notes": "={{ $json.output.rss_item_analysis.analysis_notes }}"
}
```

---

## Troubleshooting

### Issue: Field not found error
**Cause**: Field name in Airtable doesn't match n8n mapping exactly
**Solution**:
1. Check spelling and capitalization (case-sensitive)
2. Verify no extra spaces in field names
3. Recreate field if necessary (must match exactly)

### Issue: Invalid data type error
**Cause**: Sending wrong data type to field (e.g., text to number field)
**Solution**: Check field type in Airtable matches data being sent

### Issue: Required field empty
**Cause**: Source data from workflow is null/undefined
**Solution**: Add default value in n8n expression (e.g., `|| 'Unknown'`)

See **TROUBLESHOOTING.md** for more details.

---

**Schema Version**: 1.0 (V4)
**Last Updated**: November 19, 2025
**Maintained By**: KAF Team
