# Adaptive Team Example

This workflow lets the orchestrator generate teammate tasks from project context,
with user-defined guardrails.

## 1) Prepare context and guardrails

Copy and edit:
- `SubAgentsSet/templates/adaptive_context.template.md`
- `SubAgentsSet/templates/guardrails.template.json`

## 2) Bootstrap adaptive run

```powershell
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\bootstrap_adaptive_team_run.ps1 `
  -ContextPath .\SubAgentsSet\templates\adaptive_context.template.md `
  -GuardrailsPath .\SubAgentsSet\templates\guardrails.template.json `
  -TeamName adaptive-demo
```

## 3) Validate and run

```powershell
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\validate_team_board.ps1 `
  -BoardPath .\SubAgentsSet\team_runs\<run-id>\task_board.json

powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\run_team_from_board.ps1 `
  -BoardPath .\SubAgentsSet\team_runs\<run-id>\task_board.json
```
