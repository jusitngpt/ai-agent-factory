# Agent 4: Social Media Content Factory

**Status**: 📋 Ready for Implementation
**Target Launch**: Q2 2026
**Version**: 1.0 (Complete Specification)

## Overview

The Social Media Content Factory automates multi-platform social content generation, adapting messaging for each platform while maintaining brand consistency. Creates, optimizes, and schedules content across LinkedIn, Twitter, and other channels.

## Core Workflows

### Workflow 4A: Content Repurposing & Generation

**Purpose**: Transform source content (blog posts, announcements) into platform-specific social media posts

**Trigger**:
- Manual: Airtable form submission with source content
- Automated: Webhook from CMS when new content published
- Scheduled: Weekly content batch generation

**Estimated Execution Time**: 3-5 minutes
**Cost per Run**: $0.30-0.50 (generates 5-10 posts across platforms)

---

## n8n Workflow Design: Multi-Platform Content Generation

### Node Structure

```
Webhook Trigger / Airtable Record Created
    ↓
[1] Set Variables & Validate Input
    ↓
[2] Update Airtable Status → "Processing"
    ↓
[3] Fetch Brand Voice Guidelines (Airtable)
    ↓
[4] Perplexity: Research Context & Trends
    ↓
[5] Claude: Analyze Source Content
    ↓
[6] Branch: Generate Platform-Specific Content
    │   ↓
    │   [6a] LinkedIn Post (Claude)
    │   [6b] Twitter Thread (Claude)
    │   [6c] Facebook Post (Claude)
    │   [6d] Instagram Caption (Claude)
    ↓
[7] Gemini: Optimize & Add Hashtags
    ↓
[8] Loop: Generate Multiple Variants (A/B testing)
    ↓
[9] Save All Posts to Airtable
    ↓
[10] Update Status → "Complete"
    ↓
[11] Slack Notification with Preview
```

### Detailed Node Specifications

#### Node 1: Set Variables & Validate Input
- **Node Type**: Function (JavaScript)
- **Purpose**: Extract and validate input parameters

```javascript
const input = $input.all()[0].json;

// Validate required fields
if (!input.source_content && !input.source_url) {
  throw new Error('Either source_content or source_url is required');
}

return [{
  json: {
    request_id: input.request_id || 'manual-' + Date.now(),
    source_type: input.source_type || 'blog_post', // blog_post, announcement, case_study, video
    source_content: input.source_content || '',
    source_url: input.source_url || '',
    target_platforms: input.target_platforms || ['linkedin', 'twitter', 'facebook'],
    content_angle: input.content_angle || 'educational', // educational, promotional, thought_leadership, news
    tone: input.tone || 'professional', // professional, casual, inspirational, humorous
    call_to_action: input.call_to_action || 'read_more',
    include_hashtags: input.include_hashtags !== false,
    variant_count: input.variant_count || 2,
    requested_by: input.requested_by || 'system'
  }
}];
```

#### Node 2: Update Airtable Status
- **Node Type**: Airtable
- **Operation**: Update
- **Table**: Content Generation Requests
- **Record ID**: `{{ $node["Set Variables"].json.request_id }}`
- **Fields**:
  - Status: "Processing"
  - Started At: `{{ $now }}`

#### Node 3: Fetch Brand Voice Guidelines
- **Node Type**: Airtable
- **Operation**: Search records
- **Table**: Brand Voice Guidelines
- **Formula**: `{Active} = TRUE()`
- **Max Records**: 1

**Purpose**: Get current brand voice, tone, messaging guidelines

**Expected Fields**:
- Brand Voice Description
- Key Messaging Points
- Do's and Don'ts
- Sample Posts
- Prohibited Terms
- Emoji Policy

#### Node 4: Perplexity - Research Context & Trends
- **Node Type**: HTTP Request (Perplexity API)
- **Model**: sonar-pro
- **Conditional**: Only if source needs context (e.g., announcement needs industry context)
- **Prompt**:

```
Research context for this social media content:

SOURCE: {{ $node['Set Variables'].json.source_type }}
TOPIC: {{ $node['Set Variables'].json.source_content.substring(0, 500) }}

Provide:

1. TRENDING TOPICS (related to this content)
   - What's currently trending in this space
   - Relevant hashtags with momentum
   - Timely angles to leverage

2. AUDIENCE INSIGHTS
   - What this audience cares about right now
   - Common pain points or interests
   - Engagement triggers

3. COMPETITIVE CONTEXT
   - How competitors are talking about similar topics
   - Unique angles we can take
   - Content gaps to fill

4. TIMING CONSIDERATIONS
   - Best days/times to post (by platform)
   - Seasonal or event relevance
   - Urgency factors

Keep it concise and actionable for social media content creation.
```

#### Node 5: Claude - Analyze Source Content
- **Node Type**: Anthropic (Claude)
- **Model**: claude-3-5-sonnet-20241022
- **Temperature**: 0.3
- **Max Tokens**: 1000
- **Prompt**:

```
You are a social media content strategist. Analyze this content for social media adaptation:

SOURCE TYPE: {{ $node['Set Variables'].json.source_type }}
SOURCE CONTENT:
{{ $node['Set Variables'].json.source_content || 'URL: ' + $node['Set Variables'].json.source_url }}

BRAND VOICE:
{{ $node['Fetch Brand Voice'].json.Brand_Voice_Description }}

CONTEXT:
{{ $node['Perplexity Research'].json.choices[0].message.content || 'No additional context' }}

Provide:

## KEY MESSAGES (3-5 main points)
What are the most important takeaways that must be communicated?

## TARGET AUDIENCE
Who should care about this? What's in it for them?

## EMOTIONAL HOOKS
What emotions should we tap into? (curiosity, urgency, aspiration, validation, etc.)

## UNIQUE ANGLES (5-7 different approaches)
Different ways to frame this content for social:
1. Problem/Solution angle
2. Statistic or data-driven angle
3. Story or narrative angle
4. Question or curiosity angle
5. Contrarian or hot-take angle
6. How-to or educational angle
7. Social proof or testimonial angle

## CALL-TO-ACTION OPTIONS
What should readers do next? (3-5 options ranked by priority)

## CONTENT ADAPTATION NOTES
Platform-specific considerations:
- LinkedIn: Professional, in-depth
- Twitter: Concise, conversational
- Facebook: Community-focused, storytelling
- Instagram: Visual-first, lifestyle-oriented

Keep analysis strategic and actionable.
```

#### Node 6: Branch - Generate Platform-Specific Content
- **Node Type**: Switch (n8n)
- **Mode**: Execute all branches
- **Purpose**: Generate content for each target platform in parallel

##### Node 6a: LinkedIn Post (Claude)
- **Node Type**: Anthropic (Claude)
- **Model**: claude-3-5-sonnet-20241022
- **Temperature**: 0.7 (more creative)
- **Max Tokens**: 800
- **Prompt**:

```
Create a LinkedIn post based on this content analysis:

ANALYSIS:
{{ $node['Claude - Analyze Content'].json.content[0].text }}

SOURCE: {{ $node['Set Variables'].json.source_type }}
TONE: {{ $node['Set Variables'].json.tone }}
ANGLE: {{ $node['Set Variables'].json.content_angle }}

BRAND VOICE:
{{ $node['Fetch Brand Voice'].json.Brand_Voice_Description }}

GUIDELINES:
- Length: 150-300 words (1-3 paragraphs)
- Professional but conversational tone
- Use line breaks for readability (not walls of text)
- Include a hook in the first line
- Tell a mini-story or share insight
- End with engagement question or CTA
- {{ $node['Set Variables'].json.include_hashtags ? 'Include 3-5 relevant hashtags' : 'No hashtags' }}
- Emojis: {{ $node['Fetch Brand Voice'].json.Emoji_Policy }}

LINKEDIN BEST PRACTICES:
- Start with a hook that stops the scroll
- Use "you" and "your" to engage directly
- Include specific examples or data
- Structure for skim-reading (short paragraphs, bullets)
- CTA that encourages comments/shares

FORMAT:
[Hook - compelling first line]

[Main content - 1-2 paragraphs with key insight/story]

[Closing - question or CTA]

{{ $node['Set Variables'].json.include_hashtags ? '[Hashtags]' : '' }}

Generate the post now:
```

##### Node 6b: Twitter Thread (Claude)
- **Node Type**: Anthropic (Claude)
- **Model**: claude-3-5-sonnet-20241022
- **Temperature**: 0.7
- **Max Tokens**: 600
- **Prompt**:

```
Create a Twitter/X thread (5-8 tweets) based on this content:

ANALYSIS:
{{ $node['Claude - Analyze Content'].json.content[0].text }}

SOURCE: {{ $node['Set Variables'].json.source_type }}
TONE: {{ $node['Set Variables'].json.tone }}

BRAND VOICE:
{{ $node['Fetch Brand Voice'].json.Brand_Voice_Description }}

TWITTER THREAD GUIDELINES:
- Each tweet: 240-280 characters (leave room for thread numbers)
- Total thread: 5-8 tweets
- Tweet 1: Hook that promises value
- Tweets 2-6: Deliver on the promise (one idea per tweet)
- Last tweet: CTA with link or engagement ask
- Use numbers for structure (1/, 2/, etc.)
- Line breaks for readability within tweets
- {{ $node['Set Variables'].json.include_hashtags ? 'Hashtags only in first/last tweet (2-3 max)' : 'No hashtags' }}
- Emojis: Use sparingly for emphasis

TWITTER BEST PRACTICES:
- Start with a pattern interrupt or bold statement
- One clear idea per tweet
- Use "you" language
- Short sentences
- Actionable insights
- Build curiosity between tweets

FORMAT (return as JSON array):
[
  {
    "tweet_number": 1,
    "content": "1/ [Hook tweet]"
  },
  {
    "tweet_number": 2,
    "content": "2/ [Content tweet]"
  },
  ...
  {
    "tweet_number": X,
    "content": "X/ [CTA tweet]"
  }
]

Generate the thread now as JSON array:
```

##### Node 6c: Facebook Post (Claude)
- **Node Type**: Anthropic (Claude)
- **Model**: claude-3-5-sonnet-20241022
- **Temperature**: 0.7
- **Max Tokens**: 600
- **Prompt**:

```
Create a Facebook post based on this content:

ANALYSIS:
{{ $node['Claude - Analyze Content'].json.content[0].text }}

SOURCE: {{ $node['Set Variables'].json.source_type }}
TONE: {{ $node['Set Variables'].json.tone }}

BRAND VOICE:
{{ $node['Fetch Brand Voice'].json.Brand_Voice_Description }}

FACEBOOK GUIDELINES:
- Length: 100-200 words
- Conversational and community-focused
- Tell a story or share experience
- Encourage discussion and interaction
- Use questions to spark engagement
- {{ $node['Set Variables'].json.include_hashtags ? 'Include 2-4 hashtags (less critical on Facebook)' : 'No hashtags' }}
- Emojis: {{ $node['Fetch Brand Voice'].json.Emoji_Policy }}

FACEBOOK BEST PRACTICES:
- Focus on community and shared experiences
- More casual than LinkedIn
- Encourage comments and shares
- Relatable and human
- Can be slightly longer/storytelling

FORMAT:
[Opening - relatable hook or story setup]

[Main content - insight, story, or value proposition]

[Engagement ask - question or CTA that invites discussion]

{{ $node['Set Variables'].json.include_hashtags ? '[Hashtags]' : '' }}

Generate the post now:
```

##### Node 6d: Instagram Caption (Claude)
- **Node Type**: Anthropic (Claude)
- **Model**: claude-3-5-sonnet-20241022
- **Temperature**: 0.7
- **Max Tokens**: 500
- **Prompt**:

```
Create an Instagram caption based on this content:

ANALYSIS:
{{ $node['Claude - Analyze Content'].json.content[0].text }}

SOURCE: {{ $node['Set Variables'].json.source_type }}
TONE: {{ $node['Set Variables'].json.tone }}

BRAND VOICE:
{{ $node['Fetch Brand Voice'].json.Brand_Voice_Description }}

INSTAGRAM GUIDELINES:
- Length: 100-150 words (first 125 chars are critical)
- Visual-first mindset (assume accompanying image/graphic)
- Lifestyle-oriented and aspirational
- Use line breaks for readability
- Strong hook in first line
- {{ $node['Set Variables'].json.include_hashtags ? 'Include 10-15 hashtags in first comment (not caption)' : 'No hashtags' }}
- Emojis: {{ $node['Fetch Brand Voice'].json.Emoji_Policy }}

INSTAGRAM BEST PRACTICES:
- Hook in first 1-2 lines (before "...more")
- Tell a mini-story
- Aspirational or inspirational
- Authentic and personal
- CTA in bio link or comments

FORMAT:
[Hook - compelling first line that shows up before "...more"]

[Story or insight - 2-3 short paragraphs]

[CTA - usually "link in bio" or "comment below"]

{{ $node['Set Variables'].json.include_hashtags ? '\n---\nFIRST COMMENT HASHTAGS:\n[15 relevant hashtags]' : '' }}

Generate the caption now:
```

#### Node 7: Gemini - Optimize & Add Hashtags
- **Node Type**: Google Gemini
- **Model**: gemini-2.0-flash-exp
- **Temperature**: 0.2
- **Purpose**: Optimize posts and generate strategic hashtags
- **Loop**: Process each platform's content

**Prompt**:
```
Optimize this social media post and add strategic hashtags:

PLATFORM: {{ $json.platform }}
CONTENT: {{ $json.content }}

TRENDING CONTEXT:
{{ $node['Perplexity Research'].json.choices[0].message.content || 'No trend data' }}

Tasks:

1. OPTIMIZE CONTENT
   - Fix any grammatical issues
   - Improve readability
   - Ensure CTA is clear
   - Check character limits (LinkedIn: 3000, Twitter: 280, Facebook: 2000, Instagram: 2200)

2. ADD STRATEGIC HASHTAGS (if requested)
   Platform-specific approach:
   - LinkedIn: 3-5 hashtags (professional, industry-specific)
   - Twitter: 2-3 hashtags (trending + branded)
   - Facebook: 2-4 hashtags (less critical)
   - Instagram: 10-15 hashtags (mix of popular, niche, branded)

3. ENGAGEMENT SCORE (1-10)
   Rate the post's potential engagement based on:
   - Hook strength
   - Value proposition clarity
   - CTA effectiveness
   - Trend relevance

Return as JSON:
{
  "platform": "linkedin|twitter|facebook|instagram",
  "optimized_content": "...",
  "hashtags": ["hashtag1", "hashtag2", ...],
  "engagement_score": 1-10,
  "character_count": number,
  "optimization_notes": "what was changed"
}
```

#### Node 8: Loop - Generate Multiple Variants
- **Node Type**: Loop (n8n)
- **Purpose**: Generate A/B test variants for each platform
- **Iterations**: `{{ $node['Set Variables'].json.variant_count }}`

**For each platform, generate variants with different angles:**
- Variant A: Angle from analysis #1
- Variant B: Angle from analysis #2
- Variant C: Angle from analysis #3

**Process**: Re-run Claude generation nodes with different angle instructions

#### Node 9: Save All Posts to Airtable

**9a. Save Main Request Record**
- **Table**: Content Generation Requests
- **Operation**: Update
```javascript
{
  "Request ID": "{{ $node['Set Variables'].json.request_id }}",
  "Source Type": "{{ $node['Set Variables'].json.source_type }}",
  "Source URL": "{{ $node['Set Variables'].json.source_url }}",
  "Target Platforms": {{ $node['Set Variables'].json.target_platforms }},
  "Content Angle": "{{ $node['Set Variables'].json.content_angle }}",
  "Tone": "{{ $node['Set Variables'].json.tone }}",
  "Status": "Complete",
  "Completed At": "{{ $now }}",
  "Posts Generated": "{{ count of all posts }}",
  "Requested By": "{{ $node['Set Variables'].json.requested_by }}"
}
```

**9b. Save Individual Posts**
- **Table**: Social Media Posts
- **Operation**: Create (bulk)
```javascript
// Map all generated posts
const posts = [];

// LinkedIn posts
$node['LinkedIn Posts'].json.forEach((post, idx) => {
  posts.push({
    "Request": "{{ $node['Set Variables'].json.request_id }}",
    "Platform": "LinkedIn",
    "Variant": idx + 1,
    "Content": post.optimized_content,
    "Hashtags": post.hashtags.join(', '),
    "Character Count": post.character_count,
    "Engagement Score": post.engagement_score,
    "Status": "Draft",
    "Created At": new Date().toISOString()
  });
});

// Twitter threads
$node['Twitter Threads'].json.forEach((thread, idx) => {
  posts.push({
    "Request": "{{ $node['Set Variables'].json.request_id }}",
    "Platform": "Twitter",
    "Variant": idx + 1,
    "Content": JSON.stringify(thread), // Array of tweets
    "Hashtags": thread[0].hashtags?.join(', ') || '',
    "Character Count": thread.reduce((sum, t) => sum + t.content.length, 0),
    "Engagement Score": thread[0].engagement_score,
    "Status": "Draft"
  });
});

// Facebook & Instagram posts (similar pattern)

return posts;
```

#### Node 10: Update Status
- **Table**: Content Generation Requests
- **Operation**: Update
- **Status**: "Complete"

#### Node 11: Slack Notification with Preview
- **Node Type**: HTTP Request
- **Method**: POST
- **URL**: Slack webhook URL
- **Body**:

```json
{
  "text": "✅ Social Content Generated",
  "blocks": [
    {
      "type": "header",
      "text": {
        "type": "plain_text",
        "text": "🎨 New Social Media Content Ready"
      }
    },
    {
      "type": "section",
      "fields": [
        {"type": "mrkdwn", "text": "*Source:*\n{{ $node['Set Variables'].json.source_type }}"},
        {"type": "mrkdwn", "text": "*Platforms:*\n{{ $node['Set Variables'].json.target_platforms.join(', ') }}"},
        {"type": "mrkdwn", "text": "*Posts Generated:*\n{{ count }} variants"},
        {"type": "mrkdwn", "text": "*Avg Engagement Score:*\n{{ average }}/10"}
      ]
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*LinkedIn Preview (Variant 1):*\n```{{ $node['LinkedIn Posts'].json[0].optimized_content.substring(0, 200) }}...```"
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Twitter Preview (Variant 1):*\n```{{ $node['Twitter Threads'].json[0][0].content }}\n{{ $node['Twitter Threads'].json[0][1].content }}```"
      }
    },
    {
      "type": "actions",
      "elements": [
        {
          "type": "button",
          "text": {"type": "plain_text", "text": "Review in Airtable"},
          "url": "https://airtable.com/[BASE_ID]/[TABLE_ID]"
        },
        {
          "type": "button",
          "text": {"type": "plain_text", "text": "Approve All"},
          "value": "approve_all"
        }
      ]
    }
  ]
}
```

---

## Airtable Schema for Agent 4

### Table 1: Content Generation Requests

| Field Name | Type | Configuration | Description |
|------------|------|---------------|-------------|
| Request ID | Autonumber | - | Primary key |
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
| Created Date | Created time | - | Auto-timestamp |
| Started At | Date & time | - | Processing start |
| Completed At | Date & time | - | Processing end |
| Status | Single select | Pending, Processing, Complete, Failed | Current status |
| Posts Generated | Number | - | Total posts created |
| Link to Posts | Link to records | → Social Media Posts | All generated posts |
| Notes | Long text | - | Additional context |

**Views**:
- Active Requests: Status IN ("Pending", "Processing")
- Completed: Status = "Complete", sort by Completed At desc
- By Platform: Group by Target Platforms
- By Source Type: Group by Source Type

---

### Table 2: Social Media Posts

| Field Name | Type | Configuration | Description |
|------------|------|---------------|-------------|
| Post ID | Autonumber | - | Primary key |
| Request | Link to records | ← Content Generation Requests | Source request |
| Platform | Single select | LinkedIn, Twitter, Facebook, Instagram | Target platform |
| Variant | Number | 1, 2, 3, ... | A/B variant number |
| Content | Long text | Required | Post content |
| Hashtags | Long text | - | Comma-separated hashtags |
| Character Count | Number | - | Total characters |
| Engagement Score | Number | 1-10 | Predicted engagement |
| Status | Single select | Draft, Scheduled, Published, Archived | Current status |
| Scheduled Date | Date & time | - | When to publish |
| Published Date | Date & time | - | When actually published |
| Platform Post ID | Single line text | - | ID from social platform |
| Performance Metrics | Long text | JSON | Likes, shares, comments, etc. |
| Created At | Created time | - | Auto-timestamp |
| Approved By | Single line text | - | Who approved |
| Approval Date | Date & time | - | When approved |
| Notes | Long text | - | Editorial notes |
| Image URL | URL | - | Associated image/graphic |
| Link to Schedule | Link to records | → Content Calendar | Scheduled post details |

**Formulas**:

**Platform Icon**:
```
SWITCH(
  {Platform},
  'LinkedIn', '💼',
  'Twitter', '🐦',
  'Facebook', '👥',
  'Instagram', '📸',
  '📱'
)
```

**Status Color**:
```
SWITCH(
  {Status},
  'Draft', '⚪',
  'Scheduled', '🟡',
  'Published', '🟢',
  'Archived', '⚫'
)
```

**Engagement Rating**:
```
IF({Engagement Score} >= 8, "🔥 High",
  IF({Engagement Score} >= 6, "👍 Good",
    IF({Engagement Score} >= 4, "👌 Okay", "❌ Low")
  )
)
```

**Views**:
- Draft Posts: Status = "Draft", sort by Engagement Score desc
- Scheduled: Status = "Scheduled", sort by Scheduled Date asc
- Published: Status = "Published", sort by Published Date desc
- By Platform: Group by Platform
- High Engagement: Engagement Score >= 8
- This Week: Scheduled Date is within this week
- Needs Approval: Status = "Draft" AND Approved By is empty

---

### Table 3: Content Calendar (Optional)

| Field Name | Type | Configuration | Description |
|------------|------|---------------|-------------|
| Calendar ID | Autonumber | - | Primary key |
| Post Date | Date | Required | Publication date |
| Time Slot | Single select | Morning (8-10am), Midday (12-2pm), Afternoon (3-5pm), Evening (6-8pm) | Time slot |
| Platform | Single select | LinkedIn, Twitter, Facebook, Instagram | Platform |
| Post | Link to records | → Social Media Posts | Linked post |
| Content Theme | Single select | Product, Thought Leadership, Customer Story, Company News, Industry News | Theme |
| Campaign | Single line text | - | Campaign name |
| Status | Single select | Planned, Scheduled, Published, Cancelled | Status |
| Notes | Long text | - | Planning notes |

**Views**:
- This Week: Post Date is within this week
- By Platform: Group by Platform
- By Theme: Group by Content Theme
- Calendar View: Calendar by Post Date

---

### Table 4: Brand Voice Guidelines

| Field Name | Type | Configuration | Description |
|------------|------|---------------|-------------|
| Guideline ID | Autonumber | - | Primary key |
| Active | Checkbox | - | Currently active? |
| Brand Voice Description | Long text | Required | Overall brand voice |
| Key Messaging Points | Long text | - | Core messages |
| Do's | Long text | - | What to do |
| Don'ts | Long text | - | What to avoid |
| Sample Posts | Long text | - | Example good posts |
| Prohibited Terms | Long text | - | Words/phrases to avoid |
| Emoji Policy | Single select | Encouraged, Minimal, None | Emoji usage |
| Tone Guidelines | Long text | - | Tone by platform |
| Hashtag Strategy | Long text | - | Hashtag approach |
| Updated Date | Last modified time | - | Auto-timestamp |
| Updated By | Single line text | - | Who updated |

**Views**:
- Active Guidelines: Active = true
- All Guidelines: Default view

---

## Workflow 4B: Scheduled Publishing (Future)

**Purpose**: Automatically publish scheduled posts to social platforms

**Trigger**: Cron (every hour, check for scheduled posts)

**Brief Design**:
```
1. Fetch posts where Scheduled Date = now ± 1 hour
2. For each post:
   - Get platform credentials
   - Call platform API (LinkedIn, Twitter, etc.)
   - Publish post
   - Save Platform Post ID
   - Update status to "Published"
3. Track performance metrics (if supported by API)
4. Send Slack notification of published posts
```

---

## Integration Points

### Buffer/Hootsuite Integration
```javascript
// Instead of direct platform publishing, send to Buffer
{
  "profile_ids": ["linkedin_id", "twitter_id"],
  "text": "{{ post.content }}",
  "media": {"link": "{{ post.image_url }}"},
  "scheduled_at": "{{ post.scheduled_date }}"
}
```

### Canva Integration (Future)
```
1. Post marked "Needs Image"
2. Send brief to Canva API
3. Generate branded graphic
4. Attach to post
5. Mark ready for scheduling
```

---

## LLM Prompt Library

### 4A.CONTENT_ANALYSIS.v1.0
- **Model**: Claude 3.5 Sonnet
- **Tokens**: ~1500 input, ~1000 output
- **Cost**: ~$0.08

### 4A.LINKEDIN_POST.v1.0
- **Model**: Claude 3.5 Sonnet
- **Tokens**: ~800 input, ~400 output
- **Cost**: ~$0.04

### 4A.TWITTER_THREAD.v1.0
- **Model**: Claude 3.5 Sonnet
- **Tokens**: ~700 input, ~350 output
- **Cost**: ~$0.03

### 4A.FACEBOOK_POST.v1.0
- **Model**: Claude 3.5 Sonnet
- **Tokens**: ~700 input, ~300 output
- **Cost**: ~$0.03

### 4A.INSTAGRAM_CAPTION.v1.0
- **Model**: Claude 3.5 Sonnet
- **Tokens**: ~600 input, ~300 output
- **Cost**: ~$0.03

### 4A.OPTIMIZE_HASHTAGS.v1.0
- **Model**: Gemini 2.0 Flash
- **Tokens**: ~400 input, ~200 output
- **Cost**: ~$0.005

**Total Cost per Generation** (4 platforms, 2 variants): ~$0.42

---

## Cost Optimization

### Current Cost Breakdown (4 platforms, 2 variants each)
```
Perplexity (context):  $0.05 (12%)
Claude (analysis):     $0.08 (19%)
Claude (8 posts):      $0.26 (62%)
Gemini (optimize):     $0.03 (7%)
────────────────────────────
Total:                 $0.42
```

### Optimization Opportunities
1. **Batch processing**: Generate multiple requests together (save 15%)
2. **Skip context research** for simple announcements (save $0.05)
3. **Use Gemini** for simpler posts (save 80% on those posts)
4. **Cache brand voice** in prompts (save 30-40% with prompt caching)

---

## Success Metrics

Track in Airtable:
- Posts generated per week
- Average engagement score
- Approval rate (% posts published without edits)
- Time saved (vs manual creation)
- Platform performance (which performs best)
- Variant testing results

---

**Implementation Status**: Ready for development
**Estimated Build Time**: 14-18 hours
**Prerequisites**: Brand voice documented, social platform access, Airtable setup
**Next Steps**: Document brand voice guidelines, configure LLM credentials, build workflow in n8n
