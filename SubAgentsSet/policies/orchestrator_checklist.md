# Orchestrator Checklist

Checklist unica per sub-agent singoli e team-style orchestration.

## 1) Plan

- Definisci outcome finale e criteri di successo.
- Decidi modalita (`sub-agent` o `team`) con `subagent_vs_team_matrix.md`.
- Spezza il lavoro in task indipendenti e assegna ownership.

## 2) Prepare

- Per team run, crea scaffold con `bootstrap_team_run.ps1`.
- Compila `task_board.json` con owner, dipendenze, target files, deliverable.
- Verifica assenza overlap file con `validate_team_board.ps1`.
- Prepara prompt con vincoli hard: no recursion + file allowlist.

## 3) Execute

- Lancia worker con `run_subagents_from_prompts.ps1` o `run_team_from_board.ps1`.
- Non toccare manualmente i target file durante il run.
- Traccia PID, log, report e mailbox.

## 4) Monitor

- Verifica task bloccati, errori ripetuti, scope drift.
- Riassegna task solo se necessario.
- Mantieni il lead in modalita delega: niente coding diretto salvo override esplicito.

## 5) Integrate

- Riesamina output worker e diff file.
- Integra solo deliverable validi e coerenti col piano.
- Esegui test/check del progetto.

## 6) Close

- Aggiorna lo stato task a `completed` o `blocked` con motivazione.
- Esegui cleanup run (log, mailbox, prompt generati se non servono).
- Crea commit unico e coerente.
