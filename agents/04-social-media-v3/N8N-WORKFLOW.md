# Social Media Agent V3 - n8n Workflow

## Workflow ID: EFR7nvwO9690x54x

## Architecture (13 Nodes)

```
[1] Airtable Trigger → [2] Extract Blog Data → [3] Build Content Prompt
→ [4] Gemini Content Generation → [5] Extract JSON (Twitter + LinkedIn posts)
→ [6] Build Image Prompt → [7] Nano Banana Image Generation
→ [8] Split (Parallel Posting)
    → [9] Post to Twitter → [11] Get Twitter URL
    → [10] Post to LinkedIn → [12] Get LinkedIn URL
→ [13] Log to Airtable + Slack Notification
```

---

## Key Nodes

### Node 1: Airtable Trigger
**Type:** `n8n-nodes-base.airtableTrigger`
**Config:**
```json
{
  "event": "recordCreated",
  "table": "Blog Posts",
  "view": "Published",
  "polling": 60000  // Check every minute
}
```

### Node 3: Build Content Prompt
**Prompt Structure:**
```
Generate social media content for this blog post:

**Blog Title:** {{title}}
**Blog URL:** {{url}}
**Summary:** {{summary}}
**Target Audience:** QA professionals, test automation engineers, DevOps teams

**Generate 2 formats:**

1. TWITTER THREAD (4 tweets):
   - Tweet 1: Hook (max 280 chars, include engaging question or stat)
   - Tweet 2: Problem statement (pain point)
   - Tweet 3: Solution/insight from blog
   - Tweet 4: CTA with link
   - Include relevant hashtags (max 3)
   - Conversational, punchy tone

2. LINKEDIN POST (300-500 words):
   - Professional hook (data-driven)
   - 3-5 key takeaways (numbered or bulleted)
   - Real-world application
   - CTA to read blog
   - Include 4-5 relevant hashtags
   - Thought-leadership tone

Return as JSON:
{
  "twitter_thread": ["tweet 1", "tweet 2", "tweet 3", "tweet 4"],
  "linkedin_post": "full post text",
  "image_prompt": "Description for AI image generation (dashboard, abstract tech, etc.)"
}
```

### Node 4: Gemini Content Generation
**Type:** `@n8n/n8n-nodes-langchain.lmChatGoogleGemini`
**Config:**
```json
{
  "modelName": "gemini-2.0-flash-exp",
  "temperature": 0.7,  // Higher for creative social content
  "maxOutputTokens": 3000
}
```

### Node 7: Nano Banana Image Generation
**Type:** `n8n-nodes-base.httpRequest`
**API Endpoint:** `https://api.nanobana.com/v1/generate`
**Config:**
```json
{
  "method": "POST",
  "body": {
    "prompt": "={{$json.image_prompt}}",
    "style": "professional tech illustration",
    "dimensions": "1200x675",
    "brand_colors": ["#6200EA", "#0091EA"]  // Katalon purple + blue
  }
}
```

### Node 9: Post to Twitter
**Type:** `n8n-nodes-base.twitter`
**Operation:** Create tweet (thread)
**Config:**
```json
{
  "operation": "tweet",
  "text": "={{$json.twitter_thread[0]}}",
  "media": "={{$json.image_url}}",
  "thread": true,
  "replies": [
    "={{$json.twitter_thread[1]}}",
    "={{$json.twitter_thread[2]}}",
    "={{$json.twitter_thread[3]}}"
  ]
}
```

### Node 10: Post to LinkedIn
**Type:** `n8n-nodes-base.linkedin`
**Operation:** Create page post
**Config:**
```json
{
  "operation": "createPost",
  "pageId": "{{LINKEDIN_PAGE_ID}}",
  "text": "={{$json.linkedin_post}}",
  "media": "={{$json.image_url}}"
}
```

### Node 13: Log to Airtable
**Fields Updated:**
```json
{
  "Blog Title": "={{$json.blog_title}}",
  "Blog URL": "={{$json.blog_url}}",
  "Twitter URL": "={{$node['Get Twitter URL'].json.url}}",
  "LinkedIn URL": "={{$node['Get LinkedIn URL'].json.url}}",
  "Image URL": "={{$json.image_url}}",
  "Published At": "={{$now}}",
  "Status": "Posted",
  "Platforms": "Twitter, LinkedIn"
}
```

---

## Credentials Required

1. **Airtable API** - Personal Access Token
2. **Google Gemini API** - API key
3. **Nano Banana API** - API key (for image generation)
4. **Twitter API** - OAuth 1.0a (App + User tokens)
5. **LinkedIn API** - OAuth 2.0 (Page access)

---

## Performance

- **Execution Time:** 45-90 seconds
- **Cost per Post:** $0.15-$0.25
- **Success Rate:** 95%+
- **Image Generation:** 20-30s
- **Content Generation:** 10-20s

---

## Platform Limits

**Twitter:**
- Thread max: 25 tweets (we use 4)
- Image size: <5MB
- Rate limit: 300 posts/3 hours

**LinkedIn:**
- Post max: 3,000 characters
- Image size: <10MB
- Rate limit: 100 posts/day

---

**Last Updated:** 2025-11-19
