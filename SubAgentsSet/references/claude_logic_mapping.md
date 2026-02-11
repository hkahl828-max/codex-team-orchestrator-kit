# Claude Team/Sub-agent Logic Mapping

Questo file mappa i concetti documentati in Claude Code sulla implementazione portabile in questo pack Codex.

| Claude concept | Codex adaptation in SubAgentsSet |
| --- | --- |
| Team lead | Orchestrator principale (umana o agente principale) |
| Teammates | Processi Codex separati lanciati da prompt dedicati |
| Shared task list | `team_runs/<run-id>/task_board.json` |
| Task claim / dependencies | Ownership + `depends_on` nel task board |
| Inter-agent mailbox | File markdown in `team_runs/<run-id>/mailbox/` |
| Cleanup by lead only | Regola hard in policy + checklist |
| No nested teams/subagents | Regola hard in prompt template + policy |
| Context isolation | Ogni prompt sub-agent gira in processo separato |
| Permission inheritance | Configurata a livello run negli script di launch |

## Nota pratica

Claude agent teams hanno funzionalita native (task locking, messaging live, UI modes).
Codex qui replica la stessa logica in modo esplicito via file condivisi, template e script.
