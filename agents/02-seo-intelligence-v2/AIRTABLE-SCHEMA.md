# Agent-2 SEO Intelligence V2 - Airtable Schema

## Overview

**Base Name:** Katalon Agent Factory (KAF)
**Table Name:** Competitor SEO Analysis
**Primary Use:** Store weekly SEO competitive intelligence and strategic recommendations
**Records per Month:** ~20 (5 competitors × 4 weeks)
**Retention Period:** 12 months (rolling)

---

## Table Schema

### Field Summary

| # | Field Name | Type | Purpose | Required |
|---|------------|------|---------|----------|
| 1 | Competitor Name | Single line text | Competitor identifier | ✅ |
| 2 | Analysis Date | Date & time | When analysis was performed | ✅ |
| 3 | Executive Summary | Long text | High-level findings | ✅ |
| 4 | Content Strategy Overview | Long text | Content approach summary | ✅ |
| 5 | Content Types | Long text | Types of content published | ✅ |
| 6 | Top Performing Topics | Long text | Topics driving traffic | ✅ |
| 7 | Content Depth Score | Single line text | Quality rating (1-10) | ✅ |
| 8 | Organic Visibility | Long text | Search visibility assessment | ✅ |
| 9 | Top Keywords | Long text | Keywords they rank for | ✅ |
| 10 | Domain Authority | Single line text | DA score or estimate | ✅ |
| 11 | SERP Features | Long text | Owned SERP features | ✅ |
| 12 | Traffic Estimate | Single line text | Monthly organic traffic | ✅ |
| 13 | Content Gaps (JSON) | Long text | Structured JSON of opportunities | ✅ |
| 14 | Content Tactics (JSON) | Long text | Recommended content actions | ✅ |
| 15 | SEO Tactics (JSON) | Long text | Recommended SEO actions | ✅ |
| 16 | Competitive Threats (JSON) | Long text | Threats from competitor | ✅ |
| 17 | Katalon Advantages (JSON) | Long text | Exploitable weaknesses | ✅ |
| 18 | Strategic Priority Score | Number | Importance rating (1-100) | ✅ |
| 19 | Analysis Confidence | Single select | Data quality indicator | ✅ |
| 20 | Data Freshness | Single line text | Recency of research | ✅ |
| 21 | Review Frequency | Single select | How often to re-analyze | ✅ |
| 22 | Workflow Execution ID | Single line text | n8n execution reference | ✅ |
| 23 | Status | Single select | Analysis lifecycle state | ✅ |
| 24 | Assigned To | User | Team member responsible | ❌ |
| 25 | Action Items | Long text | Follow-up tasks | ❌ |
| 26 | Notes | Long text | Additional observations | ❌ |
| 27 | Last Modified | Last modified time | Auto-tracked | Auto |
| 28 | Created Time | Created time | Auto-tracked | Auto |

---

## Detailed Field Specifications

### 1. Competitor Name
**Type:** Single line text
**Max Length:** 100 characters
**Format:** Title case (e.g., "Selenium", "Cypress")
**Purpose:** Primary identifier for competitor

**Validation Rules:**
- Must match competitor list in workflow
- No duplicates within same week
- Case-sensitive

**Example Values:**
```
Selenium
Cypress
Playwright
TestCafe
Puppeteer
```

**Usage Notes:**
- Used as filter in views
- Primary grouping field for trend analysis
- Should match exactly across all analyses

---

### 2. Analysis Date
**Type:** Date & time
**Format:** ISO 8601 (YYYY-MM-DDTHH:mm:ss.sssZ)
**Timezone:** UTC
**Purpose:** Timestamp when analysis was performed

**Validation Rules:**
- Must be within last 7 days (for weekly schedule)
- Cannot be in future
- Required for all records

**Example Value:**
```
2025-11-19T09:03:45.123Z
```

**Usage Notes:**
- Used for chronological sorting
- Enables trend analysis over time
- Helps identify stale data

---

### 3. Executive Summary
**Type:** Long text
**Max Length:** 5,000 characters
**Format:** Plain text (2-3 paragraphs)
**Purpose:** High-level synthesis of key findings

**Content Requirements:**
- 2-3 paragraphs (200-400 words)
- Strategic implications for Katalon
- Key competitive insights
- Recommended actions summary

**Example Content:**
```
Selenium continues to dominate organic search visibility for "web automation"
and related terms, maintaining strong domain authority and consistent content
publishing. Their blog publishes 2-3 technical tutorials weekly, focusing on
advanced WebDriver techniques and integration guides. However, they show
significant gaps in modern testing topics like AI-assisted testing, visual
regression, and API testing automation.

Key competitive threat: Selenium's strong community engagement drives 60% of
their backlinks, creating sustainable SEO advantage. They own featured snippets
for 12+ high-value keywords in the testing automation space.

Primary opportunity for Katalon: Target content gaps around modern testing
approaches (AI, visual, API) where Selenium has minimal presence. Their content
depth scores average 6/10, indicating opportunity for more comprehensive guides.
```

**Usage Notes:**
- First field read by stakeholders
- Should be actionable, not just descriptive
- Include both threats and opportunities

---

### 4. Content Strategy Overview
**Type:** Long text
**Max Length:** 3,000 characters
**Format:** Plain text with bullet points
**Purpose:** Summary of competitor's content approach

**Content Requirements:**
- Content types used (blogs, guides, videos, etc.)
- Publishing frequency and consistency
- Target audience and personas
- Content distribution channels

**Example Content:**
```
Content Types:
• Technical tutorials (60% of content)
• Integration guides (25%)
• Release notes and updates (10%)
• Webinars and video content (5%)

Publishing Frequency:
• Blog: 2-3 posts per week
• Video: 1-2 per month
• Webinars: Monthly

Content Characteristics:
• Highly technical, developer-focused
• Code-heavy with working examples
• Step-by-step implementation guides
• Strong focus on open-source community

Distribution:
• Primary: selenium.dev blog
• Secondary: Dev.to, Medium crossposting
• Social: Twitter, Reddit r/selenium
```

**Usage Notes:**
- Informs Katalon content strategy
- Identifies successful patterns to emulate
- Reveals gaps in competitor approach

---

### 5. Content Types
**Type:** Long text
**Max Length:** 1,000 characters
**Format:** Comma-separated list
**Purpose:** Catalog of content formats competitor uses

**Example Values:**
```
Technical tutorials, Integration guides, API documentation, Video tutorials,
Webinars, Case studies, Best practices guides, Release notes, Community spotlights
```

**Usage Notes:**
- Helps identify format diversity
- Shows investment in different content types
- Informs Katalon content mix decisions

---

### 6. Top Performing Topics
**Type:** Long text
**Max Length:** 2,000 characters
**Format:** Comma-separated list with context
**Purpose:** Topics driving most organic traffic

**Example Content:**
```
WebDriver automation (highest traffic), Selenium Grid setup and configuration,
Cross-browser testing strategies, CI/CD integration with Jenkins, Headless
browser testing, Page Object Model patterns, Selenium with Python tutorials,
Docker containerization for Selenium, Mobile web testing, Test data management
```

**Usage Notes:**
- Identifies proven traffic drivers
- Shows market demand for topics
- Reveals content opportunities for Katalon
- Should be monitored for trend changes

---

### 7. Content Depth Score
**Type:** Single line text
**Max Length:** 50 characters
**Format:** "X/10" with brief justification
**Purpose:** Quality assessment of content depth

**Scoring Guide:**
- 9-10: Exceptionally comprehensive, industry-leading
- 7-8: High quality, detailed coverage
- 5-6: Adequate depth, room for improvement
- 3-4: Surface-level, lacking detail
- 1-2: Minimal depth, low quality

**Example Values:**
```
7/10 - Detailed technical content but lacks strategic context
6/10 - Good examples but needs more real-world scenarios
8/10 - Comprehensive tutorials with excellent code samples
```

**Usage Notes:**
- Helps identify quality benchmarks
- Shows where Katalon can differentiate
- Tracks quality improvements over time

---

### 8. Organic Visibility
**Type:** Long text
**Max Length:** 2,000 characters
**Format:** Plain text with metrics
**Purpose:** Assessment of search engine visibility

**Content Requirements:**
- Estimated visibility score or metrics
- Ranking positions for key terms
- SERP coverage (pages ranking in top 10)
- Trending visibility (up/down/stable)

**Example Content:**
```
Organic Visibility: High (estimated 85/100)

Key Metrics:
• 150+ keywords ranking in top 10 positions
• 45+ keywords in positions 1-3
• Domain visibility trending upward (+12% vs. last quarter)
• Strong presence in "web automation" and "selenium testing" clusters

Top Position Keywords:
• "selenium webdriver" - Position 1
• "selenium grid" - Position 2
• "selenium tutorial" - Position 1
• "browser automation" - Position 3

Visibility Trends:
• Growing: Mobile testing, CI/CD integration topics
• Stable: Core Selenium documentation
• Declining: Legacy WebDriver protocol content
```

**Usage Notes:**
- Benchmarks competitive positioning
- Identifies high-value keyword opportunities
- Tracks visibility trends over time

---

### 9. Top Keywords
**Type:** Long text
**Max Length:** 3,000 characters
**Format:** Comma-separated list (prioritized)
**Purpose:** Keywords competitor ranks well for

**Example Content:**
```
selenium webdriver, selenium tutorial, selenium grid, browser automation,
web automation testing, selenium python, selenium java, cross browser testing,
headless browser testing, selenium docker, selenium best practices,
page object model, selenium wait strategies, selenium locators,
selenium framework, selenium ci cd, selenium jenkins integration,
selenium parallel testing, selenium test automation, selenium ide
```

**Categorization:**
- Primary keywords (positions 1-3)
- Secondary keywords (positions 4-10)
- Opportunity keywords (positions 11-20)

**Usage Notes:**
- Informs Katalon keyword targeting
- Identifies direct competitive keywords
- Shows semantic clustering patterns
- Updated weekly for trend tracking

---

### 10. Domain Authority
**Type:** Single line text
**Max Length:** 100 characters
**Format:** Score with date (e.g., "DA 75 (Nov 2025)")
**Purpose:** SEO authority indicator

**Scoring:**
- DA 90-100: Extremely authoritative (rare)
- DA 70-89: High authority
- DA 50-69: Moderate authority
- DA 30-49: Developing authority
- DA 0-29: Low authority

**Example Values:**
```
DA 78 (Nov 2025) - High authority, 15K+ backlinks
DA 65 (Nov 2025) - Growing authority, strong community
DA 82 (Nov 2025) - Established leader, Microsoft backing
```

**Usage Notes:**
- Context for ranking competition difficulty
- Tracks authority changes over time
- Informs link building priorities

---

### 11. SERP Features
**Type:** Long text
**Max Length:** 1,500 characters
**Format:** Comma-separated list with counts
**Purpose:** Catalog of owned SERP features

**SERP Feature Types:**
- Featured Snippets
- People Also Ask (PAA)
- Video carousels
- Image packs
- Site links
- Knowledge panels

**Example Content:**
```
Featured Snippets: 12 (selenium webdriver setup, selenium wait types,
selenium vs cypress, selenium grid configuration, etc.)

People Also Ask: 25+ questions answered

Video Results: 8 video carousels (tutorial content)

Image Pack: 3 (selenium architecture diagrams)

Site Links: Yes (main navigation + popular pages)

Knowledge Panel: No (open source project, no entity)

Rich Results:
• FAQ schema on documentation pages
• HowTo schema on tutorial pages
• Article schema on blog posts
```

**Usage Notes:**
- Shows SERP dominance level
- Identifies schema opportunities
- Tracks feature wins/losses over time

---

### 12. Traffic Estimate
**Type:** Single line text
**Max Length:** 150 characters
**Format:** Monthly estimate with source
**Purpose:** Quantify organic traffic volume

**Example Values:**
```
450K-550K monthly visits (Ahrefs estimate, Nov 2025)
1.2M-1.5M monthly visits (SimilarWeb, Nov 2025)
300K-400K monthly visits (SEMrush, Nov 2025)
```

**Usage Notes:**
- Provides competitive context
- Shows traffic trends (growth/decline)
- Helps prioritize competitor monitoring
- Note: Estimates vary by tool

---

### 13. Content Gaps (JSON)
**Type:** Long text (JSON formatted)
**Max Length:** 10,000 characters
**Format:** JSON array of gap objects
**Purpose:** Structured list of content opportunities

**JSON Schema:**
```json
[
  {
    "gap_number": 1,
    "opportunity_title": "AI-Assisted Test Generation",
    "description": "Selenium has no content on AI/ML for automated test creation or self-healing selectors. Growing market demand (search volume up 40% YoY) with no competitive coverage.",
    "potential_impact": "High",
    "recommended_content_type": "Comprehensive Guide + Video Tutorial",
    "target_keywords": [
      "ai test automation",
      "self healing selectors",
      "ai test generation",
      "machine learning testing"
    ],
    "effort_estimate": "16-20 hours"
  },
  {
    "gap_number": 2,
    "opportunity_title": "Visual Regression Testing Integration",
    "description": "Minimal coverage of visual testing workflows. Only basic screenshots, no comparison workflows or tools like Percy, Applitools integration.",
    "potential_impact": "High",
    "recommended_content_type": "Tutorial Series (3-4 parts)",
    "target_keywords": [
      "selenium visual testing",
      "visual regression testing",
      "screenshot comparison selenium",
      "percy selenium integration"
    ],
    "effort_estimate": "12-15 hours"
  }
]
```

**Required Fields per Gap:**
- `gap_number` (integer)
- `opportunity_title` (string)
- `description` (detailed explanation)
- `potential_impact` ("High", "Medium", "Low")
- `recommended_content_type` (string)
- `target_keywords` (array of strings)
- `effort_estimate` (string)

**Usage Notes:**
- 5-7 gaps per competitor recommended
- Prioritize by impact and effort
- Update quarterly as gaps are filled
- JSON format enables programmatic parsing

---

### 14. Content Tactics (JSON)
**Type:** Long text (JSON formatted)
**Max Length:** 8,000 characters
**Format:** JSON array of tactic objects
**Purpose:** Top 5 content recommendations

**JSON Schema:**
```json
[
  {
    "tactic": "Create 'Ultimate Guide to Selenium Alternatives' comparison content",
    "rationale": "Selenium ranks well for comparison queries but content is outdated. Opportunity to capture consideration-stage traffic by positioning Katalon as modern alternative with side-by-side feature comparisons.",
    "priority": "High",
    "expected_outcome": "Capture 15-20% of 'selenium vs' search traffic (est. 12K monthly searches), improve brand awareness in evaluation stage"
  },
  {
    "tactic": "Develop video tutorial series on 'Modern Test Automation Patterns'",
    "rationale": "Selenium has minimal video content (only 5% of content mix). Video searches for testing tutorials up 35% YoY. Opportunity to dominate video SERP results.",
    "priority": "High",
    "expected_outcome": "Own 3-5 video carousel positions, generate 5K+ monthly views, improve engagement metrics"
  }
]
```

**Required Fields per Tactic:**
- `tactic` (specific actionable recommendation)
- `rationale` (why this matters, backed by data)
- `priority` ("High", "Medium", "Low")
- `expected_outcome` (measurable success criteria)

**Usage Notes:**
- Exactly 5 tactics per analysis
- Prioritize quick wins + strategic plays
- Include success metrics when possible
- Review quarterly for relevance

---

### 15. SEO Tactics (JSON)
**Type:** Long text (JSON formatted)
**Max Length:** 8,000 characters
**Format:** JSON array of tactic objects
**Purpose:** Top 5 technical SEO recommendations

**JSON Schema:**
```json
[
  {
    "tactic": "Implement HowTo schema markup on all tutorial pages",
    "rationale": "Selenium uses HowTo schema on 80% of tutorial content, earning enhanced SERP display and higher CTR. Katalon has <10% schema coverage. Low-effort, high-impact opportunity.",
    "priority": "High",
    "expected_outcome": "Improve SERP CTR by 15-25% on tutorial pages, potential featured snippet wins for step-by-step queries"
  },
  {
    "tactic": "Build internal linking hub for 'Test Automation' topic cluster",
    "rationale": "Selenium's internal linking strategy creates strong topical authority (avg 15 internal links per page). Katalon averages only 3-5 internal links, missing topical SEO opportunity.",
    "priority": "High",
    "expected_outcome": "Improve crawl depth, boost rankings for cluster keywords by 10-20 positions, increase page authority distribution"
  }
]
```

**Required Fields per Tactic:**
- `tactic` (specific technical recommendation)
- `rationale` (competitive insight driving recommendation)
- `priority` ("High", "Medium", "Low")
- `expected_outcome` (expected SEO impact)

**Usage Notes:**
- Exactly 5 tactics per analysis
- Mix quick wins and long-term strategies
- Include implementation difficulty when relevant
- Track completion in separate action items

---

### 16. Competitive Threats (JSON)
**Type:** Long text (JSON formatted)
**Max Length:** 6,000 characters
**Format:** JSON array of threat objects
**Purpose:** Identify areas where competitor is winning

**JSON Schema:**
```json
[
  {
    "threat": "Selenium's community-driven content strategy generates 200+ backlinks per month organically",
    "severity": "High",
    "recommended_response": "Launch Katalon Community Contributors program - incentivize guest posts, community tutorials, and user-generated content. Target 50+ community backlinks per month within 6 months."
  },
  {
    "threat": "Selenium owns featured snippets for 12 high-value keywords Katalon targets",
    "severity": "High",
    "recommended_response": "Audit featured snippet content structure. Rewrite target pages using Q&A format, concise definitions, and structured lists. Implement FAQ schema markup."
  },
  {
    "threat": "Selenium's documentation ranks higher than Katalon's for product comparison queries",
    "severity": "Medium",
    "recommended_response": "Create comprehensive comparison hub - 'Katalon vs Selenium', 'Why Teams Switch from Selenium', 'Migration Guide: Selenium to Katalon'. Target bottom-funnel search intent."
  }
]
```

**Required Fields per Threat:**
- `threat` (specific competitive advantage they have)
- `severity` ("High", "Medium", "Low")
- `recommended_response` (how Katalon should respond)

**Usage Notes:**
- 3-5 threats per analysis
- Focus on threats that impact Katalon directly
- Include actionable responses
- Track mitigation progress

---

### 17. Katalon Advantages (JSON)
**Type:** Long text (JSON formatted)
**Max Length:** 6,000 characters
**Format:** JSON array of advantage objects
**Purpose:** Identify exploitable competitive weaknesses

**JSON Schema:**
```json
[
  {
    "advantage": "Selenium has zero content on low-code/no-code testing approaches",
    "opportunity": "Create comprehensive content series on 'Low-Code Test Automation' - position Katalon Studio as accessible alternative to code-heavy Selenium. Target non-developer QA roles.",
    "quick_win_potential": "Yes"
  },
  {
    "advantage": "Selenium's API testing content is outdated (last updated 2022)",
    "opportunity": "Publish definitive guide to API testing automation with modern tools (Postman, REST Assured, Katalon). Own 'selenium api testing' queries with fresher, better content.",
    "quick_win_potential": "Yes"
  },
  {
    "advantage": "Selenium lacks case studies showing enterprise ROI and adoption metrics",
    "opportunity": "Leverage Katalon's enterprise customer base - publish 5-7 case studies with specific ROI data, team productivity metrics, and cost savings. Build trust for enterprise buyers.",
    "quick_win_potential": "No"
  }
]
```

**Required Fields per Advantage:**
- `advantage` (specific weakness or gap in competitor strategy)
- `opportunity` (how Katalon can exploit this)
- `quick_win_potential` ("Yes" or "No")

**Usage Notes:**
- 3-5 advantages per analysis
- Prioritize quick wins (achievable within 30-60 days)
- Include both content and product opportunities
- Review quarterly - advantages may become threats

---

### 18. Strategic Priority Score
**Type:** Number (Integer)
**Format:** 1-100
**Purpose:** Quantify overall importance of this analysis

**Scoring Methodology:**
```
Base Score Components:
• Competitive Threat Level (0-30 points)
  - High severity threats: +25-30
  - Medium severity threats: +15-24
  - Low severity threats: +5-14

• Opportunity Value (0-30 points)
  - High-impact gaps: +25-30
  - Medium-impact gaps: +15-24
  - Low-impact gaps: +5-14

• Market Relevance (0-20 points)
  - Direct competitor: +15-20
  - Indirect/emerging: +10-14
  - Peripheral: +5-9

• Data Freshness (0-10 points)
  - Last 7 days: +10
  - 8-30 days: +7
  - 31-60 days: +5
  - 60+ days: +2

• Quick Win Potential (0-10 points)
  - 3+ quick wins: +10
  - 1-2 quick wins: +5-7
  - No quick wins: +2
```

**Interpretation Guide:**
- **90-100:** Critical priority - immediate action required
- **70-89:** High priority - address within current sprint
- **50-69:** Medium priority - plan for next quarter
- **30-49:** Low priority - monitor and revisit
- **0-29:** Minimal priority - low strategic value

**Example Scores:**
```
Selenium: 95 (direct competitor, high threats, high opportunities)
Cypress: 88 (growing threat, strong differentiation opportunities)
Playwright: 82 (emerging threat, watch closely)
TestCafe: 65 (niche player, moderate relevance)
Puppeteer: 58 (different use case, lower priority)
```

**Usage Notes:**
- Drives prioritization of action items
- Helps allocate content resources
- Tracks priority changes over time
- Should correlate with business objectives

---

### 19. Analysis Confidence
**Type:** Single select
**Options:**
- High
- Medium
- Low

**Purpose:** Indicates data quality and reliability

**Confidence Criteria:**

**High Confidence:**
- Research includes 10+ recent citations
- Data from multiple authoritative sources
- Quantitative metrics available (traffic, rankings, DA)
- Analysis aligns with industry benchmarks
- Competitor information is current (< 30 days)

**Medium Confidence:**
- Research includes 5-9 citations
- Some quantitative data, mostly qualitative
- Estimates used where exact data unavailable
- Minor gaps in research coverage
- Competitor information 30-60 days old

**Low Confidence:**
- Limited citations (< 5)
- Mostly qualitative observations
- Significant data gaps
- Estimates without strong basis
- Competitor information > 60 days old

**Usage Notes:**
- Informs how much weight to give recommendations
- Flags analyses that may need refresh
- Helps identify research methodology improvements

---

### 20. Data Freshness
**Type:** Single line text
**Max Length:** 100 characters
**Format:** Descriptive text with date range
**Purpose:** Indicates recency of research data

**Example Values:**
```
Last 30 days (Nov 1-19, 2025)
Last 7 days (Nov 12-19, 2025)
Last 60 days (Sep 20 - Nov 19, 2025)
Mixed (SEO data: 30 days, Content: 7 days)
```

**Usage Notes:**
- SEO data may lag by 30-60 days (tools update monthly)
- Content analysis should be current (< 7 days)
- Traffic estimates often 30-90 days delayed
- Note any stale data sources

---

### 21. Review Frequency
**Type:** Single select
**Options:**
- Weekly
- Bi-Weekly
- Monthly
- Quarterly

**Purpose:** Recommended re-analysis schedule

**Selection Criteria:**

**Weekly:**
- Direct competitor with active content strategy
- High strategic priority score (> 85)
- Rapidly changing competitive landscape
- Example: Selenium, Cypress

**Bi-Weekly:**
- Important competitor with moderate activity
- Medium-high priority score (70-85)
- Notable market share
- Example: Playwright

**Monthly:**
- Relevant competitor with slower content pace
- Medium priority score (50-70)
- Stable competitive position
- Example: TestCafe

**Quarterly:**
- Peripheral competitor
- Low priority score (< 50)
- Different market segment
- Example: Puppeteer (different use case)

**Usage Notes:**
- Drives workflow schedule adjustments
- Optimizes research budget allocation
- Can be overridden for special circumstances

---

### 22. Workflow Execution ID
**Type:** Single line text
**Max Length:** 200 characters
**Format:** `{workflow_id}_{execution_id}`
**Purpose:** Links record to n8n execution for debugging

**Example Values:**
```
KZfgyKJr4biAMcrO_abc123def456
KZfgyKJr4biAMcrO_xyz789ghi012
```

**Components:**
- Workflow ID: `KZfgyKJr4biAMcrO` (Agent-2 SEO Intelligence V2)
- Execution ID: Unique n8n execution identifier

**Usage Notes:**
- Enables tracing back to workflow execution
- Helpful for debugging data quality issues
- Can verify which version of workflow created record
- Used in support/troubleshooting scenarios

---

### 23. Status
**Type:** Single select
**Options:**
- New Analysis
- Under Review
- Actions Planned
- In Progress
- Completed
- Archived

**Purpose:** Track analysis lifecycle and team workflow

**Status Definitions:**

**New Analysis:**
- Freshly created by workflow
- Not yet reviewed by team
- Default status for all new records

**Under Review:**
- Team is actively reviewing findings
- Validating recommendations
- Discussing prioritization

**Actions Planned:**
- Action items identified
- Work scheduled
- Resources allocated

**In Progress:**
- Team actively implementing recommendations
- Content being created
- SEO changes being deployed

**Completed:**
- All recommendations implemented
- Outcomes measured
- Analysis archived as reference

**Archived:**
- Historical record
- No longer actionable
- Retained for trend analysis

**Usage Notes:**
- Updated manually by team
- Drives workflow views and filters
- Helps track backlog of recommendations

---

### 24. Assigned To
**Type:** User
**Purpose:** Team member responsible for acting on analysis

**Configuration:**
- Linked to Airtable workspace users
- Can be one or multiple users (if needed)
- Optional field (not all analyses require assignment)

**Usage Notes:**
- Assign to content strategist for content gaps
- Assign to SEO specialist for technical SEO tactics
- Can reassign as work progresses
- Used in filtered views by assignee

---

### 25. Action Items
**Type:** Long text
**Max Length:** 5,000 characters
**Format:** Bulleted list or checkbox list
**Purpose:** Track specific follow-up tasks

**Example Content:**
```
Content Tasks:
☐ Write "Selenium vs Katalon" comparison guide (Due: Dec 1)
☐ Create video tutorial series on AI testing (Due: Dec 15)
☐ Publish case study: Enterprise Selenium migration (Due: Dec 20)

SEO Tasks:
☐ Implement HowTo schema on all tutorial pages (Due: Nov 25)
☐ Audit internal linking for test automation cluster (Due: Nov 30)
☐ Build backlink outreach list - community sites (Due: Dec 5)

Research Tasks:
☐ Deep dive on Selenium's backlink sources (Due: Nov 22)
☐ Analyze Selenium's video content performance (Due: Nov 28)
```

**Usage Notes:**
- Translates recommendations into specific tasks
- Include owners and due dates
- Update as tasks complete
- Link to project management tools if needed

---

### 26. Notes
**Type:** Long text
**Max Length:** 10,000 characters
**Format:** Free-form text
**Purpose:** Additional observations, context, or team comments

**Example Content:**
```
Nov 19, 2025 - Initial analysis shows Selenium's dominance hasn't wavered
despite Playwright growth. Their community strategy remains strongest moat.

Nov 26, 2025 - Reviewed with content team. Prioritizing AI testing content
gap - confirmed high demand from sales team requests.

Dec 3, 2025 - First video tutorial published, seeing strong engagement.
Consider expanding video strategy beyond original plan.
```

**Usage Notes:**
- Capture insights not fitting other fields
- Document team discussions
- Track implementation learnings
- Note unexpected findings

---

### 27. Last Modified (Auto)
**Type:** Last modified time
**Timezone:** UTC
**Purpose:** Auto-track when record was last updated

**Usage Notes:**
- Automatically updated by Airtable
- Helps identify stale records
- Useful for audit trails
- No manual input required

---

### 28. Created Time (Auto)
**Type:** Created time
**Timezone:** UTC
**Purpose:** Auto-track when record was created

**Usage Notes:**
- Set once when record created
- Matches workflow execution time
- Useful for historical analysis
- No manual input required

---

## Recommended Views

### 1. New Analyses (Default View)
**Filter:** Status = "New Analysis"
**Sort:** Analysis Date (newest first)
**Fields Shown:**
- Competitor Name
- Analysis Date
- Strategic Priority Score
- Executive Summary
- Status
- Assigned To

**Purpose:** Landing view for team to see latest analyses requiring review

---

### 2. High Priority Actions
**Filter:**
- Status = "Actions Planned" OR "In Progress"
- Strategic Priority Score >= 70

**Sort:** Strategic Priority Score (descending)
**Fields Shown:**
- Competitor Name
- Strategic Priority Score
- Status
- Action Items
- Assigned To
- Analysis Date

**Purpose:** Focus view for high-impact work

---

### 3. By Competitor
**Group By:** Competitor Name
**Sort:** Analysis Date (newest first)
**Fields Shown:** All fields

**Purpose:** Track individual competitor trends over time

---

### 4. Content Gaps Dashboard
**Filter:** Content Gaps (JSON) is not empty
**Sort:** Strategic Priority Score (descending)
**Fields Shown:**
- Competitor Name
- Content Gaps (JSON)
- Content Tactics (JSON)
- Strategic Priority Score
- Status

**Purpose:** Content planning and gap analysis

---

### 5. SEO Tactical View
**Filter:** SEO Tactics (JSON) is not empty
**Sort:** Strategic Priority Score (descending)
**Fields Shown:**
- Competitor Name
- SEO Tactics (JSON)
- Competitive Threats (JSON)
- Domain Authority
- Organic Visibility
- Status

**Purpose:** SEO team prioritization

---

### 6. Historical Trends
**Filter:** Created Time >= 90 days ago
**Group By:** Competitor Name
**Sort:** Analysis Date (newest first)
**Fields Shown:**
- Competitor Name
- Analysis Date
- Strategic Priority Score
- Domain Authority
- Traffic Estimate
- Top Keywords

**Purpose:** Quarterly trend analysis and reporting

---

## Automation Recommendations

### 1. Status Change Notifications
**Trigger:** When Status changes to "Actions Planned"
**Action:** Send Slack notification to assigned team member

---

### 2. Stale Analysis Alerts
**Trigger:** When Last Modified > 30 days AND Status = "Under Review"
**Action:** Send reminder to assignee to update status

---

### 3. Priority Score Escalation
**Trigger:** When Strategic Priority Score >= 90 AND Status = "New Analysis"
**Action:**
- Send immediate Slack alert to marketing lead
- Auto-assign to senior strategist
- Change status to "Under Review"

---

### 4. Completed Analysis Archival
**Trigger:** When Status = "Completed" for 90 days
**Action:** Auto-change status to "Archived"

---

## Data Retention Policy

**Active Records:** Keep all "New Analysis" through "In Progress" indefinitely

**Completed Records:** Retain for 12 months after completion

**Archived Records:** Retain for 24 months total, then delete

**Exception:** Records with Strategic Priority Score >= 85 retained for 36 months

---

## Migration Notes

### From Agent-2 V1 Schema (If Applicable)

**Changed Fields:**
- Renamed "Competitor" → "Competitor Name" (clarity)
- Added "Content Gaps (JSON)" (was plain text)
- Added "Strategic Priority Score" (new metric)
- Split "Recommendations" into "Content Tactics" and "SEO Tactics"
- Added "Katalon Advantages" field

**Migration Steps:**
1. Export V1 data to CSV
2. Create new table with V2 schema
3. Map old "Recommendations" field → parse into Content/SEO tactics
4. Calculate Strategic Priority Score for historical records (manual)
5. Import mapped data
6. Verify all JSON fields parse correctly

---

## Integration Points

### External Tools

**Airtable API:**
- Read access: Marketing dashboard aggregates priority scores
- Write access: n8n workflow (Agent-2) creates records
- Update access: Team members via Airtable interface

**n8n Workflow:**
- Creates 1 record per competitor per execution
- Populates all required fields automatically
- No manual data entry needed for core analysis

**Slack Integration:**
- Notifications link to Airtable record URLs
- Deep links enable quick access
- Summary stats pulled from Airtable

**Analytics/BI:**
- Export to Google Sheets for trend visualization
- Power BI connection for executive dashboards
- Track metrics: avg priority score, gaps identified, completion rate

---

## Support and Maintenance

**Schema Owner:** Marketing Automation Team

**Update Frequency:** Review schema quarterly

**Support Contact:** For issues with schema or data quality, contact KAF team

---

**Last Updated:** 2025-11-19
**Schema Version:** 2.0
**Status:** ✅ Production Ready
