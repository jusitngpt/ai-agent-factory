#!/bin/bash

# AI Agent Factory - Quick Start Script
# This script helps verify prerequisites and guides you through initial setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                   AI AGENT FACTORY                         ║"
echo "║              Quick Start & Prerequisites Check             ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Function to print success
success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Function to print warning
warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Function to print error
error() {
    echo -e "${RED}✗${NC} $1"
}

# Function to print info
info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to read user input
prompt() {
    echo -n "$1"
    read -r response
    echo "$response"
}

echo "==== STEP 1: System Requirements Check ===="
echo ""

# Check for Docker (for self-hosted n8n)
if command_exists docker; then
    success "Docker is installed ($(docker --version | cut -d' ' -f3 | tr -d ','))"
    DOCKER_OK=true
else
    warning "Docker not found (optional, needed for self-hosted n8n)"
    DOCKER_OK=false
fi

# Check for curl
if command_exists curl; then
    success "curl is installed"
    CURL_OK=true
else
    error "curl is NOT installed (required for API calls)"
    CURL_OK=false
fi

# Check for git
if command_exists git; then
    success "git is installed"
    GIT_OK=true
else
    warning "git is NOT installed (optional)"
    GIT_OK=false
fi

echo ""
echo "==== STEP 2: Prerequisites Checklist ===="
echo ""

info "Do you have the following? (Type 'yes' or 'no' for each)"
echo ""

# n8n Instance
echo -n "1. n8n instance (self-hosted OR n8n.cloud account)? "
read -r n8n_check
if [[ $n8n_check == "yes" ]]; then
    success "n8n instance ready"
else
    warning "You'll need n8n - see docs/setup-guide.md for installation"
fi

# Airtable Account
echo -n "2. Airtable account? "
read -r airtable_check
if [[ $airtable_check == "yes" ]]; then
    success "Airtable account ready"
else
    warning "Sign up at https://airtable.com (free tier available)"
fi

# Anthropic API Key
echo -n "3. Anthropic Claude API key? "
read -r claude_check
if [[ $claude_check == "yes" ]]; then
    success "Claude API key ready"
else
    warning "Get key at https://console.anthropic.com"
fi

# Google Gemini API Key
echo -n "4. Google Gemini API key? "
read -r gemini_check
if [[ $gemini_check == "yes" ]]; then
    success "Gemini API key ready"
else
    warning "Get key at https://ai.google.dev"
fi

# Perplexity API Key
echo -n "5. Perplexity API key? "
read -r perplexity_check
if [[ $perplexity_check == "yes" ]]; then
    success "Perplexity API key ready"
else
    warning "Get key at https://www.perplexity.ai (requires Pro account)"
fi

# Slack Workspace (optional)
echo -n "6. Slack workspace for notifications (optional)? "
read -r slack_check
if [[ $slack_check == "yes" ]]; then
    success "Slack workspace ready"
else
    info "Slack is optional but recommended for notifications"
fi

echo ""
echo "==== STEP 3: Readiness Assessment ===="
echo ""

# Calculate readiness score
ready_count=0
total_required=5

[[ $n8n_check == "yes" ]] && ((ready_count++))
[[ $airtable_check == "yes" ]] && ((ready_count++))
[[ $claude_check == "yes" ]] && ((ready_count++))
[[ $gemini_check == "yes" ]] && ((ready_count++))
[[ $perplexity_check == "yes" ]] && ((ready_count++))

readiness_percent=$((ready_count * 100 / total_required))

if [ $ready_count -eq $total_required ]; then
    success "You're ready to proceed! ($ready_count/$total_required prerequisites met)"
    echo ""
    echo "==== NEXT STEPS ===="
    echo ""
    echo "1. Create Airtable base:"
    info "   Follow: airtable/table-definitions.md"
    echo ""
    echo "2. Set up n8n workflow:"
    info "   Follow: docs/setup-guide.md (Part 5)"
    echo ""
    echo "3. Configure API credentials:"
    info "   Follow: docs/setup-guide.md (Part 4)"
    echo ""
    echo "4. Test Agent 1A:"
    info "   Submit a test research request"
    echo ""
else
    warning "Prerequisites: $ready_count/$total_required met (${readiness_percent}%)"
    echo ""
    echo "Missing items:"
    [[ $n8n_check != "yes" ]] && error "  - n8n instance"
    [[ $airtable_check != "yes" ]] && error "  - Airtable account"
    [[ $claude_check != "yes" ]] && error "  - Claude API key"
    [[ $gemini_check != "yes" ]] && error "  - Gemini API key"
    [[ $perplexity_check != "yes" ]] && error "  - Perplexity API key"
    echo ""
    echo "Please obtain the missing items and re-run this script."
fi

echo ""
echo "==== ESTIMATED SETUP TIME ===="
echo ""
info "Agent 1A (On-Demand Research): 2-3 hours"
info "  - Airtable setup: 30 minutes"
info "  - n8n workflow configuration: 60-90 minutes"
info "  - API credential setup: 20 minutes"
info "  - Testing and validation: 20-30 minutes"

echo ""
echo "==== ESTIMATED COSTS (Monthly) ===="
echo ""
info "LLM APIs (100 requests/month): ~$20-30"
info "  - Perplexity: ~$10-15"
info "  - Claude: ~$8-10"
info "  - Gemini: ~$2-5"
info "n8n Cloud (optional): $20/month (or self-host for free)"
info "Airtable: Free tier or $20/month (Pro)"
echo ""
info "Total monthly cost: $20-70 (depending on volume & hosting)"

echo ""
echo "==== USEFUL RESOURCES ===="
echo ""
info "📖 Setup Guide: docs/setup-guide.md"
info "🏗️  Architecture: docs/architecture.md"
info "💬 Prompts: docs/prompt-library.md"
info "📊 Airtable Schema: airtable/table-definitions.md"
info "🤖 Agent 1A Docs: agents/01-competitive-intel-monitor/README.md"

echo ""
echo "==== SUPPORT ===="
echo ""
info "Repository: https://github.com/jusitngpt/ai-agent-factory"
info "Documentation: See /docs folder"
info "Issues: Contact GTM Operations Team"

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Ready to build intelligent marketing automation? 🚀       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Offer to open setup guide
if [[ $ready_count -eq $total_required ]]; then
    echo -n "Would you like to view the setup guide now? (yes/no): "
    read -r view_guide
    if [[ $view_guide == "yes" ]]; then
        if command_exists less; then
            less docs/setup-guide.md
        elif command_exists cat; then
            cat docs/setup-guide.md
        else
            echo "Setup guide location: docs/setup-guide.md"
        fi
    fi
fi

echo ""
echo "Good luck! 🎯"
echo ""
