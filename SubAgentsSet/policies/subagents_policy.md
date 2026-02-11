# Sub-agent Policy

Policy operativa per usare sub-agent in Codex con isolamento forte e integrazione sicura.

## Principi obbligatori

- Usa sub-agent solo quando il task e realmente separabile.
- Mantieni un orchestrator unico che assegna, verifica e integra.
- Imposta ownership esplicita dei file per ogni sub-agent.
- Non consentire modifiche concorrenti sullo stesso file.
- Vieta recursion: un sub-agent non deve spawnare altri sub-agent.
- Definisci sempre output e done criteria prima del run.
- Riesamina tutti i diff prima dell'integrazione finale.

## Contratto minimo prompt sub-agent

- Goal unico e verificabile.
- Lista file consentiti (allowlist), niente wildcard aggressive.
- Vincolo hard: `Do NOT modify any other file`.
- Vincolo hard: `Do NOT spawn other sub-agents`.
- Deliverable chiaro (file modificati + report opzionale).
- Done criteria brevi, misurabili e testabili.

## Pattern consigliati

- Ricerca ad alto volume: delega analisi/log/test a sub-agent per tenere pulito il contesto principale.
- Lavoro parallelo: avvia piu sub-agent solo con target file disgiunti.
- Catena sequenziale: se i task dipendono fra loro, usa run sequenziali e non paralleli.

## Anti-pattern

- Sub-agent usati come default senza vantaggio reale.
- Task troppo larghi senza confini di file.
- Merge automatico senza review del lead.
- Modifiche runtime condivise da piu sub-agent in parallelo.
