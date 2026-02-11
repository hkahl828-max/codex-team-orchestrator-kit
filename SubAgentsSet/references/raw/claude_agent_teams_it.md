> ## Documentation Index
> Fetch the complete documentation index at: https://code.claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Orchestrare team di sessioni Claude Code

> Coordinare più istanze di Claude Code che lavorano insieme come un team, con attività condivise, messaggistica tra agenti e gestione centralizzata.

<Warning>
  I team di agenti sono sperimentali e disabilitati per impostazione predefinita. Abilitateli aggiungendo `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` al vostro [settings.json](/it/settings) o all'ambiente. I team di agenti hanno [limitazioni note](#limitations) riguardanti la ripresa della sessione, il coordinamento dei compiti e il comportamento di arresto.
</Warning>

I team di agenti vi permettono di coordinare più istanze di Claude Code che lavorano insieme. Una sessione agisce come il capo team, coordinando il lavoro, assegnando compiti e sintetizzando i risultati. I compagni di team lavorano indipendentemente, ciascuno nel proprio context window, e comunicano direttamente tra loro.

A differenza dei [subagent](/it/sub-agents), che vengono eseguiti all'interno di una singola sessione e possono solo riferire al principale, potete anche interagire direttamente con i singoli compagni di team senza passare attraverso il capo.

Questa pagina copre:

* [Quando utilizzare i team di agenti](#when-to-use-agent-teams), inclusi i migliori casi d'uso e come si confrontano con i subagent
* [Avviare un team](#start-your-first-agent-team)
* [Controllare i compagni di team](#control-your-agent-team), incluse le modalità di visualizzazione, l'assegnazione dei compiti e la delega
* [Best practice per il lavoro parallelo](#best-practices)

## Quando utilizzare i team di agenti

I team di agenti sono più efficaci per compiti in cui l'esplorazione parallela aggiunge valore reale. Consultate gli [esempi di casi d'uso](#use-case-examples) per scenari completi. I casi d'uso più forti sono:

* **Ricerca e revisione**: più compagni di team possono investigare diversi aspetti di un problema contemporaneamente, quindi condividere e mettere in discussione i risultati reciproci
* **Nuovi moduli o funzionalità**: i compagni di team possono possedere ciascuno un pezzo separato senza interferire l'uno con l'altro
* **Debug con ipotesi concorrenti**: i compagni di team testano diverse teorie in parallelo e convergono sulla risposta più velocemente
* **Coordinamento tra livelli**: modifiche che si estendono su frontend, backend e test, ciascuno posseduto da un diverso compagno di team

I team di agenti aggiungono overhead di coordinamento e utilizzano significativamente più token di una singola sessione. Funzionano meglio quando i compagni di team possono operare indipendentemente. Per compiti sequenziali, modifiche dello stesso file o lavoro con molte dipendenze, una singola sessione o i [subagent](/it/sub-agents) sono più efficaci.

### Confronto con i subagent

Sia i team di agenti che i [subagent](/it/sub-agents) vi permettono di parallelizzare il lavoro, ma operano diversamente. Scegliete in base al fatto che i vostri lavoratori debbano comunicare tra loro:

|                    | Subagent                                                      | Team di agenti                                                |
| :----------------- | :------------------------------------------------------------ | :------------------------------------------------------------ |
| **Context**        | Context window proprio; i risultati tornano al chiamante      | Context window proprio; completamente indipendente            |
| **Comunicazione**  | Riferiscono i risultati solo all'agente principale            | I compagni di team si messaggiano direttamente                |
| **Coordinamento**  | L'agente principale gestisce tutto il lavoro                  | Elenco di compiti condiviso con auto-coordinamento            |
| **Migliore per**   | Compiti focalizzati dove conta solo il risultato              | Lavoro complesso che richiede discussione e collaborazione    |
| **Costo in token** | Inferiore: i risultati sono riassunti nel contesto principale | Superiore: ogni compagno di team è un'istanza Claude separata |

Utilizzate i subagent quando avete bisogno di lavoratori veloci e focalizzati che riferiscono. Utilizzate i team di agenti quando i compagni di team devono condividere i risultati, mettersi in discussione e coordinarsi autonomamente.

## Abilitare i team di agenti

I team di agenti sono disabilitati per impostazione predefinita. Abilitateli impostando la variabile di ambiente `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` a `1`, sia nell'ambiente della shell che tramite [settings.json](/it/settings):

```json settings.json theme={null}
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

## Avviare il vostro primo team di agenti

Dopo aver abilitato i team di agenti, dite a Claude di creare un team di agenti e descrivete il compito e la struttura del team che desiderate in linguaggio naturale. Claude crea il team, genera i compagni di team e coordina il lavoro in base al vostro prompt.

Questo esempio funziona bene perché i tre ruoli sono indipendenti e possono esplorare il problema senza aspettarsi l'uno l'altro:

```
I'm designing a CLI tool that helps developers track TODO comments across
their codebase. Create an agent team to explore this from different angles: one
teammate on UX, one on technical architecture, one playing devil's advocate.
```

Da lì, Claude crea un team con un [elenco di compiti condiviso](/it/interactive-mode#task-list), genera compagni di team per ogni prospettiva, li fa esplorare il problema, sintetizza i risultati e tenta di [pulire il team](#clean-up-the-team) quando finito.

Il terminale del capo elenca tutti i compagni di team e su cosa stanno lavorando. Utilizzate Shift+Su/Giù per selezionare un compagno e messaggiargli direttamente.

Se desiderate che ogni compagno sia nel suo riquadro diviso, consultate [Scegliere una modalità di visualizzazione](#choose-a-display-mode).

## Controllare il vostro team di agenti

Dite al capo cosa desiderate in linguaggio naturale. Gestisce il coordinamento del team, l'assegnazione dei compiti e la delega in base alle vostre istruzioni.

### Scegliere una modalità di visualizzazione

I team di agenti supportano due modalità di visualizzazione:

* **In-process**: tutti i compagni di team vengono eseguiti all'interno del vostro terminale principale. Utilizzate Shift+Su/Giù per selezionare un compagno e digitate per messaggiargli direttamente. Funziona in qualsiasi terminale, nessuna configurazione aggiuntiva richiesta.
* **Split panes**: ogni compagno ottiene il suo riquadro. Potete vedere l'output di tutti contemporaneamente e fare clic su un riquadro per interagire direttamente. Richiede tmux o iTerm2.

<Note>
  `tmux` ha limitazioni note su certi sistemi operativi e tradizionalmente funziona meglio su macOS. Utilizzare `tmux -CC` in iTerm2 è il punto di ingresso suggerito in `tmux`.
</Note>

L'impostazione predefinita è `"auto"`, che utilizza split panes se state già eseguendo all'interno di una sessione tmux, e in-process altrimenti. L'impostazione `"tmux"` abilita la modalità split-pane e rileva automaticamente se utilizzare tmux o iTerm2 in base al vostro terminale. Per eseguire l'override, impostate `teammateMode` nel vostro [settings.json](/it/settings):

```json  theme={null}
{
  "teammateMode": "in-process"
}
```

Per forzare la modalità in-process per una singola sessione, passatela come flag:

```bash  theme={null}
claude --teammate-mode in-process
```

La modalità split-pane richiede [tmux](https://github.com/tmux/tmux/wiki) o iTerm2 con la [`it2` CLI](https://github.com/mkusaka/it2). Per installare manualmente:

* **tmux**: installate tramite il gestore di pacchetti del vostro sistema. Consultate il [wiki di tmux](https://github.com/tmux/tmux/wiki/Installing) per istruzioni specifiche della piattaforma.
* **iTerm2**: installate la [`it2` CLI](https://github.com/mkusaka/it2), quindi abilitate l'API Python in **iTerm2 → Settings → General → Magic → Enable Python API**.

### Specificare compagni di team e modelli

Claude decide il numero di compagni di team da generare in base al vostro compito, oppure potete specificare esattamente quello che desiderate:

```
Create a team with 4 teammates to refactor these modules in parallel.
Use Sonnet for each teammate.
```

### Richiedere l'approvazione del piano per i compagni di team

Per compiti complessi o rischiosi, potete richiedere ai compagni di team di pianificare prima di implementare. Il compagno lavora in modalità piano di sola lettura fino a quando il capo approva il loro approccio:

```
Spawn an architect teammate to refactor the authentication module.
Require plan approval before they make any changes.
```

Quando un compagno finisce di pianificare, invia una richiesta di approvazione del piano al capo. Il capo esamina il piano e lo approva o lo rifiuta con feedback. Se rifiutato, il compagno rimane in modalità piano, rivede in base al feedback e lo riinvia. Una volta approvato, il compagno esce dalla modalità piano e inizia l'implementazione.

Il capo prende decisioni di approvazione autonomamente. Per influenzare il giudizio del capo, fornitegli criteri nel vostro prompt, come "approva solo i piani che includono la copertura dei test" o "rifiuta i piani che modificano lo schema del database".

### Utilizzare la modalità delega

Senza la modalità delega, il capo a volte inizia a implementare i compiti stesso invece di aspettare i compagni di team. La modalità delega previene questo limitando il capo ai soli strumenti di coordinamento: generazione, messaggistica, arresto dei compagni di team e gestione dei compiti.

Questo è utile quando desiderate che il capo si concentri interamente sull'orchestrazione, come suddividere il lavoro, assegnare compiti e sintetizzare i risultati, senza toccare il codice direttamente.

Per abilitarla, avviate prima un team, quindi premete Shift+Tab per ciclarsi nella modalità delega.

### Parlare direttamente con i compagni di team

Ogni compagno è una sessione Claude Code completa e indipendente. Potete messaggiare qualsiasi compagno direttamente per fornire istruzioni aggiuntive, fare domande di follow-up o reindirizzare il loro approccio.

* **Modalità in-process**: utilizzate Shift+Su/Giù per selezionare un compagno, quindi digitate per inviargli un messaggio. Premete Invio per visualizzare la sessione di un compagno, quindi Esc per interrompere il loro turno attuale. Premete Ctrl+T per attivare/disattivare l'elenco dei compiti.
* **Modalità split-pane**: fate clic nel riquadro di un compagno per interagire direttamente con la sua sessione. Ogni compagno ha una visualizzazione completa del proprio terminale.

### Assegnare e rivendicare compiti

L'elenco di compiti condiviso coordina il lavoro in tutto il team. Il capo crea compiti e i compagni di team li completano. I compiti hanno tre stati: in sospeso, in corso e completato. I compiti possono anche dipendere da altri compiti: un compito in sospeso con dipendenze non risolte non può essere rivendicato fino a quando quelle dipendenze non sono completate.

Il capo può assegnare compiti esplicitamente, oppure i compagni di team possono auto-rivendicare:

* **Il capo assegna**: dite al capo quale compito dare a quale compagno di team
* **Auto-rivendicazione**: dopo aver completato un compito, un compagno raccoglie il prossimo compito non assegnato e non bloccato da solo

La rivendicazione dei compiti utilizza il blocco dei file per prevenire condizioni di gara quando più compagni di team tentano di rivendicare lo stesso compito contemporaneamente.

### Arrestare i compagni di team

Per terminare gracefully la sessione di un compagno:

```
Ask the researcher teammate to shut down
```

Il capo invia una richiesta di arresto. Il compagno può approvare, uscendo gracefully, o rifiutare con una spiegazione.

### Pulire il team

Quando avete finito, chiedete al capo di pulire:

```
Clean up the team
```

Questo rimuove le risorse del team condivise. Quando il capo esegue la pulizia, controlla i compagni di team attivi e fallisce se ce ne sono ancora in esecuzione, quindi arrestateli prima.

<Warning>
  Utilizzate sempre il capo per pulire. I compagni di team non dovrebbero eseguire la pulizia perché il loro contesto di team potrebbe non risolversi correttamente, lasciando potenzialmente le risorse in uno stato incoerente.
</Warning>

## Come funzionano i team di agenti

Questa sezione copre l'architettura e la meccanica dietro i team di agenti. Se desiderate iniziare a utilizzarli, consultate [Controllare il vostro team di agenti](#control-your-agent-team) sopra.

### Come Claude avvia i team di agenti

Ci sono due modi in cui i team di agenti vengono avviati:

* **Voi richiedete un team**: date a Claude un compito che beneficia dal lavoro parallelo e chiedete esplicitamente un team di agenti. Claude ne crea uno in base alle vostre istruzioni.
* **Claude propone un team**: se Claude determina che il vostro compito beneficerebbe dal lavoro parallelo, potrebbe suggerire di creare un team. Voi confermate prima che proceda.

In entrambi i casi, rimanete in controllo. Claude non creerà un team senza la vostra approvazione.

### Architettura

Un team di agenti consiste di:

| Componente            | Ruolo                                                                                               |
| :-------------------- | :-------------------------------------------------------------------------------------------------- |
| **Team lead**         | La sessione Claude Code principale che crea il team, genera i compagni di team e coordina il lavoro |
| **Compagni di team**  | Istanze Claude Code separate che ciascuna lavora su compiti assegnati                               |
| **Elenco di compiti** | Elenco condiviso di elementi di lavoro che i compagni di team rivendicano e completano              |
| **Mailbox**           | Sistema di messaggistica per la comunicazione tra agenti                                            |

Consultate [Scegliere una modalità di visualizzazione](#choose-a-display-mode) per le opzioni di configurazione della visualizzazione. I messaggi dei compagni arrivano al capo automaticamente.

Il sistema gestisce le dipendenze dei compiti automaticamente. Quando un compagno completa un compito da cui altri compiti dipendono, i compiti bloccati si sbloccano senza intervento manuale.

I team e i compiti sono archiviati localmente:

* **Configurazione del team**: `~/.claude/teams/{team-name}/config.json`
* **Elenco di compiti**: `~/.claude/tasks/{team-name}/`

La configurazione del team contiene un array `members` con il nome di ogni compagno, l'ID dell'agente e il tipo di agente. I compagni di team possono leggere questo file per scoprire altri membri del team.

### Permessi

I compagni di team iniziano con le impostazioni di permesso del capo. Se il capo viene eseguito con `--dangerously-skip-permissions`, lo fanno anche tutti i compagni di team. Dopo la generazione, potete cambiare le modalità dei singoli compagni, ma non potete impostare modalità per compagno al momento della generazione.

### Context e comunicazione

Ogni compagno ha il suo context window. Quando generato, un compagno carica lo stesso contesto di progetto di una sessione regolare: CLAUDE.md, server MCP e skills. Riceve anche il prompt di generazione dal capo. La cronologia della conversazione del capo non viene trasferita.

**Come i compagni di team condividono le informazioni:**

* **Consegna automatica dei messaggi**: quando i compagni di team inviano messaggi, vengono consegnati automaticamente ai destinatari. Il capo non ha bisogno di sondare gli aggiornamenti.
* **Notifiche di inattività**: quando un compagno finisce e si ferma, notifica automaticamente il capo.
* **Elenco di compiti condiviso**: tutti gli agenti possono vedere lo stato dei compiti e rivendicare il lavoro disponibile.

**Messaggistica dei compagni di team:**

* **message**: invia un messaggio a un compagno specifico
* **broadcast**: invia a tutti i compagni contemporaneamente. Utilizzate con parsimonia, poiché i costi si scalano con la dimensione del team.

### Utilizzo dei token

I team di agenti utilizzano significativamente più token di una singola sessione. Ogni compagno ha il suo context window e l'utilizzo dei token si scala con il numero di compagni di team attivi. Per ricerca, revisione e lavoro su nuove funzionalità, i token extra di solito valgono la pena. Per compiti di routine, una singola sessione è più conveniente. Consultate i [costi dei token dei team di agenti](/it/costs#agent-team-token-costs) per la guida all'utilizzo.

## Esempi di casi d'uso

Questi esempi mostrano come i team di agenti gestiscono compiti in cui l'esplorazione parallela aggiunge valore.

### Eseguire una revisione del codice parallela

Un singolo revisore tende a gravitare verso un tipo di problema alla volta. Dividere i criteri di revisione in domini indipendenti significa che la sicurezza, le prestazioni e la copertura dei test ricevono tutti attenzione approfondita contemporaneamente. Il prompt assegna a ogni compagno una lente distinta in modo che non si sovrappongano:

```
Create an agent team to review PR #142. Spawn three reviewers:
- One focused on security implications
- One checking performance impact
- One validating test coverage
Have them each review and report findings.
```

Ogni revisore lavora dallo stesso PR ma applica un filtro diverso. Il capo sintetizza i risultati tra tutti e tre dopo che finiscono.

### Investigare con ipotesi concorrenti

Quando la causa principale è poco chiara, un singolo agente tende a trovare una spiegazione plausibile e smettere di cercare. Il prompt combatte questo rendendo i compagni di team esplicitamente avversari: il lavoro di ciascuno non è solo investigare la propria teoria ma sfidare le altre.

```
Users report the app exits after one message instead of staying connected.
Spawn 5 agent teammates to investigate different hypotheses. Have them talk to
each other to try to disprove each other's theories, like a scientific
debate. Update the findings doc with whatever consensus emerges.
```

La struttura del dibattito è il meccanismo chiave qui. L'investigazione sequenziale soffre di ancoraggio: una volta che una teoria è stata esplorata, l'investigazione successiva è distorta verso di essa.

Con più investigatori indipendenti che attivamente cercano di disprove l'uno l'altro, la teoria che sopravvive è molto più probabile che sia la causa principale effettiva.

## Best practice

### Fornire ai compagni di team contesto sufficiente

I compagni di team caricano il contesto del progetto automaticamente, inclusi CLAUDE.md, server MCP e skills, ma non ereditano la cronologia della conversazione del capo. Consultate [Context e comunicazione](#context-and-communication) per i dettagli. Includete i dettagli specifici del compito nel prompt di generazione:

```
Spawn a security reviewer teammate with the prompt: "Review the authentication module
at src/auth/ for security vulnerabilities. Focus on token handling, session
management, and input validation. The app uses JWT tokens stored in
httpOnly cookies. Report any issues with severity ratings."
```

### Dimensionare i compiti appropriatamente

* **Troppo piccoli**: l'overhead di coordinamento supera il beneficio
* **Troppo grandi**: i compagni di team lavorano troppo a lungo senza check-in, aumentando il rischio di sforzo sprecato
* **Giusti**: unità auto-contenute che producono un deliverable chiaro, come una funzione, un file di test o una revisione

<Tip>
  Il capo suddivide il lavoro in compiti e li assegna ai compagni di team automaticamente. Se non sta creando abbastanza compiti, chiedetegli di dividere il lavoro in pezzi più piccoli. Avere 5-6 compiti per compagno mantiene tutti produttivi e permette al capo di riassegnare il lavoro se qualcuno rimane bloccato.
</Tip>

### Aspettare che i compagni di team finiscano

A volte il capo inizia a implementare i compiti stesso invece di aspettare i compagni di team. Se notate questo:

```
Wait for your teammates to complete their tasks before proceeding
```

### Iniziare con ricerca e revisione

Se siete nuovi ai team di agenti, iniziate con compiti che hanno confini chiari e non richiedono di scrivere codice: revisionare un PR, ricercare una libreria o investigare un bug. Questi compiti mostrano il valore dell'esplorazione parallela senza le sfide di coordinamento che vengono con l'implementazione parallela.

### Evitare conflitti di file

Due compagni di team che modificano lo stesso file porta a sovrascritture. Suddividete il lavoro in modo che ogni compagno possieda un set diverso di file.

### Monitorare e sterzare

Controllate il progresso dei compagni di team, reindirizzate gli approcci che non funzionano e sintetizzate i risultati man mano che arrivano. Lasciare un team senza supervisione per troppo tempo aumenta il rischio di sforzo sprecato.

## Troubleshooting

### I compagni di team non appaiono

Se i compagni di team non appaiono dopo aver chiesto a Claude di creare un team:

* In modalità in-process, i compagni di team potrebbero già essere in esecuzione ma non visibili. Premete Shift+Giù per ciclarsi attraverso i compagni di team attivi.
* Controllate che il compito che avete dato a Claude fosse abbastanza complesso da giustificare un team. Claude decide se generare i compagni di team in base al compito.
* Se avete esplicitamente richiesto split panes, assicuratevi che tmux sia installato e disponibile nel vostro PATH:
  ```bash  theme={null}
  which tmux
  ```
* Per iTerm2, verificate che la `it2` CLI sia installata e che l'API Python sia abilitata nelle preferenze di iTerm2.

### Troppi prompt di permesso

Le richieste di permesso dei compagni di team si propagano al capo, il che può creare attrito. Pre-approvate le operazioni comuni nelle vostre [impostazioni di permesso](/it/permissions) prima di generare i compagni di team per ridurre le interruzioni.

### I compagni di team si fermano su errori

I compagni di team possono fermarsi dopo aver incontrato errori invece di recuperare. Controllate il loro output utilizzando Shift+Su/Giù in modalità in-process o facendo clic sul riquadro in modalità split, quindi:

* Date loro istruzioni aggiuntive direttamente
* Generare un compagno di team sostitutivo per continuare il lavoro

### Il capo si arresta prima che il lavoro sia finito

Il capo potrebbe decidere che il team è finito prima che tutti i compiti siano effettivamente completati. Se questo accade, ditegli di continuare. Potete anche dire al capo di aspettare che i compagni di team finiscano prima di procedere se inizia a fare lavoro invece di delegare.

### Sessioni tmux orfane

Se una sessione tmux persiste dopo che il team finisce, potrebbe non essere stata completamente pulita. Elencate le sessioni e uccidete quella creata dal team:

```bash  theme={null}
tmux ls
tmux kill-session -t <session-name>
```

## Limitazioni

I team di agenti sono sperimentali. Le limitazioni attuali di cui essere consapevoli:

* **Nessuna ripresa della sessione con compagni di team in-process**: `/resume` e `/rewind` non ripristinano i compagni di team in-process. Dopo aver ripreso una sessione, il capo potrebbe tentare di messaggiare compagni di team che non esistono più. Se questo accade, dite al capo di generare nuovi compagni di team.
* **Lo stato dei compiti può ritardare**: i compagni di team a volte non riescono a contrassegnare i compiti come completati, il che blocca i compiti dipendenti. Se un compito sembra bloccato, controllate se il lavoro è effettivamente fatto e aggiornate lo stato del compito manualmente o dite al capo di spingere il compagno di team.
* **L'arresto può essere lento**: i compagni di team finiscono la loro richiesta attuale o la chiamata dello strumento prima di arrestarsi, il che può richiedere tempo.
* **Un team per sessione**: un capo può gestire solo un team alla volta. Pulite il team attuale prima di avviarne uno nuovo.
* **Nessun team annidato**: i compagni di team non possono generare i loro team o compagni di team. Solo il capo può gestire il team.
* **Il capo è fisso**: la sessione che crea il team è il capo per tutta la sua vita. Non potete promuovere un compagno di team a capo o trasferire la leadership.
* **Permessi impostati al momento della generazione**: tutti i compagni di team iniziano con la modalità di permesso del capo. Potete cambiare le modalità dei singoli compagni dopo la generazione, ma non potete impostare modalità per compagno al momento della generazione.
* **Split panes richiedono tmux o iTerm2**: la modalità in-process predefinita funziona in qualsiasi terminale. La modalità split-pane non è supportata nel terminale integrato di VS Code, Windows Terminal o Ghostty.

<Tip>
  **`CLAUDE.md` funziona normalmente**: i compagni di team leggono i file `CLAUDE.md` dalla loro directory di lavoro. Utilizzate questo per fornire una guida specifica del progetto a tutti i compagni di team.
</Tip>

## Prossimi passi

Esplorate approcci correlati per il lavoro parallelo e la delega:

* **Delega leggera**: i [subagent](/it/sub-agents) generano agenti helper per ricerca o verifica all'interno della vostra sessione, migliore per compiti che non hanno bisogno di coordinamento tra agenti
* **Sessioni parallele manuali**: i [Git worktrees](/it/common-workflows#run-parallel-claude-code-sessions-with-git-worktrees) vi permettono di eseguire più sessioni Claude Code voi stessi senza coordinamento automatico del team
* **Confrontare gli approcci**: consultate il confronto [subagent vs agent team](/it/features-overview#compare-similar-features) per una suddivisione fianco a fianco

