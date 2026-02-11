---
name: wp-env-workflow
description: Set up and run a local WordPress environment (WP env) and perform per-session real-time plugin testing in wp-admin.
---

# WP Env Workflow (Local WordPress)

## When to use
- At the start of the project: create the local WordPress environment for BlogEditorAI development.
- Every development session: start the environment, open the browser, and smoke test the plugin live.

## Recommended approach
Use a reproducible local WP environment. Preferred default is `wp-env` (Docker-based) if available.

## Project files (suggested)
- `wp-env.json` (or equivalent) committed to the repo.
- A stable port mapping so URLs do not change between sessions.

## Session workflow (required)
1. Start the WP environment.
2. Open the browser to:
   - WP admin: `http://localhost:<port>/wp-admin/`
   - Plugin page (once installed/available): the plugin's admin menu entry.
3. Smoke test:
   - Plugin activates without fatal errors.
   - Dashboard pages load and capability checks work.
   - Any API calls show a clear status (and failures are readable).
4. Stop the environment when not needed.

## Commands (wp-env, if used)
Verify commands against the installed tooling, but typical usage:
- Start: `npx @wordpress/env start`
- Stop: `npx @wordpress/env stop`
- Logs: `npx @wordpress/env logs`

## Browser open (Windows)
Use PowerShell to open URLs when requested by the workflow:
- `Start-Process \"http://localhost:<port>/wp-admin/\"`

## Notes
- If ports differ, use the env config as source of truth and update the docs accordingly.
- Keep the environment stable: do not bake secrets into config; use env vars where possible.

## Sub-agents note
- If sub-agents are used in the same session, they must not change WP env/runtime configuration concurrently.
