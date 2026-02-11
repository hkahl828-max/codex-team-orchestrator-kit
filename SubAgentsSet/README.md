# SubAgentsSet

Portable skill-style pack for Codex sub-agents and team-style orchestration.

## Purpose

Provide one copy-paste folder for any project, including:
- sub-agent and team orchestration policies
- prompt templates and shared task board templates
- bootstrap, validation, render, and execution scripts
- adaptive worker generation from project context with guardrails
- source mapping and reference material

## Structure

- `SubAgentsSet/SKILL.md`: skill entrypoint
- `SubAgentsSet/agents/openai.yaml`: skill metadata
- `SubAgentsSet/policies/`: policy docs and checklists
- `SubAgentsSet/templates/`: lead/teammate/task-board templates
- `SubAgentsSet/scripts/`: execution tooling
- `SubAgentsSet/prompts/`: prompt templates and examples
- `SubAgentsSet/examples/`: ready examples (legacy migration + light profile + adaptive)
- `SubAgentsSet/references/`: source mapping and raw references
- `SubAgentsSet/team_runs/`: generated run folders

## Quick Start

1. Copy `SubAgentsSet/` into your repository.
2. Read `SubAgentsSet/SKILL.md`.
3. Choose mode with `SubAgentsSet/policies/subagent_vs_team_matrix.md`.

Run focused sub-agents:

```powershell
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\run_subagents_from_prompts.ps1 `
  .\SubAgentsSet\prompts\topic_a.txt `
  .\SubAgentsSet\prompts\topic_b.txt
```

Run team mode:

```powershell
# 1) Bootstrap
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\bootstrap_team_run.ps1 `
  -TeamName my-feature -Teammates 3

# 2) Edit and validate board
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\validate_team_board.ps1 `
  -BoardPath .\SubAgentsSet\team_runs\<run-id>\task_board.json

# 3) Render prompts and run workers
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\run_team_from_board.ps1 `
  -BoardPath .\SubAgentsSet\team_runs\<run-id>\task_board.json
```

Migrate legacy prompt files into task board format:

```powershell
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\migrate_legacy_prompts_to_board.ps1 `
  -PromptDir .\SubAgentsSet\prompts `
  -OutputBoardPath .\SubAgentsSet\examples\seo_kb_team\task_board.json `
  -TeamName seo-kb-team `
  -Teammates 2
```

Bootstrap a light report-only team (2 workers):

```powershell
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\bootstrap_light_team_run.ps1 `
  -TeamName light-analysis
```

Generate sub-agent prompts quickly from CSV (few lines workflow):

```powershell
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\generate_subagent_prompts_from_csv.ps1 `
  -CsvPath .\SubAgentsSet\templates\subagent_quick_tasks.template.csv `
  -OutputDir .\SubAgentsSet\prompts\generated
```

Adaptive generation with user-defined guardrails:

```powershell
# 1) create context and guardrails from templates
# 2) bootstrap adaptive run
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\bootstrap_adaptive_team_run.ps1 `
  -ContextPath .\SubAgentsSet\templates\adaptive_context.template.md `
  -GuardrailsPath .\SubAgentsSet\templates\guardrails.template.json `
  -TeamName adaptive-demo

# 3) validate + run
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\validate_team_board.ps1 `
  -BoardPath .\SubAgentsSet\team_runs\<run-id>\task_board.json
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\run_team_from_board.ps1 `
  -BoardPath .\SubAgentsSet\team_runs\<run-id>\task_board.json
```

Key guardrail fields (`templates/guardrails.template.json`):
- `max_subagents_total`
- `max_parallel_workers`
- `require_disjoint_target_files`
- `no_recursive_subagents`
- `require_lead_approval_for_code_changes`
- `allow_code_changes`

## Core rule

The lead/orchestrator remains the single integration authority: split work, monitor workers, validate outputs, and close with cleanup.
