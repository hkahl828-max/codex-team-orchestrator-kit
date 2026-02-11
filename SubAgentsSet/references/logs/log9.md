# Log 9

Data: 2026-02-10
Versione: 0.0.9

## Cosa e' stato fatto
- Rafforzate le regole su sotto-agenti:
  - sub-agents non possono invocare altri sub-agents (no recursion)
  - l'agente principale resta orchestratore unico
  - usare sub-agents solo quando utile/performante (non per default)
- Aggiornati `agents.md` e le skill:
  - `.agents/skills/seo-kb-curation/SKILL.md`
  - `.agents/skills/blogeditorai-plugin-dev/SKILL.md`
  - `.agents/skills/wp-env-workflow/SKILL.md` (nota su concorrenza)
- Aggiornati i template prompt in `subagent_prompts/` con vincolo "no sub-agents".
- Aggiornato `VERSION` a `0.0.9`.

