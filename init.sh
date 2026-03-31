#!/usr/bin/env bash
# init.sh — Initialize the BHIL Product Roadmap Engine for a specific product
# Usage: ./tools/scripts/init.sh "Product Name" "SaaS / B2B / [your context]"
# BHIL Product Roadmap Engine — barryhurd.com

set -euo pipefail

PRODUCT_NAME="${1:-My Product}"
PRODUCT_CONTEXT="${2:-SaaS product}"
DATE=$(date +%Y-%m-%d)

echo "🚀 Initializing BHIL Product Roadmap Engine for: ${PRODUCT_NAME}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ─── 1. Update CLAUDE.md and AGENTS.md ────────────────────────────────────────
echo "📝 Updating CLAUDE.md..."
sed -i.bak \
  -e "s|\[Your product name\]|${PRODUCT_NAME}|g" \
  CLAUDE.md 2>/dev/null || true
rm -f CLAUDE.md.bak

# ─── 2. Update product context ────────────────────────────────────────────────
echo "📝 Updating product context..."
sed -i.bak \
  -e "s|\[Your Product Name\]|${PRODUCT_NAME}|g" \
  -e "s|\[Your Company\]|${PRODUCT_NAME} Inc.|g" \
  -e "s|^last_updated: YYYY-MM-DD|last_updated: ${DATE}|" \
  project/.sdlc/context/product-context.md 2>/dev/null || true
rm -f project/.sdlc/context/product-context.md.bak

# ─── 3. Create directory structure ────────────────────────────────────────────
echo "📁 Creating project directories..."
mkdir -p project/.sdlc/opportunities
mkdir -p project/.sdlc/knowledge
mkdir -p project/channels/active
mkdir -p project/channels/archive
mkdir -p project/feedback/raw
mkdir -p project/feedback/normalized
mkdir -p project/sprints/S-01/progress
mkdir -p docs/adr

# ─── 4. Initialize feedback index ─────────────────────────────────────────────
echo "📄 Initializing feedback index..."
if [ ! -f "project/feedback/normalized/index.json" ]; then
  echo '{"last_id": 0, "records": {}}' > project/feedback/normalized/index.json
fi

# ─── 5. Create tagging taxonomy customization note ────────────────────────────
echo "📄 Creating taxonomy setup note..."
cat > project/.sdlc/context/taxonomy-setup-needed.md << EOF
# Taxonomy Setup Required

Before running the pipeline, customize the tagging taxonomy at:
  schemas/tagging-taxonomy.yaml

Steps:
1. Review the default categories and themes
2. Remove categories that don't apply to ${PRODUCT_NAME}
3. Add product-specific themes in the relevant categories
4. Update example_phrases to match ${PRODUCT_NAME}'s terminology
5. Set product and last_updated fields
6. Delete this file when done

BHIL Product Roadmap Engine — ${DATE}
EOF

# ─── 6. Install git hooks ─────────────────────────────────────────────────────
echo "🪝 Installing git hooks..."
mkdir -p .git/hooks

cat > .git/hooks/pre-commit << 'HOOK'
#!/usr/bin/env bash
# Pre-commit: validate Roadmap Engine artifacts

STAGED=$(git diff --cached --name-only | grep -E 'OPP-|RICE-|PRD-STUB-' || echo "")

if [ -n "$STAGED" ]; then
  echo "🔍 Validating staged roadmap artifacts..."
  chmod +x tools/scripts/validate-pipeline.sh 2>/dev/null || true
  ./tools/scripts/validate-pipeline.sh --all 2>/dev/null || {
    echo "❌ Artifact validation failed. Fix errors before committing."
    exit 1
  }
fi

exit 0
HOOK
chmod +x .git/hooks/pre-commit

# ─── 7. Update .gitignore ─────────────────────────────────────────────────────
echo "📄 Updating .gitignore..."
cat >> .gitignore << 'EOF'

# BHIL Product Roadmap Engine
.env
.env.local
*.env.*
project/feedback/raw/*/runs/
project/feedback/normalized/index.json.bak
*.bak
EOF

# ─── 8. Summary ───────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Initialized: ${PRODUCT_NAME}"
echo ""
echo "📁 Created:"
echo "   project/.sdlc/opportunities/    (OPP-NNN, RICE-NNN, PRD-STUB-NNN)"
echo "   project/feedback/               (raw/ and normalized/)"
echo "   project/sprints/S-01/"
echo "   docs/adr/                       (for storage ADR)"
echo ""
echo "🔮 Next steps:"
echo "   1. Customize schemas/tagging-taxonomy.yaml for ${PRODUCT_NAME}"
echo "   2. Configure your first channel: cp templates/channel/CHANNEL-CONFIG-TEMPLATE.yaml"
echo "      integrations/channels/CHANNEL-001-[name].yaml"
echo "   3. Set environment variables for channel authentication"
echo "   4. Open Claude Code: claude"
echo "   5. Use 'new-opportunity-brief' skill after first feedback ingestion"
echo ""
echo "📚 Read first: guides/00-getting-started.md"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
