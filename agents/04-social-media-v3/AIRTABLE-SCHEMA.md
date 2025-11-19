# Social Media Agent V3 - Airtable Schema

## Table 1: Blog Posts (Input)

### Fields
| Field | Type | Purpose |
|-------|------|---------|
| Title | Single line text | Blog post title |
| URL | URL | Blog post link |
| Summary | Long text | 2-3 sentence summary |
| Published Date | Date | When blog went live |
| Category | Single select | Content type |
| Status | Single select | Draft/Published/Archived |

### Single Select Options

**Category:**
- Tutorial
- Case Study
- Product Update
- Industry Insights
- Best Practices

**Status:**
- Draft (not posted to social)
- Published (triggers workflow)
- Archived (ignored)

---

## Table 2: Social Media Posts (Output)

### Fields
| Field | Type | Purpose |
|-------|------|---------|
| Blog Title | Single line text | Reference to source blog |
| Blog URL | URL | Link to blog post |
| Twitter URL | URL | Link to posted tweet thread |
| LinkedIn URL | URL | Link to LinkedIn post |
| Image URL | URL | AI-generated image |
| Twitter Engagement | Number | Likes + RTs + replies |
| LinkedIn Engagement | Number | Likes + comments + shares |
| Published At | Date & time | When posted |
| Status | Single select | Posted/Failed/Scheduled |
| Platforms | Multiple select | Twitter/LinkedIn/Facebook |

### Automation Recommendations

**Auto-link to Blog Posts table:**
- Link field: "Blog Post" → Links to Table 1
- Auto-populate blog details when linked

**Engagement tracking automation:**
- Manual update field for Twitter engagement
- Manual update field for LinkedIn engagement
- Formula: Total Engagement = Twitter + LinkedIn

---

## View Recommendations

### 1. Recent Posts
- **Filter:** Published At >= 30 days ago
- **Sort:** Published At (desc)
- **Purpose:** Monitor recent social activity

### 2. High Engagement
- **Filter:** Total Engagement > 100
- **Sort:** Total Engagement (desc)
- **Purpose:** Identify top-performing content

### 3. Failed Posts
- **Filter:** Status = "Failed"
- **Purpose:** Troubleshoot posting issues

---

**Last Updated:** 2025-11-19
