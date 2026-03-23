# Gemini Social Media Content Generation Prompt

**Node:** 4 - Content Generation
**Model:** Google Gemini 2.5 Pro (gemini-2.0-flash-exp)
**Temperature:** 0.7 (higher for creative social content)
**Max Output Tokens:** 3000

---

## Prompt Template

```
Generate social media content for this blog post:

**Blog Title:** {{$json.title}}
**Blog URL:** {{$json.url}}
**Summary:** {{$json.summary}}
**Category:** {{$json.category}}
**Target Audience:** QA professionals, test automation engineers, DevOps teams, engineering managers

---

## Your Task:

Create platform-optimized social media content in 2 formats:

### 1. TWITTER THREAD (4 tweets)

**Requirements:**
- **Tweet 1 (Hook):** Grab attention with a question, stat, or bold claim. Max 280 chars. Include emoji for visual interest.
- **Tweet 2 (Problem):** State the pain point this blog addresses. Make it relatable.
- **Tweet 3 (Insight):** Share a key takeaway or "aha" moment from the blog. Add value even if they don't click.
- **Tweet 4 (CTA):** Call to action with blog link. Invite engagement (comment, share).
- **Hashtags:** Max 3, relevant to QA/testing/DevOps. Avoid generic (#tech, #innovation).
- **Tone:** Conversational, punchy, approachable. Use "you", ask questions.

**Thread Structure:**
Each tweet should work standalone BUT also flow as a thread. Use thread hooks: "Here's why:", "The problem?", "The solution:"

### 2. LINKEDIN POST (300-500 words)

**Requirements:**
- **Opening Hook:** Professional but engaging. Lead with data, insight, or thought-provoking statement.
- **Body (3-5 key points):** Use numbered list or bullet points. Each point = 1-2 sentences.
- **Professional Tone:** Thought leadership, not promotional. Frame as industry insights/lessons.
- **Value First:** Provide enough value that readers benefit even if they don't click the blog.
- **CTA:** Invite to read full blog + encourage comments/discussion.
- **Hashtags:** 4-5 relevant industry hashtags at end.
- **Formatting:** Use line breaks, emojis for section headers (1️⃣ 2️⃣ 3️⃣), bullet points (•).

---

## Output JSON Format:

{
  "twitter_thread": [
    "Tweet 1 text (with emoji, max 280 chars)",
    "Tweet 2 text",
    "Tweet 3 text",
    "Tweet 4 text with {{BLOG_URL}}"
  ],

  "linkedin_post": "Full LinkedIn post text with formatting (300-500 words)",

  "image_prompt": "Description for AI image generation. Style: Professional tech illustration, modern SaaS aesthetic, Katalon brand colors (purple #6200EA, blue #0091EA). Be specific about visual concept but concise (1-2 sentences)."
}

---

## Content Guidelines:

### Twitter Best Practices:
- Use emojis strategically (1-2 per tweet max)
- Ask questions to boost engagement
- Thread should tell a story: Hook → Problem → Solution → Action
- Avoid jargon unless industry-standard (#CI/CD, #TestAutomation ok)

### LinkedIn Best Practices:
- Lead with data or counterintuitive insight
- Use "we", "our", "teams" (inclusive language)
- Share lessons, not just features
- End with question to spark comments
- Professional but human (not corporate-speak)

### Image Prompt Guidelines:
- Describe the concept, not design specs
- Good: "Dashboard showing test metrics with green checkmarks, isometric view"
- Bad: "1200x675 image with 3 panels and purple gradients"
- Focus on: What the image represents (concept) vs how it looks (let AI handle style)

---

## Example Output:

{
  "twitter_thread": [
    "🚨 We tested 50 test automation tools. Only 3 passed this simple challenge: Run 1,000 tests in under 10 minutes without infrastructure headaches. Here's what we learned:",

    "The problem? Most teams hit a wall at 100-200 automated tests. Why? ⏱️ Tests run sequentially (too slow) 🔧 Parallel execution = infrastructure complexity 💸 Cloud testing platforms = $$$ monthly bills",

    "The pattern we found: Teams that nail distributed testing share 3 traits: 1) Smart test selection (run only what changed) 2) Auto-scaling infrastructure 3) Built-in result aggregation No DIY required.",

    "Full breakdown of how high-performing teams run 1,000+ tests in minutes (without a DevOps degree): {{BLOG_URL}} What's your biggest test execution bottleneck? 👇 #TestAutomation #CI/CD #DevOps"
  ],

  "linkedin_post": "Test automation is broken at scale.\n\nAfter analyzing 50+ enterprise test automation implementations, we found a surprising pattern: Most teams abandon test automation or drastically reduce coverage once they hit 200-300 automated tests.\n\nWhy? The execution time problem.\n\nHere's the data:\n\n1️⃣ Sequential Execution Hell\n• Average test suite: 300 tests\n• Sequential execution time: 2-3 hours\n• Impact: Developers wait 3 hours for CI/CD feedback\n• Result: Teams reduce test coverage to speed up pipelines\n\n2️⃣ The Parallel Execution Trap\n• Solution: Run tests in parallel\n• Problem: Requires Kubernetes expertise, infrastructure management, result aggregation\n• Reality: 60% of teams lack DevOps resources to implement this\n\n3️⃣ Cloud Testing Cost Spiral\n• Cloud platforms solve the infrastructure problem\n• But: Costs scale linearly (more tests = higher bills)\n• Average: $500-2,000/month for 500-1,000 tests\n\nThe teams that solved this share 3 patterns:\n\n✓ Smart Test Selection: Run only tests affected by code changes (reduces execution by 70%)\n✓ Auto-Scaling Infrastructure: Spin up containers on-demand, shut down when done\n✓ Integrated Results: No manual aggregation from 50 parallel workers\n\nThe difference? High-performing teams run 1,000+ tests in under 10 minutes. Struggling teams run 200 tests in 2 hours.\n\nWe broke down the exact strategies, tools, and ROI calculations in our latest deep-dive.\n\nRead the full analysis: {{BLOG_URL}}\n\nWhat's your team's biggest test execution challenge? Drop a comment below.\n\n#TestAutomation #QualityAssurance #DevOps #ContinuousIntegration #SoftwareTesting",

  "image_prompt": "Modern dashboard displaying test automation metrics with green checkmarks and progress bars, isometric 3D style, purple and blue gradient background, clean tech aesthetic"
}
```

---

**Last Updated:** 2025-11-19
