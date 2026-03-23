# Gemini Lead Scoring Prompt

**Node:** 4 - Gemini Analysis
**Model:** Google Gemini 2.5 Pro (gemini-2.0-flash-exp)
**Temperature:** 0.3
**Max Output Tokens:** 2000

---

## Prompt Template

```
Analyze this lead and provide multi-dimensional scoring (0-100 scale).

**Lead Information:**
- Name: {{$json.name}}
- Email: {{$json.email}}
- Company: {{$json.company}}
- Job Title: {{$json.job_title}}
- Company Size: {{$json.company_size}}
- Industry: {{$json.industry}}
- Phone: {{$json.phone}}
- Company Website: {{$json.company_website}}
- Message: {{$json.message}}
- Form Source: {{$json.form_source}}
- UTM Source: {{$json.utm_source}}

---

## Scoring Criteria (Total: 0-100)

### 1. Company Fit (0-25 points)
Score based on:
- **Industry Match** (0-10):
  - 10: SaaS/Software, E-commerce, Financial Services (perfect fit)
  - 7-9: Tech-adjacent (Healthcare IT, Manufacturing with dev teams)
  - 4-6: Traditional with QA needs (Healthcare, Education)
  - 1-3: Low fit industries
  - 0: Not relevant

- **Company Size** (0-10):
  - 10: 50-500 employees (sweet spot)
  - 8-9: 501-1000 employees
  - 6-7: 20-49 employees or 1001-5000 employees
  - 3-5: 10-19 employees
  - 1-2: 1-9 employees or 5000+ (different sales motion)

- **Tech Stack Indicators** (0-5):
  - Mentions Selenium, Jenkins, CI/CD tools: +5
  - Mentions competing tools: +4
  - Mentions testing challenges: +3
  - Generic inquiry: +1

### 2. Role Fit (0-20 points)
- VP/Director of Engineering/QA: 20 points
- QA Manager/Test Lead: 15 points
- Engineering Manager: 12 points
- Senior QA Engineer/SDET: 8 points
- QA Engineer: 5 points
- Developer (mentions testing): 5 points
- Other roles: 0-3 points

### 3. Intent Signals (0-20 points)
- **Form Source** (0-10):
  - Demo Request: 10
  - Contact Sales: 9
  - Free Trial: 8
  - Pricing Page: 7
  - Whitepaper/Guide Download: 5
  - Webinar Registration: 4
  - Newsletter Signup: 2

- **Message Content** (0-10):
  - Mentions competitor by name: +5
  - Mentions timeline (Q1, ASAP, urgent): +3
  - Mentions budget/pricing: +2
  - Specific use case described: +2
  - Mentions team size: +1
  - Generic inquiry: 0

### 4. Engagement Level (0-10 points)
- Multiple touchpoints (UTM source shows returning): +5
- Downloaded content previously: +3
- Detailed message (>100 words): +2
- Complete profile (all fields filled): +2
- Phone number provided: +1

### 5. Geographic Fit (0-10 points)
- North America (US, Canada): 10
- Western Europe (UK, Germany, France): 9
- Australia/New Zealand: 8
- Rest of Europe: 7
- APAC (Singapore, Japan): 6
- Latin America: 5
- Other regions: 3

### 6. Budget Indicators (0-10 points)
- Company funded (Series A+): +5
- Paying for competitor tool: +4
- Team size >20 (budget proxy): +3
- Enterprise company size: +2
- References pricing/budget in message: +2

### 7. Strategic Value (0-5 points)
- Notable brand (Fortune 500, unicorn): +5
- High-growth company (hiring, funded): +3
- Potential case study: +2
- Expansion opportunity (large org): +2

---

## Output JSON Format:

{
  "company_fit_score": 0-25,
  "role_fit_score": 0-20,
  "intent_score": 0-20,
  "engagement_score": 0-10,
  "geo_fit_score": 0-10,
  "budget_score": 0-10,
  "strategic_score": 0-5,

  "key_signals": [
    "Most important signal 1 (e.g., 'VP-level buyer', 'Mentions Selenium migration')",
    "Signal 2",
    "Signal 3"
  ],

  "recommended_actions": [
    "Specific action 1 (e.g., 'Contact within 4 hours - high urgency')",
    "Action 2",
    "Action 3"
  ],

  "talking_points": [
    "Point to emphasize 1 (e.g., 'Selenium expertise - position as enterprise-ready alternative')",
    "Point 2"
  ],

  "red_flags": [
    "Concern 1 (e.g., 'Personal email address')",
    "Concern 2"
  ]
}

Return ONLY valid JSON. No markdown, no code blocks.
```

---

## Example Input

```json
{
  "name": "John Doe",
  "email": "john.doe@acmesaas.com",
  "company": "Acme SaaS",
  "job_title": "VP Engineering",
  "company_size": "201-500 employees",
  "industry": "SaaS/Software",
  "phone": "+1-555-123-4567",
  "company_website": "https://acmesaas.com",
  "message": "We're looking to replace Selenium with a more maintainable solution. Need something that works for our 50-person QA team. Evaluating options for Q1 decision.",
  "form_source": "Demo Request",
  "utm_source": "google-cpc"
}
```

## Example Output

```json
{
  "company_fit_score": 23,
  "role_fit_score": 20,
  "intent_score": 18,
  "engagement_score": 8,
  "geo_fit_score": 10,
  "budget_score": 9,
  "strategic_score": 5,

  "key_signals": [
    "VP-level decision maker (high authority)",
    "Mentioned Selenium replacement (active evaluation, competitive win opportunity)",
    "Q1 timeline (high urgency, 2-3 month sales cycle)",
    "50-person QA team (significant budget, enterprise deal)",
    "Demo request (high intent signal)"
  ],

  "recommended_actions": [
    "URGENT: Contact within 4 hours (express interest while evaluation is hot)",
    "Prepare Selenium migration case study and ROI calculator",
    "Offer executive briefing with CTO + personalized demo for 50-person team scenario",
    "Research Acme SaaS tech stack (LinkedIn, job postings) before call"
  ],

  "talking_points": [
    "Selenium expertise: Position Katalon as 'Selenium, but enterprise-ready' with built-in features",
    "Team scale: Emphasize Katalon's team collaboration, test management for 50+ QA team",
    "Maintenance burden: Highlight self-healing tests, smart waits to reduce maintenance vs Selenium",
    "ROI: Show cost savings - licensing + reduced maintenance time for 50-person team"
  ],

  "red_flags": []
}
```

---

**Last Updated:** 2025-11-19
