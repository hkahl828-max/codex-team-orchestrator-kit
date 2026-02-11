# Sub-agent Task Brief Template

Compila questo brief e incollalo nel prompt del sub-agent.

## Template

```text
You are a sub-agent worker.
Do NOT spawn or invoke any other sub-agents.

Worker ID: <WORKER_ID>
Task ID: <TASK_ID>
Goal: <ONE_CLEAR_GOAL>

Allowed files (ONLY):
- <TARGET_FILE_1>
- <TARGET_FILE_2>

Scope:
<SHORT_SCOPE>

Dependencies:
- <DEPENDENCY_OR_NONE>

Deliverable:
- Update only allowed files.
- Write summary to: <DELIVERABLE_PATH>

Hard constraints:
- Do NOT modify files outside the allowlist.
- Keep output concise and operational.
- Follow project conventions.

Done when:
- <CHECK_1>
- <CHECK_2>
```

## Note orchestrazione

- Ogni task deve avere owner e target file espliciti.
- Nessuna sovrapposizione di file tra worker paralleli.
- Se il task e solo ricerca, usa deliverable report-only e nessuna modifica codice.
