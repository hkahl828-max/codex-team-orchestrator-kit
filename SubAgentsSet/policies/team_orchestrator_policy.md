# Team Orchestrator Policy

Policy per emulare in Codex una logica team lead + teammates ispirata ai team di agenti.

## Modello operativo

- `Lead`: orchestration pura (task split, assegnazione, monitoraggio, integrazione, cleanup).
- `Teammates`: worker indipendenti che eseguono task con scope definito.
- `Task board`: stato condiviso (`pending`, `in_progress`, `completed`, `blocked`) in `task_board.json`.
- `Mailbox`: comunicazione asincrona tramite file in `mailbox/`.

## Regole hard

- Un solo lead per run.
- Nessun team annidato e nessun sub-agent ricorsivo.
- Ogni task deve avere owner, target_files, done_when e deliverable.
- Nessuna sovrapposizione di target_files tra task aperti.
- Il cleanup va sempre eseguito dal lead.

## Lifecycle run

1. `Bootstrap`: crea run scaffold con `bootstrap_team_run.ps1`.
2. `Planning`: compila board e dipendenze.
3. `Validation`: esegui `validate_team_board.ps1`.
4. `Execution`: render prompt e avvio worker.
5. `Steering`: monitoraggio log/report, riassegnazione solo se necessario.
6. `Integration`: review output e test.
7. `Cleanup`: chiusura task e pulizia artefatti temporanei.

## Permessi e sicurezza

- I worker devono partire con stesso livello di sicurezza deciso dal lead.
- Evita run con permessi troppo larghi senza necessita.
- Per task rischiosi, usa flusso plan-first (review piano prima delle modifiche).

## Failure handling

- Se un worker fallisce: marca task `blocked`, registra causa, rigenera prompt o sostituisci worker.
- Se lo stato task e incoerente: correggi manualmente la board prima di nuovi run.
- Se il lead devia in coding diretto: riporta il lead in modalita delega.
