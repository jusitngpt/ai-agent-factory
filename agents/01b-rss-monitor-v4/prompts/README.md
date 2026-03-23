# Agent-1B V4 - Prompts Directory

This directory contains all AI prompts used in the Agent-1B V4 Multi-Feed RSS Monitor workflow.

## Prompt Files

### 1. `perplexity-rss-research.md`
**Node:** 5 (VOC Research via Perplexity)
**Purpose:** Analyzes RSS feed items for competitive intelligence
**Model:** Perplexity Sonar Pro
**Input:** RSS feed item (title, link, content)
**Output:** Competitive analysis with ICE scoring

### 2. `gemini-competitive-analysis.md`
**Node:** 6 (Strategic Analysis via Gemini)
**Purpose:** Synthesizes research into structured competitive intelligence
**Model:** Google Gemini 2.5 Pro
**Input:** Perplexity research findings
**Output:** JSON with priority scores, strategic recommendations

## Prompt Versioning

**Version:** 4.0
**Last Updated:** 2025-11-19
**Maintained By:** Katalon Marketing Automation Team

## Customization Notes

- **Perplexity prompt:** Adjust search recency filter (currently 30 days) for more/less historical context
- **Gemini prompt:** Modify ICE scoring weights to match your competitive strategy priorities
- **Both prompts:** Update competitor names and focus areas as market evolves

## Testing Prompts

To test prompt changes:
1. Copy original prompt to `prompts/archive/`
2. Modify prompt file
3. Update workflow node with new prompt
4. Test with single RSS item
5. Compare output quality vs. original
6. Iterate or rollback as needed
