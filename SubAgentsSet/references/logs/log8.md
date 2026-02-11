# Log 8

Data: 2026-02-10
Versione: 0.0.8

## Cosa e' stato fatto
- Usati sotto-agenti Codex (processi separati) per accelerare la redazione di nuove entry KB (senza modifiche concorrenti sugli stessi file).
- Aggiunte nuove entry in `kb/entries/` (con Sources + Accessed):
  - `internal_linking.md`
  - `snippets_meta_description.md`
  - `sitemaps_robots_indexing.md`
- Aggiornati `kb/index.md` e `kb/prompt_pack.md` per includere le nuove regole (snippet/meta description, anchor text, robots/noindex).
- Aggiunti strumenti di supporto:
  - `scripts/run_subagents.ps1`
  - `subagent_prompts/` (prompt template per sub-agenti)
  - `.gitignore` per escludere `subagent_logs/`
- Aggiornato `VERSION` a `0.0.8`.

