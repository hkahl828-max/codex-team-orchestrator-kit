# SEO KB Team Example (Migrated)

This example was migrated from the legacy prompt files in `SubAgentsSet/prompts/`.

Included assets:
- `task_board.json` migrated board
- `prompts/` teammate prompts rendered from the board

Re-generate board from legacy prompts:

```powershell
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\migrate_legacy_prompts_to_board.ps1 `
  -PromptDir .\SubAgentsSet\prompts `
  -OutputBoardPath .\SubAgentsSet\examples\seo_kb_team\task_board.json `
  -TeamName seo-kb-team `
  -Teammates 2
```

Render teammate prompts from board:

```powershell
powershell -ExecutionPolicy Bypass -File .\SubAgentsSet\scripts\render_prompts_from_board.ps1 `
  -BoardPath .\SubAgentsSet\examples\seo_kb_team\task_board.json `
  -OutputDir .\SubAgentsSet\examples\seo_kb_team\prompts
```
