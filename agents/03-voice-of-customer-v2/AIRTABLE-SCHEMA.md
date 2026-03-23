# Agent-3 Voice of Customer V2 - Airtable Schema

## Table: Competitor VOC Analysis

### Field Summary

| # | Field Name | Type | Purpose |
|---|------------|------|---------|
| 1 | Competitor Name | Single line text | Competitor identifier |
| 2 | Analysis Date | Date & time | When analysis performed |
| 3 | Overall Rating | Single line text | Aggregate rating (X.X/5) |
| 4 | Rating Trend | Single select | Improving/Stable/Declining |
| 5 | Review Volume | Single line text | Total + recent counts |
| 6 | Verified Percentage | Single line text | % verified reviews |
| 7 | Sentiment Distribution | Long text (JSON) | Positive/neutral/negative % |
| 8 | Executive Summary | Long text | Strategic overview |
| 9 | Positive Themes (JSON) | Long text | Array of positive themes |
| 10 | Negative Themes (JSON) | Long text | Array of negative themes |
| 11 | Strengths vs Katalon (JSON) | Long text | Competitive advantages |
| 12 | Weaknesses vs Katalon (JSON) | Long text | Competitive vulnerabilities |
| 13 | Product Priorities (JSON) | Long text | Recommended product actions |
| 14 | Messaging Opportunities (JSON) | Long text | Marketing angles |
| 15 | CS Tactics (JSON) | Long text | Customer success actions |
| 16 | Reviewer Personas | Long text | Common job titles/roles |
| 17 | Company Size Distribution | Single line text | SMB/Mid/Enterprise % |
| 18 | Primary Use Cases | Long text | Common applications |
| 19 | Strategic Priority Score | Number (1-100) | Importance rating |
| 20 | Analysis Confidence | Single select | High/Medium/Low |
| 21 | Data Freshness | Single line text | Recency indicator |
| 22 | Review Frequency | Single select | Monthly/Quarterly |
| 23 | Workflow Execution ID | Single line text | n8n reference |
| 24 | Status | Single select | Analysis lifecycle |
| 25 | Assigned To | User | Responsible team member |
| 26 | Action Items | Long text | Follow-up tasks |
| 27 | Notes | Long text | Additional observations |

---

## Detailed Field Specifications

### 4. Rating Trend

**Type:** Single select

**Options:**
- Improving (+0.2 or more vs 6 months ago)
- Stable (±0.1)
- Declining (-0.2 or more)
- New (first analysis, no historical data)

**Usage:** Track sentiment trajectory over time

---

### 9. Positive Themes (JSON)

**Example Structure:**
```json
[
  {
    "theme": "Easy to use for beginners",
    "frequency": "High",
    "mention_percentage": "45%",
    "representative_quotes": [
      "Very intuitive, our manual testers were productive in days",
      "Best tool for teams with mixed technical skills",
      "Drag-and-drop interface saves so much time"
    ],
    "features_praised": ["Visual test recorder", "Low-code scripting", "Built-in tutorials"],
    "strategic_implication": "Ease of use is major differentiator vs code-heavy competitors"
  },
  {
    "theme": "Excellent customer support",
    "frequency": "Medium",
    "mention_percentage": "30%",
    "representative_quotes": [
      "Support team responds within hours",
      "Very helpful onboarding process"
    ],
    "features_praised": ["Live chat support", "Dedicated CSM for enterprise"],
    "strategic_implication": "Support quality drives retention and NPS"
  }
]
```

---

### 10. Negative Themes (JSON)

**Example Structure:**
```json
[
  {
    "theme": "Steep learning curve for advanced features",
    "frequency": "High",
    "mention_percentage": "35%",
    "representative_quotes": [
      "Easy to start, hard to master",
      "Documentation for advanced scenarios is lacking",
      "Took months to fully utilize all capabilities"
    ],
    "features_criticized": ["Scripting mode", "Custom keywords", "Advanced reporting"],
    "strategic_implication": "OPPORTUNITY: Improve advanced documentation, create certification program"
  }
]
```

---

### 11. Strengths vs Katalon (JSON)

**Example:**
```json
[
  {
    "strength": "Completely free and open source (Selenium)",
    "evidence": "50% of positive reviews mention 'no cost' or 'free'",
    "threat_level": "High"
  },
  {
    "strength": "Faster test execution (Cypress)",
    "evidence": "Tests run 2-3x faster than Selenium-based tools per reviews",
    "threat_level": "Medium"
  }
]
```

---

### 12. Weaknesses vs Katalon (JSON)

**Example:**
```json
[
  {
    "weakness": "No built-in test management (Selenium)",
    "evidence": "40% of reviews cite need for separate test management tool",
    "opportunity_level": "High"
  },
  {
    "weakness": "Limited browser support (Cypress)",
    "evidence": "35% of negative reviews mention Chrome-only limitation",
    "opportunity_level": "High"
  }
]
```

---

### 13. Product Priorities (JSON)

**Example:**
```json
[
  {
    "recommendation": "Add AI-powered test healing feature",
    "rationale": "30% of competitor negative reviews cite 'flaky tests' and 'maintenance burden'",
    "priority": "High",
    "expected_impact": "Reduce test maintenance by 40%, major differentiator",
    "effort_estimate": "High (6-9 months)"
  }
]
```

---

### 14. Messaging Opportunities (JSON)

**Example:**
```json
[
  {
    "angle": "The only tool that's both easy for beginners AND powerful for experts",
    "target_audience": "Teams with mixed skill levels (common in SMB/Mid-Market)",
    "competitor_vulnerability": "Selenium too complex, Cypress too limited - neither balance ease + power",
    "proof_points": [
      "Visual recorder for manual testers",
      "Full scripting mode for developers",
      "65% of teams report productivity in first week"
    ]
  }
]
```

---

### 15. CS Tactics (JSON)

**Example:**
```json
[
  {
    "tactic": "Proactive check-in at 30-day mark for advanced feature training",
    "problem_addressed": "35% of competitor churn due to 'couldn't utilize advanced features'",
    "implementation": "Automated email at day 30 offering 1:1 training session",
    "expected_outcome": "Reduce early-stage churn by 20%, increase feature adoption"
  }
]
```

---

## Recommended Views

### 1. Latest Analysis (Default)
- **Filter:** Analysis Date >= 30 days ago
- **Sort:** Analysis Date (desc)
- **Fields:** Competitor Name, Overall Rating, Rating Trend, Executive Summary, Status

### 2. High Priority Insights
- **Filter:** Strategic Priority Score >= 75
- **Sort:** Strategic Priority Score (desc)
- **Fields:** All

### 3. By Competitor Trend
- **Group By:** Competitor Name
- **Sort:** Analysis Date (desc)
- **Purpose:** Track competitor sentiment over time

### 4. Product Opportunities
- **Filter:** Weaknesses vs Katalon (JSON) is not empty
- **Sort:** Strategic Priority Score (desc)
- **Fields:** Competitor Name, Weaknesses, Product Priorities, Priority Score

---

## Automation Recommendations

### 1. High Priority Alert
- **Trigger:** Strategic Priority Score >= 85
- **Action:** Slack DM to product lead + marketing lead

### 2. Monthly Summary
- **Trigger:** 5 records created in same month
- **Action:** Generate executive summary report, email to leadership

### 3. Trend Alert
- **Trigger:** Rating Trend = "Declining" for Katalon (if tracking Katalon)
- **Action:** Immediate alert to customer success team

---

**Last Updated:** 2025-11-19
**Schema Version:** 2.0
**Status:** ✅ Production Ready
