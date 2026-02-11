# Source Index (SubAgentsSet)

Tracciamento sorgenti per policy, template e script del pack.

## Core policy sources (legacy project)

- `agents.md` (sezione sotto-agenti)
- `.agents/skills/blogeditorai-plugin-dev/SKILL.md`
- `.agents/skills/seo-kb-curation/SKILL.md`
- `.agents/skills/wp-env-workflow/SKILL.md`

Copie raw:
- `SubAgentsSet/references/raw/agents.md`
- `SubAgentsSet/references/raw/skill_blogeditorai-plugin-dev_SKILL.md`
- `SubAgentsSet/references/raw/skill_seo-kb-curation_SKILL.md`
- `SubAgentsSet/references/raw/skill_wp-env-workflow_SKILL.md`

Policy operative aggiunte nel pack:
- `SubAgentsSet/policies/subagents_policy.md`
- `SubAgentsSet/policies/team_orchestrator_policy.md`
- `SubAgentsSet/policies/subagent_vs_team_matrix.md`
- `SubAgentsSet/policies/orchestrator_checklist.md`
- `SubAgentsSet/policies/adaptive_subagent_generation.md`

## Claude docs sources integrated

- `https://code.claude.com/docs/it/sub-agents`
- `https://code.claude.com/docs/it/agent-teams`

Copie raw importate:
- `SubAgentsSet/references/raw/claude_sub_agents_it.md`
- `SubAgentsSet/references/raw/claude_agent_teams_it.md`
- `SubAgentsSet/references/raw/claude_sub_agents_it.html`
- `SubAgentsSet/references/raw/claude_agent_teams_it.html`

Mapping locale:
- `SubAgentsSet/references/claude_logic_mapping.md`

## Script sources

Script originali copiati:
- `SubAgentsSet/scripts/original/run_subagents.ps1`
- `SubAgentsSet/scripts/original/run_subagents_from_prompts.ps1`

Script operativi attuali:
- `SubAgentsSet/scripts/run_subagents.ps1`
- `SubAgentsSet/scripts/run_subagents_from_prompts.ps1`
- `SubAgentsSet/scripts/bootstrap_team_run.ps1`
- `SubAgentsSet/scripts/bootstrap_light_team_run.ps1`
- `SubAgentsSet/scripts/bootstrap_adaptive_team_run.ps1`
- `SubAgentsSet/scripts/validate_team_board.ps1`
- `SubAgentsSet/scripts/render_prompts_from_board.ps1`
- `SubAgentsSet/scripts/run_team_from_board.ps1`
- `SubAgentsSet/scripts/migrate_legacy_prompts_to_board.ps1`
- `SubAgentsSet/scripts/generate_subagent_prompts_from_csv.ps1`

## Templates and prompts

Template principali:
- `SubAgentsSet/prompts/TEMPLATE_subagent_prompt.txt`
- `SubAgentsSet/templates/team_lead_prompt_template.txt`
- `SubAgentsSet/templates/teammate_prompt_template.txt`
- `SubAgentsSet/templates/task_board.template.json`
- `SubAgentsSet/templates/profiles/light_report_only.task_board.json`
- `SubAgentsSet/templates/team_message_template.md`
- `SubAgentsSet/templates/guardrails.template.json`
- `SubAgentsSet/templates/adaptive_context.template.md`
- `SubAgentsSet/templates/orchestrator_adaptive_prompt_template.txt`
- `SubAgentsSet/templates/subagent_quick_tasks.template.csv`

Prompt esempi preesistenti:
- `SubAgentsSet/prompts/internal_linking.txt`
- `SubAgentsSet/prompts/snippets_meta.txt`
- `SubAgentsSet/prompts/sitemaps_robots.txt`
- `SubAgentsSet/prompts/keyword_research_clusters.txt`
- `SubAgentsSet/prompts/content_refresh_pruning.txt`

Esempi convertiti:
- `SubAgentsSet/examples/seo_kb_team/task_board.json`
- `SubAgentsSet/examples/seo_kb_team/prompts/*.txt`
- `SubAgentsSet/examples/light_team_report_only/task_board.json`
- `SubAgentsSet/examples/adaptive_team/README.md`
- `SubAgentsSet/examples/quick_generated_prompts/*.txt`

## Session history sources

- `SubAgentsSet/references/logs/log8.md`
- `SubAgentsSet/references/logs/log9.md`
- `SubAgentsSet/references/logs/log10.md`
