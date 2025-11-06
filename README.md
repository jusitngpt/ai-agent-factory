# AI Agent Factory

**Enterprise Marketing Automation Suite Built on n8n**

A comprehensive suite of 6 AI-powered agents designed to automate and enhance marketing operations for go-to-market (GTM) teams. Built using n8n workflows, multiple LLM providers, and Airtable for data management.

## Overview

The AI Agent Factory transforms marketing operations by automating research, content creation, customer intelligence, and personalization at scale. Each agent is designed to solve specific GTM challenges while integrating seamlessly into your existing workflow.

## Agent Suite

### 1A. Competitive Intelligence Monitor (On-Demand Research)
- **Status**: ✅ Production Ready
- **Purpose**: Deep competitive analysis and market research on demand
- **Key Features**: Multi-source research, competitor tracking, trend analysis
- **Use Cases**: Product launches, competitive positioning, market entry research

### 1B. Competitive Intelligence Monitor (RSS Monitoring)
- **Status**: 🚧 In Development
- **Purpose**: Automated monitoring of competitor news and updates
- **Key Features**: RSS feed aggregation, alert system, change detection

### 2. SEO & Content Intelligence Agent
- **Status**: 📋 Planned
- **Purpose**: Content optimization and SEO strategy automation
- **Key Features**: Keyword research, content gap analysis, SERP monitoring

### 3. Voice of Customer Analysis Agent
- **Status**: 📋 Planned
- **Purpose**: Customer feedback analysis and sentiment tracking
- **Key Features**: Review aggregation, sentiment analysis, insights extraction

### 4. Social Media Content Factory
- **Status**: 📋 Planned
- **Purpose**: Multi-platform social content generation and scheduling
- **Key Features**: Content creation, platform optimization, posting automation

### 5. Lead Intelligence & Scoring Agent
- **Status**: 📋 Planned
- **Purpose**: Lead enrichment and intelligent scoring
- **Key Features**: Company research, lead qualification, priority scoring

### 6. Hyper-Personalization Engine
- **Status**: 📋 Planned
- **Purpose**: Personalized outreach content generation
- **Key Features**: Account-based personalization, email customization, dynamic content

## Technology Stack

- **Workflow Engine**: n8n (self-hosted or cloud)
- **LLM Providers**:
  - Anthropic Claude (primary reasoning)
  - Google Gemini (research tasks)
  - Perplexity AI (web research)
- **Database**: Airtable (data storage and management)
- **Notifications**: Slack integration
- **Deployment**: Docker-ready, cloud-agnostic

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/jusitngpt/ai-agent-factory.git
cd ai-agent-factory

# 2. Check prerequisites
./scripts/quickstart.sh

# 3. Follow the setup guide
# See docs/setup-guide.md for detailed instructions
```

## Repository Structure

```
ai-agent-factory/
├── agents/                      # Individual agent documentation
│   ├── 01-competitive-intel-monitor/
│   ├── 02-seo-content-intelligence/
│   ├── 03-voice-of-customer/
│   ├── 04-social-factory/
│   ├── 05-lead-intel-scoring/
│   └── 06-hyper-personalization/
├── docs/                        # Technical documentation
│   ├── architecture.md          # System architecture
│   ├── setup-guide.md          # Installation & configuration
│   └── prompt-library.md       # LLM prompts and configs
├── airtable/                    # Database schema
│   └── table-definitions.md
├── scripts/                     # Helper scripts
│   └── quickstart.sh
├── README.md                    # This file
└── SETUP-STATUS.md             # Current implementation status
```

## Documentation

- **[Setup Guide](docs/setup-guide.md)** - Step-by-step installation and configuration
- **[Architecture](docs/architecture.md)** - System design and data flow
- **[Prompt Library](docs/prompt-library.md)** - LLM prompts and model configurations
- **[Setup Status](SETUP-STATUS.md)** - Current implementation progress

## Prerequisites

- n8n instance (v1.0+)
- Airtable account
- API keys:
  - Anthropic Claude API
  - Google Gemini API
  - Perplexity API
- Slack workspace (optional, for notifications)

## Key Features

- **Multi-LLM Architecture**: Leverage the best model for each task
- **Modular Design**: Deploy individual agents or the complete suite
- **Cost Optimization**: Smart routing between LLM providers
- **Human-in-the-Loop**: Review and approval workflows built-in
- **Enterprise Ready**: Secure, scalable, and production-tested

## Business Value

- **Time Savings**: Automate 10-15 hours/week of manual research and content work
- **Consistency**: Maintain brand voice and quality across all outputs
- **Scalability**: Handle 10x volume without adding headcount
- **Intelligence**: Access real-time market insights and competitive intelligence
- **ROI**: Typical payback period of 2-3 months

## Getting Started

1. **Start with Agent 1A**: Easiest to implement, immediate value
2. **Set up Airtable**: Follow [table definitions](airtable/table-definitions.md)
3. **Import n8n workflow**: Available in agent folders
4. **Configure API keys**: See [setup guide](docs/setup-guide.md)
5. **Test execution**: Run sample research request

## Contributing

This is an internal project for GTM teams. For questions or improvements, please reach out to the repository maintainer.

## License

Proprietary - Internal use only

## Support

- Documentation: See `/docs` folder
- Issues: Contact repository maintainer
- n8n Workflow ID (Agent 1A Production): `VN0rMvGd5ewydmKR`

---

**Built with** n8n + Claude + Airtable | **Maintained by** GTM Operations Team
