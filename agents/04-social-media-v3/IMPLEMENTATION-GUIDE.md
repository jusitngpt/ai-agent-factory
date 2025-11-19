# Social Media Agent V3 - Implementation Guide

## Quick Setup (60 minutes)

### Step 1: Twitter API Setup (15 min)

1. **Create Twitter Developer Account:**
   - Go to: https://developer.twitter.com/
   - Apply for developer access
   - Create new app (takes 5-10 min)

2. **Get API Credentials:**
   - App → Keys and Tokens
   - Copy: API Key, API Secret, Bearer Token
   - Generate: Access Token, Access Token Secret

3. **Enable Write Permissions:**
   - App Settings → Permissions → Read and Write
   - Regenerate tokens after changing permissions

**Note:** Twitter API access may require approval (can take 24-48 hours)

---

### Step 2: LinkedIn API Setup (15 min)

1. **Create LinkedIn Page:**
   - Must post to LinkedIn Page, not personal profile
   - Company must have LinkedIn Page

2. **Create LinkedIn App:**
   - Go to: https://www.linkedin.com/developers/apps
   - Create app, associate with your company page
   - Request permissions: `w_member_social`, `w_organization_social`

3. **Get Access Token:**
   - OAuth 2.0 flow (n8n handles this)
   - Authorize n8n to post on behalf of your page

---

### Step 3: Nano Banana Setup (10 min)

1. **Sign up:** https://nanobana.com/
2. **Get API key:** Dashboard → API Keys
3. **Configure defaults:**
   - Style: "Professional tech illustration"
   - Brand colors: Katalon purple + blue
   - Dimensions: 1200x675 (Twitter optimized)

**Alternative:** Use DALL-E or Midjourney API if preferred

---

### Step 4: Airtable Setup (10 min)

1. **Create tables:**
   - Table 1: "Blog Posts" (input)
   - Table 2: "Social Media Posts" (output log)

2. **Configure trigger view:**
   - In "Blog Posts" table
   - Create view: "Published"
   - Filter: Status = "Published"
   - Workflow only triggers on this view

3. **Get credentials:**
   - Personal Access Token
   - Base ID, Table IDs

---

### Step 5: n8n Configuration (10 min)

1. **Import workflow:**
   `/workflows/social-media-agent-v3.json`

2. **Add credentials:**
   - Airtable API (Node 1, 13)
   - Google Gemini API (Node 4)
   - Nano Banana API (Node 7)
   - Twitter OAuth (Node 9)
   - LinkedIn OAuth (Node 10)

3. **Configure Node 3:**
   - Customize content prompt for your brand voice
   - Adjust target audience

4. **Configure Node 7:**
   - Set brand colors
   - Adjust image style preferences

5. **Activate workflow**

---

### Step 6: Test (10 min)

1. **Create test blog post in Airtable:**
   ```
   Title: Test Post - Please Ignore
   URL: https://katalon.com/blog/test
   Summary: This is a test post for Social Media Agent V3
   Status: Published
   ```

2. **Verify execution:**
   - Check n8n execution log (should complete in 60-90s)
   - Twitter: Check your account for thread
   - LinkedIn: Check page for post
   - Airtable: Check "Social Media Posts" for new record

3. **Quality check:**
   - Content sounds natural?
   - Image looks professional?
   - Links work correctly?
   - Hashtags relevant?

4. **Clean up:**
   - Delete test posts from Twitter/LinkedIn
   - Mark Airtable test record as "Test"

---

## Customization

### Adjust Content Style

**Node 3 prompt modifications:**

```
For more casual tone:
"Conversational, friendly tone, use emojis, relatable language"

For more professional:
"Authoritative, data-driven, thought-leadership, minimal emojis"

For more technical:
"Deep technical insights, code examples, developer-focused"
```

### Change Image Style

**Node 7 Nano Banana settings:**

```
Modern minimal:
"style": "minimal flat design, clean lines, modern aesthetic"

Abstract geometric:
"style": "abstract geometric patterns, tech-inspired, futuristic"

Realistic 3D:
"style": "3D rendered tech scene, photorealistic, professional lighting"
```

### Add More Platforms

**Duplicate Node 10 for Facebook:**
- Node type: `n8n-nodes-base.facebook`
- Operation: Create page post
- Configure Facebook OAuth credential

---

## Content Calendar Integration

**Option 1: Schedule via Airtable:**
- Add "Schedule For" date field
- Workflow checks if date = today before posting
- Allows batching blog posts in advance

**Option 2: n8n Schedule Trigger:**
- Change Node 1 from Airtable trigger → Schedule trigger
- Query Airtable for "Status = Published AND Posted To Social = No"
- Post any unpublished blog posts
- Run daily at 10 AM

---

## Monitoring

**Daily:**
- Check Airtable "Social Media Posts" for failures
- Spot-check latest posts for quality

**Weekly:**
- Review engagement metrics
- Identify top-performing post formats
- Refine content prompt based on learnings

**Monthly:**
- Analyze engagement trends
- A/B test different content styles
- Update image prompts for variety

---

## Troubleshooting Quick Fixes

| Issue | Solution |
|-------|----------|
| Twitter API error 403 | Check app permissions = "Read and Write" |
| LinkedIn post fails | Verify page admin access, token not expired |
| Image generation fails | Check Nano Banana API credits, retry with simpler prompt |
| Content too generic | Enhance Node 3 prompt with more specific brand voice |
| Hashtags not relevant | Add hashtag examples to Node 3 prompt |

---

## Success Criteria

✅ Blog posts auto-posted within 2 minutes of publishing
✅ Twitter threads engaging (hook + value + CTA)
✅ LinkedIn posts professional (data-driven insights)
✅ Images consistent brand aesthetic
✅ 95%+ execution success rate
✅ 30-50% higher engagement vs manual posts

---

**Setup Time:** 60 minutes
**Monthly Maintenance:** 2 hours
**ROI:** 99.5% cost reduction vs manual

**Last Updated:** 2025-11-19
