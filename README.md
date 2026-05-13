# Lessons Learned

A Spec Kit [extension](https://github.com/github/spec-kit/blob/main/extensions/README.md) and [preset](https://github.com/github/spec-kit/blob/main/presets/README.md) that enables "lessons learned" to be incorporated into your spec-driven development workflow.

Read the [Introduction](INTRODUCTION.md) for the *why* — how this extension turns Spec Kit's one-shot SDD loop into a compounding feedback loop that gets smarter with every merged PR.

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

Use this mode when a single feature is delivered across several PRs (e.g. a backend PR, a frontend PR, and a migration PR), or when you want to capture feedback from a batch of recently merged work.

`/speckit.feedback` accepts a specific PR number via the `--pr` flag, and the central `memory/lessons.md` database is deduplicated automatically, so it is safe to run repeatedly across many PRs.

Workflow:
1. Identify the PRs you want to harvest lessons from (e.g. `gh pr list --state merged --limit 10`).
2. Run `/speckit.feedback --pr <number>` for each one. The extension will:
   - Create or update `memory/feedback/pr-<number>-lessons.md` for that PR.
   - Merge new lessons into `memory/lessons.md`, incrementing the `frequency` count on any lesson that has already been seen (so recurring issues bubble up).
3. Optionally add `--commit` to have each run stage, commit, and push the updated lessons to the current branch.
4. Open a single PR that bundles the harvested lessons, or fold them into your next feature branch.

Tip: lessons that show up in multiple PRs end up with a higher `frequency` value — a useful signal for which guardrails deserve to be promoted into your constitution or a stricter preset rule.

## Option 3: Gather historical feedback

Use this mode to **bootstrap** `memory/lessons.md` from your project's history before adopting the workflow day-to-day. This is the fastest way to seed the lessons database with the wisdom already buried in past code reviews.

Workflow:
1. Pick a window of merged PRs that are representative of recent practice — typically the last 1–3 months, or the PRs that touched the subsystem you're about to start working on:
   ```bash
   gh pr list --state merged --limit 50
   ```
2. For each PR worth mining, run:
   ```
   /speckit.feedback --pr <number> --commit
   ```
   PRs with no substantive review comments are skipped automatically — only PRs that produced real discussion will contribute lessons.
3. Review the resulting `memory/lessons.md`. Edit, merge, or delete entries by hand; this file is intended to be human-curated, not just machine-appended.
4. Commit the seeded `memory/lessons.md` to `main` so every future `/speckit.specify` and `/speckit.plan` invocation picks it up as context from day one.

Once seeded, switch to **Option 1** for your next feature so each new PR keeps the database growing.
