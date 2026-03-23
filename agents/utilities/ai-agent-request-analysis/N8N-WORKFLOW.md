# AI Agent Request Analysis - n8n Workflow Specification

**Workflow ID**: `jVRyNBedQHJAxHg6`
**Version**: 1.0.0
**Status**: ✅ Production Active
**Last Updated**: November 19, 2025

---

## Workflow Architecture

### Overview

The AI Agent Request Analysis workflow consists of **6 nodes** arranged in a linear processing pipeline:

```
[Airtable Trigger] → [Claude Analysis] → [Information Extractor] → [Airtable Update] → [Slack Notification]
                                              ↑
                                    [Gemini Chat Model]
```

### Data Flow

1. **Input**: New Airtable record in `AI Agent Requests` table
2. **Processing**: Claude Sonnet 4 analyzes request using ICE framework
3. **Extraction**: Gemini extracts structured JSON from Claude's response
4. **Storage**: Results written back to Airtable
5. **Notification**: Slack message sent to team channel

---

## Node 1: Airtable Trigger

**Type**: `n8n-nodes-base.airtableTrigger`
**Version**: 1
**Position**: [64, 304]

### Purpose
Monitors the `AI Agent Requests` table for new submissions and triggers the workflow.

### Configuration

```json
{
  "pollTimes": {
    "item": [
      {
        "mode": "everyHour"
      }
    ]
  },
  "authentication": "airtableTokenApi",
  "baseId": {
    "__rl": true,
    "value": "appELRlEUB59eOw3q",
    "mode": "id"
  },
  "tableId": {
    "__rl": true,
    "value": "tblXpXyzvOrNdqkqE",
    "mode": "id"
  },
  "triggerField": "Request Date",
  "additionalFields": {}
}
```

### Key Settings

| Setting | Value | Notes |
|---------|-------|-------|
| **Poll Interval** | Every hour | Can be adjusted for faster response |
| **Base ID** | `appELRlEUB59eOw3q` | Katalon Agent Factory base |
| **Table ID** | `tblXpXyzvOrNdqkqE` | AI Agent Requests table |
| **Trigger Field** | `Request Date` | Auto-populated timestamp field |
| **Authentication** | Personal Access Token | Requires Airtable token with base access |

### Output Schema

The trigger outputs the complete Airtable record with these key fields:

```json
{
  "id": "recXXXXXXXXXXXXXX",
  "fields": {
    "Requestor Name": "John Doe",
    "Requestor Department": "Marketing",
    "AI Agent Request": "Competitor Pricing Monitor",
    "Description of AI Agent": "...",
    "Data Sources": ["APIs", "Web Scraping"],
    "Trigger or On Demand": "Trigger-based",
    "KPI or OKR alignment": "Increase competitive intelligence visibility",
    "Potential Impact": "Help sales team respond faster to pricing changes",
    "Request Date": "2025-11-19T10:30:00.000Z"
  },
  "createdTime": "2025-11-19T10:30:00.000Z"
}
```

### Error Handling

- **Connection Failures**: n8n retries with exponential backoff
- **No New Records**: Workflow completes successfully with no execution
- **Invalid Base/Table**: Workflow fails with clear error message

### Performance Notes

- **Polling Overhead**: Minimal (single API call per hour)
- **Batch Processing**: Processes multiple new records if found
- **Execution Limit**: No limit (processes all new records)

---

## Node 2: Message a Model (Claude Sonnet 4)

**Type**: `@n8n/n8n-nodes-langchain.anthropic`
**Version**: 1
**Position**: [320, 304]
**ID**: `2b829296-796b-41f9-9063-66b8490c1373`

### Purpose
Analyzes the agent request using Claude Sonnet 4 to provide ICE scoring and technical recommendations.

### Configuration

```json
{
  "modelId": {
    "__rl": true,
    "value": "claude-sonnet-4-5-20250929",
    "mode": "list",
    "cachedResultName": "claude-sonnet-4-5-20250929"
  },
  "messages": {
    "values": [
      {
        "content": "=You are an expert AI automation architect..."
      }
    ]
  },
  "options": {}
}
```

### Prompt Engineering

The prompt is **dynamically constructed** using Airtable data:

```javascript
// Prompt Template (n8n expression syntax)
`You are an expert AI automation architect specializing in analyzing and prioritizing AI agent requests for the Katalon Agent Factory (KAF) system. Your role is to evaluate new AI agent proposals using the ICE scoring framework and provide technical recommendations.

CONTEXT:
The Katalon Agent Factory is a sophisticated AI-powered marketing automation system built on n8n workflows. It consists of interconnected agents that handle competitive intelligence, content generation, lead scoring, and personalized outreach. The system integrates with Airtable, Google Workspace, Slack, and various APIs.

ICE FRAMEWORK:
ICE stands for Impact, Confidence, and Ease. Evaluate each dimension:

**Impact (1-10)**: How much value will this agent deliver?
- Business outcomes (revenue, efficiency, cost savings)
- Scope of benefit (team, department, company-wide)
- Strategic alignment with KPIs/OKRs

**Confidence (1-10)**: How certain are you about the impact estimate?
- Similar proven use cases
- Data quality and availability
- Technical feasibility

**Ease (1-10)**: How simple is implementation?
- Technical complexity
- Integration requirements
- Resource and time investment
- Maintenance overhead

ICE Score = (Impact × Confidence × Ease) / 100

**RATING CATEGORIES:**
- **1 - High Impact, Low Effort**: ICE Score 7-10 (Quick wins - prioritize immediately)
- **2 - High Impact High Effort**: ICE Score 4-6.9 (Strategic investments - schedule carefully)
- **2 - Low Impact Low Effort**: ICE Score 4-6.9 (Nice-to-haves - fill gaps in roadmap)
- **3 - Low Impact High Effort**: ICE Score 0-3.9 (Avoid or defer indefinitely)

---

**AI AGENT REQUEST DATA:**

Requestor: {{ $json.fields['Requestor Name'] }}
Department: {{ $json.fields['Requestor Department'] }}
Agent Name: {{ $json.fields['AI Agent Request'] }}

Description:
{{ $json.fields['Description of AI Agent'] }}

Data Sources: {{ $json.fields['Data Sources'] }}
Trigger Type: {{ $json.fields['Trigger or On Demand'] }}
KPI/OKR Alignment: {{ $json.fields['KPI or OKR alignment'] }}
Potential Impact: {{ $json.fields['Potential Impact'] }}
Request Date: {{ $json.fields['Request Date'] }}

---

**YOUR ANALYSIS TASK:**

Analyze this AI agent request and provide the following three outputs:

**1. ICE RATING**
Select ONE of the following exact options:
- "1 - High Impact, Low Effort"
- "2 - High Impact High Effort"
- "2 - Low Impact Low Effort"
- "3 - Low Impact High Effort"

**2. REASON FOR ICE RATING**
Provide a detailed 2-4 paragraph explanation that includes:
- Your numerical estimates for Impact, Confidence, and Ease (with the calculation)
- Specific justification for each dimension based on the request details
- Key factors that influenced your rating
- Any assumptions or considerations
- Potential risks or challenges

**3. RECOMMENDED AGENTIC WORKFLOW**
Provide a technical workflow description that includes:
- High-level architecture (trigger → processing → output)
- Specific n8n nodes recommended (e.g., Airtable, HTTP Request, Claude AI, etc.)
- Data flow and transformations needed
- Integration points with existing KAF system
- Suggested scheduling (if trigger-based) or invocation method (if on-demand)
- Error handling and monitoring approach
- Estimated development time

Format your workflow description as a technical blueprint that an n8n developer could use to build the agent.

---

**OUTPUT FORMAT:**

Provide your analysis in the following structure:

ICE RATING: [Select one of the four exact options above]

REASON FOR ICE RATING:
[Your detailed analysis with numerical ICE calculations and justification]

RECOMMENDED AGENTIC WORKFLOW:
[Your technical workflow description]

---

Begin your analysis now.`
```

### Model Parameters

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| **Model** | `claude-sonnet-4-5-20250929` | Latest Sonnet for advanced reasoning |
| **Temperature** | Default (1.0) | Balanced creativity and consistency |
| **Max Tokens** | Default (4096) | Sufficient for detailed responses |
| **Top P** | Default (0.9) | Standard sampling |

### Expected Output

Claude returns a structured text response:

```
ICE RATING: 1 - High Impact, Low Effort

REASON FOR ICE RATING:
[Detailed 2-4 paragraph analysis with numerical breakdowns]

Impact Score: 9/10
Confidence Score: 8/10
Ease Score: 9/10
ICE Score: (9 × 8 × 9) / 100 = 6.48

[Rest of analysis...]

RECOMMENDED AGENTIC WORKFLOW:
[Technical blueprint...]
```

### Token Usage & Cost

| Metric | Value |
|--------|-------|
| **Input Tokens** | 800-1200 (varies by request length) |
| **Output Tokens** | 300-500 (detailed responses) |
| **Total Cost** | ~$0.003-$0.006 per request |

**Cost Breakdown** (Claude Sonnet 4 pricing):
- Input: $3.00 per 1M tokens
- Output: $15.00 per 1M tokens

### Error Handling

Potential errors:
- **API Timeout**: Retry with exponential backoff (handled by n8n)
- **Rate Limiting**: Rare (well under limits)
- **Invalid Response**: Caught by Information Extractor node

### Performance Notes

- **Response Time**: 4-8 seconds typical
- **Quality**: High consistency with structured prompt
- **Determinism**: Reasonably consistent scores for similar requests

---

## Node 3: Information Extractor

**Type**: `@n8n/n8n-nodes-langchain.informationExtractor`
**Version**: 1
**Position**: [656, 304]
**ID**: `information-extractor`

### Purpose
Extracts structured JSON data from Claude's natural language response to ensure consistent Airtable updates.

### Configuration

```json
{
  "text": "={{ $json.content[0].text }}",
  "schemaType": "fromJson",
  "jsonSchemaExample": "{\n  \"type\": \"object\",\n  \"properties\": {\n    \"ice_rating\": {\n      \"type\": \"string\",\n      \"description\": \"The ICE priority rating for the AI agent request\",\n      \"enum\": [\n        \"1 - High Impact, Low Effort\",\n        \"2 - High Impact High Effort\",\n        \"2 - Low Impact Low Effort\",\n        \"3 - Low Impact High Effort\"\n      ]\n    },\n    \"reason_for_ice_rating\": {\n      \"type\": \"string\",\n      \"description\": \"Detailed explanation of the ICE rating including Impact, Confidence, and Ease scores with justification (2-4 paragraphs)\"\n    },\n    \"recommended_workflow\": {\n      \"type\": \"string\",\n      \"description\": \"Technical description of the recommended agentic workflow including n8n nodes, architecture, data flow, integrations, and implementation details\"\n    }\n  },\n  \"required\": [\n    \"ice_rating\",\n    \"reason_for_ice_rating\",\n    \"recommended_workflow\"\n  ],\n  \"additionalProperties\": false\n}",
  "options": {}
}
```

### JSON Schema

The extractor validates against this schema:

```json
{
  "type": "object",
  "properties": {
    "ice_rating": {
      "type": "string",
      "description": "The ICE priority rating for the AI agent request",
      "enum": [
        "1 - High Impact, Low Effort",
        "2 - High Impact High Effort",
        "2 - Low Impact Low Effort",
        "3 - Low Impact High Effort"
      ]
    },
    "reason_for_ice_rating": {
      "type": "string",
      "description": "Detailed explanation of the ICE rating including Impact, Confidence, and Ease scores with justification (2-4 paragraphs)"
    },
    "recommended_workflow": {
      "type": "string",
      "description": "Technical description of the recommended agentic workflow including n8n nodes, architecture, data flow, integrations, and implementation details"
    }
  },
  "required": [
    "ice_rating",
    "reason_for_ice_rating",
    "recommended_workflow"
  ],
  "additionalProperties": false
}
```

### Connected Language Model

**Model**: Google Gemini Chat Model (Gemini 2.5 Pro)
**Connection Type**: `ai_languageModel`

The Information Extractor uses Gemini to parse Claude's response and extract JSON.

### Output Format

```json
{
  "output": {
    "properties": {
      "ice_rating": {
        "enum": ["1 - High Impact, Low Effort"]
      },
      "reason_for_ice_rating": {
        "description": "Impact Score: 9/10 - This agent addresses a critical gap..."
      },
      "recommended_workflow": {
        "description": "**Recommended n8n Workflow Architecture:**\n\n1. Trigger: Schedule Trigger (daily at 9 AM)..."
      }
    }
  }
}
```

### Error Handling

- **Malformed JSON**: Gemini retries extraction
- **Missing Required Fields**: Extraction fails, workflow stops
- **Invalid Enum Value**: Closest match selected or error raised

### Cost

- **Gemini 2.5 Pro**: ~$0.001-$0.002 per extraction
- **Token Usage**: 1000-1500 tokens (depends on Claude response length)

---

## Node 4: Google Gemini Chat Model

**Type**: `@n8n/n8n-nodes-langchain.lmChatGoogleGemini`
**Version**: 1
**Position**: [656, 464]
**ID**: `gemini-model`

### Purpose
Provides the language model backend for the Information Extractor node.

### Configuration

```json
{
  "modelName": "models/gemini-2.5-pro",
  "options": {}
}
```

### Model Parameters

| Parameter | Value | Notes |
|-----------|-------|-------|
| **Model** | `gemini-2.5-pro` | Latest Gemini Pro for JSON extraction |
| **Temperature** | Default | Structured extraction doesn't need creativity |
| **Max Tokens** | Auto | Based on input length |

### Connection

**Type**: AI Language Model connection to Information Extractor
**Purpose**: Powers the JSON extraction from Claude's response

---

## Node 5: Update Record (Airtable)

**Type**: `n8n-nodes-base.airtable`
**Version**: 2.1
**Position**: [1008, 304]
**ID**: `6debd0c7-8ac6-494a-acdb-3b5d146e12d0`

### Purpose
Writes the analysis results back to the original Airtable request record.

### Configuration

```json
{
  "operation": "update",
  "base": {
    "__rl": true,
    "value": "appELRlEUB59eOw3q",
    "mode": "id"
  },
  "table": {
    "__rl": true,
    "value": "tblXpXyzvOrNdqkqE",
    "mode": "id"
  },
  "columns": {
    "mappingMode": "defineBelow",
    "value": {
      "id": "={{ $('Airtable Trigger1').item.json.id }}",
      "ICE Rating": "={{ $json.output.properties.ice_rating.enum[0] }}",
      "Reason for ICE Rating": "={{ $json.output.properties.reason_for_ice_rating.description }}",
      "Recommended Agentic Workflow": "={{ $json.output.properties.recommended_workflow.description }}"
    },
    "matchingColumns": ["id"]
  }
}
```

### Field Mappings

| Airtable Field | Source | Expression |
|----------------|--------|------------|
| **id** | Trigger node | `={{ $('Airtable Trigger1').item.json.id }}` |
| **ICE Rating** | Extractor | `={{ $json.output.properties.ice_rating.enum[0] }}` |
| **Reason for ICE Rating** | Extractor | `={{ $json.output.properties.reason_for_ice_rating.description }}` |
| **Recommended Agentic Workflow** | Extractor | `={{ $json.output.properties.recommended_workflow.description }}` |

### Update Strategy

- **Method**: Update by `id` (matching column)
- **Overwrites**: Yes (replaces previous analysis if re-run)
- **Creates**: No (only updates existing records)

### Error Handling

- **Record Not Found**: Workflow fails (shouldn't happen with trigger)
- **Field Type Mismatch**: Airtable rejects update
- **API Limit**: Rare (well under limits)

---

## Node 6: Send a Message (Slack)

**Type**: `n8n-nodes-base.slack`
**Version**: 2.3
**Position**: [1232, 304]
**ID**: `a20070a6-0c71-4634-97f9-07b108a181d3`

### Purpose
Notifies the team of completed analysis via Slack message.

### Configuration

```json
{
  "authentication": "oAuth2",
  "select": "channel",
  "channelId": {
    "__rl": true,
    "value": "C09TPD4DEFQ",
    "mode": "list",
    "cachedResultName": "new-agent-requests"
  },
  "text": "=A new agent request for:  {{ $json.fields['AI Agent Request'] }} \n\nRequested by: {{ $json.fields['Requestor Name'] }}\n\nICE Rating: {{ $json.fields['ICE Rating'] }}\n\nKPI/OKR Alignement: {{ $json.fields['KPI or OKR alignment'] }}\n\nAirtable ID: {{ $json.id }}",
  "otherOptions": {}
}
```

### Message Template

```
A new agent request for: [Agent Name]

Requested by: [Requestor Name]

ICE Rating: [1-3 rating]

KPI/OKR Alignment: [Business metric]

Airtable ID: [Record ID]
```

### Channel Settings

| Setting | Value | Notes |
|---------|-------|-------|
| **Channel** | `#new-agent-requests` | Dedicated channel for intake |
| **Channel ID** | `C09TPD4DEFQ` | Slack channel ID |
| **Authentication** | OAuth2 | Slack app integration |
| **As User** | No | Posts as bot |

### Notification Timing

- **Trigger**: Immediately after Airtable update succeeds
- **Frequency**: One per analyzed request
- **Delivery**: Near-instant (Slack API is fast)

---

## Workflow Settings

### Execution Settings

```json
{
  "saveExecutionProgress": true,
  "saveManualExecutions": true,
  "saveDataErrorExecution": "all",
  "saveDataSuccessExecution": "all",
  "executionTimeout": 3600,
  "timezone": "UTC",
  "callerPolicy": "workflowsFromSameOwner",
  "availableInMCP": false
}
```

| Setting | Value | Purpose |
|---------|-------|---------|
| **Save Progress** | true | Track execution steps for debugging |
| **Save Manual Executions** | true | Keep test run history |
| **Save Errors** | all | Full error logging |
| **Save Success** | all | Complete audit trail |
| **Timeout** | 3600s (1 hour) | Generous timeout for API calls |
| **Timezone** | UTC | Standard reference timezone |
| **Caller Policy** | workflowsFromSameOwner | Security constraint |

### Workflow Status

- **Active**: `true` (currently running in production)
- **Version ID**: `19da16e4-6c7d-4cbd-9b43-ef6168a6df19`

---

## Connection Map

### Node Connections

```
Airtable Trigger1 → Message a model (main)
Message a model → Information Extractor (main)
Google Gemini Chat Model → Information Extractor (ai_languageModel)
Information Extractor → Update record (main)
Update record → Send a message (main)
```

### Data Flow

1. **Airtable Trigger** outputs new request record
2. **Message a model** receives full record, outputs Claude analysis
3. **Information Extractor** receives Claude text, outputs structured JSON
4. **Google Gemini** powers the extraction process
5. **Update record** receives JSON, outputs updated Airtable record
6. **Send a message** receives updated record, posts to Slack

---

## Error Handling & Recovery

### Built-in Error Handling

n8n provides automatic error handling:
- **Retries**: Exponential backoff for API failures
- **Timeout**: 1-hour maximum execution time
- **Error Logging**: All errors saved to execution history

### Custom Error Scenarios

| Error Type | Cause | Resolution |
|------------|-------|------------|
| **Airtable Trigger Fails** | Invalid base/table ID | Update configuration with correct IDs |
| **Claude Timeout** | API slowness | Retry manually or wait for next trigger |
| **Gemini Extraction Fails** | Malformed Claude response | Review prompt, may need adjustment |
| **Airtable Update Fails** | Field type mismatch | Check schema consistency |
| **Slack Notification Fails** | Invalid channel | Update channel ID or permissions |

### Recovery Procedures

1. **Check Execution Log**: Review n8n execution history for error details
2. **Verify Credentials**: Ensure all API keys are valid
3. **Test Manually**: Run workflow with test data
4. **Review Schema**: Confirm Airtable fields match expectations
5. **Contact Support**: If persistent, escalate to n8n or API provider

---

## Performance Optimization

### Current Performance

- **Execution Time**: 8-12 seconds average
- **Success Rate**: >95% (estimated)
- **Cost per Run**: ~$0.004-$0.008

### Optimization Opportunities

1. **Reduce Polling Frequency**: Change from hourly to every 4 hours (if acceptable)
2. **Batch Processing**: Process multiple requests in parallel (requires n8n pro)
3. **Caching**: Cache similar requests (requires custom logic)
4. **Prompt Optimization**: Shorten prompt to reduce token usage

### Scaling Considerations

- **Current Load**: Low (~20 requests/month)
- **Capacity**: Can handle 1000s of requests/month
- **Bottleneck**: Claude API (rate limits are generous)

---

## Testing Procedures

### Manual Test

1. Create test record in Airtable `AI Agent Requests` table
2. Wait for next hourly trigger OR manually execute workflow
3. Verify results:
   - Airtable record updated with ICE rating
   - Slack notification received
   - Execution completed successfully

### Validation Checklist

- [ ] All 6 nodes execute successfully
- [ ] Claude provides detailed analysis
- [ ] JSON extraction produces valid structure
- [ ] Airtable record updated correctly
- [ ] Slack message posted to correct channel
- [ ] Execution time < 30 seconds
- [ ] Cost < $0.01 per request

---

## Deployment Checklist

Before deploying to production:

- [ ] Airtable base and table IDs updated
- [ ] All credentials configured and tested
- [ ] Slack channel created and bot invited
- [ ] Trigger interval set appropriately
- [ ] Test execution completed successfully
- [ ] Error logging enabled
- [ ] Documentation reviewed
- [ ] Team notified of new workflow

---

## Maintenance

### Regular Monitoring

- **Weekly**: Review execution history for errors
- **Monthly**: Analyze cost trends
- **Quarterly**: Audit ICE score accuracy

### Updates Required

- **API Changes**: Update model IDs if Claude/Gemini versions change
- **Schema Changes**: Update Airtable field mappings if schema evolves
- **Prompt Tuning**: Refine ICE prompt based on feedback

---

## Changelog

See [CHANGELOG.md](./CHANGELOG.md) for version history.

---

**Documentation Version**: 1.0
**Last Updated**: November 19, 2025
**Status**: Complete
