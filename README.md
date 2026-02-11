# Codex Team Orchestrator Kit

Portable workflow kit to orchestrate **Codex sub-agents** and **team-style parallel sessions** with strict file ownership, shared task boards, and reusable prompts.

This repository helps you run Codex in a repeatable lead/worker model:
- fast `sub-agent` mode for focused tasks
- `team` mode for multi-worker parallel work with dependencies
- `light-report-only` mode for quick 2-worker analysis runs
- `adaptive` mode where the lead generates workers from project context with user-defined guardrails

## Why this is useful

Codex is strong at task execution, but parallel coordination patterns are often ad-hoc.
This kit provides:
- clear orchestration policies
- ready-to-run PowerShell scripts
- prompt templates for lead and teammates
- board validation to prevent file overlap and race conditions

## Keywords

Codex, Codex teams, sub-agents, team orchestration, parallel AI coding, agent workflow, multi-agent coding.

## Repository layout

All runtime assets are bundled in one folder so you can copy it into any project:

- `SubAgentsSet/` main portable pack
- `SubAgentsSet/SKILL.md` skill entrypoint
- `SubAgentsSet/policies/` orchestration rules and checklists
- `SubAgentsSet/templates/` lead/teammate/task board templates
- `SubAgentsSet/scripts/` bootstrap, validate, render, run scripts

## Requirements

- PowerShell 7+ (or Windows PowerShell with compatible syntax)
- Codex CLI available in `PATH` as `codex`

## Quick start (Codex from terminal)

### 1) Copy the pack into your project

Copy `SubAgentsSet/` into your target repository.

### 2) Pick mode

Use:
- `SubAgentsSet/policies/subagent_vs_team_matrix.md`

### 3) Run sub-agents (simple mode)

```powershell
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\run_subagents_from_prompts.ps1 `
  .\SubAgentsSet\prompts\topic_a.txt `
  .\SubAgentsSet\prompts\topic_b.txt
```

or run all prompt `.txt` files in `SubAgentsSet/prompts/` (except `TEMPLATE*`):

```powershell
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\run_subagents.ps1
```

### 4) Run team orchestration mode

Bootstrap a run:

```powershell
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\bootstrap_team_run.ps1 `
  -TeamName my-feature -Teammates 3
```

Validate board:

```powershell
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\validate_team_board.ps1 `
  -BoardPath .\SubAgentsSet\team_runs\<run-id>\task_board.json
```

Run teammates from board:

```powershell
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\run_team_from_board.ps1 `
  -BoardPath .\SubAgentsSet\team_runs\<run-id>\task_board.json
```

### 5) Migrate legacy prompts to task board format

```powershell
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\migrate_legacy_prompts_to_board.ps1 `
  -PromptDir .\SubAgentsSet\prompts `
  -OutputBoardPath .\SubAgentsSet\examples\seo_kb_team\task_board.json `
  -TeamName seo-kb-team `
  -Teammates 2
```

### 6) Bootstrap the light profile (2 workers, report-only)

```powershell
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\bootstrap_light_team_run.ps1 `
  -TeamName light-analysis
```

### 7) Generate prompts in a few lines (CSV -> sub-agent prompts)

Use the template CSV:
- `SubAgentsSet/templates/subagent_quick_tasks.template.csv`

Then generate prompts:

```powershell
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\generate_subagent_prompts_from_csv.ps1 `
  -CsvPath .\SubAgentsSet\templates\subagent_quick_tasks.template.csv `
  -OutputDir .\SubAgentsSet\prompts\generated
```

### 8) Adaptive mode: orchestrator creates domain workers with guardrails

Prepare:
- context file from `SubAgentsSet/templates/adaptive_context.template.md`
- guardrails from `SubAgentsSet/templates/guardrails.template.json`

Bootstrap adaptive run:

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

Guardrail knobs (in `SubAgentsSet/templates/guardrails.template.json`):
- `max_subagents_total`
- `max_parallel_workers`
- `require_disjoint_target_files`
- `no_recursive_subagents`
- `require_lead_approval_for_code_changes`
- `allow_code_changes`

## Recommended GitHub topics

`codex` `sub-agents` `ai-agents` `multi-agent` `agent-orchestration` `developer-tools` `prompt-engineering` `automation`

## License

MIT (see `LICENSE`).
