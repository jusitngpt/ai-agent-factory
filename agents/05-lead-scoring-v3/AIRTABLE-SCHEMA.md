# Agent 5 Lead Scoring V3 - Airtable Schema

## Table: Leads

### Input Fields (Form Submission)
| Field | Type | Source |
|-------|------|--------|
| Name | Single line text | Form |
| Email | Email | Form |
| Company | Single line text | Form |
| Job Title | Single line text | Form |
| Company Size | Single select | Form |
| Industry | Single select | Form |
| Phone | Phone | Form (optional) |
| Company Website | URL | Form (optional) |
| Message | Long text | Form |
| Form Source | Single select | Form tracking |
| UTM Source | Single line text | URL parameter |
| Created Time | Created time | Auto |

### Scoring Output Fields (Written by Workflow)
| Field | Type | Description |
|-------|------|-------------|
| Lead Score | Number (0-100) | Total score |
| Routing | Single select | Enterprise/SMB/Nurture |
| Company Fit Score | Number (0-25) | Company match |
| Role Fit Score | Number (0-20) | Role authority |
| Intent Score | Number (0-20) | Urgency signals |
| Engagement Score | Number (0-10) | Activity level |
| Geo Fit Score | Number (0-10) | Market match |
| Budget Score | Number (0-10) | Budget indicators |
| Strategic Score | Number (0-5) | Strategic value |
| Key Signals | Long text | Comma-separated |
| Recommended Actions | Long text | Line-separated |
| Talking Points | Long text | Line-separated |
| Red Flags | Long text | Issues/concerns |
| Status | Single select | New/Scored/Contacted/Qualified/Lost |
| Scored At | Date & time | Timestamp |
| Assigned To | User | Sales rep |

### Single Select Options

**Company Size:**
- 1-10 employees
- 11-50 employees
- 51-200 employees
- 201-500 employees
- 501-1000 employees
- 1000+ employees

**Industry:**
- SaaS/Software
- E-commerce
- Financial Services
- Healthcare
- Manufacturing
- Other

**Form Source:**
- Demo Request (highest intent)
- Contact Sales
- Free Trial
- Whitepaper Download
- Webinar Registration
- Newsletter Signup

**Routing:**
- Enterprise (Score 75-100)
- SMB (Score 50-74)
- Nurture (Score 0-49)

**Status:**
- New (just created)
- Scored (workflow complete)
- Contacted (rep reached out)
- Qualified (SQL)
- Lost (disqualified)

---

## Recommended Views

### 1. High-Priority Leads
- **Filter:** Lead Score >= 75 AND Status = "Scored"
- **Sort:** Lead Score (desc)
- **Purpose:** Enterprise AEs focus on top leads

### 2. SMB Queue
- **Filter:** Routing = "SMB" AND Status = "Scored"
- **Sort:** Created Time (desc)
- **Purpose:** SMB team round-robin

### 3. Nurture List
- **Filter:** Routing = "Nurture"
- **Purpose:** Marketing automation sync

---

**Last Updated:** 2025-11-19
