---
name: seo-kb-curation
description: Curate and expand the SEO knowledge base from base_di_conoscenza.md into structured repo docs (kb/) and a prompt-ready synthesis for the AI backend.
---

# SEO Knowledge Base Curation

## When to use
- The task is to "study" or summarize SEO sources, add new references, or maintain a high-quality internal SEO knowledge base.
- The task is to turn SEO research into a prompt-ready set of rules/guidelines to improve AI outputs for BlogEditorAI.

## Ground rules
- Prefer small, incremental updates. Add a few high-signal entries per session and keep them easy to maintain.
- Avoid long verbatim quotes. Summarize and extract rules.
- Keep everything traceable: every claim should point back to a source URL and an "accessed" date.

## Where knowledge lives (repo)
- Source list: `base_di_conoscenza.md`
- Knowledge base index: `kb/index.md`
- Prompt-ready synthesis (what the model should follow): `kb/prompt_pack.md`
- Optional deep dives: `kb/entries/*.md` (create only when needed)

## Workflow (repeatable)
1. Pick a narrow topic (e.g., internal linking, cannibalization, CTR/title tests, helpful content, CWV, structured data).
2. Select 1-3 sources from `base_di_conoscenza.md` that are likely to contain primary/authoritative guidance for that topic.
3. Browse only what you need and capture:
   - Title, URL, published date (if visible), accessed date (today)
   - Key takeaways (3-10 bullets)
   - "Actionable rules" the plugin or AI should follow
   - "Failure modes" (what NOT to do)
4. Add/extend an entry in `kb/entries/` only if the topic needs more than ~15 bullets.
5. Update `kb/index.md` with a short, scannable entry.
6. Update `kb/prompt_pack.md` with distilled guidance that can be injected into model calls:
   - Rules must be short, unambiguous, and testable.
   - Prefer constraints and checklists over prose.
7. Update `base_di_conoscenza.md` only when adding a new source domain or an important new feed.
8. Session hygiene (required by `agents.md`):
   - Bump `VERSION` (PATCH by default).
   - Create the next `logN.md` with date, version, and summary.
   - Commit to git with a message that matches the change.

## Sub-agents (optional acceleration)
- The main agent is the orchestrator: it assigns tasks, reviews outputs, integrates changes, and owns the final commit.
- If using sub-agents (separate Codex processes), enforce:
  - File-level isolation: each sub-agent may touch ONLY one dedicated output file (typically one `kb/entries/*.md`).
  - No recursion: sub-agents MUST NOT spawn other sub-agents.
  - The prompt given to sub-agents must explicitly include both constraints above.
- Use sub-agents sparingly: only when the work is cleanly parallelizable and the overhead is justified.

## KB entry template (for kb/index.md or kb/entries/*.md)
Use this structure to keep entries consistent:
- Topic:
- Source:
- Published:
- Accessed:
- Summary:
- Actionable rules:
- Examples / patterns:
- Notes / caveats:
