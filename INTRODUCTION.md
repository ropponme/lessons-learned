# Introduction

This repository introduces the **Lessons-Learned Extension** for [Spec Kit](https://github.com/github/spec-kit) — a small addition to Spec-Driven Development (SDD) that closes the feedback loop and turns your codebase into a self-improving system.

## Why Spec Kit?

[Spec Kit](https://github.com/github/spec-kit) is an open-source toolkit from GitHub for building software with AI coding agents in a structured, predictable way. Rather than coding from transient chat prompts ("vibe coding"), Spec Kit shifts the engineering focus to **version-controlled artifacts** — a `spec.md`, a `plan.md`, a task list — that flow through a deliberate sequence of slash commands:

```
/speckit.constitution → /speckit.specify → /speckit.plan → /speckit.tasks → /speckit.implement
```

From the Spec Kit README, the core philosophy is:

- **Intent-driven development** — specifications define the *what* before the *how*
- **Rich specification creation** using guardrails and organizational principles
- **Multi-step refinement** rather than one-shot code generation from prompts
- **Heavy reliance** on advanced AI model capabilities for specification interpretation

The payoff: AI agents (and human reviewers) work from a shared, durable description of intent. Ambiguity goes down. Rework goes down. Hallucinated APIs and fabricated module paths become much rarer because the agent is reasoning from a written spec rather than reconstructing intent on every prompt.

## A Missing Step: Feedback

Spec Kit gets you a great *first* implementation. But what happens on the second feature? The tenth? The hundredth?

In traditional workflows — and even in vanilla Spec Kit workflows — the insights generated during a code review evaporate the moment a Pull Request is merged:

- The reviewer who caught a premature abstraction moves on.
- The comment about an N+1 query gets resolved and scrolls off the page.
- The "we tried that pattern last quarter and it bit us" warning lives in someone's head.
- The migration that broke because mocked tests passed becomes a war story, not a guardrail.

The next time an AI agent (or a new engineer) tackles a similar problem, they are doomed to repeat the same mistakes. Worse, AI agents are particularly prone to confidently re-introducing patterns that the team has *already* learned to avoid, because their context window has no memory of last quarter's incident.

This is the gap the **Lessons-Learned Extension** fills.

## How the Extension Works

The extension adds one new command — `/speckit.feedback` — that runs as a final step in your SDD loop, after PR review and before merge:

```
/speckit.specify → /speckit.plan → /speckit.tasks → /speckit.implement → /speckit.feedback
```

When run, `/speckit.feedback` fetches the review comments, suggestions, and discussion threads from your open (or merged) PR, distills them into discrete, categorized lessons, and writes them to two places:

- `memory/feedback/pr-<number>-lessons.md` — a per-PR record of what was learned
- `memory/lessons.md` — a central, deduplicated database of all lessons across the project

Each lesson has a stable ID, a category (`architecture`, `testing`, `security`, `performance`, etc.), tags, and a source reference back to the originating PR. For example:

* **L001** — Premature abstraction blew up an "easy" refactor *(architecture)*
* **L002** — Mocked databases hid a destructive migration *(testing)*
* **L004** — An ORM hid an N+1 query until production caught fire *(performance)*
* **L006** — A feature flag for "safety" stayed live for fourteen months *(architecture)*

This is where the second half of the extension — the **preset** — earns its keep. The preset customizes `/speckit.specify`, `/speckit.plan`, and `/speckit.implement` to automatically load `memory/lessons.md` as context. Every future spec and plan is written *in light of* every lesson the team has already paid for.

## Why This Matters: Compound Engineering

The aim is **compound engineering** — each merged PR raises the floor for every PR that follows.

- **Self-improving repositories.** Your repo stops being just a codebase and becomes an active system for building the codebase correctly. The baseline quality of AI-generated plans and code compounds with every merged PR.
- **Preventing repeat AI mistakes.** AI agents fall into the same context traps over and over: hallucinated module paths, fabricated types, re-introducing patterns the team already rejected. Feeding `lessons.md` back into the agent's prompt establishes customized guardrails against your team's specific failure modes.
- **Preserving institutional memory.** "Self-documenting code" rots because it describes *what*, not *why*. Lessons preserve the hard-won *why* — the architectural compromises, the test flakiness, the performance gotchas — and actively apply them.
- **Generative code reviews.** Code review stops being pure gatekeeping. Every piece of friction surfaced during review is converted into a durable rule that speeds up the *next* implementation cycle. Reviewers stop repeating themselves across PRs.

## What's Next

Head back to the [README](README.md) for installation and usage instructions, including how to capture feedback from a single open PR, across multiple PRs in a multi-PR feature, or retroactively from your project's historical PRs.
