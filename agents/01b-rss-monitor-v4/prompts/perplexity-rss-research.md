# Perplexity RSS Research Prompt

**Node:** 5 - RSS Feed Analysis
**Model:** Perplexity Sonar Pro
**Temperature:** 0.3
**Max Tokens:** 4000
**Search Recency:** Last 30 days

---

## Prompt Template

```
You are a competitive intelligence analyst for Katalon. Analyze this RSS feed item from a competitor and extract strategic insights.

**RSS Feed Item:**
- Title: {{$json.title}}
- Link: {{$json.link}}
- Published: {{$json.pubDate}}
- Content Preview: {{$json.contentSnippet}}
- Competitor: {{$json.competitor_name}}

**Your Task:**
Conduct deep research on this announcement/article and provide competitive intelligence analysis.

## Research Requirements:

### 1. Content Analysis
- What is this announcement/article about?
- What is the main message or value proposition?
- What problem does it solve or address?
- What is new or noteworthy about this?

### 2. Strategic Significance
- Why is this significant for Katalon?
- Does this represent a new capability, market move, or positioning shift?
- How does this compare to Katalon's offerings?
- Is this a threat, opportunity, or neutral development?

### 3. Competitive Implications
- What does this reveal about the competitor's strategy?
- What customer pain points are they targeting?
- What market segment are they pursuing?
- How aggressive/defensive is this move?

### 4. Market Context
- Is this following an industry trend or setting a new direction?
- Who else in the market has similar offerings?
- What is the timing significance (why now)?
- What customer demand is driving this?

### 5. Technical Details
- What specific features or capabilities are mentioned?
- What technology stack or approach are they using?
- What integrations or partnerships are highlighted?
- What are the technical differentiators?

### 6. Customer Impact
- What customer segments benefit most from this?
- What use cases does this enable?
- What ROI or value metrics are claimed?
- Are there customer quotes or testimonials?

### 7. Katalon Competitive Response
- Should Katalon respond to this? How urgently?
- What are Katalon's comparable capabilities?
- Where does Katalon have advantages?
- Where might Katalon have gaps?

## Output Format:

Provide comprehensive research covering all 7 dimensions above.
Include specific quotes from the source material where relevant.
Cite any additional sources you find through web search.
Be analytical and strategic, not just descriptive.
Focus on actionable intelligence for product and marketing teams.

**Research Depth:** This is primary competitive intelligence. Be thorough.
**Perspective:** You work for Katalon, so frame insights from Katalon's competitive position.
**Tone:** Professional, analytical, objective (not promotional)
```

---

## Variables Used

| Variable | Source | Example |
|----------|--------|---------|
| `{{$json.title}}` | RSS feed item | "Announcing Selenium Grid 5.0" |
| `{{$json.link}}` | RSS feed item | "https://selenium.dev/blog/2025/grid-5" |
| `{{$json.pubDate}}` | RSS feed item | "2025-11-15T10:00:00Z" |
| `{{$json.contentSnippet}}` | RSS feed item | "Major update with parallel execution..." |
| `{{$json.competitor_name}}` | Node 4 extraction | "Selenium" |

---

## Customization Options

### Adjust Research Depth
```
For lighter analysis (faster, cheaper):
"Focus only on: Content Analysis, Strategic Significance, Katalon Response"
Remove: Market Context, Technical Details sections

For deeper analysis:
Add: "Pricing analysis", "Go-to-market strategy", "Partnership implications"
```

### Change Competitive Focus
```
For product-focused intel:
"Prioritize: Technical Details, Feature comparison, Technology stack"

For marketing-focused intel:
"Prioritize: Customer Impact, Market positioning, Messaging analysis"
```

### Modify Search Recency
```
Current: searchRecencyFilter: "month"  (last 30 days)

For breaking news: "week" or "day"
For historical context: "year"
```

---

## Example Output

```
**1. Content Analysis:**
This is Selenium's announcement of Grid 5.0, their distributed test execution platform. The main message is "massive scalability improvements" - claiming 10x performance increase over Grid 4.x. They're addressing the pain point of slow parallel test execution at enterprise scale.

New/Noteworthy: First major Grid update in 2 years. Introduces Kubernetes-native architecture, replacing Docker Compose approach.

**2. Strategic Significance:**
HIGH SIGNIFICANCE for Katalon. Selenium is directly competing in the cloud/distributed testing space where Katalon TestCloud operates. This closes a capability gap Selenium had vs. commercial solutions.

Comparison to Katalon: Katalon TestCloud offers similar distributed execution but with built-in test orchestration and reporting. Selenium Grid 5.0 requires separate tools for these functions.

Threat Level: MEDIUM - Improves Selenium's competitive position but doesn't match Katalon's integrated platform approach.

**3. Competitive Implications:**
This reveals Selenium's strategy to remain competitive with commercial platforms (Katalon, BrowserStack, Sauce Labs) by improving their free/open-source distributed testing capabilities. They're targeting enterprise teams who previously hit scalability limits with Grid 4.x.

Customer Pain Point: Enterprises struggling with slow test execution and complex Grid 4.x setup.

Market Segment: Large enterprises with in-house DevOps/infra teams (who can manage Kubernetes).

Aggressiveness: DEFENSIVE - closing a gap rather than leapfrogging competitors.

**4. Market Context:**
This follows the industry trend toward Kubernetes-native tooling. Similar moves: Playwright's distributed testing support, TestCafe's new cloud executor.

Timing: Likely response to increased adoption of commercial cloud testing platforms. Selenium needed to modernize to retain enterprise users.

Customer Demand: Survey data shows 60% of enterprise QA teams prioritize "faster CI/CD feedback" - this addresses that demand.

**5. Technical Details:**
- Kubernetes-native architecture (Helm chart for deployment)
- Support for 100+ parallel sessions per cluster
- Auto-scaling based on test queue depth
- WebDriver BiDi protocol support (experimental)
- Integrations: Jenkins, GitLab CI, GitHub Actions

Technology Stack: Kubernetes, gRPC for node communication, Redis for session management

Differentiators: Open source (vs. Katalon's proprietary TestCloud), Kubernetes scalability

**6. Customer Impact:**
Primary Beneficiaries: Enterprise teams with Kubernetes infrastructure, 1,000+ automated tests, complex test suites requiring parallel execution.

Use Cases Enabled:
- Running 500+ tests in under 10 minutes (vs. 2+ hours sequential)
- Cross-browser testing at scale (10+ browser/OS combinations simultaneously)
- CI/CD pipelines with sub-15-minute feedback loops

ROI Claims: Blog post cites "10x faster execution, 70% reduction in CI/CD time"

Customer Quotes: Beta tester from Acme Corp: "We went from 2-hour test runs to 12 minutes with Grid 5.0"

**7. Katalon Competitive Response:**

URGENCY: MEDIUM (respond within Q1 2025)

Recommended Actions:
1. PRODUCT: Audit TestCloud's Kubernetes performance vs. Selenium Grid 5.0. Ensure Katalon matches or exceeds claimed 10x improvement.
2. MARKETING: Create "Selenium Grid 5.0 vs. Katalon TestCloud" comparison content highlighting Katalon's integrated reporting, test management, and no-infra-required approach.
3. SALES: Arm team with battle card: "Selenium Grid 5.0 is great if you have Kubernetes expertise and want to manage infrastructure. TestCloud is better if you want testing capabilities out-of-the-box."

Katalon Advantages:
- No Kubernetes knowledge required (managed service)
- Integrated test analytics and reporting (Grid 5.0 requires separate tools)
- Visual test recorder (Grid is code-only)
- Built-in test management (Grid has none)

Katalon Gaps to Address:
- If Selenium Grid 5.0's 10x claim is accurate, ensure TestCloud performance is competitive
- Consider offering Kubernetes-native deployment option for enterprise customers who prefer self-hosted

**Sources:**
- https://selenium.dev/blog/2025/grid-5
- https://github.com/SeleniumHQ/selenium/releases/tag/selenium-5.0.0
- https://thenewstack.io/selenium-grid-5-kubernetes-native-testing (industry analysis)
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 4.0 | 2025-11-19 | Complete rewrite for Gemini integration, 7-dimension framework |
| 3.0 | 2025-08-01 | Added Market Context and Customer Impact sections |
| 2.0 | 2025-05-15 | Refined for Perplexity Sonar Pro (previously GPT-4) |
| 1.0 | 2025-03-01 | Initial version |

---

**Last Updated:** 2025-11-19
**Maintained By:** Katalon Marketing Automation Team
