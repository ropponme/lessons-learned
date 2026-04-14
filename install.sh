#!/usr/bin/env bash
set -euo pipefail

# Installation script for Lessons Learned extension and preset
# Usage: curl -fsSL https://raw.githubusercontent.com/ropponme/lessons-learned/main/install.sh | bash
# Or with version: curl -fsSL https://raw.githubusercontent.com/ropponme/lessons-learned/v1.0.0/install.sh | bash -s v1.0.0

VERSION="${1:-latest}"
REPO="ropponme/lessons-learned"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Lessons Learned for Spec Kit"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if specify command exists
if ! command -v specify &> /dev/null; then
    echo "❌ Error: 'specify' command not found."
    echo ""
    echo "Please install Spec Kit first:"
    echo "  https://github.com/github/spec-kit"
    echo ""
    exit 1
fi

# Resolve version
if [ "$VERSION" = "latest" ]; then
    echo "📡 Fetching latest release..."
    VERSION=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "$VERSION" ]; then
        echo "❌ Error: Could not determine latest version"
        exit 1
    fi
    echo "   Latest version: $VERSION"
fi

# Remove 'v' prefix if present for URL construction
VERSION_NUMBER="${VERSION#v}"

echo ""
echo "📦 Installing Lessons Learned ${VERSION}..."
echo ""

# Construct URLs
EXTENSION_URL="https://github.com/${REPO}/releases/download/${VERSION}/lessons-learned-extension-${VERSION_NUMBER}.zip"
PRESET_URL="https://github.com/${REPO}/releases/download/${VERSION}/lessons-learned-preset-${VERSION_NUMBER}.zip"

# Install extension
echo "1️⃣  Installing extension..."
if specify extension add --from "$EXTENSION_URL"; then
    echo "   ✅ Extension installed successfully"
else
    echo "   ❌ Extension installation failed"
    exit 1
fi

echo ""

# Install preset
echo "2️⃣  Installing preset..."
if specify preset add --from "$PRESET_URL"; then
    echo "   ✅ Preset installed successfully"
else
    echo "   ❌ Preset installation failed"
    echo "   ⚠️  Extension was installed, but preset failed"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Installation Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📚 What was installed:"
echo ""
echo "  Extension: Lessons Learned v${VERSION_NUMBER}"
echo "    • Provides: /speckit.feedback command"
echo "    • Purpose: Collect PR feedback and extract insights"
echo ""
echo "  Preset: Lessons Learned v${VERSION_NUMBER}"
echo "    • Modifies: /speckit.specify, /speckit.plan, /speckit.implement"
echo "    • Purpose: Integrate lessons into your workflow"
echo ""
echo "🚀 Next Steps:"
echo ""
echo "  1. Open a PR and gather feedback"
echo "  2. Run: /speckit.feedback"
echo "  3. Lessons will be saved to .specify/memory/lessons-learned/"
echo "  4. Future /speckit.specify, /speckit.plan, and /speckit.implement"
echo "     commands will automatically reference your lessons"
echo ""
echo "📖 Documentation:"
echo "  https://github.com/${REPO}"
echo ""
