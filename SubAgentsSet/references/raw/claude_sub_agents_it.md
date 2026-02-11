> ## Documentation Index
> Fetch the complete documentation index at: https://code.claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Creare subagent personalizzati

> Crea e utilizza subagent AI specializzati in Claude Code per flussi di lavoro specifici per attività e una migliore gestione del contesto.

I subagent sono assistenti AI specializzati che gestiscono tipi specifici di attività. Ogni subagent viene eseguito nel proprio context window con un prompt di sistema personalizzato, accesso a strumenti specifici e autorizzazioni indipendenti. Quando Claude incontra un'attività che corrisponde alla descrizione di un subagent, la delega a quel subagent, che lavora in modo indipendente e restituisce i risultati.

<Note>
  Se hai bisogno di più agenti che lavorano in parallelo e comunicano tra loro, consulta invece [agent teams](/it/agent-teams). I subagent lavorano all'interno di una singola sessione; i team di agenti coordinano tra sessioni separate.
</Note>

I subagent ti aiutano a:

* **Preservare il contesto** mantenendo l'esplorazione e l'implementazione fuori dalla tua conversazione principale
* **Applicare vincoli** limitando quali strumenti un subagent può utilizzare
* **Riutilizzare configurazioni** tra progetti con subagent a livello utente
* **Specializzare il comportamento** con prompt di sistema focalizzati per domini specifici
* **Controllare i costi** instradando le attività a modelli più veloci e economici come Haiku

Claude utilizza la descrizione di ogni subagent per decidere quando delegare le attività. Quando crei un subagent, scrivi una descrizione chiara in modo che Claude sappia quando utilizzarlo.

Claude Code include diversi subagent integrati come **Explore**, **Plan** e **general-purpose**. Puoi anche creare subagent personalizzati per gestire attività specifiche. Questa pagina copre i [subagent integrati](#built-in-subagents), [come creare i tuoi](#quickstart-create-your-first-subagent), [opzioni di configurazione complete](#configure-subagents), [pattern per lavorare con i subagent](#work-with-subagents) e [subagent di esempio](#example-subagents).

## Built-in subagents

Claude Code include subagent integrati che Claude utilizza automaticamente quando appropriato. Ognuno eredita le autorizzazioni della conversazione principale con restrizioni di strumenti aggiuntive.

<Tabs>
  <Tab title="Explore">
    Un agente veloce e di sola lettura ottimizzato per la ricerca e l'analisi di codebase.

    * **Model**: Haiku (veloce, bassa latenza)
    * **Tools**: Strumenti di sola lettura (accesso negato agli strumenti Write e Edit)
    * **Purpose**: Scoperta di file, ricerca di codice, esplorazione di codebase

    Claude delega a Explore quando ha bisogno di cercare o comprendere una codebase senza apportare modifiche. Questo mantiene i risultati dell'esplorazione fuori dal contesto della tua conversazione principale.

    Quando invoca Explore, Claude specifica un livello di accuratezza: **quick** per ricerche mirate, **medium** per esplorazione equilibrata, o **very thorough** per analisi completa.
  </Tab>

  <Tab title="Plan">
    Un agente di ricerca utilizzato durante [plan mode](/it/common-workflows#use-plan-mode-for-safe-code-analysis) per raccogliere contesto prima di presentare un piano.

    * **Model**: Eredita dalla conversazione principale
    * **Tools**: Strumenti di sola lettura (accesso negato agli strumenti Write e Edit)
    * **Purpose**: Ricerca di codebase per la pianificazione

    Quando sei in plan mode e Claude ha bisogno di comprendere la tua codebase, delega la ricerca al subagent Plan. Questo previene l'annidamento infinito (i subagent non possono generare altri subagent) mentre raccoglie comunque il contesto necessario.
  </Tab>

  <Tab title="General-purpose">
    Un agente capace per attività complesse e multi-step che richiedono sia esplorazione che azione.

    * **Model**: Eredita dalla conversazione principale
    * **Tools**: Tutti gli strumenti
    * **Purpose**: Ricerca complessa, operazioni multi-step, modifiche di codice

    Claude delega a general-purpose quando l'attività richiede sia esplorazione che modifica, ragionamento complesso per interpretare i risultati, o più step dipendenti.
  </Tab>

  <Tab title="Other">
    Claude Code include agenti helper aggiuntivi per attività specifiche. Questi vengono generalmente invocati automaticamente, quindi non hai bisogno di utilizzarli direttamente.

    | Agent             | Model   | Quando Claude lo utilizza                                      |
    | :---------------- | :------ | :------------------------------------------------------------- |
    | Bash              | Eredita | Esecuzione di comandi terminali in un contesto separato        |
    | statusline-setup  | Sonnet  | Quando esegui `/statusline` per configurare la tua status line |
    | Claude Code Guide | Haiku   | Quando fai domande sulle funzionalità di Claude Code           |
  </Tab>
</Tabs>

Oltre a questi subagent integrati, puoi creare i tuoi con prompt personalizzati, restrizioni di strumenti, modalità di autorizzazione, hooks e skills. Le sezioni seguenti mostrano come iniziare e personalizzare i subagent.

## Quickstart: crea il tuo primo subagent

I subagent sono definiti in file Markdown con frontmatter YAML. Puoi [crearli manualmente](#write-subagent-files) o utilizzare il comando `/agents`.

Questa procedura ti guida attraverso la creazione di un subagent a livello utente con il comando `/agent`. Il subagent esamina il codice e suggerisce miglioramenti per la codebase.

<Steps>
  <Step title="Apri l'interfaccia dei subagent">
    In Claude Code, esegui:

    ```
    /agents
    ```
  </Step>

  <Step title="Crea un nuovo agente a livello utente">
    Seleziona **Create new agent**, quindi scegli **User-level**. Questo salva il subagent in `~/.claude/agents/` in modo che sia disponibile in tutti i tuoi progetti.
  </Step>

  <Step title="Genera con Claude">
    Seleziona **Generate with Claude**. Quando richiesto, descrivi il subagent:

    ```
    A code improvement agent that scans files and suggests improvements
    for readability, performance, and best practices. It should explain
    each issue, show the current code, and provide an improved version.
    ```

    Claude genera il prompt di sistema e la configurazione. Premi `e` per aprirlo nel tuo editor se desideri personalizzarlo.
  </Step>

  <Step title="Seleziona gli strumenti">
    Per un revisore di sola lettura, deseleziona tutto tranne **Read-only tools**. Se mantieni tutti gli strumenti selezionati, il subagent eredita tutti gli strumenti disponibili per la conversazione principale.
  </Step>

  <Step title="Seleziona il modello">
    Scegli quale modello utilizza il subagent. Per questo agente di esempio, seleziona **Sonnet**, che bilancia capacità e velocità per analizzare i pattern di codice.
  </Step>

  <Step title="Scegli un colore">
    Scegli un colore di sfondo per il subagent. Questo ti aiuta a identificare quale subagent è in esecuzione nell'interfaccia utente.
  </Step>

  <Step title="Salva e provalo">
    Salva il subagent. È disponibile immediatamente (non è necessario riavviare). Provalo:

    ```
    Use the code-improver agent to suggest improvements in this project
    ```

    Claude delega al tuo nuovo subagent, che scansiona la codebase e restituisce suggerimenti di miglioramento.
  </Step>
</Steps>

Ora hai un subagent che puoi utilizzare in qualsiasi progetto sulla tua macchina per analizzare le codebase e suggerire miglioramenti.

Puoi anche creare subagent manualmente come file Markdown, definirli tramite flag CLI, o distribuirli attraverso plugin. Le sezioni seguenti coprono tutte le opzioni di configurazione.

## Configure subagents

### Usa il comando /agents

Il comando `/agents` fornisce un'interfaccia interattiva per gestire i subagent. Esegui `/agents` per:

* Visualizzare tutti i subagent disponibili (integrati, utente, progetto e plugin)
* Creare nuovi subagent con configurazione guidata o generazione Claude
* Modificare la configurazione del subagent esistente e l'accesso agli strumenti
* Eliminare subagent personalizzati
* Vedere quali subagent sono attivi quando esistono duplicati

Questo è il modo consigliato per creare e gestire i subagent. Per la creazione manuale o l'automazione, puoi anche aggiungere file subagent direttamente.

### Scegli l'ambito del subagent

I subagent sono file Markdown con frontmatter YAML. Archiviali in posizioni diverse a seconda dell'ambito. Quando più subagent condividono lo stesso nome, la posizione con priorità più alta vince.

| Location                       | Scope                      | Priority      | Come creare                           |
| :----------------------------- | :------------------------- | :------------ | :------------------------------------ |
| `--agents` CLI flag            | Sessione corrente          | 1 (più alta)  | Passa JSON quando avvii Claude Code   |
| `.claude/agents/`              | Progetto corrente          | 2             | Interattivo o manuale                 |
| `~/.claude/agents/`            | Tutti i tuoi progetti      | 3             | Interattivo o manuale                 |
| Directory `agents/` del plugin | Dove il plugin è abilitato | 4 (più bassa) | Installato con [plugins](/it/plugins) |

I **subagent di progetto** (`.claude/agents/`) sono ideali per subagent specifici di una codebase. Archiviali nel controllo della versione in modo che il tuo team possa utilizzarli e migliorarli in modo collaborativo.

I **subagent utente** (`~/.claude/agents/`) sono subagent personali disponibili in tutti i tuoi progetti.

I **subagent definiti da CLI** vengono passati come JSON quando avvii Claude Code. Esistono solo per quella sessione e non vengono salvati su disco, rendendoli utili per test rapidi o script di automazione:

```bash  theme={null}
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer. Use proactively after code changes.",
    "prompt": "You are a senior code reviewer. Focus on code quality, security, and best practices.",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

Il flag `--agents` accetta JSON con gli stessi campi del [frontmatter](#supported-frontmatter-fields). Usa `prompt` per il prompt di sistema (equivalente al corpo markdown nei subagent basati su file). Consulta il [riferimento CLI](/it/cli-reference#agents-flag-format) per il formato JSON completo.

I **subagent plugin** provengono dai [plugin](/it/plugins) che hai installato. Appaiono in `/agents` insieme ai tuoi subagent personalizzati. Consulta il [riferimento dei componenti plugin](/it/plugins-reference#agents) per i dettagli sulla creazione di subagent plugin.

### Scrivi file subagent

I file subagent utilizzano frontmatter YAML per la configurazione, seguito dal prompt di sistema in Markdown:

<Note>
  I subagent vengono caricati all'avvio della sessione. Se crei un subagent aggiungendo manualmente un file, riavvia la sessione o utilizza `/agents` per caricarlo immediatamente.
</Note>

```markdown  theme={null}
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. When invoked, analyze the code and provide
specific, actionable feedback on quality, security, and best practices.
```

Il frontmatter definisce i metadati e la configurazione del subagent. Il corpo diventa il prompt di sistema che guida il comportamento del subagent. I subagent ricevono solo questo prompt di sistema (più dettagli di base sull'ambiente come la directory di lavoro), non il prompt di sistema completo di Claude Code.

#### Campi frontmatter supportati

I seguenti campi possono essere utilizzati nel frontmatter YAML. Solo `name` e `description` sono obbligatori.

| Field             | Required | Description                                                                                                                                                                                                                            |
| :---------------- | :------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`            | Yes      | Identificatore univoco utilizzando lettere minuscole e trattini                                                                                                                                                                        |
| `description`     | Yes      | Quando Claude dovrebbe delegare a questo subagent                                                                                                                                                                                      |
| `tools`           | No       | [Strumenti](#available-tools) che il subagent può utilizzare. Eredita tutti gli strumenti se omesso                                                                                                                                    |
| `disallowedTools` | No       | Strumenti da negare, rimossi dall'elenco ereditato o specificato                                                                                                                                                                       |
| `model`           | No       | [Modello](#choose-a-model) da utilizzare: `sonnet`, `opus`, `haiku`, o `inherit`. Predefinito a `inherit`                                                                                                                              |
| `permissionMode`  | No       | [Modalità di autorizzazione](#permission-modes): `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, o `plan`                                                                                                                    |
| `skills`          | No       | [Skills](/it/skills) da caricare nel contesto del subagent all'avvio. Il contenuto completo della skill viene iniettato, non solo reso disponibile per l'invocazione. I subagent non ereditano le skill dalla conversazione principale |
| `hooks`           | No       | [Lifecycle hooks](#define-hooks-for-subagents) limitati a questo subagent                                                                                                                                                              |
| `memory`          | No       | [Ambito di memoria persistente](#enable-persistent-memory): `user`, `project`, o `local`. Abilita l'apprendimento tra sessioni                                                                                                         |

### Scegli un modello

Il campo `model` controlla quale [modello AI](/it/model-config) utilizza il subagent:

* **Alias del modello**: Utilizza uno degli alias disponibili: `sonnet`, `opus`, o `haiku`
* **inherit**: Utilizza lo stesso modello della conversazione principale
* **Omesso**: Se non specificato, predefinito a `inherit` (utilizza lo stesso modello della conversazione principale)

### Controlla le capacità del subagent

Puoi controllare cosa possono fare i subagent attraverso l'accesso agli strumenti, le modalità di autorizzazione e le regole condizionali.

#### Strumenti disponibili

I subagent possono utilizzare qualsiasi [strumento interno](/it/settings#tools-available-to-claude) di Claude Code. Per impostazione predefinita, i subagent ereditano tutti gli strumenti dalla conversazione principale, inclusi gli strumenti MCP.

Per limitare gli strumenti, utilizza il campo `tools` (allowlist) o il campo `disallowedTools` (denylist):

```yaml  theme={null}
---
name: safe-researcher
description: Research agent with restricted capabilities
tools: Read, Grep, Glob, Bash
disallowedTools: Write, Edit
---
```

#### Modalità di autorizzazione

Il campo `permissionMode` controlla come il subagent gestisce i prompt di autorizzazione. I subagent ereditano il contesto di autorizzazione dalla conversazione principale ma possono sovrascrivere la modalità.

| Mode                | Behavior                                                                                       |
| :------------------ | :--------------------------------------------------------------------------------------------- |
| `default`           | Controllo di autorizzazione standard con prompt                                                |
| `acceptEdits`       | Auto-accetta modifiche di file                                                                 |
| `dontAsk`           | Auto-nega prompt di autorizzazione (gli strumenti esplicitamente consentiti funzionano ancora) |
| `bypassPermissions` | Salta tutti i controlli di autorizzazione                                                      |
| `plan`              | Plan mode (esplorazione di sola lettura)                                                       |

<Warning>
  Utilizza `bypassPermissions` con cautela. Salta tutti i controlli di autorizzazione, consentendo al subagent di eseguire qualsiasi operazione senza approvazione.
</Warning>

Se il principale utilizza `bypassPermissions`, questo ha la precedenza e non può essere sovrascritto.

#### Precarica le skill nei subagent

Utilizza il campo `skills` per iniettare il contenuto della skill nel contesto del subagent all'avvio. Questo dà al subagent la conoscenza del dominio senza richiedere di scoprire e caricare le skill durante l'esecuzione.

```yaml  theme={null}
---
name: api-developer
description: Implement API endpoints following team conventions
skills:
  - api-conventions
  - error-handling-patterns
---

Implement API endpoints. Follow the conventions and patterns from the preloaded skills.
```

Il contenuto completo di ogni skill viene iniettato nel contesto del subagent, non solo reso disponibile per l'invocazione. I subagent non ereditano le skill dalla conversazione principale; devi elencarle esplicitamente.

<Note>
  Questo è l'inverso di [eseguire una skill in un subagent](/it/skills#run-skills-in-a-subagent). Con `skills` in un subagent, il subagent controlla il prompt di sistema e carica il contenuto della skill. Con `context: fork` in una skill, il contenuto della skill viene iniettato nell'agente che specifichi. Entrambi utilizzano lo stesso sistema sottostante.
</Note>

#### Abilita memoria persistente

Il campo `memory` dà al subagent una directory persistente che sopravvive tra le conversazioni. Il subagent utilizza questa directory per accumulare conoscenza nel tempo, come pattern di codebase, intuizioni di debug e decisioni architettoniche.

```yaml  theme={null}
---
name: code-reviewer
description: Reviews code for quality and best practices
memory: user
---

You are a code reviewer. As you review code, update your agent memory with
patterns, conventions, and recurring issues you discover.
```

Scegli un ambito in base a quanto ampiamente la memoria dovrebbe applicarsi:

| Scope     | Location                                      | Usa quando                                                                                                         |
| :-------- | :-------------------------------------------- | :----------------------------------------------------------------------------------------------------------------- |
| `user`    | `~/.claude/agent-memory/<name-of-agent>/`     | il subagent dovrebbe ricordare gli insegnamenti tra tutti i progetti                                               |
| `project` | `.claude/agent-memory/<name-of-agent>/`       | la conoscenza del subagent è specifica del progetto e condivisibile tramite controllo della versione               |
| `local`   | `.claude/agent-memory-local/<name-of-agent>/` | la conoscenza del subagent è specifica del progetto ma non dovrebbe essere archiviata nel controllo della versione |

Quando la memoria è abilitata:

* Il prompt di sistema del subagent include istruzioni per leggere e scrivere nella directory di memoria.
* Il prompt di sistema del subagent include anche le prime 200 righe di `MEMORY.md` nella directory di memoria, con istruzioni per curare `MEMORY.md` se supera 200 righe.
* Gli strumenti Read, Write e Edit vengono automaticamente abilitati in modo che il subagent possa gestire i suoi file di memoria.

##### Suggerimenti per la memoria persistente

* `user` è l'ambito predefinito consigliato. Utilizza `project` o `local` quando la conoscenza del subagent è rilevante solo per una codebase specifica.
* Chiedi al subagent di consultare la sua memoria prima di iniziare il lavoro: "Review this PR, and check your memory for patterns you've seen before."
* Chiedi al subagent di aggiornare la sua memoria dopo aver completato un'attività: "Now that you're done, save what you learned to your memory." Nel tempo, questo costruisce una base di conoscenza che rende il subagent più efficace.
* Includi le istruzioni di memoria direttamente nel file markdown del subagent in modo che mantenga proattivamente la sua base di conoscenza:

  ```markdown  theme={null}
  Update your agent memory as you discover codepaths, patterns, library
  locations, and key architectural decisions. This builds up institutional
  knowledge across conversations. Write concise notes about what you found
  and where.
  ```

#### Regole condizionali con hook

Per un controllo più dinamico sull'utilizzo degli strumenti, utilizza gli hook `PreToolUse` per convalidare le operazioni prima che vengano eseguite. Questo è utile quando hai bisogno di consentire alcune operazioni di uno strumento mentre ne blocchi altre.

Questo esempio crea un subagent che consente solo query di database di sola lettura. L'hook `PreToolUse` esegue lo script specificato in `command` prima di ogni comando Bash:

```yaml  theme={null}
---
name: db-reader
description: Execute read-only database queries
tools: Bash
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-readonly-query.sh"
---
```

Claude Code [passa l'input dell'hook come JSON](/it/hooks#pretooluse-input) tramite stdin ai comandi dell'hook. Lo script di convalida legge questo JSON, estrae il comando Bash e [esce con codice 2](/it/hooks#exit-code-2-behavior-per-event) per bloccare le operazioni di scrittura:

```bash  theme={null}
#!/bin/bash
# ./scripts/validate-readonly-query.sh

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Block SQL write operations (case-insensitive)
if echo "$COMMAND" | grep -iE '\b(INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|TRUNCATE)\b' > /dev/null; then
  echo "Blocked: Only SELECT queries are allowed" >&2
  exit 2
fi

exit 0
```

Consulta [Hook input](/it/hooks#pretooluse-input) per lo schema di input completo e [exit codes](/it/hooks#exit-code-output) per come i codici di uscita influenzano il comportamento.

#### Disabilita subagent specifici

Puoi impedire a Claude di utilizzare subagent specifici aggiungendoli all'array `deny` nelle tue [impostazioni](/it/settings#permission-settings). Utilizza il formato `Task(subagent-name)` dove `subagent-name` corrisponde al campo name del subagent.

```json  theme={null}
{
  "permissions": {
    "deny": ["Task(Explore)", "Task(my-custom-agent)"]
  }
}
```

Questo funziona sia per i subagent integrati che personalizzati. Puoi anche utilizzare il flag CLI `--disallowedTools`:

```bash  theme={null}
claude --disallowedTools "Task(Explore)"
```

Consulta la [documentazione Permissions](/it/permissions#tool-specific-permission-rules) per ulteriori dettagli sulle regole di autorizzazione.

### Definisci hook per i subagent

I subagent possono definire [hook](/it/hooks) che vengono eseguiti durante il ciclo di vita del subagent. Ci sono due modi per configurare gli hook:

1. **Nel frontmatter del subagent**: Definisci gli hook che vengono eseguiti solo mentre quel subagent è attivo
2. **In `settings.json`**: Definisci gli hook che vengono eseguiti nella sessione principale quando i subagent si avviano o si fermano

#### Hook nel frontmatter del subagent

Definisci gli hook direttamente nel file markdown del subagent. Questi hook vengono eseguiti solo mentre quel subagent specifico è attivo e vengono puliti quando finisce.

Tutti gli [hook events](/it/hooks#hook-events) sono supportati. Gli eventi più comuni per i subagent sono:

| Event         | Matcher input        | Quando si attiva                                                    |
| :------------ | :------------------- | :------------------------------------------------------------------ |
| `PreToolUse`  | Nome dello strumento | Prima che il subagent utilizzi uno strumento                        |
| `PostToolUse` | Nome dello strumento | Dopo che il subagent ha utilizzato uno strumento                    |
| `Stop`        | (nessuno)            | Quando il subagent finisce (convertito a `SubagentStop` al runtime) |

Questo esempio convalida i comandi Bash con l'hook `PreToolUse` ed esegue un linter dopo le modifiche di file con `PostToolUse`:

```yaml  theme={null}
---
name: code-reviewer
description: Review code changes with automatic linting
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-command.sh $TOOL_INPUT"
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/run-linter.sh"
---
```

Gli hook `Stop` nel frontmatter vengono automaticamente convertiti a eventi `SubagentStop`.

#### Hook a livello di progetto per gli eventi del subagent

Configura gli hook in `settings.json` che rispondono agli eventi del ciclo di vita del subagent nella sessione principale.

| Event           | Matcher input           | Quando si attiva                       |
| :-------------- | :---------------------- | :------------------------------------- |
| `SubagentStart` | Nome del tipo di agente | Quando un subagent inizia l'esecuzione |
| `SubagentStop`  | (nessuno)               | Quando qualsiasi subagent si completa  |

`SubagentStart` supporta i matcher per indirizzare tipi di agenti specifici per nome. `SubagentStop` si attiva per tutti i completamenti del subagent indipendentemente dai valori del matcher. Questo esempio esegue uno script di configurazione solo quando il subagent `db-agent` si avvia e uno script di pulizia quando qualsiasi subagent si ferma:

```json  theme={null}
{
  "hooks": {
    "SubagentStart": [
      {
        "matcher": "db-agent",
        "hooks": [
          { "type": "command", "command": "./scripts/setup-db-connection.sh" }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          { "type": "command", "command": "./scripts/cleanup-db-connection.sh" }
        ]
      }
    ]
  }
}
```

Consulta [Hooks](/it/hooks) per il formato di configurazione completo degli hook.

## Lavora con i subagent

### Comprendi la delega automatica

Claude delega automaticamente le attività in base alla descrizione dell'attività nella tua richiesta, al campo `description` nelle configurazioni del subagent e al contesto attuale. Per incoraggiare la delega proattiva, includi frasi come "use proactively" nel campo description del tuo subagent.

Puoi anche richiedere un subagent specifico esplicitamente:

```
Use the test-runner subagent to fix failing tests
Have the code-reviewer subagent look at my recent changes
```

### Esegui i subagent in primo piano o in background

I subagent possono essere eseguiti in primo piano (bloccante) o in background (concorrente):

* I **subagent in primo piano** bloccano la conversazione principale fino al completamento. I prompt di autorizzazione e le domande di chiarimento (come [`AskUserQuestion`](/it/settings#tools-available-to-claude)) vengono passati a te.
* I **subagent in background** vengono eseguiti contemporaneamente mentre continui a lavorare. Prima di avviarsi, Claude Code richiede le autorizzazioni di strumenti di cui il subagent avrà bisogno, assicurando che abbia le approvazioni necessarie in anticipo. Una volta in esecuzione, il subagent eredita queste autorizzazioni e auto-nega qualsiasi cosa non pre-approvata. Se un subagent in background ha bisogno di fare domande di chiarimento, quella chiamata di strumento fallisce ma il subagent continua. Gli strumenti MCP non sono disponibili nei subagent in background.

Se un subagent in background fallisce a causa di autorizzazioni mancanti, puoi [riprenderlo](#resume-subagents) in primo piano per riprovare con prompt interattivi.

Claude decide se eseguire i subagent in primo piano o in background in base all'attività. Puoi anche:

* Chiedere a Claude di "run this in the background"
* Premere **Ctrl+B** per mettere in background un'attività in esecuzione

Per disabilitare tutta la funzionalità di attività in background, imposta la variabile di ambiente `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` a `1`. Consulta [Variabili di ambiente](/it/settings#environment-variables).

### Pattern comuni

#### Isola operazioni ad alto volume

Uno degli usi più efficaci per i subagent è isolare le operazioni che producono grandi quantità di output. L'esecuzione di test, il recupero della documentazione o l'elaborazione di file di log possono consumare un contesto significativo. Delegando questi a un subagent, l'output dettagliato rimane nel contesto del subagent mentre solo il riassunto rilevante ritorna alla tua conversazione principale.

```
Use a subagent to run the test suite and report only the failing tests with their error messages
```

#### Esegui ricerche parallele

Per indagini indipendenti, genera più subagent per lavorare simultaneamente:

```
Research the authentication, database, and API modules in parallel using separate subagents
```

Ogni subagent esplora la sua area in modo indipendente, quindi Claude sintetizza i risultati. Questo funziona meglio quando i percorsi di ricerca non dipendono l'uno dall'altro.

<Warning>
  Quando i subagent si completano, i loro risultati ritornano alla tua conversazione principale. L'esecuzione di molti subagent che ognuno restituisce risultati dettagliati può consumare un contesto significativo.
</Warning>

Per attività che richiedono parallelismo sostenuto o superano la tua finestra di contesto, [agent teams](/it/agent-teams) danno a ogni worker il suo contesto indipendente.

#### Concatena i subagent

Per flussi di lavoro multi-step, chiedi a Claude di utilizzare i subagent in sequenza. Ogni subagent completa la sua attività e restituisce i risultati a Claude, che poi passa il contesto rilevante al subagent successivo.

```
Use the code-reviewer subagent to find performance issues, then use the optimizer subagent to fix them
```

### Scegli tra subagent e conversazione principale

Utilizza la **conversazione principale** quando:

* L'attività ha bisogno di frequenti scambi o raffinamento iterativo
* Più fasi condividono un contesto significativo (pianificazione → implementazione → test)
* Stai facendo un cambiamento rapido e mirato
* La latenza è importante. I subagent si avviano da zero e potrebbero aver bisogno di tempo per raccogliere il contesto

Utilizza i **subagent** quando:

* L'attività produce output dettagliato che non hai bisogno nel tuo contesto principale
* Vuoi applicare restrizioni di strumenti specifici o autorizzazioni
* Il lavoro è autonomo e può restituire un riassunto

Considera invece [Skills](/it/skills) quando vuoi prompt o flussi di lavoro riutilizzabili che vengono eseguiti nel contesto della conversazione principale piuttosto che nel contesto isolato del subagent.

<Note>
  I subagent non possono generare altri subagent. Se il tuo flusso di lavoro richiede delega annidata, utilizza [Skills](/it/skills) o [concatena i subagent](#chain-subagents) dalla conversazione principale.
</Note>

### Gestisci il contesto del subagent

#### Riprendi i subagent

Ogni invocazione di subagent crea una nuova istanza con contesto fresco. Per continuare il lavoro di un subagent esistente invece di ricominciare da capo, chiedi a Claude di riprenderlo.

I subagent ripresi mantengono la loro cronologia di conversazione completa, incluse tutte le precedenti chiamate di strumenti, risultati e ragionamento. Il subagent riprende esattamente da dove si era fermato piuttosto che ricominciare da capo.

Quando un subagent si completa, Claude riceve il suo ID agente. Per riprendere un subagent, chiedi a Claude di continuare il lavoro precedente:

```
Use the code-reviewer subagent to review the authentication module
[Agent completes]

Continue that code review and now analyze the authorization logic
[Claude resumes the subagent with full context from previous conversation]
```

Puoi anche chiedere a Claude l'ID agente se desideri farvi riferimento esplicitamente, o trovare gli ID nei file di trascrizione in `~/.claude/projects/{project}/{sessionId}/subagents/`. Ogni trascrizione è archiviata come `agent-{agentId}.jsonl`.

Le trascrizioni del subagent persistono indipendentemente dalla conversazione principale:

* **Compattazione della conversazione principale**: Quando la conversazione principale si compatta, le trascrizioni del subagent non sono interessate. Sono archiviate in file separati.
* **Persistenza della sessione**: Le trascrizioni del subagent persistono all'interno della loro sessione. Puoi [riprendere un subagent](#resume-subagents) dopo aver riavviato Claude Code riprendendo la stessa sessione.
* **Pulizia automatica**: Le trascrizioni vengono pulite in base all'impostazione `cleanupPeriodDays` (predefinito: 30 giorni).

#### Auto-compattazione

I subagent supportano la compattazione automatica utilizzando la stessa logica della conversazione principale. Per impostazione predefinita, la compattazione automatica si attiva a circa il 95% della capacità. Per attivare la compattazione prima, imposta `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` a una percentuale inferiore (ad esempio, `50`). Consulta [variabili di ambiente](/it/settings#environment-variables) per i dettagli.

Gli eventi di compattazione vengono registrati nei file di trascrizione del subagent:

```json  theme={null}
{
  "type": "system",
  "subtype": "compact_boundary",
  "compactMetadata": {
    "trigger": "auto",
    "preTokens": 167189
  }
}
```

Il valore `preTokens` mostra quanti token sono stati utilizzati prima che si verificasse la compattazione.

## Subagent di esempio

Questi esempi dimostrano pattern efficaci per costruire i subagent. Usali come punti di partenza, o genera una versione personalizzata con Claude.

<Tip>
  **Best practices:**

  * **Progetta subagent focalizzati:** ogni subagent dovrebbe eccellere in un'attività specifica
  * **Scrivi descrizioni dettagliate:** Claude utilizza la descrizione per decidere quando delegare
  * **Limita l'accesso agli strumenti:** concedi solo le autorizzazioni necessarie per la sicurezza e la focalizzazione
  * **Archivia nel controllo della versione:** condividi i subagent di progetto con il tuo team
</Tip>

### Code reviewer

Un subagent di sola lettura che esamina il codice senza modificarlo. Questo esempio mostra come progettare un subagent focalizzato con accesso limitato agli strumenti (nessuno Edit o Write) e un prompt dettagliato che specifica esattamente cosa cercare e come formattare l'output.

```markdown  theme={null}
---
name: code-reviewer
description: Expert code review specialist. Proactively reviews code for quality, security, and maintainability. Use immediately after writing or modifying code.
tools: Read, Grep, Glob, Bash
model: inherit
---

You are a senior code reviewer ensuring high standards of code quality and security.

When invoked:
1. Run git diff to see recent changes
2. Focus on modified files
3. Begin review immediately

Review checklist:
- Code is clear and readable
- Functions and variables are well-named
- No duplicated code
- Proper error handling
- No exposed secrets or API keys
- Input validation implemented
- Good test coverage
- Performance considerations addressed

Provide feedback organized by priority:
- Critical issues (must fix)
- Warnings (should fix)
- Suggestions (consider improving)

Include specific examples of how to fix issues.
```

### Debugger

Un subagent che può sia analizzare che correggere i problemi. A differenza del revisore di codice, questo include Edit perché correggere i bug richiede la modifica del codice. Il prompt fornisce un flusso di lavoro chiaro dalla diagnosi alla verifica.

```markdown  theme={null}
---
name: debugger
description: Debugging specialist for errors, test failures, and unexpected behavior. Use proactively when encountering any issues.
tools: Read, Edit, Bash, Grep, Glob
---

You are an expert debugger specializing in root cause analysis.

When invoked:
1. Capture error message and stack trace
2. Identify reproduction steps
3. Isolate the failure location
4. Implement minimal fix
5. Verify solution works

Debugging process:
- Analyze error messages and logs
- Check recent code changes
- Form and test hypotheses
- Add strategic debug logging
- Inspect variable states

For each issue, provide:
- Root cause explanation
- Evidence supporting the diagnosis
- Specific code fix
- Testing approach
- Prevention recommendations

Focus on fixing the underlying issue, not the symptoms.
```

### Data scientist

Un subagent specifico del dominio per il lavoro di analisi dei dati. Questo esempio mostra come creare subagent per flussi di lavoro specializzati al di fuori dei tipici compiti di codifica. Imposta esplicitamente `model: sonnet` per un'analisi più capace.

```markdown  theme={null}
---
name: data-scientist
description: Data analysis expert for SQL queries, BigQuery operations, and data insights. Use proactively for data analysis tasks and queries.
tools: Bash, Read, Write
model: sonnet
---

You are a data scientist specializing in SQL and BigQuery analysis.

When invoked:
1. Understand the data analysis requirement
2. Write efficient SQL queries
3. Use BigQuery command line tools (bq) when appropriate
4. Analyze and summarize results
5. Present findings clearly

Key practices:
- Write optimized SQL queries with proper filters
- Use appropriate aggregations and joins
- Include comments explaining complex logic
- Format results for readability
- Provide data-driven recommendations

For each analysis:
- Explain the query approach
- Document any assumptions
- Highlight key findings
- Suggest next steps based on data

Always ensure queries are efficient and cost-effective.
```

### Database query validator

Un subagent che consente l'accesso a Bash ma convalida i comandi per consentire solo query SQL di sola lettura. Questo esempio mostra come utilizzare gli hook `PreToolUse` per la convalida condizionale quando hai bisogno di un controllo più fine di quanto il campo `tools` fornisca.

```markdown  theme={null}
---
name: db-reader
description: Execute read-only database queries. Use when analyzing data or generating reports.
tools: Bash
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-readonly-query.sh"
---

You are a database analyst with read-only access. Execute SELECT queries to answer questions about the data.

When asked to analyze data:
1. Identify which tables contain the relevant data
2. Write efficient SELECT queries with appropriate filters
3. Present results clearly with context

You cannot modify data. If asked to INSERT, UPDATE, DELETE, or modify schema, explain that you only have read access.
```

Claude Code [passa l'input dell'hook come JSON](/it/hooks#pretooluse-input) tramite stdin ai comandi dell'hook. Lo script di convalida legge questo JSON, estrae il comando in esecuzione e lo controlla rispetto a un elenco di operazioni di scrittura SQL. Se viene rilevata un'operazione di scrittura, lo script [esce con codice 2](/it/hooks#exit-code-2-behavior-per-event) per bloccare l'esecuzione e restituisce un messaggio di errore a Claude tramite stderr.

Crea lo script di convalida in qualsiasi punto del tuo progetto. Il percorso deve corrispondere al campo `command` nella tua configurazione dell'hook:

```bash  theme={null}
#!/bin/bash
# Blocks SQL write operations, allows SELECT queries

# Read JSON input from stdin
INPUT=$(cat)

# Extract the command field from tool_input using jq
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Block write operations (case-insensitive)
if echo "$COMMAND" | grep -iE '\b(INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|TRUNCATE|REPLACE|MERGE)\b' > /dev/null; then
  echo "Blocked: Write operations not allowed. Use SELECT queries only." >&2
  exit 2
fi

exit 0
```

Rendi lo script eseguibile:

```bash  theme={null}
chmod +x ./scripts/validate-readonly-query.sh
```

L'hook riceve JSON tramite stdin con il comando Bash in `tool_input.command`. Il codice di uscita 2 blocca l'operazione e alimenta il messaggio di errore a Claude. Consulta [Hooks](/it/hooks#exit-code-output) per i dettagli sui codici di uscita e [Hook input](/it/hooks#pretooluse-input) per lo schema di input completo.

## Passaggi successivi

Ora che comprendi i subagent, esplora queste funzionalità correlate:

* [Distribuisci i subagent con i plugin](/it/plugins) per condividere i subagent tra team o progetti
* [Esegui Claude Code a livello di programmazione](/it/headless) con l'Agent SDK per CI/CD e automazione
* [Utilizza i server MCP](/it/mcp) per dare ai subagent l'accesso a strumenti e dati esterni

