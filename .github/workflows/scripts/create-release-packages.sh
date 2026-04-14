#!/usr/bin/env bash
set -euo pipefail

# Script to create release packages for the lessons-learned spec-kit extension
# Usage: ./create-release-packages.sh <version>
# Example: ./create-release-packages.sh v1.0.0

VERSION="${1:-}"

if [ -z "$VERSION" ]; then
  echo "Error: Version argument is required"
  echo "Usage: $0 <version>"
  echo "Example: $0 v1.0.0"
  exit 1
fi

# Remove 'v' prefix if present for consistency
VERSION_NUMBER="${VERSION#v}"

echo "Creating release packages for version ${VERSION_NUMBER}..."

# Create releases directory if it doesn't exist
RELEASES_DIR="releases/${VERSION_NUMBER}"
mkdir -p "$RELEASES_DIR"

# Ensure we're in the repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
cd "$REPO_ROOT"

# Recreate releases directory with absolute path
RELEASES_DIR="${REPO_ROOT}/releases/${VERSION_NUMBER}"
mkdir -p "$RELEASES_DIR"

# Temporary directory for building packages
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "Building extension package..."
EXTENSION_DIR="${TEMP_DIR}/lessons-learned-extension"
mkdir -p "$EXTENSION_DIR"

# Copy extension files
cp extension.yml "$EXTENSION_DIR/"
cp LICENSE "$EXTENSION_DIR/"
cp -r extension "$EXTENSION_DIR/"

# Create extension README
cat > "$EXTENSION_DIR/README.md" << EOF
# Lessons Learned Extension v${VERSION_NUMBER}

Collect PR feedback, extract insights, and add lessons learned to your project memory.

## Companion Preset

⚠️ **This extension works best with the [Lessons Learned Preset](https://github.com/ropponme/lessons-learned).**

The preset integrates lessons learned into core Spec Kit commands (specify, plan, implement).

## Quick Install (Recommended)

Install both the extension and preset together:

\`\`\`bash
# From GitHub releases
specify extension add --from https://github.com/ropponme/lessons-learned/releases/download/${VERSION}/lessons-learned-extension-${VERSION_NUMBER}.zip
specify preset add --from https://github.com/ropponme/lessons-learned/releases/download/${VERSION}/lessons-learned-preset-${VERSION_NUMBER}.zip
\`\`\`

Or use the install script:

\`\`\`bash
curl -fsSL https://raw.githubusercontent.com/ropponme/lessons-learned/${VERSION}/install.sh | bash -s ${VERSION}
\`\`\`

## Extension Only Install

If you only want the feedback collection command:

\`\`\`bash
specify extension add --from https://github.com/ropponme/lessons-learned/releases/download/${VERSION}/lessons-learned-extension-${VERSION_NUMBER}.zip
\`\`\`

## What This Extension Provides

- **Command**: \`/speckit.feedback\` (alias: \`/speckit.lessons-learned.feedback\`)
  - Collects PR review comments and discussions
  - Extracts actionable insights
  - Stores lessons in project memory for future reference

## Usage

After installation, run the feedback command on your PRs:

\`\`\`bash
/speckit.feedback
\`\`\`

The extension will gather feedback from your open PR and add it to \`.specify/memory/lessons-learned/\`.

For more information, see the [main repository](https://github.com/ropponme/lessons-learned).
EOF

# Create extension zip
(cd "$TEMP_DIR" && zip -r "${RELEASES_DIR}/lessons-learned-extension-${VERSION_NUMBER}.zip" lessons-learned-extension)

echo "Building preset package..."
PRESET_DIR="${TEMP_DIR}/lessons-learned-preset"
mkdir -p "$PRESET_DIR"

# Copy preset files
cp preset.yml "$PRESET_DIR/"
cp LICENSE "$PRESET_DIR/"
cp -r preset "$PRESET_DIR/"

# Create preset README
cat > "$PRESET_DIR/README.md" << EOF
# Lessons Learned Preset v${VERSION_NUMBER}

Integrates lessons learned into your spec-driven development workflow.

## Companion Extension Required

⚠️ **This preset requires the [Lessons Learned Extension](https://github.com/ropponme/lessons-learned) to function properly.**

The extension provides the \`/speckit.feedback\` command that collects PR feedback.

## Quick Install (Recommended)

Install both the extension and preset together:

\`\`\`bash
# From GitHub releases
specify extension add --from https://github.com/ropponme/lessons-learned/releases/download/${VERSION}/lessons-learned-extension-${VERSION_NUMBER}.zip
specify preset add --from https://github.com/ropponme/lessons-learned/releases/download/${VERSION}/lessons-learned-preset-${VERSION_NUMBER}.zip
\`\`\`

Or use the install script:

\`\`\`bash
curl -fsSL https://raw.githubusercontent.com/ropponme/lessons-learned/${VERSION}/install.sh | bash -s ${VERSION}
\`\`\`

## Preset Only Install

If you already have the extension installed:

\`\`\`bash
specify preset add --from https://github.com/ropponme/lessons-learned/releases/download/${VERSION}/lessons-learned-preset-${VERSION_NUMBER}.zip
\`\`\`

## What This Preset Provides

This preset customizes core Spec Kit commands to incorporate lessons learned:

- **\`/speckit.specify\`** - Reviews past lessons when creating specifications
- **\`/speckit.plan\`** - Applies learned patterns during planning
- **\`/speckit.implement\`** - References relevant lessons during implementation

## How It Works

1. Use \`/speckit.feedback\` (from the extension) to collect PR feedback
2. Lessons are stored in \`.specify/memory/lessons-learned/\`
3. Modified commands automatically reference these lessons in future work

For more information, see the [main repository](https://github.com/ropponme/lessons-learned).
EOF

# Create preset zip
(cd "$TEMP_DIR" && zip -r "${RELEASES_DIR}/lessons-learned-preset-${VERSION_NUMBER}.zip" lessons-learned-preset)

echo ""
echo "✅ Release packages created successfully in ${RELEASES_DIR}:"
echo ""
ls -lh "$RELEASES_DIR"
echo ""
echo "Packages created:"
echo "  - lessons-learned-extension-${VERSION_NUMBER}.zip (extension)"
echo "  - lessons-learned-preset-${VERSION_NUMBER}.zip (preset)"
echo ""
echo "Standard Installation (recommended):"
echo ""
echo "  # Install extension"
echo "  specify extension add --from https://github.com/ropponme/lessons-learned/releases/download/${VERSION}/lessons-learned-extension-${VERSION_NUMBER}.zip"
echo ""
echo "  # Install preset"
echo "  specify preset add --from https://github.com/ropponme/lessons-learned/releases/download/${VERSION}/lessons-learned-preset-${VERSION_NUMBER}.zip"
echo ""
echo "Or use the quick install script:"
echo "  curl -fsSL https://raw.githubusercontent.com/ropponme/lessons-learned/${VERSION}/install.sh | bash -s ${VERSION}"
echo ""
