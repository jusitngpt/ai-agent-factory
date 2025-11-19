# Complete Guide: Hosting N8N on Elestio + Claude MCP Integration

## Overview

This comprehensive guide walks you through deploying N8N on Elestio cloud hosting and connecting it to Claude via Model Context Protocol (MCP) for advanced workflow automation and AI agent orchestration.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Deploy N8N on Elestio](#part-1-deploy-n8n-on-elestio)
3. [Set Up Claude MCP Integration](#part-2-set-up-claude-mcp-integration)
4. [Test the Integration](#part-3-test-the-integration)
5. [Advanced Configuration](#part-4-advanced-configuration)
6. [Troubleshooting](#part-5-troubleshooting)
7. [Next Steps](#part-6-next-steps)
8. [Cost Breakdown](#cost-breakdown)
9. [Support Resources](#support-resources)
10. [Security Checklist](#security-checklist)
11. [Quick Reference](#quick-reference-information-youll-need)

---

**Progress Tracker:**
```
Setup → Deploy → Configure → Test → Optimize → Complete
```

---

## Prerequisites

Before you begin, ensure you have:

- ☐ Elestio account (sign up at https://elest.io)
- ☐ Claude account (Anthropic)
- ☐ Basic understanding of APIs and webhooks
- ☐ Credit card for Elestio hosting costs ($10-30/month)

---

## Part 1: Deploy N8N on Elestio

### 1. Create Elestio Account

1. Go to https://elest.io
2. Click "Sign Up"
3. Complete registration with email verification
4. Add payment method (required for deployment)

### 2. Deploy N8N Service

1. **Login to Elestio Dashboard**
2. **Click "Create Service"**
3. **Search for N8N:**
   - In the service catalog, search "n8n"
   - Select "N8N – Workflow Automation"

4. **Configure Deployment:**
   - **Service Name:** `n8n-automation` (or your preferred name)
   - **Cloud Provider:** Choose (AWS, Google Cloud, DigitalOcean)
   - **Region:** Select closest to your location
   - **Plan:** Start with "Small" ($9.90/month) – can upgrade later
   - **Advanced Settings:**
     - N8N Version: Latest stable
     - Database: PostgreSQL (recommended for production)
     - Storage: 20GB minimum
5. **Click "Create Service"**

### 3. Initial N8N Setup

**Wait for Deployment** (5-10 minutes)

#### Access Credentials:

> ⚠️ **IMPORTANT:** Replace these with your actual values from Elestio dashboard

Go to Elestio dashboard → Your N8N service and note down your credentials:

**Example format (yours will be different):**
```
URL: https://n8n-abc123-u12345.vm.elestio.app:443/
Admin Email: user@example.com
Admin Password: RandomGeneratedPassword123
```

**Your actual values:**
```
URL: https://[YOUR-SERVICE-NAME].vm.elestio.app:443/
Admin Email: [YOUR-EMAIL-FROM-ELESTIO]
Admin Password: [YOUR-PASSWORD-FROM-ELESTIO]
```

#### First Login:
1. Open the N8N URL in browser
2. Login with provided credentials
3. **Change password immediately** for security

### 4. Configure N8N Security

1. **Enable HTTPS** (should be automatic on Elestio)
2. **Set up Authentication:**
   - Go to Settings → Security
   - Enable "Require Authentication"
   - Set strong admin password
3. **Configure Webhooks:**
   - Settings → Endpoints
   - Note your webhook base URL:
     ```
     https://[YOUR-SERVICE-NAME].vm.elestio.app/webhook
     ```

---

## Part 2: Set Up Claude MCP Integration

### 5. Understanding MCP Connection

**Model Context Protocol (MCP)** allows Claude to directly interact with your N8N instance as a tool, enabling:

- ✅ Real-time workflow creation and modification
- ✅ Node analysis and recommendations
- ✅ Automated workflow testing and optimization
- ✅ Listing and managing workflows
- ✅ Viewing execution history

### 6. Prepare N8N for MCP Access

#### Create API Key:

1. In N8N, go to **Settings → API Keys**
2. Click "Create API Key"
3. **Name:** `claude-mcp-access`
4. **Copy and save the API key immediately** (you won't see it again)

**📝 Your API Key will look like this (example only - yours will be different):**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJYOURISTM...rest_of_token...msAapYDAf18
```

> ⚠️ **IMPORTANT:** Save your actual API key in a secure location!

#### Configure API Access:

1. Ensure API is enabled in **Settings → General**
2. Your N8N API endpoint format:
   ```
   https://[YOUR-SERVICE-NAME].vm.elestio.app/api/v1
   ```

### 7. Set Up Claude MCP Client

> **Note:** This requires Claude Desktop or API access with MCP support.

1. **Install Claude Desktop** (if not already installed)
2. **Configure MCP Settings:**
   - Open Claude Desktop settings
   - Navigate to "Model Context Protocol"
   - Add new MCP server:

**📝 TEMPLATE - Replace bracketed values with your information:**

```json
{
  "servers": {
    "n8n": {
      "command": "npx",
      "args": [
        "@anthropic-ai/mcp-server-n8n",
        "--api-base-url",
        "[YOUR-N8N-URL]/api/v1",
        "--api-key",
        "[YOUR-API-KEY]"
      ]
    }
  }
}
```

**Example with placeholder values (replace with your actual values):**

```json
{
  "servers": {
    "n8n": {
      "command": "npx",
      "args": [
        "@anthropic-ai/mcp-server-n8n",
        "--api-base-url",
        "https://n8n-abc123-u12345.vm.elestio.app/api/v1",
        "--api-key",
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.YOUR_ACTUAL_TOKEN_HERE"
      ]
    }
  }
}
```

#### Alternative: Manual API Integration

If MCP server isn't available, you can use HTTP requests:

**Base URL:** `https://[YOUR-SERVICE-NAME].vm.elestio.app/api/v1/`

**Headers:**
- `Authorization: Bearer [YOUR-API-KEY]`
- `Content-Type: application/json`

---

## Part 3: Test the Integration

### 8. Verify N8N Deployment

#### Create Test Workflow:

1. Login to your N8N instance
2. Click "New Workflow"
3. Add a "Manual Trigger" node
4. Add an "HTTP Request" node
5. Connect them and save as "Test Workflow"

#### Test API Access:

**📝 Replace the placeholders in this command:**

```bash
curl -H "Authorization: Bearer [YOUR-API-KEY]" \
  https://[YOUR-SERVICE-NAME].vm.elestio.app/api/v1/workflows
```

**Example (with dummy values):**

```bash
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.YOUR_TOKEN" \
  https://n8n-abc123-u12345.vm.elestio.app/api/v1/workflows
```

**Expected:** Should return list of workflows (including your test workflow)

### 9. Test Claude Integration

#### In Claude (with MCP configured):

1. Ask: **"Can you list my N8N workflows?"**
2. Ask: **"What nodes are available in my N8N instance?"**
3. Ask: **"Help me create a workflow that sends Slack messages"**

#### Expected Results:

- ✅ Claude should access your N8N instance
- ✅ Return real workflow data
- ✅ Provide specific node recommendations
- ✅ Help create actual workflows

#### Verified Working Capabilities:

- ✅ List workflows
- ✅ Get workflow details
- ✅ Create new workflows
- ✅ Update existing workflows
- ✅ Delete workflows
- ✅ Activate/deactivate workflows
- ✅ List executions
- ✅ Get execution details

---

## Part 4: Advanced Configuration

### 10. Production Optimization

#### Scale Resources (if needed):

1. In Elestio dashboard, upgrade plan for more CPU/RAM
2. Monitor usage in N8N **Settings → Usage**

#### Database Backup:

1. Elestio provides automatic backups
2. Configure additional backup frequency if needed

#### Domain Setup (optional):

1. Add custom domain in Elestio dashboard
2. Update DNS records as instructed
3. Update MCP configuration with new domain

### 11. Security Hardening

#### IP Restrictions:

1. In Elestio dashboard → Security
2. Add IP whitelist if needed (for webhook access)

#### Environment Variables:

1. Set sensitive credentials in N8N environment
2. **Never hardcode API keys in workflows**

#### SSL Certificate:

1. Verify HTTPS is working properly
2. Check certificate auto-renewal settings

---

## Part 5: Troubleshooting

### Common Issues and Solutions

#### **N8N Not Loading**

- Check Elestio service status
- Verify DNS propagation (if using custom domain)
- Check firewall settings

#### **MCP Connection Failed**

- Verify API key is correct and active
- Check N8N API endpoint URL (ensure `/api/v1` is included)
- Ensure Claude has internet access to your Elestio instance
- **Note:** Use double dashes (`--`) in MCP configuration, not triple dashes

#### **Webhook Issues**

- Verify webhook URL format: `https://[YOUR-SERVICE-NAME].vm.elestio.app/webhook/your-webhook-id`
- Check if authentication is required for webhooks
- Test with simple HTTP client first

#### **Performance Issues**

- Monitor resource usage in Elestio dashboard
- Consider upgrading plan if CPU/RAM usage is high
- Optimize workflows to reduce resource consumption

### Useful Commands

**📝 Remember to replace placeholders with your actual values:**

```bash
# Test API connectivity
curl -H "Authorization: Bearer [YOUR-API-KEY]" \
  https://[YOUR-SERVICE-NAME].vm.elestio.app/api/v1/workflows

# Check service health
curl https://[YOUR-SERVICE-NAME].vm.elestio.app/healthz

# Test webhook
curl -X POST https://[YOUR-SERVICE-NAME].vm.elestio.app/webhook/test \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
```

---

## Part 6: Next Steps

### Workflow Development

#### Start with Simple Automations:

1. HTTP Request → Slack notification
2. Webhook → Google Sheets update
3. Scheduled task → API call

#### Build AI Agent Workflows:

1. Use Claude's MCP access to create complex workflows
2. Implement multi-agent orchestration
3. Set up error handling and monitoring

#### Integrate Business Tools:

1. Connect Google Workspace
2. Set up Slack automations
3. Integrate CRM systems

### Monitoring and Maintenance

#### Set up Monitoring:

1. Use N8N's built-in execution monitoring
2. Set up alerts for failed workflows
3. Monitor Elestio resource usage

#### Regular Maintenance:

1. Update N8N when new versions are available
2. Review and optimize workflow performance
3. Backup workflow configurations

---

## Cost Breakdown

| Service | Plan | Monthly Cost | Specs |
|---------|------|--------------|-------|
| **Elestio Hosting** | Small Plan | $9.90 | 1 vCPU, 2GB RAM |
| | Medium Plan | $19.90 | 2 vCPU, 4GB RAM |
| | Large Plan | $39.90 | 4 vCPU, 8GB RAM |
| **Additional Costs** | Custom domain | $10-15/year | Optional |
| | Extra storage | $0.10/GB/month | As needed |
| | Bandwidth | Usually included | - |

**Total Monthly Cost:** $10-40 depending on usage

---

## Support Resources

- **Elestio Support:** https://docs.elest.io
- **N8N Documentation:** https://docs.n8n.io
- **N8N Community:** https://community.n8n.io
- **Claude MCP Documentation:** https://docs.anthropic.com/claude/mcp
- **API Reference:** https://docs.n8n.io/api/

---

## Security Checklist

- ☐ Changed default admin password
- ☐ Enabled HTTPS
- ☐ Created limited-scope API key for MCP
- ☐ Configured IP restrictions (if needed)
- ☐ Set up proper webhook authentication
- ☐ Verified backup configuration
- ☐ Tested disaster recovery process
- ☐ Reviewed access logs regularly

---

## Quick Reference: Information You'll Need

### 📋 Gather these from Elestio Dashboard:

- ☐ Your N8N service URL
- ☐ Admin email
- ☐ Admin password (initial)

### 📋 Gather these from N8N Settings:

- ☐ API key for MCP
- ☐ Webhook base URL
- ☐ API endpoint URL

### 📋 For MCP Configuration:

- ☐ N8N API base URL (with `/api/v1`)
- ☐ N8N API key
- ☐ Claude Desktop installed and configured

---

**Note:** This integration allows Claude to directly manage your N8N workflows, providing powerful automation capabilities but requiring careful security consideration. Always keep your API keys secure and never share them publicly.

---

**Built with** n8n + Claude MCP + Elestio | **Version** 1.0
