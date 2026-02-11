# Light Team Report-Only Example

Minimal 2-worker setup for low-overhead analysis runs with no code edits.

Included:
- `task_board.json` sample board for report-only workflow

Quick bootstrap (recommended for real runs):

```powershell
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\bootstrap_light_team_run.ps1 `
  -TeamName light-analysis
```

Alternative bootstrap using profile flag:

```powershell
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\bootstrap_team_run.ps1 `
  -TeamName light-analysis `
  -Profile light-report-only `
  -Teammates 2
```

Then validate and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\validate_team_board.ps1 `
  -BoardPath .\SubAgentsSet\team_runs\<run-id>\task_board.json

powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\run_team_from_board.ps1 `
  -BoardPath .\SubAgentsSet\team_runs\<run-id>\task_board.json
```
