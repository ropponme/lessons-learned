# Lessons Learned

A Spec Kit [extension](https://github.com/github/spec-kit/blob/main/extensions/README.md) and [preset](https://github.com/github/spec-kit/blob/main/presets/README.md) that enables "lessons learned" to be incorporated into your spec-driven development workflow.

## What It Does

**Extension**: Adds the `/speckit.feedback` command to collect PR review comments and discussions, extracting actionable insights and storing them in your project memory.

**Preset**: Customizes core Spec Kit commands (`specify`, `plan`, `implement`) to automatically reference and apply lessons learned from past PRs.

## Installation

### Quick Install (Recommended)

Install both the extension and preset using the install script:

```bash
curl -fsSL https://raw.githubusercontent.com/ropponme/lessons-learned/main/install.sh | bash
```

Or specify a version:

```bash
curl -fsSL https://raw.githubusercontent.com/ropponme/lessons-learned/main/install.sh | bash -s v1.0.0
```

### Manual Installation

Install from GitHub releases:

```bash
# Install extension
specify extension add lessons-learned-extension --from https://github.com/ropponme/lessons-learned/releases/download/v1.0.0/lessons-learned-extension-1.0.0.zip

# Install preset
specify preset add lessons-learned-preset --from https://github.com/ropponme/lessons-learned/releases/download/v1.0.0/lessons-learned-preset-1.0.0.zip
```

### Development Installation

For local development:

```bash
# Clone this repository
git clone https://github.com/ropponme/lessons-learned.git
cd lessons-learned

# In your spec-kit project directory
specify extension add --dev /path/to/lessons-learned
specify preset add --dev /path/to/lessons-learned
```

## Verify Installation

Check that both components are installed:

```bash
specify extension list | grep -i "lessons"
specify preset list | grep -i "lessons"
```

# Usage

The command supports three main usage styles:

## Option 1: Single PR (recommended)

In this mode, feedback is gathered from comments on your open PR as a final step before the PR is approved and merged.

Workflow:
1. Develop your feature with `/speckit.specify -> /speckit.plan -> /speckit.tasks -> /speckit.implement -> etc`
2. Push your commits and open your PR
3. Request peer reviews and get comments
4. Gather the feedback from your open PR with `/speckit.feedback`
5. Commit any additions to your project memory and push to your open PR
6. Request final approvals and merge PR

## Option 2: Multiple PRs

TODO

## Option 3: Gather historical feedback

You can use this tool to harvest lessons learned from any previously merged PRs.

TODO
