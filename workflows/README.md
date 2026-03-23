# KAF Workflows

This folder contains the actual n8n workflow JSON exports for all Katalon Agent Factory agents. These files can be imported directly into n8n for deployment.

## How to Import

1. Open your n8n instance
2. Click **Workflows** → **Import from File**
3. Select the desired workflow JSON file
4. Click **Import**
5. Configure credentials (see implementation guides for each agent)
6. Activate the workflow

## Available Workflows

### Production-Ready Workflows

| Workflow | File | Status | Documentation |
|----------|------|--------|---------------|
| AI Agent Request Analysis | `ai-agent-request-analysis.json` | ✅ Active | `/agents/utilities/ai-agent-request-analysis/` |
| Agent-1B RSS Monitor V4 Multi-Feed | `agent-1b-v4-multi-feed.json` | 📋 Ready | `/agents/01b-rss-monitor-v4/` |
| Agent-2 SEO Intelligence V2 | `agent-2-seo-intelligence-v2.json` | 📋 Ready | `/agents/02-seo-intelligence-v2/` |
| Agent-3 Voice of Customer V2 | `agent-3-voice-of-customer-v2.json` | 📋 Ready | `/agents/03-voice-of-customer-v2/` |
| Agent 5 Lead Scoring V3 | `agent-5-lead-scoring-v3.json` | 📋 Ready | `/agents/05-lead-scoring-v3/` |
| Social Media Agent V3 | `social-media-agent-v3.json` | 📋 Ready | `/agents/04-social-media-v3/` |

### Historical Versions

| Workflow | File | Note |
|----------|------|------|
| Agent-1B RSS Monitor V2 | `agent-1b-rss-monitor-v2.json` | Superseded by V4 |
| Agent-4 Content Generation V2 | `agent-4-content-generation-v2.json` | Superseded by Social Media V3 |

## Workflow IDs

**Important**: After import, these workflows will receive new IDs in your n8n instance. The original IDs from this export are:

- `jVRyNBedQHJAxHg6` - AI Agent Request Analysis
- `a1uOjQdsk2ZEA4W8` - Agent-1A V2
- `8HGOmJjpQATXhnzy` - Agent-1B V4
- `pwToD20YujqL7QT7` - Agent-1B V2
- `KZfgyKJr4biAMcrO` - Agent-2 V2
- `TEyv2qC5T0lv71Fe` - Agent-3 V2
- `J63zOStIrrBNCRtN` - Agent-4 V2
- `SUAWI4IOqnU62yhJ` - Agent 5 V3
- `EFR7nvwO9690x54x` - Social Media V3

## Prerequisites

Before importing workflows, ensure you have:

1. **n8n version 1.0+** installed
2. **API credentials** configured:
   - Anthropic Claude API
   - Google Gemini API  
   - Perplexity API
   - Airtable Personal Access Token
   - Slack OAuth credentials (for notifications)
3. **Airtable base** set up with required tables (see Airtable schema docs)

## Post-Import Configuration

After importing a workflow:

1. **Update Credentials**:
   - Replace all credential references with your own
   - Test API connections

2. **Update Base/Table IDs**:
   - Replace Airtable Base IDs with your base
   - Replace Table IDs with your tables
   - See AIRTABLE-SCHEMA.md in each agent folder

3. **Configure Triggers**:
   - Adjust polling intervals if needed
   - Set up webhooks if required

4. **Test Execution**:
   - Run a manual test execution
   - Verify data flow
   - Check error handling

## Troubleshooting

### Import Fails

- **Error**: "Invalid JSON"
  - **Solution**: Ensure file downloaded completely, try re-downloading

- **Error**: "Missing node types"
  - **Solution**: Install required n8n community nodes or update n8n version

### Credentials Issues

- **Error**: "Credential not found"
  - **Solution**: Reconfigure all credentials after import

### Execution Fails

- **Check**: Airtable Base IDs and Table IDs match your setup
- **Check**: All API keys are valid and have correct permissions
- **Check**: Triggers are configured correctly

See individual agent TROUBLESHOOTING.md files for specific issues.

## Support

For questions or issues:
- Review agent-specific documentation in `/agents/` folder
- Check IMPLEMENTATION-GUIDE.md for each workflow
- See main repository README.md

---

**Last Updated**: November 19, 2025  
**Total Workflows**: 9  
**Production Ready**: 7
