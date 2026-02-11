---
name: blogeditorai-plugin-dev
description: Develop the BlogEditorAI WordPress plugin (wp-admin only) with maintainable architecture, mapping (MAP.md), and integrations (Rank Math, Search Console, AI backend).
---

# BlogEditorAI Plugin Development

## When to use
- Any work that changes plugin behavior, adds WP admin pages, introduces integrations, or modifies the AI pipeline.

## Non-negotiables (project constraints)
- Backend-only: everything must live in `wp-admin`. No public UI in the theme/front-end.
- Human-in-the-loop: MVP must not auto-publish; the user triggers drafts.
- Maintain mapping: update `MAP.md` whenever you add/change pages, hooks, storage, jobs, or integrations.

## Architecture guidelines (pragmatic)
- Keep UI thin: admin pages should call a service layer (PHP) that talks to the AI backend.
- Long tasks must be async: implement jobs with explicit states (queued/running/succeeded/failed) and retry rules.
- Always validate + sanitize input and escape output. Use nonces for state-changing actions.
- Prefer explicit capabilities (custom capability if needed) and verify access on every admin page.

## Required docs updates (every session)
Follow `agents.md` rules:
- Update `README.md` if behavior/usage changes.
- Update `MAP.md` to keep the plugin mappable.
- Update `base_di_conoscenza.md` only when adding sources.
- Bump `VERSION`, create next `logN.md`, commit to git.

## Sub-agents policy (if used)
- The main agent remains the orchestrator and is responsible for integration and commits.
- Sub-agents must be constrained to a single output file and MUST NOT spawn additional sub-agents.
- Use sub-agents only when they are likely to improve throughput without creating coordination overhead.

## Integrations (high-level)
- Rank Math:
  - Read/write SEO meta for drafts in a controlled way.
  - Provide a fallback path if Rank Math is not installed.
- Google Search Console:
  - OAuth + property selection.
  - Incremental sync and caching.
  - Use GSC primarily for prioritization (quick wins, position 8-20, CTR improvements, cannibalization).
- AI backend:
  - Define a stable API contract (inputs/outputs, job IDs, error codes).
  - Track token/cost budgets and cache repeated analysis.

## QA checklist (wp-admin)
- Plugin activation: no fatals, no warnings in common flows.
- Capability checks: editors see what they should; unauthorized users cannot access endpoints.
- Async jobs: progress is visible; failures are actionable.
- Draft creation: WordPress draft is created correctly; SEO meta is set when integration is enabled.
