# On-Demand Competitive Research - Detailed Methodology

## Overview

This document provides an in-depth explanation of how Agent 1A conducts on-demand competitive research, including research methodology, quality assurance processes, and best practices for getting optimal results.

## Research Methodology

### Phase 1: Information Gathering (Perplexity AI)

#### What We Research

**Primary Sources**:
- Company official website
- Official blog and press releases
- Product documentation
- Pricing pages (if public)

**Secondary Sources**:
- Tech news coverage (TechCrunch, VentureBeat, etc.)
- Review platforms (G2, Capterra, Trustpilot)
- Social media (LinkedIn, Twitter/X)
- Financial news (if public company)
- Industry analyst reports (Gartner, Forrester)

**Tertiary Sources**:
- Reddit discussions
- HackerNews threads
- Glassdoor reviews (company culture insights)
- GitHub activity (for tech companies)

#### Research Depth Levels

**Standard Research** (Default)
- 10-15 sources analyzed
- Focus on last 6 months of information
- 3-5 minute execution time
- Cost: ~$0.20

**Deep Dive Research** (On Request)
- 20-30 sources analyzed
- Historical data (1-2 years)
- 5-8 minute execution time
- Cost: ~$0.40

**Quick Scan** (On Request)
- 5-8 sources analyzed
- Most recent information only
- 2-3 minute execution time
- Cost: ~$0.10

### Phase 2: Strategic Analysis (Claude)

#### Analysis Framework

We use a modified **Porter's Five Forces** + **SWOT** approach:

**1. Company Positioning**
- Market segment
- Target customers
- Value proposition
- Brand positioning

**2. Competitive Forces**
- Direct competitors
- Indirect/adjacent competitors
- Substitutes
- Market barriers

**3. Internal Assessment**
- Strengths (competitive advantages)
- Weaknesses (vulnerabilities)
- Core capabilities
- Resource constraints

**4. Market Dynamics**
- Industry trends
- Technology shifts
- Regulatory changes
- Customer behavior changes

**5. Strategic Implications**
- Opportunities for our team
- Threats to monitor
- Recommended actions
- Differentiation strategies

#### Analysis Quality Indicators

Claude provides a **confidence score** (0-100) based on:
- Source quality and recency
- Data completeness
- Consistency across sources
- Public information availability

**Score Interpretation**:
- 90-100: High confidence, multiple credible sources
- 75-89: Good confidence, adequate source coverage
- 60-74: Moderate confidence, limited public information
- Below 60: Low confidence, very limited data (manual review recommended)

### Phase 3: Structured Output (Gemini)

#### Output Formatting

Gemini converts the analysis into a structured format optimized for:
- Airtable database storage
- Quick scanning by users
- Downstream processing (reports, dashboards)
- Integration with other tools

**JSON Schema**:
```json
{
  "executive_summary": "Business-friendly overview",
  "key_findings": ["Actionable insights"],
  "competitive_advantages": ["Their strengths"],
  "weaknesses": ["Their vulnerabilities"],
  "recommendations": ["What we should do"],
  "competitor_names": ["List of competitors"],
  "industries": ["Market categories"],
  "confidence_score": 85
}
```

## Quality Assurance

### Automated Checks

**Pre-Execution**:
- ✅ Company name validation (not empty, reasonable length)
- ✅ Duplicate request detection (warn if researched recently)
- ✅ API key validity
- ✅ Airtable connection

**During Execution**:
- ✅ Response validation (not empty, expected format)
- ✅ Token usage monitoring (alert if excessive)
- ✅ Timeout protection (max 5 minutes)
- ✅ Error rate tracking

**Post-Execution**:
- ✅ Output completeness (all required fields present)
- ✅ Source citation validation (URLs accessible)
- ✅ Confidence score check (flag if <60)
- ✅ Cost validation (alert if >$0.50)

### Manual Review Triggers

Research is flagged for human review if:
- Confidence score < 60
- Very limited source availability (<5 sources)
- Contradictory information detected
- Unusually high cost (>$0.50)
- User-reported inaccuracy

### Accuracy Validation

**Ongoing Process**:
1. Random sampling (10% of reports monthly)
2. Expert review by GTM team
3. Comparison with manual research
4. User feedback collection
5. Prompt iteration based on findings

**Historical Accuracy**: 87% (as of Nov 2025)

## Best Practices for Users

### Writing Effective Research Requests

#### Company Name

**Good Examples**:
- "Stripe" ✅
- "Salesforce" ✅
- "OpenAI" ✅

**Bad Examples**:
- "that payment company" ❌
- "SFDC" ❌ (use full name "Salesforce")
- "www.stripe.com" ❌ (just company name)

#### Research Focus

**Good Examples** (Specific):
- "Developer experience and API design compared to competitors" ✅
- "Pricing strategy for enterprise customers" ✅
- "Recent product launches in AI/ML space" ✅
- "Market share in European fintech market" ✅

**Bad Examples** (Too Vague):
- "Everything about them" ❌
- "General info" ❌
- "What they do" ❌

**Good Examples** (Contextual):
- "We're launching a new payment API - how does Stripe position their developer tools?" ✅
- "Preparing for Q4 competitive analysis - focus on their enterprise features" ✅

### Optimizing Research Quality

#### Timing Matters

**Best Times**:
- After competitor product launches
- Before quarterly business reviews
- Prior to pricing decisions
- When entering new markets

**Avoid**:
- Researching same company >1x per week (diminishing returns)
- Running 10+ requests simultaneously (degrades quality)

#### Focus Areas That Work Well

**Highly Effective**:
- Product feature comparisons
- Pricing and packaging analysis
- Target market positioning
- Recent news and developments
- Technology stack (for tech companies)

**Less Effective**:
- Financial performance (unless public company)
- Internal processes and culture
- Proprietary technology details
- Unreleased product information
- Executive compensation

### Interpreting Results

#### Executive Summary
- Read this first for quick overview
- 2-3 paragraphs covering who, what, why
- Suitable for sharing with executives

#### Key Findings
- Actionable insights you can use immediately
- Typically 5-7 bullet points
- Focus on differentiation opportunities

#### Competitive Advantages
- What makes them strong
- Consider: Can we match? Should we avoid? Can we counter?

#### Weaknesses
- Where they're vulnerable
- Opportunities for differentiation
- Features/markets to target

#### Recommendations
- Specific actions for our team
- Prioritized by impact
- Based on strategic analysis

#### Sources
- Always review sources for credibility
- Click through to verify critical facts
- Note publication dates (recency matters)

## Advanced Use Cases

### 1. Competitive Battle Cards

**Workflow**:
1. Research primary competitor (Agent 1A)
2. Extract key findings → Battle card template
3. Schedule quarterly updates (Agent 1B future feature)
4. Distribute to sales team

**Research Focus**: "Feature comparison, pricing, customer testimonials, common objections"

### 2. Market Entry Research

**Workflow**:
1. Research top 5 players in new market
2. Analyze common patterns
3. Identify market gaps
4. Build differentiation strategy

**Research Focus**: "Target customers, pricing models, go-to-market strategies"

### 3. Pre-Sales Competitive Intel

**Workflow**:
1. Sales identifies competitor in deal
2. Submit research request (High priority)
3. Review results before customer call
4. Use insights for positioning

**Research Focus**: "Enterprise features, pricing, implementation process, customer references"

### 4. Product Roadmap Intelligence

**Workflow**:
1. Monthly research on key competitors
2. Track product announcements
3. Identify feature trends
4. Inform product priorities

**Research Focus**: "Recent product launches, beta features, public roadmap items"

### 5. Investment Due Diligence

**Workflow**:
1. Research acquisition target
2. Analyze competitive position
3. Assess market threats
4. Validate strategic fit

**Research Focus**: "Market position, competitive moat, growth trajectory, vulnerabilities"

## Research Request Templates

### Template 1: New Competitor Discovery

```
Company Name: [Company]
Research Focus: We've identified them as a potential competitor. Provide overview of their product, target market, competitive positioning, and how they compare to our offering in [specific area].
Priority: Medium
```

### Template 2: Pricing Intelligence

```
Company Name: [Company]
Research Focus: Detailed analysis of their pricing strategy, packaging tiers, enterprise discounting, and how pricing compares to market average. We're reviewing our pricing and need competitive context.
Priority: High
```

### Template 3: Feature Comparison

```
Company Name: [Company]
Research Focus: Deep dive on their [specific feature] capabilities. How does it work? Who uses it? What do reviews say? How does it compare to our [our feature]?
Priority: Medium
```

### Template 4: Market Positioning

```
Company Name: [Company]
Research Focus: How do they position themselves in the market? What's their messaging? Who are their ideal customers? What market segment are they targeting?
Priority: Low
```

### Template 5: Recent Developments

```
Company Name: [Company]
Research Focus: They recently [announced X / raised funding / launched product]. What are the strategic implications? How should we respond?
Priority: Urgent
```

## Handling Edge Cases

### Private/Stealth Companies

**Challenge**: Limited public information

**Approach**:
- Focus on founder backgrounds
- Analyze job postings for product clues
- Review any press coverage
- Check LinkedIn for company updates
- Note: Confidence scores will be lower

**Output**: Partial research with clear limitations noted

### International Companies

**Challenge**: Language barriers, regional sources

**Current**: Best results for English-speaking markets

**Planned** (Q1 2026): Multilingual support
- Translate sources automatically
- Access regional news sources
- Cultural context in analysis

### Highly Technical Products

**Challenge**: Deep technical evaluation requires expertise

**Approach**:
- Focus on publicly available technical docs
- Review developer community feedback
- Analyze GitHub repos (if open source)
- Include technical specifications

**Recommendation**: Combine with manual technical review

### Emerging Startups

**Challenge**: Minimal public information, frequent pivots

**Approach**:
- Product Hunt, Hacker News coverage
- Founder social media activity
- Early customer testimonials
- Beta program information

**Note**: Mark as "Early stage - information may change rapidly"

## Cost Optimization Tips

### Reducing Research Costs

**1. Be Specific in Research Focus**
- Narrow focus = fewer tokens = lower cost
- Example: "API pricing" vs "everything about their APIs"

**2. Reuse Recent Research**
- Check if researched in last 30 days
- Incremental updates cheaper than full research

**3. Batch Related Requests**
- Research similar companies together
- Share context across requests

**4. Choose Appropriate Depth**
- Quick scan for initial triage
- Deep dive only when necessary
- Standard for most use cases

### Cost Tracking

View costs in Airtable:
- Per-request cost in Research Results table
- Monthly totals via Airtable charts
- Budget alerts via Slack

**Typical Monthly Costs** (by team size):
- Small team (10-20 requests/mo): $3-5
- Medium team (50-100 requests/mo): $12-25
- Large team (200+ requests/mo): $40-80

## Continuous Improvement

### Feedback Loop

**How to Provide Feedback**:
1. Airtable: Add note to Research Results record
2. Slack: Post in #ai-agents channel
3. Direct: Contact GTM Ops team

**What to Report**:
- Inaccurate information (with corrections)
- Missing competitors or insights
- Formatting issues
- Cost concerns
- Feature requests

### Prompt Evolution

We continuously improve research quality:
- Monthly prompt reviews
- A/B testing new approaches
- Incorporating user feedback
- Tracking accuracy metrics

**Recent Improvements**:
- Nov 2025: Reduced exec summary length (better readability)
- Oct 2025: Added B2B SaaS specialization (higher relevance)
- Sep 2025: Switched to Gemini for formatting (60% cost reduction)

### Metrics We Track

**Quality Metrics**:
- User satisfaction scores
- Accuracy validation results
- Confidence score trends
- Manual review rate

**Performance Metrics**:
- Average execution time
- Success rate
- Retry frequency
- API timeout rate

**Cost Metrics**:
- Cost per request (trend)
- Monthly total costs
- Token usage efficiency
- Model cost breakdown

## Comparison with Manual Research

### Manual Research Process

**Typical Workflow**:
1. Google searches (15-20 min)
2. Company website review (10-15 min)
3. News article reading (20-30 min)
4. Review site analysis (15-20 min)
5. Note-taking and synthesis (20-30 min)
6. Report writing (30-45 min)

**Total Time**: 2-3 hours
**Cost**: $50-150 (researcher hourly rate)

### Agent 1A Process

**Workflow**:
1. Fill form (1 min)
2. Automated execution (3-5 min)
3. Review results (5-10 min)

**Total Time**: 10-15 minutes
**Cost**: $0.20

### When to Use Manual vs Agent

**Use Agent 1A When**:
- ✅ Need quick competitive overview
- ✅ Researching well-known companies
- ✅ Public information is sufficient
- ✅ Time-sensitive research
- ✅ High volume of requests

**Use Manual Research When**:
- ✅ Deep proprietary information needed
- ✅ Industry expertise required
- ✅ Stealth/private companies
- ✅ Sensitive strategic analysis
- ✅ Board-level presentations

**Best Approach**: Agent 1A for initial research → Manual for deep dive

## Security & Compliance

### Data Handling

**What We Store**:
- Research requests and results
- Source URLs
- Metadata (timestamps, costs)

**What We DON'T Store**:
- Personal data about competitor employees
- Proprietary information obtained improperly
- Data scraped from paywalled sources

### Ethical Research Guidelines

**We DO**:
- ✅ Use publicly available information
- ✅ Cite all sources
- ✅ Respect robots.txt and ToS
- ✅ Focus on legitimate competitive intelligence

**We DON'T**:
- ❌ Access private/confidential information
- ❌ Misrepresent our identity
- ❌ Violate terms of service
- ❌ Conduct industrial espionage

### Compliance

**GDPR**: No personal data processing
**CCPA**: Public information only
**Data Retention**: 1 year (configurable)
**Access Control**: Airtable permissions

## Roadmap

### Q1 2026
- [ ] Multilingual support
- [ ] Batch processing mode
- [ ] Custom research templates
- [ ] Enhanced source validation

### Q2 2026
- [ ] Historical trend analysis
- [ ] Competitor comparison reports
- [ ] Integration with CRM (Salesforce, HubSpot)
- [ ] Automated quarterly updates

### Q3 2026
- [ ] AI-suggested research topics
- [ ] Competitive intelligence dashboard
- [ ] Slack bot interface
- [ ] Export to presentation formats

---

**Document Version**: 1.0
**Last Updated**: November 2025
**Maintained by**: GTM Operations Team
**Feedback**: #ai-agents Slack channel
