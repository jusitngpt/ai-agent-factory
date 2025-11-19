# Social Media Agent V3 - Troubleshooting

## Common Issues

### 1. Twitter Posting Fails (403 Forbidden)

**Symptoms:** Node 9 error "You do not have write permissions"

**Solutions:**

1. **Check app permissions:**
   - Twitter Developer Portal → Your App → Settings
   - Permissions: Must be "Read and Write"
   - If changed, regenerate Access Token and Access Token Secret

2. **Verify correct credentials:**
   - n8n → Credentials → Twitter OAuth 1.0a
   - Must use Access Token (not just API Key)

3. **Test API access:**
   ```bash
   # Use Twitter API tester
   curl -X POST "https://api.twitter.com/2/tweets" \
     -H "Authorization: Bearer YOUR_TOKEN" \
     -d '{"text":"test"}'
   ```

---

### 2. LinkedIn Posting Fails

**Symptoms:** Node 10 error "Invalid access token"

**Causes & Solutions:**

1. **Token expired (expires after 60 days):**
   - n8n → Credentials → LinkedIn OAuth2
   - Click "Reconnect"
   - Re-authorize app

2. **Missing page permissions:**
   - LinkedIn → App settings
   - Verify: `w_organization_social` permission granted
   - Re-request if missing

3. **Not admin of page:**
   - LinkedIn Page → Admins → Verify you're listed
   - Must be Super Admin or Content Admin

---

### 3. Image Generation Fails

**Symptoms:** Node 7 timeout or error

**Solutions:**

1. **Nano Banana API credits depleted:**
   - Check: nanobana.com/dashboard
   - Add credits if needed

2. **Prompt too complex:**
   - Simplify image prompt in Node 3
   - Remove specific details, use generic descriptions
   - Example: "tech dashboard" instead of "dashboard showing 15 metrics with green/red indicators"

3. **Timeout (image generation slow):**
   - Node 7 → Settings → Timeout: 60000ms (1 minute)

4. **Alternative: Use Unsplash stock photos:**
   - Add Unsplash node instead of Nano Banana
   - Search for relevant image based on blog category
   - Free, no API cost

---

### 4. Content Quality Issues

**Symptoms:** Posts sound generic, not engaging

**Solutions:**

1. **Enhance Gemini prompt (Node 3):**
   ```
   Add specific examples of good posts:

   "Example Twitter hook:
   🚨 We tested 50 test automation tools. Only 3 passed this challenge:"

   "Example LinkedIn opening:
   Test automation is broken. Here's the data to prove it:"
   ```

2. **Increase creativity:**
   - Node 4 → Temperature: 0.7 → 0.8
   - More varied, creative output

3. **Provide more blog context:**
   - Node 2: Extract more than just title/URL/summary
   - Include: Key stats, quotes, main takeaway
   - Pass to Node 3 for richer content generation

---

### 5. Posts Not Triggering

**Symptoms:** Blog published but no social posts

**Solutions:**

1. **Airtable view filter issue:**
   - Node 1 → Verify "view" matches your Airtable
   - Blog must be in "Published" view to trigger

2. **Status field mismatch:**
   - Check Status field = exactly "Published" (case-sensitive)

3. **Polling interval too long:**
   - Node 1 → Polling: 60000ms (1 min)
   - Reduce to 30000ms (30s) if needed

4. **Workflow not active:**
   - n8n → Workflows → Verify "Active" status

---

### 6. Twitter Thread Breaks/Doesn't Link

**Symptoms:** 4 separate tweets instead of thread

**Causes:**
- Twitter API changed thread format
- Reply-to-tweet ID missing

**Solutions:**

1. **Use Twitter v2 API threading:**
   - Node 9 → Configure `reply_settings`
   - Include `in_reply_to_tweet_id` for each tweet

2. **Manual thread creation:**
   ```
   Tweet 1 → Get tweet ID
   Tweet 2 → Reply to Tweet 1 ID
   Tweet 3 → Reply to Tweet 2 ID
   Tweet 4 → Reply to Tweet 3 ID
   ```

3. **Simplify to single tweet:**
   - If threading too complex, post 1 tweet only
   - Include image + link + summary

---

### 7. High API Costs

**Symptoms:** Gemini + Nano Banana costs >$0.50/post

**Expected:** $0.15-$0.25/post

**Solutions:**

1. **Reduce Gemini tokens:**
   - Node 4 → maxOutputTokens: 3000 → 2000

2. **Simplify image generation:**
   - Use same image template for all posts
   - Only generate new image weekly
   - Store/reuse generic brand images

3. **Use cheaper image source:**
   - Switch from Nano Banana → Unsplash (free)
   - Or Pexels API (free stock photos)

---

### 8. Hashtags Not Relevant

**Symptoms:** Generic hashtags like #tech #innovation

**Solutions:**

**Node 3 prompt enhancement:**
```
"Generate hashtags specific to:
- QA testing (e.g., #TestAutomation, #QualityAssurance)
- DevOps (e.g., #CI/CD, #DevOps)
- Specific tools mentioned (e.g., #Selenium, #Playwright)

Avoid generic hashtags like: #tech, #innovation, #software
Maximum 3 hashtags for Twitter, 5 for LinkedIn."
```

---

### 9. LinkedIn Post Formatting Lost

**Symptoms:** Bullets/numbers don't display correctly

**Cause:** LinkedIn API doesn't preserve all markdown

**Solutions:**

1. **Use Unicode symbols:**
   ```
   Instead of: 1. First point
   Use: 1️⃣ First point

   Instead of: - Bullet
   Use: • Bullet or ✓ Checkmark
   ```

2. **Update Node 3 prompt:**
   ```
   "Format LinkedIn post with:
   - Use emoji numbers (1️⃣ 2️⃣ 3️⃣) instead of 1. 2. 3.
   - Use bullet points (•) or checkmarks (✓)
   - Double line breaks between paragraphs"
   ```

---

### 10. Image Doesn't Upload to Twitter/LinkedIn

**Symptoms:** Post succeeds but no image attached

**Causes & Solutions:**

1. **Image URL not accessible:**
   - Nano Banana image URL expired
   - Solution: Download image to n8n, then upload
   ```
   Add HTTP Request node:
   → Download image from Nano Banana URL
   → Convert to binary data
   → Pass to Twitter/LinkedIn nodes
   ```

2. **Image too large:**
   - Twitter: Max 5MB
   - LinkedIn: Max 10MB
   - Solution: Resize in Nano Banana API call

3. **Wrong image format:**
   - Use: JPG or PNG
   - Avoid: GIF (for static images), WebP

---

## Error Code Reference

| Code | Platform | Meaning | Quick Fix |
|------|----------|---------|-----------|
| 403 | Twitter | No write permission | Enable Read+Write in app settings |
| 401 | LinkedIn | Token expired | Reconnect OAuth credential |
| 429 | Twitter | Rate limit (300 posts/3hr) | Wait or reduce posting frequency |
| 400 | Nano Banana | Invalid prompt | Simplify image description |
| 500 | Any | Server error | Retry, check platform status |

---

## Emergency Procedures

### Complete Failure - Manual Fallback

1. **Disable workflow:**
   - n8n → Deactivate Social Media Agent V3

2. **Manual posting process:**
   ```
   For each new blog:
   1. Copy blog link
   2. Use ChatGPT to draft social posts
   3. Use Canva to create image
   4. Post manually to Twitter + LinkedIn
   ```

3. **Log in Airtable:**
   - Manually create record in "Social Media Posts"
   - Status: "Manual" (so you know which were affected)

4. **Debug and restore:**
   - Check n8n execution logs
   - Fix root cause
   - Reactivate workflow

---

## Getting Help

**Before requesting support:**
- Error message (exact text)
- Node that failed (Node 9, 10, etc.)
- Execution ID
- Platform (Twitter/LinkedIn/Nano Banana)

**Support:**
- Twitter API: https://twittercommunity.com/
- LinkedIn API: LinkedIn Developer Support
- Nano Banana: support@nanobana.com
- n8n: https://community.n8n.io/

---

**Last Updated:** 2025-11-19
**Status:** ✅ Production Ready
