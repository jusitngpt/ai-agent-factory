# Agent 4: Social Media Content Factory - Airtable Schema

## Table 1: Content Generation Requests

Track all social media content generation requests from submission to completion.

| Field Name | Type | Configuration | Description |
|------------|------|---------------|-------------|
| Request ID | Autonumber | Primary key | Unique identifier |
| Source Type | Single select | Blog Post, Announcement, Case Study, Video, Product Launch, Event, News | Content source type |
| Source URL | URL | - | Original content URL |
| Source Content | Long text | - | Content text (if not URL) |
| Target Platforms | Multiple select | LinkedIn, Twitter, Facebook, Instagram, TikTok, YouTube | Platforms to generate for |
| Content Angle | Single select | Educational, Promotional, Thought Leadership, News, Behind the Scenes | Content approach |
| Tone | Single select | Professional, Casual, Inspirational, Humorous, Urgent | Desired tone |
| Call to Action | Single select | Read More, Sign Up, Download, Comment, Share, Visit Website, Book Demo | CTA type |
| Include Hashtags | Checkbox | Default: true | Add hashtags? |
| Variant Count | Number | Default: 2 | How many variants per platform |
| Requested By | Single line text | - | User email/name |
| Created Date | Created time | Auto | Auto-timestamp |
| Started At | Date & time | - | Processing start |
| Completed At | Date & time | - | Processing end |
| Status | Single select | Pending, Processing, Complete, Failed | Current status |
| Posts Generated | Number | - | Total posts created |
| Link to Posts | Link to records | → Social Media Posts | All generated posts |
| Notes | Long text | - | Additional context |
| Error Message | Long text | - | Error details if failed |

**Formulas**:

**Processing Time (Minutes)**:
```
IF(
  AND({Started At}, {Completed At}),
  ROUND(DATETIME_DIFF({Completed At}, {Started At}, 'seconds') / 60, 1),
  BLANK()
)
```

**Status Icon**:
```
SWITCH(
  {Status},
  'Pending', '⏳',
  'Processing', '⚙️',
  'Complete', '✅',
  'Failed', '❌',
  '❓'
)
```

**Efficiency Score**:
```
IF(
  {Posts Generated},
  ROUND({Posts Generated} / IF({Processing Time (Minutes)} > 0, {Processing Time (Minutes)}, 1), 1),
  BLANK()
)
```

**Views**:
- **Active Requests**: Status IN ("Pending", "Processing")
- **Completed This Week**: Status = "Complete", Created Date is within this week
- **Failed Requests**: Status = "Failed", sort by Created Date desc
- **By Platform**: Group by Target Platforms
- **By Source Type**: Group by Source Type
- **High Volume**: Posts Generated >= 8

---

## Table 2: Social Media Posts

Individual social media posts generated for each platform and variant.

| Field Name | Type | Configuration | Description |
|------------|------|---------------|-------------|
| Post ID | Autonumber | Primary key | Unique identifier |
| Request | Link to records | ← Content Generation Requests | Source request |
| Platform | Single select | Required: LinkedIn, Twitter, Facebook, Instagram | Target platform |
| Variant | Number | 1, 2, 3, ... | A/B variant number |
| Content | Long text | Required | Post content |
| Hashtags | Long text | - | Comma-separated hashtags |
| Character Count | Number | - | Total characters |
| Engagement Score | Number | 1-10 | Predicted engagement |
| Status | Single select | Draft, Scheduled, Published, Archived | Current status |
| Scheduled Date | Date & time | - | When to publish |
| Published Date | Date & time | - | When actually published |
| Platform Post ID | Single line text | - | ID from social platform |
| Performance Metrics | Long text | JSON format | Likes, shares, comments, etc. |
| Created At | Created time | Auto | Auto-timestamp |
| Approved By | Single line text | - | Who approved |
| Approval Date | Date & time | - | When approved |
| Notes | Long text | - | Editorial notes |
| Image URL | URL | - | Associated image/graphic |
| Link to Calendar | Link to records | → Content Calendar | Scheduled post details |
| Optimization Notes | Long text | - | What Gemini changed |

**Formulas**:

**Platform Icon**:
```
SWITCH(
  {Platform},
  'LinkedIn', '💼',
  'Twitter', '🐦',
  'Facebook', '👥',
  'Instagram', '📸',
  'TikTok', '🎵',
  'YouTube', '📹',
  '📱'
)
```

**Status Icon**:
```
SWITCH(
  {Status},
  'Draft', '⚪',
  'Scheduled', '🟡',
  'Published', '🟢',
  'Archived', '⚫',
  '❓'
)
```

**Engagement Rating**:
```
IF(
  {Engagement Score},
  IF({Engagement Score} >= 8, "🔥 High",
    IF({Engagement Score} >= 6, "👍 Good",
      IF({Engagement Score} >= 4, "👌 Okay", "❌ Low")
    )
  ),
  BLANK()
)
```

**Character Limit Check**:
```
SWITCH(
  {Platform},
  'LinkedIn', IF({Character Count} > 3000, '⚠️ Too long', '✓'),
  'Twitter', IF({Character Count} > 280, '⚠️ Too long', '✓'),
  'Facebook', IF({Character Count} > 2000, '⚠️ Too long', '✓'),
  'Instagram', IF({Character Count} > 2200, '⚠️ Too long', '✓'),
  '✓'
)
```

**Days Until Publish**:
```
IF(
  AND({Scheduled Date}, {Status} = 'Scheduled'),
  DATETIME_DIFF({Scheduled Date}, NOW(), 'days'),
  BLANK()
)
```

**Performance Summary** (if metrics exist):
```
IF(
  {Performance Metrics},
  CONCATENATE(
    '👍 ', VALUE(REGEX_EXTRACT({Performance Metrics}, '"likes":(\\d+)')),
    ' | 💬 ', VALUE(REGEX_EXTRACT({Performance Metrics}, '"comments":(\\d+)')),
    ' | 🔄 ', VALUE(REGEX_EXTRACT({Performance Metrics}, '"shares":(\\d+)'))
  ),
  'Not published'
)
```

**Views**:
- **Draft Posts**: Status = "Draft", sort by Engagement Score desc
- **Awaiting Approval**: Status = "Draft" AND Approved By is empty
- **Scheduled**: Status = "Scheduled", sort by Scheduled Date asc
- **Published This Week**: Status = "Published", Published Date is within this week
- **By Platform**: Group by Platform
- **High Engagement Predicted**: Engagement Score >= 8
- **Publishing This Week**: Scheduled Date is within this week
- **Performance Dashboard**: Status = "Published", show Performance Summary

---

## Table 3: Content Calendar

Plan and schedule content across all platforms.

| Field Name | Type | Configuration | Description |
|------------|------|---------------|-------------|
| Calendar ID | Autonumber | Primary key | Unique identifier |
| Post Date | Date | Required | Publication date |
| Time Slot | Single select | Morning (8-10am), Midday (12-2pm), Afternoon (3-5pm), Evening (6-8pm) | Time slot |
| Platform | Single select | LinkedIn, Twitter, Facebook, Instagram | Platform |
| Post | Link to records | → Social Media Posts | Linked post |
| Content Theme | Single select | Product, Thought Leadership, Customer Story, Company News, Industry News, Educational, Promotional | Theme |
| Campaign | Single line text | - | Campaign name |
| Status | Single select | Planned, Scheduled, Published, Cancelled | Status |
| Notes | Long text | - | Planning notes |
| Owner | Single line text | - | Responsible person |
| Priority | Single select | High, Medium, Low | Priority level |

**Formulas**:

**Calendar Display**:
```
CONCATENATE(
  DATETIME_FORMAT({Post Date}, 'MMM D'),
  ' - ',
  {Platform},
  ' (',
  {Time Slot},
  ')'
)
```

**Status Icon**:
```
SWITCH(
  {Status},
  'Planned', '📋',
  'Scheduled', '⏰',
  'Published', '✅',
  'Cancelled', '❌',
  '❓'
)
```

**Week Number**:
```
WEEKNUM({Post Date})
```

**Views**:
- **This Week**: Post Date is within this week
- **Next Week**: Post Date is within next week
- **By Platform**: Group by Platform
- **By Theme**: Group by Content Theme
- **By Campaign**: Group by Campaign
- **Calendar View**: Calendar by Post Date
- **Publishing Today**: Post Date = TODAY()
- **Needs Content**: Post is empty, Status != "Cancelled"

---

## Table 4: Brand Voice Guidelines

Centralized brand voice, tone, and messaging guidelines used by the content generator.

| Field Name | Type | Configuration | Description |
|------------|------|---------------|-------------|
| Guideline ID | Autonumber | Primary key | Unique identifier |
| Active | Checkbox | Default: false | Currently active? (only 1 should be true) |
| Version | Single line text | - | Version number (e.g., 1.0, 1.1) |
| Brand Voice Description | Long text | Required | Overall brand voice and personality |
| Key Messaging Points | Long text | - | Core messages to communicate |
| Do's | Long text | - | What to do in content |
| Don'ts | Long text | - | What to avoid in content |
| Sample Posts | Long text | - | Example good posts by platform |
| Prohibited Terms | Long text | - | Words/phrases to avoid |
| Emoji Policy | Single select | Encouraged, Minimal, Professional Only, None | Emoji usage |
| Tone Guidelines | Long text | - | Tone by platform and content type |
| Hashtag Strategy | Long text | - | Hashtag approach by platform |
| Competitor Differentiation | Long text | - | How we differ from competitors |
| Target Audience | Long text | - | Who we're speaking to |
| Value Propositions | Long text | - | Core value props to emphasize |
| Updated Date | Last modified time | Auto | Auto-timestamp |
| Updated By | Single line text | - | Who updated |
| Change Notes | Long text | - | What changed in this version |

**Formulas**:

**Active Status**:
```
IF({Active}, '✅ ACTIVE', '📦 Archived')
```

**Version Display**:
```
CONCATENATE(
  'v',
  {Version},
  IF({Active}, ' (Current)', '')
)
```

**Views**:
- **Active Guidelines**: Active = true (should only show 1 record)
- **All Versions**: Sort by Updated Date desc
- **Recently Updated**: Updated Date is within last 30 days

---

## Table 5: Performance Analytics

Track actual performance of published posts to improve future content generation.

| Field Name | Type | Configuration | Description |
|------------|------|---------------|-------------|
| Analytics ID | Autonumber | Primary key | Unique identifier |
| Post | Link to records | ← Social Media Posts | Related post |
| Platform | Lookup | From Post | Platform (for grouping) |
| Measured Date | Date & time | - | When metrics collected |
| Likes | Number | - | Like count |
| Comments | Number | - | Comment count |
| Shares | Number | - | Share count |
| Clicks | Number | - | Link clicks |
| Impressions | Number | - | Times seen |
| Engagement Rate | Number | % | (Likes + Comments + Shares) / Impressions |
| Click-Through Rate | Number | % | Clicks / Impressions |
| Top Performing | Checkbox | - | In top 20% for engagement |
| Underperforming | Checkbox | - | In bottom 20% for engagement |
| Content Type | Lookup | From Post → Request | Content angle/type |
| Hashtags Used | Lookup | From Post | Hashtags |
| Predicted Score | Lookup | From Post | Engagement Score (predicted) |
| Prediction Accuracy | Formula | - | How accurate was the prediction |

**Formulas**:

**Engagement Rate**:
```
IF(
  AND({Impressions}, {Impressions} > 0),
  ROUND(({Likes} + {Comments} + {Shares}) / {Impressions} * 100, 2),
  BLANK()
)
```

**Click-Through Rate**:
```
IF(
  AND({Impressions}, {Impressions} > 0),
  ROUND({Clicks} / {Impressions} * 100, 2),
  BLANK()
)
```

**Prediction Accuracy**:
```
IF(
  AND({Predicted Score}, {Engagement Rate}),
  ROUND(
    100 - ABS(({Predicted Score} * 10) - {Engagement Rate}),
    0
  ),
  BLANK()
)
```

**Performance Tier**:
```
IF(
  {Engagement Rate},
  IF({Engagement Rate} >= 5, '🔥 Excellent',
    IF({Engagement Rate} >= 3, '⭐ Good',
      IF({Engagement Rate} >= 1.5, '👌 Average', '❄️ Low')
    )
  ),
  BLANK()
)
```

**Views**:
- **Top Performers**: Top Performing = true
- **Underperforming**: Underperforming = true
- **By Platform**: Group by Platform
- **Recent (7 days)**: Measured Date is within last 7 days
- **Prediction Accuracy**: Show Prediction Accuracy, sort desc
- **Engagement Leaders**: Sort by Engagement Rate desc

---

## Automation Triggers

### Automation 1: Process New Content Request

**Trigger**: When record created in "Content Generation Requests"
**Condition**: Status = "Pending"
**Action**:
```javascript
// Call n8n webhook
const webhookUrl = 'https://your-n8n-instance.com/webhook/agent-4-content-gen';
const requestData = {
  request_id: record.id,
  source_type: record.get('Source Type'),
  source_content: record.get('Source Content'),
  source_url: record.get('Source URL'),
  target_platforms: record.get('Target Platforms'),
  content_angle: record.get('Content Angle'),
  tone: record.get('Tone'),
  call_to_action: record.get('Call to Action'),
  include_hashtags: record.get('Include Hashtags'),
  variant_count: record.get('Variant Count'),
  requested_by: record.get('Requested By')
};

await fetch(webhookUrl, {
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify(requestData)
});
```

### Automation 2: Publish Scheduled Posts (Future)

**Trigger**: Every hour
**Condition**: Status = "Scheduled" AND Scheduled Date <= NOW() + 1 hour
**Action**: Call platform publishing workflow

### Automation 3: Collect Performance Metrics (Future)

**Trigger**: Daily at 9am
**Condition**: Status = "Published" AND Published Date was 1, 7, or 30 days ago
**Action**: Call metric collection workflow

---

## Integration Points

### Buffer/Hootsuite Integration

Map posts to Buffer format:
```javascript
{
  "profile_ids": ["linkedin_id", "twitter_id"],
  "text": post.get('Content'),
  "media": {"link": post.get('Image URL')},
  "scheduled_at": post.get('Scheduled Date').toISOString(),
  "shorten": false
}
```

### Zapier Integration

Trigger Zap when:
- New post created with Status = "Draft"
- Post status changes to "Scheduled"
- Post published (Status = "Published")

---

## Data Retention

- **Content Generation Requests**: Keep indefinitely (historical record)
- **Social Media Posts**:
  - Draft: Delete after 90 days if not approved
  - Published: Keep indefinitely
  - Archived: Keep for 1 year
- **Content Calendar**: Keep for 2 years
- **Brand Voice Guidelines**: Keep all versions indefinitely
- **Performance Analytics**: Keep indefinitely (valuable for learning)

---

**Schema Version**: 1.0
**Last Updated**: November 2025
**Maintained by**: GTM Operations Team
