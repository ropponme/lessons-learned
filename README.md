# Lessons Learned

This repository provides a Spec Kit [extension](https://github.com/github/spec-kit/blob/main/extensions/README.md) and [preset](https://github.com/github/spec-kit/blob/main/presets/README.md) which can be used together to enable "lessons learned" to be incorporated into your spec-driven development workflow. 

The extension adds a new command (`specify.feedback`) to the end of the feature workflow, which collects PR feedback and adds it to the project memory.

The preset customizes the built-in Spec Kit commands (specify, plan, implement) to incorporate that feedback for new features.

# Installation

An installable package isn't available yet, but the extension can be installed in development mode.

1. Clone this repository to your machine.
2. `cd` into the repository where you have previously installed spec kit via `specify init ...`
3. Install the extension: `specify extension add --dev /path/to/this/repository`
4. Install the preset: `specify preset add --dev /path/to/this/repository`

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
