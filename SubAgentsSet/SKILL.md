---
name: subagent-team-orchestrator
description: Orchestrate Codex sub-agents and team-style parallel sessions with shared task boards, strict file ownership, and reusable prompts/scripts. Use when work must be split across independent workers, when lead/teammate coordination is required, or when you want a portable parallel-workflow kit that can be copied to any project.
---

# Subagent Team Orchestrator

Use this skill to run safe parallel workflows in Codex with two modes:

- `sub-agent mode`: fast delegation for focused independent tasks.
- `team mode`: lead + teammates + shared task board for complex multi-part work.
- `adaptive mode`: lead generates domain workers from context, constrained by guardrails.

## Workflow

1. Choose mode using `policies/subagent_vs_team_matrix.md`.
2. Enforce rules in `policies/subagents_policy.md`, `policies/team_orchestrator_policy.md`, and `policies/adaptive_subagent_generation.md` when adaptive mode is used.
3. For sub-agent mode, prepare prompts from `prompts/TEMPLATE_subagent_prompt.txt` and run with:
   - `scripts/run_subagents_from_prompts.ps1`
   - `scripts/run_subagents.ps1`
4. For team mode:
   - Bootstrap run: `scripts/bootstrap_team_run.ps1`
   - Light profile bootstrap: `scripts/bootstrap_light_team_run.ps1`
   - Validate board: `scripts/validate_team_board.ps1`
   - Render teammate prompts: `scripts/render_prompts_from_board.ps1`
   - Run team: `scripts/run_team_from_board.ps1`
5. Migrate legacy prompt files to board when needed:
   - `scripts/migrate_legacy_prompts_to_board.ps1`
6. Generate sub-agent prompts quickly from CSV when needed:
   - `scripts/generate_subagent_prompts_from_csv.ps1`
7. For adaptive generation:
   - Prepare `templates/adaptive_context.template.md`
   - Prepare `templates/guardrails.template.json`
   - Bootstrap with `scripts/bootstrap_adaptive_team_run.ps1`
8. Integrate outputs with `policies/orchestrator_checklist.md`.

## Key constraints

- Keep file ownership disjoint across open tasks.
- Never allow recursive sub-agent spawning.
- Keep orchestrator as single integration point.
- Run cleanup only after active work is finished.
- Enforce user-defined limits for adaptive generation (max workers, parallelism, approval mode).

## References

- Claude logic mapping: `references/claude_logic_mapping.md`
- Sources index: `references/source_index.md`
- Raw imported docs: `references/raw/claude_sub_agents_it.md`, `references/raw/claude_agent_teams_it.md`
