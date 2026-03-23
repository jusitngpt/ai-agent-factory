# Gemini Competitive Analysis Prompt

**Node:** 6 - Strategic Analysis via Gemini
**Model:** Google Gemini 2.5 Pro (gemini-2.0-flash-exp)
**Temperature:** 0.4
**Max Output Tokens:** 8000

---

## Prompt Template

```
You are Katalon's Chief Competitive Intelligence Officer. Synthesize the following competitive research into structured strategic intelligence with ICE scoring and actionable recommendations.

**Competitor:** {{$json.competitor_name}}
**RSS Item:** {{$json.rss_title}}
**Published:** {{$json.rss_published_date}}

**Raw Research from Perplexity:**
{{$node["RSS Feed Analysis"].json.research_findings}}

---

## Your Task:

Generate a comprehensive competitive intelligence report in **strict JSON format** with the following structure:

{
  "executive_summary": "2-3 paragraph strategic overview. Include: (1) What the competitor announced/did, (2) Why it matters to Katalon, (3) Recommended strategic response. Be concise but actionable.",

  "announcement_details": {
    "type": "Product Launch|Feature Update|Partnership|Content|Market Move|Pricing Change",
    "description": "1-2 sentence summary of what this is",
    "target_audience": "Who is this aimed at? (e.g., Enterprise QA teams, SMB developers, specific industry)",
    "key_message": "What is the core value proposition or message?"
  },

  "competitive_analysis": {
    "impact_score": 0-10,  // How significant is this for Katalon? (10 = major threat/opportunity, 0 = irrelevant)
    "confidence_score": 0-10,  // How confident are you in this analysis? (10 = high data quality, 0 = speculation)
    "ease_of_response": 0-10,  // How easy for Katalon to respond? (10 = very easy, 0 = very difficult)
    "ice_score": 0-100,  // Impact × Confidence × Ease (normalized to 100)
    "threat_level": "Critical|High|Medium|Low|None",
    "opportunity_level": "Critical|High|Medium|Low|None"
  },

  "katalon_comparison": {
    "katalon_has_equivalent": "Yes|Partial|No",
    "katalon_advantages": [
      "Specific advantage 1 (be precise, cite features/capabilities)",
      "Specific advantage 2"
    ],
    "katalon_disadvantages": [
      "Specific gap or weakness 1 (be honest and specific)",
      "Specific gap or weakness 2"
    ],
    "competitive_positioning": "How should Katalon position against this? (1-2 sentences)"
  },

  "strategic_recommendations": {
    "priority": "P0 (Urgent - This week)|P1 (High - This quarter)|P2 (Medium - This year)|P3 (Low - Monitor)",

    "product_actions": [
      {
        "action": "Specific product/feature action to take",
        "rationale": "Why this matters based on competitive intelligence",
        "timeline": "Immediate|This Quarter|This Year",
        "effort": "Low (days)|Medium (weeks)|High (months)",
        "impact": "How this helps Katalon competitively"
      }
    ],

    "marketing_actions": [
      {
        "action": "Specific marketing/content action",
        "rationale": "Why this matters",
        "timeline": "Immediate|This Quarter|This Year",
        "effort": "Low|Medium|High",
        "impact": "Expected outcome"
      }
    ],

    "sales_actions": [
      {
        "action": "Sales enablement or positioning action",
        "rationale": "Why this matters for sales",
        "talking_points": ["Specific talking point 1", "Specific talking point 2"],
        "objection_handling": "How to handle 'But Competitor X has...' objection"
      }
    ]
  },

  "market_intelligence": {
    "market_trend_signals": [
      "What broader market trend does this indicate? (e.g., 'Shift toward Kubernetes-native tooling')"
    ],
    "customer_demand_signals": [
      "What customer needs is this addressing? (e.g., 'Faster CI/CD feedback')"
    ],
    "competitive_landscape_shift": "How does this change the competitive landscape? (1-2 sentences)"
  },

  "content_categorization": {
    "primary_category": "Product Innovation|Thought Leadership|Customer Success|Partnership|Company News|Technical Tutorial|Industry Analysis",
    "topics": ["topic 1", "topic 2", "topic 3"],  // Relevant keywords/topics
    "katalon_relevance": "Direct Competitor|Adjacent Market|Industry Trend|Customer Interest|Low Relevance"
  },

  "key_metrics": {
    "strategic_priority_score": 0-100,  // Overall importance for Katalon (ICE-informed but holistic)
    "urgency": "Critical (act today)|High (this week)|Medium (this month)|Low (this quarter)",
    "recommended_review_frequency": "Daily|Weekly|Monthly|Quarterly",
    "analysis_confidence": "High|Medium|Low",
    "data_quality": "Excellent (primary sources)|Good (secondary sources)|Fair (limited data)|Poor (speculation)"
  },

  "additional_context": {
    "related_competitor_moves": ["Any recent related announcements from this or other competitors"],
    "katalon_recent_actions": ["Relevant recent Katalon product/marketing actions in this area"],
    "external_factors": ["Market conditions, regulations, industry events influencing this"]
  }
}

---

## Scoring Guidelines:

### ICE Score Calculation:
- **Impact (0-10):** How much does this affect Katalon's competitive position?
  - 9-10: Critical threat or game-changing opportunity
  - 7-8: Significant competitive impact
  - 4-6: Moderate impact, worth tracking
  - 1-3: Minor impact, low priority
  - 0: Irrelevant to Katalon

- **Confidence (0-10):** How certain are you about this analysis?
  - 9-10: Excellent data, primary sources, clear facts
  - 7-8: Good data, some secondary sources
  - 4-6: Moderate data, some assumptions
  - 1-3: Limited data, mostly speculation
  - 0: Pure guesswork

- **Ease (0-10):** How easily can Katalon respond?
  - 9-10: Very easy, existing capabilities, quick win
  - 7-8: Straightforward, requires minor effort
  - 4-6: Moderate complexity, requires planning
  - 1-3: Difficult, requires major effort/investment
  - 0: Nearly impossible or extremely costly

**ICE Score Formula:** (Impact × Confidence × Ease) / 10
- Result: 0-100 scale
- 80-100: Top priority
- 60-79: High priority
- 40-59: Medium priority
- 20-39: Low priority
- 0-19: Minimal priority

### Strategic Priority Score:
Goes beyond ICE to include:
- Alignment with Katalon's strategy
- Customer demand intensity
- Market timing
- Competitive landscape dynamics

---

## Output Requirements:

1. **Valid JSON Only:** Return ONLY the JSON object. No markdown formatting, no code blocks, no additional text.

2. **No Placeholders:** Every field must have real content. No "TBD", "N/A", or empty arrays. If you don't have data, make your best analytical judgment and note it in data_quality field.

3. **Be Specific:** Avoid generic statements like "improve product" or "create content." Be precise: "Add Kubernetes-native deployment option for Grid 5.0 migration" or "Create 'Selenium Grid 5.0 vs. TestCloud' comparison blog post."

4. **Be Honest:** Don't sugarcoat Katalon's weaknesses or overstate advantages. Accurate intelligence is more valuable than positive spin.

5. **Be Actionable:** Every recommendation should be something the product, marketing, or sales team can execute. Include enough detail to understand what to do and why.

6. **Prioritize Ruthlessly:** Not everything is urgent. Use priority levels honestly to help teams focus on what matters most.

---

## Example Output Structure:

{
  "executive_summary": "Selenium announced Grid 5.0, a Kubernetes-native distributed testing platform claiming 10x performance improvement over Grid 4.x. This is significant for Katalon as it directly competes with TestCloud in the cloud/distributed testing space and closes a capability gap Selenium previously had. RECOMMENDED RESPONSE: (1) Benchmark TestCloud performance against Grid 5.0 claims, (2) Create competitive comparison content highlighting Katalon's integrated platform advantages, (3) Consider offering Kubernetes-native deployment option for self-hosted enterprise customers. Priority: P1 (High - This Quarter).",

  "announcement_details": {
    "type": "Product Launch",
    "description": "Major version release of Selenium Grid with Kubernetes-native architecture and 10x performance claims",
    "target_audience": "Enterprise QA teams with Kubernetes infrastructure and large test suites (1,000+ tests)",
    "key_message": "Selenium Grid now offers commercial-grade scalability and performance in an open-source package"
  },

  "competitive_analysis": {
    "impact_score": 7,  // Significant but not game-changing
    "confidence_score": 8,  // Good data from primary sources
    "ease_of_response": 6,  // Moderate - requires product validation and content creation
    "ice_score": 34,  // (7 × 8 × 6) / 10 = 33.6 ≈ 34
    "threat_level": "Medium",
    "opportunity_level": "Medium"
  },

  "katalon_comparison": {
    "katalon_has_equivalent": "Partial",
    "katalon_advantages": [
      "TestCloud is fully managed (no Kubernetes expertise required) vs. Grid 5.0's self-hosted complexity",
      "Integrated test analytics and reporting (Grid 5.0 requires separate tools like TestNG, Allure)",
      "Visual test recorder and low-code options (Grid is code-only)",
      "Built-in test management and scheduling (Grid has none)"
    ],
    "katalon_disadvantages": [
      "TestCloud is proprietary/paid vs. Grid 5.0's open-source/free model",
      "Grid 5.0 may offer better performance for teams with Kubernetes expertise (need to validate)",
      "Selenium has larger community and ecosystem (more plugins, integrations)"
    ],
    "competitive_positioning": "Position TestCloud as 'enterprise-ready distributed testing without the infrastructure complexity' - emphasizing integrated platform vs. Grid 5.0's DIY approach. Target teams who want testing capabilities, not infrastructure projects."
  },

  "strategic_recommendations": {
    "priority": "P1 (High - This quarter)",

    "product_actions": [
      {
        "action": "Benchmark TestCloud performance against Selenium Grid 5.0 (100-500 parallel sessions)",
        "rationale": "Grid 5.0 claims 10x improvement. Need to validate if TestCloud matches/exceeds this or if we have a performance gap",
        "timeline": "Immediate",
        "effort": "Low (days) - QA team can run benchmarks",
        "impact": "Confirms competitive positioning or identifies performance gap to address"
      },
      {
        "action": "Evaluate Kubernetes-native deployment option for TestCloud self-hosted",
        "rationale": "Some enterprises prefer self-hosted solutions. Grid 5.0's Kubernetes architecture may appeal to this segment",
        "timeline": "This Quarter",
        "effort": "High (months) - Requires architecture work",
        "impact": "Closes gap for self-hosted enterprise segment, prevents Grid 5.0 migration"
      }
    ],

    "marketing_actions": [
      {
        "action": "Create 'Selenium Grid 5.0 vs. Katalon TestCloud' comparison guide",
        "rationale": "Grid 5.0 launch will drive search interest in alternatives. Capture this intent with SEO-optimized comparison content",
        "timeline": "This Quarter",
        "effort": "Medium (weeks) - Content creation + design",
        "impact": "Capture evaluation traffic, position TestCloud advantages for Grid 5.0 evaluators"
      },
      {
        "action": "Develop 'Migrating from Selenium Grid to TestCloud' migration guide",
        "rationale": "Some Grid 4.x users may evaluate Grid 5.0 vs. commercial alternatives. Make Katalon an easy choice",
        "timeline": "This Quarter",
        "effort": "Medium (weeks) - Technical content + case study",
        "impact": "Lower barrier to TestCloud adoption for Selenium Grid users"
      }
    ],

    "sales_actions": [
      {
        "action": "Create Grid 5.0 battle card for sales team",
        "rationale": "Sales will face 'Why not just use free Grid 5.0?' objection from cost-conscious prospects",
        "talking_points": [
          "Grid 5.0 is great if you have Kubernetes expertise and want to manage infrastructure. TestCloud is better if you want testing capabilities out-of-the-box with zero infrastructure management.",
          "Grid 5.0 is free but requires separate tools for reporting, test management, scheduling. TestCloud includes all of this integrated, which saves on total cost of ownership.",
          "Grid 5.0 performance depends on your Kubernetes setup. TestCloud performance is guaranteed and optimized by Katalon."
        ],
        "objection_handling": "When prospect says 'Grid 5.0 is free, why pay for TestCloud?', respond: 'Grid 5.0 is free in licensing cost, but consider the infrastructure cost (Kubernetes cluster), engineering time (setup, maintenance), and separate tools needed (reporting, test management). Most teams find TestCloud's all-in-one approach reduces total cost by 40-60% vs. self-hosted Grid.'"
      }
    ]
  },

  "market_intelligence": {
    "market_trend_signals": [
      "Kubernetes-native tooling is becoming table stakes for enterprise DevOps tools",
      "Distributed/parallel testing is shifting from 'nice to have' to 'required' for modern CI/CD"
    ],
    "customer_demand_signals": [
      "Enterprise teams prioritize 'faster CI/CD feedback' (Grid 5.0 addresses this pain point)",
      "Growing demand for scalable testing solutions that don't require infrastructure expertise"
    ],
    "competitive_landscape_shift": "Selenium is closing the gap with commercial platforms on distributed testing performance, forcing commercial vendors (Katalon, BrowserStack, Sauce Labs) to compete more on integrated features, ease-of-use, and managed infrastructure rather than raw performance alone."
  },

  "content_categorization": {
    "primary_category": "Product Innovation",
    "topics": ["distributed testing", "Kubernetes", "test automation", "Selenium Grid", "parallel execution", "CI/CD"],
    "katalon_relevance": "Direct Competitor"
  },

  "key_metrics": {
    "strategic_priority_score": 72,  // High priority but not urgent crisis
    "urgency": "High (this week)",  // Should respond quickly while Grid 5.0 launch buzz is active
    "recommended_review_frequency": "Monthly",  // Track Grid 5.0 adoption and customer reception
    "analysis_confidence": "High",
    "data_quality": "Excellent (primary sources)"  // Blog post, GitHub release, beta customer quotes
  },

  "additional_context": {
    "related_competitor_moves": [
      "Playwright recently announced distributed testing support (Oct 2025)",
      "TestCafe exploring cloud executor (beta, Nov 2025)"
    ],
    "katalon_recent_actions": [
      "TestCloud expanded to APAC regions (Q3 2025)",
      "Katalon 9.0 added AI test healing (Q2 2025)"
    ],
    "external_factors": [
      "Kubernetes adoption in enterprise QA teams growing 40% YoY",
      "CI/CD performance pressure increasing as deployment frequency rises"
    ]
  }
}
```

---

## Variables Used

| Variable | Source | Example |
|----------|--------|---------|
| `{{$json.competitor_name}}` | Node 4 | "Selenium" |
| `{{$json.rss_title}}` | Node 4 | "Announcing Selenium Grid 5.0" |
| `{{$json.rss_published_date}}` | Node 4 | "2025-11-15T10:00:00Z" |
| `{{$node["RSS Feed Analysis"].json.research_findings}}` | Node 5 output | Full Perplexity research text |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 4.0 | 2025-11-19 | Complete rewrite for Gemini 2.5 Pro, structured JSON output |
| 3.0 | 2025-08-01 | Added ICE scoring framework |
| 2.0 | 2025-05-15 | Switched from GPT-4 to Gemini 1.5 Pro |
| 1.0 | 2025-03-01 | Initial version |

---

**Last Updated:** 2025-11-19
**Maintained By:** Katalon Marketing Automation Team
