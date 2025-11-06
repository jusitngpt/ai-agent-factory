# AI Agent Factory - Setup Guide

Complete step-by-step guide to deploying the AI Agent Factory suite.

## Prerequisites Checklist

Before starting, ensure you have:

- [ ] **n8n Instance** (v1.0+)
  - Self-hosted OR n8n Cloud account
  - Admin access to create workflows

- [ ] **Airtable Account**
  - Free or paid plan
  - Ability to create new bases

- [ ] **API Keys**
  - [ ] Anthropic Claude API key
  - [ ] Google Gemini API key
  - [ ] Perplexity API key

- [ ] **Slack Workspace** (optional but recommended)
  - Admin access to create webhooks
  - Channel for notifications

- [ ] **Technical Skills**
  - Basic understanding of APIs
  - Familiarity with JSON
  - Comfortable with webhooks

**Estimated Setup Time**: 2-3 hours for Agent 1A

---

## Part 1: Airtable Setup

### Step 1: Create New Base

1. Log into Airtable at https://airtable.com
2. Click **"Add a base"** → **"Start from scratch"**
3. Name it: `AI Agent Factory`
4. Click **"Create base"**

### Step 2: Create Research Requests Table

1. Rename the default table to `Research Requests`
2. Create the following fields:

| Field Name | Field Type | Configuration |
|------------|------------|---------------|
| Request ID | Autonumber | Auto-generated |
| Company Name | Single line text | Required |
| Research Focus | Long text | Required |
| Status | Single select | Options: Pending, Processing, Complete, Failed |
| Priority | Single select | Options: Low, Medium, High, Urgent |
| Requested By | Single line text | User email/name |
| Created Date | Created time | Auto-generated |
| Due Date | Date | Optional |
| Notes | Long text | Optional |
| Link to Results | Link to another record | Link to Research Results table |

3. Set default view:
   - **Filter**: Status is not "Complete"
   - **Sort**: Priority (Urgent → Low), then Created Date (newest first)
   - **Group**: By Status

### Step 3: Create Research Results Table

1. Click **"+"** to add new table
2. Name it: `Research Results`
3. Create these fields:

| Field Name | Field Type | Configuration |
|------------|------------|---------------|
| Result ID | Autonumber | Auto-generated |
| Request | Link to another record | Link to Research Requests |
| Executive Summary | Long text | Main findings summary |
| Full Report | Long text | Complete research output |
| Key Findings | Long text | Bullet points |
| Sources | Long text | URLs and references |
| Competitor Names | Multiple select | Auto-populated from research |
| Industries | Multiple select | Auto-populated |
| Confidence Score | Number | 0-100 scale |
| Research Date | Created time | Auto-generated |
| Processing Time | Number | In seconds |
| Cost | Currency | LLM API costs |
| Attachments | Attachment | Screenshots, PDFs |

### Step 4: Create Competitor Tracking Table

1. Add another table: `Competitor Tracking`
2. Create fields:

| Field Name | Field Type | Configuration |
|------------|------------|---------------|
| Company Name | Single line text | Primary field |
| Website | URL | Company homepage |
| Industry | Single select | Predefined list |
| Last Researched | Date | Auto-updated |
| Research Count | Count | Links to Research Results |
| Priority | Single select | Low/Medium/High |
| RSS Feed | URL | For Agent 1B |
| Notes | Long text | Strategic notes |

### Step 5: Get API Credentials

1. Click your profile icon → **"Account"**
2. Go to **"API"** section
3. Click **"Generate API key"**
4. Copy and save securely (you'll need this for n8n)
5. Note your Base ID:
   - Open your base
   - Look at URL: `https://airtable.com/[BASE_ID]/...`
   - Copy the BASE_ID (starts with `app`)

### Step 6: Create Airtable Form (Optional)

1. Open **Research Requests** table
2. Click **"Form"** view type
3. Add fields to form:
   - Company Name
   - Research Focus
   - Priority
   - Requested By
   - Notes
4. Customize form design
5. Click **"Share form"** → Copy link
6. Share with your team

---

## Part 2: API Keys Setup

### Anthropic Claude API

1. Visit https://console.anthropic.com
2. Sign up or log in
3. Go to **"API Keys"**
4. Click **"Create Key"**
5. Name it: `AI Agent Factory`
6. Copy key (starts with `sk-ant-`)
7. Save securely

**Recommended Model**: `claude-3-5-sonnet-20241022`

**Pricing** (as of Nov 2025):
- Input: $3 / million tokens
- Output: $15 / million tokens

### Google Gemini API

1. Visit https://ai.google.dev
2. Click **"Get API key"**
3. Create new project or select existing
4. Enable **Gemini API**
5. Create credentials → API key
6. Copy key
7. Save securely

**Recommended Model**: `gemini-2.0-flash-exp`

**Pricing**:
- Free tier: 1500 requests/day
- Paid: $0.075 / million tokens (very affordable)

### Perplexity API

1. Visit https://www.perplexity.ai
2. Sign up for Pro account (required for API)
3. Go to **Settings** → **API**
4. Generate API key
5. Copy key
6. Save securely

**Recommended Model**: `sonar-pro`

**Pricing**:
- ~$5 per 1000 requests
- Includes web search + citations

---

## Part 3: n8n Installation

### Option A: n8n Cloud (Easiest)

1. Visit https://n8n.io
2. Click **"Start free"**
3. Create account
4. Your instance is ready (skip to Part 4)

**Pricing**: Free tier available, $20/month for production

### Option B: Self-Hosted with Docker (Recommended)

#### Prerequisites
- Docker installed
- Docker Compose installed
- 2GB RAM minimum
- 10GB disk space

#### Installation Steps

1. Create directory:
```bash
mkdir ~/ai-agent-factory-n8n
cd ~/ai-agent-factory-n8n
```

2. Create `docker-compose.yml`:
```yaml
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: ai-agent-factory-n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=change_this_password
      - N8N_HOST=localhost
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - NODE_ENV=production
      - EXECUTIONS_TIMEOUT=300
      - EXECUTIONS_TIMEOUT_MAX=600
    volumes:
      - ./n8n_data:/home/node/.n8n
      - ./workflows:/home/node/workflows
```

3. Start n8n:
```bash
docker-compose up -d
```

4. Access n8n:
   - Open browser: http://localhost:5678
   - Login with credentials from docker-compose.yml
   - Change default password immediately

5. Verify installation:
   - Click **"Credentials"** → Should load without errors
   - Click **"Workflows"** → Should see empty list

---

## Part 4: n8n Configuration

### Step 1: Add Airtable Credentials

1. In n8n, go to **"Credentials"** → **"Add Credential"**
2. Search for **"Airtable API"**
3. Click **"Airtable API"**
4. Enter:
   - **Credential Name**: `Airtable - AI Agent Factory`
   - **API Key**: [Your Airtable API key from Part 1]
5. Click **"Save"**
6. Test connection by clicking **"Test"**

### Step 2: Add Anthropic Claude Credentials

1. **"Credentials"** → **"Add Credential"**
2. Search **"Anthropic"**
3. Enter:
   - **Credential Name**: `Claude API - Production`
   - **API Key**: [Your Claude API key]
4. **"Save"** and **"Test"**

### Step 3: Add Google Gemini Credentials

1. **"Credentials"** → **"Add Credential"**
2. Search **"Google Gemini"** or **"Google AI"**
3. Enter:
   - **Credential Name**: `Gemini API - Production`
   - **API Key**: [Your Gemini API key]
4. **"Save"** and **"Test"**

### Step 4: Add Perplexity Credentials

Perplexity might not have native n8n integration. Use **HTTP Request** node:

1. **"Credentials"** → **"Add Credential"**
2. Select **"Header Auth"**
3. Enter:
   - **Credential Name**: `Perplexity API`
   - **Name**: `Authorization`
   - **Value**: `Bearer [YOUR_PERPLEXITY_API_KEY]`
4. **"Save"**

### Step 5: Add Slack Webhook (Optional)

1. Go to https://api.slack.com/apps
2. Click **"Create New App"** → **"From scratch"**
3. Name: `AI Agent Factory`
4. Select your workspace
5. Go to **"Incoming Webhooks"**
6. **"Activate Incoming Webhooks"** → ON
7. **"Add New Webhook to Workspace"**
8. Select channel (e.g., `#ai-agents`)
9. Copy webhook URL
10. In n8n:
    - **"Credentials"** → **"Webhook"** (or use HTTP Request)
    - Save the webhook URL for use in workflows

---

## Part 5: Deploy Agent 1A Workflow

### Step 1: Create New Workflow

1. In n8n, click **"Workflows"** → **"Add Workflow"**
2. Name it: `Agent 1A - Competitive Intel (On-Demand)`
3. Click **"Save"**

### Step 2: Add Webhook Trigger

1. Click **"+"** → Search **"Webhook"**
2. Add **"Webhook"** node
3. Configure:
   - **HTTP Method**: POST
   - **Path**: `agent-1a-research`
   - **Response Mode**: "When Last Node Finishes"
4. Click **"Listen for Test Event"**
5. Copy the webhook URL (you'll test this later)

### Step 3: Build the Workflow

Add these nodes in sequence:

#### Node 1: Webhook (already added)
- Receives request with `company_name` and `research_focus`

#### Node 2: Set Variables
- **Node Type**: Set
- **Purpose**: Extract and validate input
- **Fields**:
  - `company_name` = `{{ $json.body.company_name }}`
  - `research_focus` = `{{ $json.body.research_focus || "general competitive analysis" }}`
  - `request_id` = `{{ $json.body.request_id }}`

#### Node 3: Update Airtable Status (Start)
- **Node Type**: Airtable
- **Operation**: Update
- **Table**: Research Requests
- **Record ID**: `{{ $node["Set Variables"].json.request_id }}`
- **Fields**:
  - Status = "Processing"

#### Node 4: Slack Notification (Started)
- **Node Type**: HTTP Request (using webhook)
- **Method**: POST
- **URL**: [Your Slack webhook URL]
- **Body**:
```json
{
  "text": "🔍 Research started: {{ $node['Set Variables'].json.company_name }}"
}
```

#### Node 5: Perplexity Research
- **Node Type**: HTTP Request
- **Authentication**: Header Auth (Perplexity API)
- **Method**: POST
- **URL**: `https://api.perplexity.ai/chat/completions`
- **Headers**:
  - Content-Type: `application/json`
- **Body**:
```json
{
  "model": "sonar-pro",
  "messages": [
    {
      "role": "user",
      "content": "Research {{ $node['Set Variables'].json.company_name }}. Focus: {{ $node['Set Variables'].json.research_focus }}. Provide: company overview, key products/services, target market, competitive position, recent news, and 5-10 relevant URLs as sources."
    }
  ]
}
```

#### Node 6: Claude Analysis
- **Node Type**: Anthropic Chat Model (or HTTP Request)
- **Model**: claude-3-5-sonnet-20241022
- **Prompt**:
```
Analyze the following research about {{ $node['Set Variables'].json.company_name }}:

{{ $node["Perplexity Research"].json.choices[0].message.content }}

Provide:
1. Executive Summary (2-3 paragraphs)
2. Key Findings (5-7 bullet points)
3. Competitive Advantages
4. Potential Weaknesses
5. Strategic Recommendations

Format in clear, business-friendly language.
```

#### Node 7: Gemini Structured Output
- **Node Type**: Google Gemini (or HTTP Request)
- **Model**: gemini-2.0-flash-exp
- **Prompt**:
```
Format the following analysis as a JSON object:

{{ $node["Claude Analysis"].json.content[0].text }}

JSON structure:
{
  "executive_summary": "string",
  "key_findings": ["string"],
  "competitive_advantages": ["string"],
  "weaknesses": ["string"],
  "recommendations": ["string"],
  "confidence_score": number (0-100)
}
```

#### Node 8: Save to Airtable (Results)
- **Node Type**: Airtable
- **Operation**: Create
- **Table**: Research Results
- **Fields**:
  - Request: `{{ $node["Set Variables"].json.request_id }}`
  - Executive Summary: `{{ $node["Gemini Structured Output"].json.executive_summary }}`
  - Full Report: `{{ $node["Claude Analysis"].json.content[0].text }}`
  - Key Findings: `{{ $node["Gemini Structured Output"].json.key_findings.join('\n') }}`
  - Sources: `{{ $node["Perplexity Research"].json.choices[0].message.content }}`
  - Confidence Score: `{{ $node["Gemini Structured Output"].json.confidence_score }}`

#### Node 9: Update Request Status (Complete)
- **Node Type**: Airtable
- **Operation**: Update
- **Table**: Research Requests
- **Record ID**: `{{ $node["Set Variables"].json.request_id }}`
- **Fields**:
  - Status: "Complete"

#### Node 10: Slack Notification (Complete)
- **Node Type**: HTTP Request
- **Body**:
```json
{
  "text": "✅ Research complete: {{ $node['Set Variables'].json.company_name }}\n\nView results: [Airtable link]"
}
```

### Step 4: Add Error Handling

1. Click workflow settings (gear icon)
2. **"Error Workflow"** → **"Create New"**
3. In error workflow, add:
   - Trigger: Error Trigger
   - Airtable Update (set status to "Failed")
   - Slack notification with error details

### Step 5: Test the Workflow

1. Click **"Execute Workflow"** button
2. Use Postman or curl to send test request:

```bash
curl -X POST http://localhost:5678/webhook/agent-1a-research \
  -H "Content-Type: application/json" \
  -d '{
    "company_name": "Stripe",
    "research_focus": "payment processing competitive landscape",
    "request_id": "rec123456"
  }'
```

3. Watch workflow execute in real-time
4. Check Airtable for results
5. Verify Slack notification

### Step 6: Activate Workflow

1. Click the **"Inactive"** toggle in top-right
2. Should switch to **"Active"**
3. Workflow is now live and listening for webhooks

---

## Part 6: Connect Airtable Automation

### Step 1: Create Automation in Airtable

1. Open **Research Requests** table
2. Click **"Automations"** (top-right)
3. **"Create automation"**

### Step 2: Configure Trigger

1. **Trigger**: When record created
2. **Table**: Research Requests
3. **Conditions**: Status is "Pending"

### Step 3: Add Webhook Action

1. **Action**: Send webhook
2. **URL**: [Your n8n webhook URL from Part 5]
3. **Method**: POST
4. **Body**:
```json
{
  "company_name": "{{ Company Name }}",
  "research_focus": "{{ Research Focus }}",
  "request_id": "{{ Record ID }}"
}
```

### Step 4: Test Automation

1. Click **"Test automation"**
2. Create test record in Research Requests
3. Watch automation fire → n8n workflow execute
4. Verify results in Research Results table

---

## Part 7: Security & Best Practices

### API Key Security

**DO**:
- ✅ Use environment variables for keys
- ✅ Rotate keys every 90 days
- ✅ Use different keys for dev/prod
- ✅ Enable API usage alerts

**DON'T**:
- ❌ Commit keys to git
- ❌ Share keys in Slack/email
- ❌ Use production keys for testing
- ❌ Store keys in n8n workflow notes

### Monitoring

Set up alerts for:
- Workflow failures (>10% failure rate)
- High costs (>$50/day)
- Long execution times (>10 minutes)
- API rate limit errors

### Backup Strategy

**Weekly**:
- Export Airtable base (CSV backup)
- Export n8n workflows (JSON backup)

**Monthly**:
- Review API costs
- Archive old research results
- Update documentation

---

## Part 8: Testing & Validation

### Test Cases

Run these tests before going to production:

1. **Happy Path**
   - Create request with valid company name
   - Verify complete workflow execution
   - Check all Airtable fields populated

2. **Error Handling**
   - Invalid company name
   - API timeout (mock by disconnecting)
   - Malformed input

3. **Edge Cases**
   - Very long research focus (>500 chars)
   - Special characters in company name
   - Multiple simultaneous requests

4. **Cost Validation**
   - Run 10 test requests
   - Calculate total cost
   - Verify within budget ($0.50 total)

### Acceptance Criteria

Before marking Agent 1A as production-ready:

- [ ] 10 successful test runs
- [ ] All error scenarios handled gracefully
- [ ] Airtable data structure validated
- [ ] Slack notifications working
- [ ] Average cost per request <$0.30
- [ ] Average execution time <5 minutes
- [ ] Documentation complete
- [ ] Team trained on usage

---

## Part 9: Go Live

### Pre-Launch Checklist

- [ ] All tests passing
- [ ] Error handling verified
- [ ] Slack channel configured
- [ ] Team training completed
- [ ] Backup process established
- [ ] Monitoring alerts set up
- [ ] API budgets configured
- [ ] Documentation published

### Launch Steps

1. **Soft Launch**: Invite 2-3 power users
2. **Gather Feedback**: Run for 1 week
3. **Iterate**: Fix issues, improve prompts
4. **Full Launch**: Announce to entire team
5. **Monitor**: Watch for first 2 weeks closely

### Success Metrics

Track for first month:
- Number of requests processed
- Average cost per request
- User satisfaction (survey)
- Time saved vs manual research
- Workflow failure rate

---

## Troubleshooting

### Common Issues

**Issue**: Webhook not firing
- **Solution**: Check Airtable automation is active, verify webhook URL

**Issue**: API rate limit errors
- **Solution**: Add wait nodes, implement retry logic

**Issue**: Incomplete results
- **Solution**: Check API responses, increase timeout settings

**Issue**: High costs
- **Solution**: Review prompts for efficiency, consider using cheaper models

**Issue**: n8n workflow stuck
- **Solution**: Check execution logs, restart n8n container

---

## Next Steps

Once Agent 1A is stable:

1. **Agent 1B**: RSS monitoring
2. **Agent 2**: SEO intelligence
3. **Advanced Features**:
   - Scheduled recurring research
   - Research result comparisons
   - Trend analysis dashboards

---

## Support & Resources

- **n8n Documentation**: https://docs.n8n.io
- **Airtable API**: https://airtable.com/developers/web/api
- **Anthropic Docs**: https://docs.anthropic.com
- **Project Repository**: https://github.com/jusitngpt/ai-agent-factory

---

**Last Updated**: November 6, 2025
**Setup Guide Version**: 1.0
**Maintained by**: GTM Operations Team
