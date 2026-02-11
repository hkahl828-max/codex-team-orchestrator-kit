# Sub-agent vs Team Matrix

Usa questa matrice per scegliere rapidamente la modalita operativa.

| Criterio | Sub-agent | Team-style orchestration |
| --- | --- | --- |
| Coordinamento tra worker | Solo tramite orchestrator | Diretto + orchestrator |
| Stato condiviso task | Facoltativo | Obbligatorio (`task_board.json`) |
| Costo/overhead | Basso | Medio/alto |
| Migliore per | Task focalizzati e veloci | Lavoro complesso multi-ruolo |
| Rischio conflitti | Basso se file isolati | Alto senza board e validazione |
| Controllo richiesto dal lead | Moderato | Alto e continuo |

## Regola pratica

- Scegli `sub-agent` per 1-3 task indipendenti, output sintetico, integrazione veloce.
- Scegli `team` quando servono piu worker con dipendenze, task board, messaggistica e steering attivo.
- Se due worker devono toccare lo stesso file, evita parallelismo.
