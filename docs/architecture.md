# AI Agent Factory - System Architecture

## Overview

The AI Agent Factory is built on a modular, event-driven architecture that leverages n8n for workflow orchestration, multiple LLM providers for intelligence, and Airtable for data persistence. This document outlines the system design, data flows, and technical decisions.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        INPUT LAYER                               │
├─────────────────────────────────────────────────────────────────┤
│  Webhooks  │  Airtable Forms  │  Slack Commands  │  Scheduled   │
└──────┬──────────────┬────────────────┬──────────────┬───────────┘
       │              │                │              │
       └──────────────┴────────────────┴──────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    ORCHESTRATION LAYER                           │
│                          (n8n)                                   │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │ Agent 1A │  │ Agent 1B │  │ Agent 2  │  │ Agent... │       │
│  │ Workflow │  │ Workflow │  │ Workflow │  │ Workflow │       │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘       │
│       │             │              │              │              │
└───────┼─────────────┼──────────────┼──────────────┼─────────────┘
        │             │              │              │
        ▼             ▼              ▼              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    INTELLIGENCE LAYER                            │
│                      (LLM Providers)                             │
├─────────────────────────────────────────────────────────────────┤
│  ┌────────────┐  ┌────────────┐  ┌────────────┐                │
│  │ Perplexity │  │   Claude   │  │   Gemini   │                │
│  │    API     │  │    API     │  │    API     │                │
│  │            │  │            │  │            │                │
│  │  Research  │  │  Analysis  │  │ Structured │                │
│  │   Tasks    │  │ Reasoning  │  │   Output   │                │
│  └────────────┘  └────────────┘  └────────────┘                │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DATA LAYER                                  │
│                      (Airtable)                                  │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │ Research │  │Competitor│  │   SEO    │  │  Leads   │       │
│  │ Requests │  │ Tracking │  │   Data   │  │   DB     │       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    NOTIFICATION LAYER                            │
├─────────────────────────────────────────────────────────────────┤
│      Slack Channels  │  Email  │  Webhooks  │  Dashboard        │
└─────────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. Input Layer

**Purpose**: Accept requests from various sources and route to appropriate workflows

**Components**:
- **Webhooks**: HTTP endpoints for programmatic access
- **Airtable Forms**: User-friendly form interface for non-technical users
- **Slack Commands**: Direct Slack integration for quick requests
- **Scheduled Triggers**: Cron-based automation for recurring tasks

**Example Flow**:
```
User submits Airtable form → Form creates record →
Airtable automation fires webhook → n8n receives request
```

### 2. Orchestration Layer (n8n)

**Purpose**: Workflow execution engine that coordinates all agent activities

**Key Features**:
- Visual workflow editor
- Error handling and retries
- Conditional logic and branching
- Data transformation
- API integrations

**Workflow Pattern** (Agent 1A Example):
```
1. Webhook Trigger
2. Parse Input & Validate
3. Update Status in Airtable
4. Call Perplexity API (Initial Research)
5. Process Research Results
6. Call Claude API (Analysis)
7. Call Gemini API (Structured Output)
8. Save Results to Airtable
9. Send Slack Notification
10. Error Handler (if any step fails)
```

**n8n Configuration**:
- **Environment**: Self-hosted (Docker recommended)
- **Version**: 1.0+
- **Execution Mode**: Queue mode for reliability
- **Timeout Settings**: 5 minutes per workflow
- **Retry Policy**: 3 attempts with exponential backoff

### 3. Intelligence Layer (LLMs)

**Purpose**: Provide AI capabilities through specialized model routing

#### Model Selection Strategy

| Task Type | Primary Model | Reason | Fallback |
|-----------|---------------|--------|----------|
| Web Research | Perplexity API | Real-time web access, citations | Gemini 2.0 |
| Deep Analysis | Claude 3.5 Sonnet | Superior reasoning, long context | GPT-4 |
| Structured Output | Gemini 2.0 Flash | JSON mode, cost-effective | Claude |
| Content Generation | Claude 3.5 | Brand voice, creativity | Gemini |
| Code Generation | Claude 3.5 | Best for technical content | GPT-4 |

#### Cost Optimization

**Token Management**:
- Compress prompts to reduce input tokens
- Use streaming for long responses
- Cache system prompts where possible
- Route simple tasks to cheaper models

**Expected Costs** (Agent 1A):
```
Perplexity Research: $0.05-0.10 per request
Claude Analysis:     $0.05-0.15 per request
Gemini Output:       $0.02-0.05 per request
Total per run:       $0.12-0.30
```

### 4. Data Layer (Airtable)

**Purpose**: Centralized data storage with user-friendly interface

**Why Airtable?**
- ✅ No-code interface for non-technical users
- ✅ Built-in forms and views
- ✅ Real-time collaboration
- ✅ API for automation
- ✅ Attachment storage
- ❌ Not ideal for high-volume (use PostgreSQL for scale)

**Database Schema** (see `/airtable/table-definitions.md` for full details):

```
Research Requests Table
├── Request ID (Primary Key)
├── Company Name
├── Research Focus
├── Status (Pending/Processing/Complete/Failed)
├── Created Date
├── Assigned To
└── Link to Results

Research Results Table
├── Result ID (Primary Key)
├── Request ID (Foreign Key)
├── Executive Summary
├── Full Research Report
├── Key Findings (Array)
├── Sources (URLs)
└── Completion Date
```

### 5. Notification Layer

**Purpose**: Keep users informed of agent activities

**Channels**:
- **Slack**: Real-time notifications for completions/errors
- **Email**: Digest reports and summaries
- **Webhooks**: Integration with external systems
- **Airtable**: In-app status updates

## Data Flow Examples

### Agent 1A: On-Demand Competitive Research

```
Step 1: Input
  User → Airtable Form → Creates record with company name

Step 2: Trigger
  Airtable automation → Webhook → n8n workflow starts

Step 3: Initial Status Update
  n8n → Airtable API → Set status to "Processing"
  n8n → Slack API → Post "Research started on [Company]"

Step 4: Web Research
  n8n → Perplexity API → Prompt: "Research [Company]..."
  Perplexity → Returns: Raw research data + sources

Step 5: Analysis
  n8n → Claude API → Prompt: "Analyze this research..."
  Claude → Returns: Executive summary, key insights

Step 6: Structured Output
  n8n → Gemini API → Prompt: "Format as JSON..."
  Gemini → Returns: Structured data object

Step 7: Save Results
  n8n → Airtable API → Create result record
  n8n → Airtable API → Update request status to "Complete"

Step 8: Notification
  n8n → Slack API → Post completion message with link

Step 9: Error Handling (if needed)
  Any step fails → n8n error catcher →
  Update status to "Failed" → Notify team → Log details
```

**Timeline**: 2-5 minutes total
**Cost**: $0.15-0.30 per request

## Security Architecture

### API Key Management

**Storage**:
- Environment variables (never in code)
- n8n credentials store (encrypted)
- Secrets manager for production (recommended)

**Rotation Policy**:
- Rotate keys every 90 days
- Use separate keys per environment (dev/prod)
- Log all API calls for audit

### Data Security

**In Transit**:
- HTTPS for all API calls
- TLS 1.2+ required
- Certificate pinning for critical services

**At Rest**:
- Airtable encryption (managed by Airtable)
- No PII storage without consent
- Regular data retention reviews

**Access Control**:
- n8n: Role-based access (editor/viewer)
- Airtable: Per-base permissions
- API webhooks: Secret token validation

### Compliance

- **Data Residency**: Airtable US-based
- **GDPR**: Right to delete implemented
- **SOC 2**: n8n and Airtable are compliant
- **Audit Logs**: All executions logged

## Error Handling Strategy

### Levels of Error Handling

**1. API-Level Errors**
```
Rate Limit → Wait & Retry (3 attempts, exponential backoff)
Timeout → Retry with extended timeout
Invalid Response → Log & try fallback model
Auth Error → Alert admin immediately
```

**2. Workflow-Level Errors**
```
Data Validation Fails → Return to user with error message
External Service Down → Queue for retry in 15 minutes
Partial Completion → Save progress, resume from last step
Critical Failure → Alert admin, mark as failed
```

**3. System-Level Errors**
```
n8n Crash → Docker auto-restart
Database Connection Lost → Retry with circuit breaker
Out of Memory → Scale container resources
```

### Monitoring & Alerting

**Metrics Tracked**:
- Workflow execution time
- Success/failure rates
- API response times
- Cost per execution
- Queue depth

**Alert Thresholds**:
- Failure rate > 10% in 1 hour → Slack alert
- Average execution time > 10 minutes → Investigate
- API costs > $50/day → Review usage
- Queue depth > 20 → Scale warning

## Scalability Considerations

### Current Limits

| Resource | Current Capacity | Bottleneck |
|----------|-----------------|------------|
| n8n Workflows | 100 concurrent | Single instance |
| Airtable Records | 50,000 (free tier) | Plan limits |
| API Rate Limits | Varies by provider | Perplexity: 50/min |
| Storage | Unlimited (Airtable) | Cost increases |

### Scaling Strategy

**Phase 1** (Current): Single n8n instance
- Good for: <100 requests/day
- Cost: ~$50/month

**Phase 2** (Growth): n8n Queue Mode + Redis
- Good for: 100-1000 requests/day
- Cost: ~$200/month
- Add: Redis for queue, Load balancer

**Phase 3** (Enterprise): Multi-instance + PostgreSQL
- Good for: >1000 requests/day
- Cost: ~$500+/month
- Add: PostgreSQL, Container orchestration, Monitoring stack

## Technology Decisions

### Why n8n?

**Pros**:
- ✅ Open source, self-hostable
- ✅ Visual workflow builder
- ✅ 350+ integrations
- ✅ Affordable ($20/month cloud or free self-hosted)
- ✅ Great for GTM teams (non-technical friendly)

**Cons**:
- ❌ Not ideal for high-frequency tasks (use dedicated services)
- ❌ Limited version control (workflows stored in DB)
- ❌ Debugging can be challenging

**Alternatives Considered**:
- Zapier (too expensive at scale)
- Make.com (similar to n8n, less flexible)
- Custom Node.js (too complex for team)

### Why Airtable?

**Pros**:
- ✅ User-friendly interface
- ✅ Built-in forms and views
- ✅ Real-time collaboration
- ✅ Quick setup (hours, not days)

**Cons**:
- ❌ Cost scales with records
- ❌ Limited query capabilities
- ❌ Not ideal for relational data

**Alternatives Considered**:
- PostgreSQL (too technical for team)
- Google Sheets (rate limits, not reliable)
- MongoDB (no good UI for users)

### Why Multi-LLM?

**Strategy**: Use the best model for each task

- **Perplexity**: Web research (real-time data)
- **Claude**: Analysis & reasoning (superior quality)
- **Gemini**: Structured output (JSON mode, cost-effective)

**Benefits**:
- Cost optimization (30-40% savings vs Claude-only)
- Better results (right tool for each job)
- Redundancy (fallback options)

## Future Architecture Enhancements

### Planned Improvements

1. **Docker Containerization**
   - Easier deployment
   - Environment parity
   - Simplified scaling

2. **CI/CD Pipeline**
   - Automated testing
   - Workflow version control
   - Staged deployments

3. **Monitoring Dashboard**
   - Real-time metrics
   - Cost tracking
   - Performance insights

4. **API Gateway**
   - Unified API for all agents
   - Rate limiting
   - Analytics

5. **Vector Database**
   - Semantic search
   - Research history analysis
   - Better recommendations

## Conclusion

The AI Agent Factory architecture is designed for **simplicity first, scale when needed**. The current setup handles low-to-medium volume efficiently while maintaining flexibility for future growth.

**Key Principles**:
- Modular design (agents are independent)
- Cost-conscious (optimize LLM usage)
- User-friendly (non-technical team members can use)
- Production-ready (error handling, monitoring)
- Extensible (easy to add new agents)

For implementation details, see:
- [Setup Guide](setup-guide.md)
- [Prompt Library](prompt-library.md)
- [Agent Documentation](../agents/)

---

**Last Updated**: November 6, 2025
**Maintained by**: GTM Operations Team
