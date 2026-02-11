# Adaptive Sub-agent Generation

Use this guide when you need new sub-agents outside existing domains.

## Goal

Let the orchestrator create fit-for-context workers with bounded risk.

## Input contract

Provide one short project context (5-20 lines) including:
- objective
- constraints
- target outputs
- risky areas to avoid

Optional:
- preferred domains (comma-separated)
- report-only mode or code-change mode

Use template:
- `templates/adaptive_context.template.md`

## Guardrails (must be explicit)

Define limits before generation:
- `max_subagents_total`
- `max_parallel_workers`
- `require_disjoint_target_files`
- `no_recursive_subagents`
- `require_lead_approval_for_code_changes`

Use `templates/guardrails.template.json` as baseline.

## Orchestrator generation workflow

1. Read context and infer candidate domains.
2. Cap worker count to `max_subagents_total`.
3. Generate one task per worker with:
   - owner
   - scope
   - target files
   - done criteria
4. Validate with `scripts/validate_team_board.ps1`.
5. Render prompts and run workers.

Bootstrap command:

```powershell
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\bootstrap_adaptive_team_run.ps1 `
  -ContextPath .\SubAgentsSet\templates\adaptive_context.template.md `
  -GuardrailsPath .\SubAgentsSet\templates\guardrails.template.json `
  -TeamName adaptive-demo
```

Validate and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\validate_team_board.ps1 `
  -BoardPath .\SubAgentsSet\team_runs\<run-id>\task_board.json
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\run_team_from_board.ps1 `
  -BoardPath .\SubAgentsSet\team_runs\<run-id>\task_board.json
```

## Domain starter catalog

Default domain families (customizable):
- frontend-ux-review
- backend-api-review
- testing-quality-review
- data-persistence-review
- infra-runtime-review
- docs-developer-experience
- security-risk-review
- performance-hotspots-review
- general-code-quality-review

## Operational rule

If code ownership is unclear, start with report-only tasks, then convert approved tasks into code-change tasks.

## Few-lines alternative

For quick manual sub-agent creation, use CSV + generator:
- `templates/subagent_quick_tasks.template.csv`
- `scripts/generate_subagent_prompts_from_csv.ps1`
