# AI Agent Factory - Prompt Library

This document contains all LLM prompts used across the AI Agent Factory suite, including model configurations, version history, and performance notes.

## Prompt Management Guidelines

### Versioning Convention
```
Format: AGENT.STEP.VERSION
Example: 1A.RESEARCH.v2.1

AGENT: 1A, 1B, 2, 3, etc.
STEP: RESEARCH, ANALYSIS, FORMATTING, etc.
VERSION: Major.Minor (increment minor for tweaks, major for rewrites)
```

### Best Practices
- Always include version number in prompt metadata
- Track changes with date and performance impact
- Test prompts with 5+ examples before deploying
- Monitor token usage and adjust for cost optimization
- Include clear instructions and examples in prompts

---

## Agent 1A: Competitive Intelligence Monitor

### 1A.RESEARCH.v1.0 - Perplexity Initial Research

**Model**: Perplexity Sonar Pro
**Purpose**: Gather comprehensive company information from web sources
**Created**: October 2025
**Status**: ✅ Production
**Avg Tokens**: 500 input / 2000 output
**Cost**: ~$0.10 per request

#### Prompt Template

```
Research {COMPANY_NAME} with focus on: {RESEARCH_FOCUS}.

Provide a comprehensive analysis including:

1. COMPANY OVERVIEW
   - Founded, headquarters, size
   - Mission and core business model
   - Key leadership

2. PRODUCTS & SERVICES
   - Main offerings
   - Unique features or differentiators
   - Pricing model (if public)

3. TARGET MARKET
   - Primary customer segments
   - Geographic focus
   - Market positioning

4. COMPETITIVE LANDSCAPE
   - Main competitors
   - Market share estimates
   - Competitive advantages

5. RECENT DEVELOPMENTS
   - News from last 3-6 months
   - Product launches
   - Funding or acquisitions

6. STRATEGIC INSIGHTS
   - Growth trajectory
   - Challenges or risks
   - Market trends affecting them

7. SOURCES
   - Provide 5-10 relevant URLs used for this research
   - Include official sources (website, blog) and third-party sources (news, reviews)

Focus particularly on: {RESEARCH_FOCUS}

Use current, credible sources and cite URLs at the end.
```

#### Variables
- `{COMPANY_NAME}`: Target company (e.g., "Stripe")
- `{RESEARCH_FOCUS}`: Specific angle (e.g., "payment processing competitive landscape")

#### Performance Notes
- **Strengths**: Excellent at finding recent news and official sources
- **Weaknesses**: Sometimes misses niche competitors
- **Token Optimization**: Reduced from "comprehensive detailed analysis" to specific sections (saved ~300 tokens)
- **Success Rate**: 98% (2% fail due to very obscure companies)

#### Example Output Quality
```
Input: Company="Stripe", Focus="payment processing competitive landscape"
Output Quality: 9/10
- Covered all major competitors (PayPal, Square, Adyen)
- Found 2024 pricing changes
- Included 8 credible sources
- Minor issue: Missed some regional competitors
```

#### Version History
- **v1.0** (Oct 2025): Initial version
- Planned **v1.1**: Add "Focus on companies in [REGION]" for better regional coverage

---

### 1A.ANALYSIS.v1.2 - Claude Strategic Analysis

**Model**: Claude 3.5 Sonnet (claude-3-5-sonnet-20241022)
**Purpose**: Analyze research data and provide strategic insights
**Created**: October 2025
**Updated**: November 2025 (v1.2)
**Status**: ✅ Production
**Avg Tokens**: 2500 input / 1500 output
**Cost**: ~$0.08 per request

#### Prompt Template

```
You are a strategic business analyst specializing in competitive intelligence for B2B SaaS and technology companies.

Analyze the following research about {COMPANY_NAME}:

---
{RESEARCH_DATA}
---

Provide a structured analysis with the following sections:

## EXECUTIVE SUMMARY
Write 2-3 concise paragraphs summarizing:
- What the company does and who they serve
- Their market position and key differentiators
- Most important strategic insights for our team

## KEY FINDINGS
Provide 5-7 bullet points of the most important discoveries:
- Focus on actionable insights
- Highlight competitive threats or opportunities
- Include quantitative data where available

## COMPETITIVE ADVANTAGES
List 3-5 specific strengths that give them competitive edge:
- Technology capabilities
- Market position
- Customer relationships
- Other strategic assets

## POTENTIAL WEAKNESSES
Identify 3-5 areas where they may be vulnerable:
- Product gaps
- Market coverage
- Customer complaints
- Strategic risks

## STRATEGIC RECOMMENDATIONS
Provide 3-5 specific, actionable recommendations for how our team should:
- Differentiate against this competitor
- Capitalize on their weaknesses
- Defend against their strengths
- Monitor their activities

Write in clear, business-friendly language. Avoid jargon unless necessary. Focus on insights that will help our GTM team make better decisions.
```

#### Variables
- `{COMPANY_NAME}`: Target company
- `{RESEARCH_DATA}`: Output from Perplexity research step

#### Model Configuration
```json
{
  "model": "claude-3-5-sonnet-20241022",
  "max_tokens": 2048,
  "temperature": 0.3,
  "top_p": 0.9,
  "stop_sequences": []
}
```

**Configuration Rationale**:
- `temperature: 0.3` - Lower for factual, consistent analysis (not creative writing)
- `max_tokens: 2048` - Sufficient for detailed analysis without being excessive
- `top_p: 0.9` - Default, works well for analytical tasks

#### Performance Notes
- **Strengths**: Excellent strategic thinking, clear business language
- **Weaknesses**: Sometimes over-cautious in recommendations
- **Token Optimization**: Added "2-3 paragraphs" constraint to executive summary (saved ~400 tokens)
- **Success Rate**: 99%

#### Version History
- **v1.0** (Oct 2025): Initial version with generic analyst role
- **v1.1** (Oct 2025): Added "B2B SaaS and technology" specialization
- **v1.2** (Nov 2025): Restructured recommendations to be more actionable, reduced exec summary length

#### A/B Test Results
| Version | Avg Tokens | User Rating | Token Cost |
|---------|-----------|-------------|------------|
| v1.0 | 2200 | 7.5/10 | $0.10 |
| v1.1 | 2100 | 8.2/10 | $0.09 |
| v1.2 | 1800 | 8.8/10 | $0.08 |

**Conclusion**: v1.2 is more concise, costs less, and rates higher

---

### 1A.FORMAT.v1.1 - Gemini Structured Output

**Model**: Gemini 2.0 Flash Experimental
**Purpose**: Convert analysis into structured JSON format for Airtable
**Created**: October 2025
**Updated**: November 2025 (v1.1)
**Status**: ✅ Production
**Avg Tokens**: 1800 input / 800 output
**Cost**: ~$0.02 per request (very affordable)

#### Prompt Template

```
Convert the following competitive analysis into a structured JSON format.

Analysis:
---
{ANALYSIS_TEXT}
---

Output a valid JSON object with this exact structure:

{
  "executive_summary": "string - 2-3 paragraph summary",
  "key_findings": [
    "string - finding 1",
    "string - finding 2",
    "string - finding 3"
  ],
  "competitive_advantages": [
    "string - advantage 1",
    "string - advantage 2",
    "string - advantage 3"
  ],
  "weaknesses": [
    "string - weakness 1",
    "string - weakness 2",
    "string - weakness 3"
  ],
  "recommendations": [
    "string - recommendation 1",
    "string - recommendation 2",
    "string - recommendation 3"
  ],
  "competitor_names": [
    "string - competitor 1",
    "string - competitor 2"
  ],
  "industries": [
    "string - industry 1",
    "string - industry 2"
  ],
  "confidence_score": number (0-100, your confidence in this analysis based on source quality)
}

Rules:
1. Extract information directly from the analysis text
2. Each array should have 3-7 items
3. Keep each string concise (1-2 sentences max)
4. confidence_score should reflect source quality and data completeness
5. competitor_names should be company names only (not descriptions)
6. industries should be broad categories (e.g., "Payment Processing", "SaaS")
7. Return ONLY the JSON object, no markdown formatting or additional text
```

#### Variables
- `{ANALYSIS_TEXT}`: Output from Claude analysis step

#### Model Configuration
```json
{
  "model": "gemini-2.0-flash-exp",
  "temperature": 0.1,
  "max_output_tokens": 1024,
  "response_mime_type": "application/json"
}
```

**Configuration Rationale**:
- `temperature: 0.1` - Very low for consistent JSON formatting
- `response_mime_type: "application/json"` - Forces JSON output (Gemini 2.0 feature)
- `max_output_tokens: 1024` - Sufficient for structured output

#### Performance Notes
- **Strengths**: Perfect JSON formatting 99.9% of time, very cheap
- **Weaknesses**: Occasionally misses extracting all competitor names
- **Token Optimization**: Using Gemini instead of Claude saves ~$0.10 per request
- **Success Rate**: 99.9% (only fails if Claude output is malformed)

#### Version History
- **v1.0** (Oct 2025): Initial version, asked for markdown code blocks
- **v1.1** (Nov 2025): Switched to `response_mime_type: "application/json"`, eliminated code blocks

#### Error Handling
```javascript
// In n8n workflow, add this validation
if (!json.executive_summary || !Array.isArray(json.key_findings)) {
  // Retry with Claude as fallback
  // OR return error to user
}
```

---

## Agent 1B: RSS Monitoring (Planned)

### 1B.SUMMARY.v1.0 - News Article Summarization

**Model**: Gemini 2.0 Flash
**Purpose**: Summarize competitor blog posts and news
**Status**: 🚧 In Development
**Target Cost**: <$0.01 per article

#### Prompt Template (Draft)

```
Summarize the following article about {COMPANY_NAME}:

URL: {ARTICLE_URL}
Published: {PUBLISHED_DATE}

Content:
---
{ARTICLE_CONTENT}
---

Provide:

1. HEADLINE SUMMARY (1 sentence)
   - What is the main announcement or topic?

2. KEY POINTS (3-5 bullets)
   - Most important information
   - Product/feature updates
   - Business implications

3. STRATEGIC SIGNIFICANCE (1-2 sentences)
   - Why does this matter for competitive intelligence?
   - How might this affect our positioning?

4. RECOMMENDED ACTION
   - No action needed
   - Monitor for updates
   - Deep dive research recommended
   - Alert sales/product team

Keep it concise and actionable.
```

---

## Prompt Optimization Techniques

### 1. Token Reduction Strategies

**Before**:
```
Please provide a comprehensive, detailed, and thorough analysis...
```

**After** (saves ~10 tokens):
```
Provide a detailed analysis...
```

**Impact**: 5-10% token reduction

### 2. Output Length Control

**Before**:
```
Write a summary.
```
(Output: 5-10 paragraphs)

**After**:
```
Write a 2-3 paragraph summary.
```
(Output: Exactly 2-3 paragraphs)

**Impact**: 40-60% token reduction

### 3. Structured Instructions

**Before**:
```
Tell me about the company, what they do, their competitors, and recent news.
```

**After**:
```
Provide:
1. Company overview
2. Main competitors
3. Recent news (last 3 months)
```

**Impact**: More consistent outputs, easier parsing

### 4. Model Selection

| Task | Wrong Model | Right Model | Savings |
|------|-------------|-------------|---------|
| JSON formatting | Claude 3.5 | Gemini 2.0 | 80% |
| Web research | Claude 3.5 | Perplexity | 50% |
| Creative writing | Gemini | Claude 3.5 | N/A |

### 5. Prompt Caching (Future)

For prompts used repeatedly:
```
{STATIC_SYSTEM_PROMPT} ← Cache this (5000 tokens)
{DYNAMIC_USER_INPUT} ← Only pay for this (100 tokens)
```

Anthropic prompt caching could save 90% on repeated system prompts.

---

## Testing & Evaluation

### Prompt Testing Process

1. **Create Test Cases** (5-10 examples)
   ```
   Input: {company: "Stripe", focus: "API developer experience"}
   Expected: Should mention Stripe API docs, developer community
   ```

2. **Run Prompt Variants**
   - Test 3-5 prompt variations
   - Use same test cases for all

3. **Evaluate Results**
   - Accuracy: Does it include correct information?
   - Relevance: Is output focused on the request?
   - Completeness: Did it cover all required sections?
   - Conciseness: Is it unnecessarily long?
   - Cost: Token usage

4. **Select Winner**
   - Balance quality vs cost
   - User testing with real team members

### Evaluation Rubric

| Criterion | Weight | Scoring |
|-----------|--------|---------|
| Accuracy | 40% | 0-10 points |
| Relevance | 25% | 0-10 points |
| Completeness | 20% | 0-10 points |
| Conciseness | 10% | 0-10 points |
| Cost | 5% | 0-10 points |

**Example Calculation**:
```
Accuracy: 9/10 × 40% = 3.6
Relevance: 8/10 × 25% = 2.0
Completeness: 9/10 × 20% = 1.8
Conciseness: 7/10 × 10% = 0.7
Cost: 8/10 × 5% = 0.4
Total Score: 8.5/10
```

---

## Model Comparison Matrix

### Task: Competitive Analysis

| Model | Cost per 1K | Quality | Speed | Best For |
|-------|-------------|---------|-------|----------|
| Claude 3.5 Sonnet | $18/1M tokens | 9.5/10 | Fast | Analysis, reasoning |
| GPT-4 Turbo | $10/1M tokens | 9/10 | Fast | General tasks |
| Gemini 2.0 Flash | $0.075/1M | 8/10 | Very fast | Structured output |
| Perplexity Sonar Pro | ~$5/1K requests | 8.5/10 | Medium | Web research |

### Task: Web Research

| Model | Real-time Web | Citations | Cost | Recommendation |
|-------|---------------|-----------|------|----------------|
| Perplexity Sonar Pro | ✅ Yes | ✅ Excellent | High | ⭐ Best choice |
| Gemini 2.0 + Search | ✅ Yes | ⚠️ Limited | Low | Budget option |
| Claude (web search) | ❌ No | N/A | N/A | Not suitable |

### Task: JSON Formatting

| Model | JSON Mode | Consistency | Cost | Recommendation |
|-------|-----------|-------------|------|----------------|
| Gemini 2.0 Flash | ✅ Native | 99.9% | Very low | ⭐ Best choice |
| GPT-4 JSON mode | ✅ Native | 99.5% | Medium | Good alternative |
| Claude (prompted) | ⚠️ Via prompt | 95% | High | Not recommended |

---

## Cost Analysis Dashboard

### Agent 1A Cost Breakdown (Per Request)

```
┌─────────────────────────────────────────────────┐
│ COST BREAKDOWN - AGENT 1A                       │
├─────────────────────────────────────────────────┤
│ Perplexity Research:    $0.10 (44%)            │
│ Claude Analysis:        $0.08 (35%)            │
│ Gemini Formatting:      $0.02 (9%)             │
│ n8n execution:          $0.02 (9%)             │
│ Airtable API:           $0.01 (3%)             │
├─────────────────────────────────────────────────┤
│ TOTAL PER REQUEST:      $0.23                   │
└─────────────────────────────────────────────────┘

Monthly estimate (100 requests): $23
```

### Optimization Opportunities

1. **Switch Perplexity to Gemini Search**: Save $0.07 per request
   - Tradeoff: Slightly lower quality citations

2. **Use Claude Haiku for simple analyses**: Save $0.05 per request
   - Tradeoff: Less strategic depth

3. **Batch requests**: Process 5+ at once to save n8n costs
   - Tradeoff: Longer wait times

---

## Prompt Changelog

### November 2025
- **1A.ANALYSIS.v1.2**: Reduced exec summary length requirement
- **1A.FORMAT.v1.1**: Added `response_mime_type: "application/json"`

### October 2025
- **1A.RESEARCH.v1.0**: Initial Perplexity research prompt
- **1A.ANALYSIS.v1.1**: Added B2B SaaS specialization
- **1A.FORMAT.v1.0**: Initial Gemini formatting prompt

---

## Future Enhancements

### Planned Additions

1. **Prompt Caching** (Q1 2026)
   - Implement Anthropic prompt caching
   - Expected savings: 40-60% on Claude costs

2. **Few-Shot Examples** (Q1 2026)
   - Add 2-3 example outputs to prompts
   - Improve consistency and quality

3. **Fine-Tuned Models** (Q2 2026)
   - Fine-tune Gemini on our data
   - Better formatting, lower costs

4. **Dynamic Prompt Selection** (Q2 2026)
   - Choose prompt based on company type
   - E.g., different prompts for SaaS vs hardware

---

## Contributing to Prompt Library

When adding new prompts:

1. Use version naming convention
2. Document model configuration
3. Include 3+ test examples
4. Measure token usage and cost
5. Get review from 2+ team members
6. Update this library with new entry

---

**Last Updated**: November 6, 2025
**Maintained by**: GTM Operations Team
**Total Prompts**: 3 (Production) + 1 (Development)
