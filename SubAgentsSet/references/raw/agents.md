# BlogEditorAI (WordPress Plugin) - Concept, Objective, Milestones

Data: 2026-02-10

## Concetto
BlogEditorAI e un plugin WordPress che vive interamente nel backend (`wp-admin`) e guida l'utente (editor/admin) in un flusso end-to-end:

1. Parte da zero (nuovo progetto editoriale) oppure legge i contenuti esistenti del sito (ultimi N articoli, default 10).
2. Il motore AI (servizio backend esterno chiamato via API) analizza contenuti e metadati SEO (prima integrazione: Rank Math), estrae topic/cluster, keyword candidate e gap.
3. Integra dati proprietari del sito (opzionale ma consigliato: Google Search Console) per prioritizzare opportunita reali (impression, CTR, position).
4. Propone una lista di focus keyword e un piano editoriale (calendarizzato).
5. Su richiesta dell'utente ("Redigi bozza"), genera bozze WordPress (draft) con struttura SEO, meta, FAQ, suggerimenti internal linking e note editoriali.

Il plugin resta "leggero": UI + connessione + scrittura su WordPress. Il lavoro pesante e asincrono (analisi/generazione) vive nel backend AI.

## Obiettivo
Ridurre drasticamente il tempo e l'incertezza nel ciclo:

Contenuti esistenti -> insight -> piano -> bozza pubblicabile

Metriche-obiettivo (indicative, per validare valore):
- Tempo per passare da "nessuna idea" a "piano di 20 contenuti" < 30 minuti.
- Tempo per produrre una bozza strutturata (outline + meta + FAQ + internal link suggeriti) < 3 minuti per contenuto, con revisione umana.
- Aumento output editoriale senza peggiorare cannibalizzazione e contenuti duplicati.

## Regole operative (obbligatorie)
Queste regole valgono per ogni sessione di lavoro futura su questo progetto.

1. Documentazione: mantenere `README.md` (il "readmi") come documentazione principale del plugin e aggiornarla ad ogni sessione.
2. Mappatura plugin: mentre viene costruito il plugin, mantenerlo mappato in `MAP.md` per facilitare manutenzione e interventi futuri (pagine admin, hook WP, storage, job asincroni, endpoint backend, integrazioni).
3. Ambiente WP: a inizio progetto viene creato un ambiente WordPress locale (WP env) per sviluppo e test del plugin.
4. Test ad ogni sessione: ad ogni sessione di lavoro l'ambiente WP viene avviato e viene aperto il browser, cosi da testare il plugin in tempo reale.
5. Versione: mantenere un file `VERSION` con la versione corrente (SemVer consigliato: `MAJOR.MINOR.PATCH`).
6. Log progressivo: ad ogni sessione creare un nuovo file `logN.md` (es. `log1.md`, `log2.md`, ...) che riporti data, versione e cosa e' stato fatto.
7. Git: usare git per il versionamento; ogni sessione deve produrre almeno un commit coerente con la versione e con i cambi descritti nel log.
8. Base di conoscenza: mantenere una lista di fonti in `base_di_conoscenza.md` e aggiornarla quando vengono aggiunte nuove reference utili (SEO/Content/WordPress).
9. Sotto-agenti (opzionale, se efficace): e' permesso invocare Codex in nuove finestre PowerShell come sotto-agenti per accelerare task ripetitivi (es. studio fonti KB, stesura voci, refactor doc).
   - Uso parsimonioso: invocare sotto-agenti solo quando necessario e utile (parallelizzabile e con guadagno reale). Non usarli "sempre" per default.
   - Anti-conflitto: ogni sotto-agente lavora su file disgiunti (es. una entry in `kb/entries/` per volta). Vietate modifiche concorrenti sullo stesso file.
   - Coordinamento: assegnare un obiettivo specifico e un output atteso (file/paths) e far confluire i risultati in un solo commit di sessione.
   - Chiusura: prima di fare commit, verificare che non ci siano stati conflitti o sovrascritture involontarie.
   - Orchestrazione: l'agente principale resta l'unico orchestratore (assegna task, verifica output, integra e committa).
   - No-recursion: i sotto-agenti devono sapere di esserlo e NON devono invocare altri sotto-agenti (vietato spawn ricorsivo).

## Principi di prodotto (vincoli pratici)
- Backend-only: nessuna UI pubblica sul frontend.
- Human-in-the-loop: l'AI propone, l'utente approva (mai autopubblicazione in MVP).
- Trasparenza: ogni focus keyword deve avere un "perche" (intent, opportunita, fonti: contenuti, GSC, trend, ecc.).
- Anti-fragilita: niente scraping SERP come requisito core; competitor/trend solo se via provider/API o moduli opzionali.
- Cost control: budget token per sito/progetto e cache per analisi ripetute.

## Utenti target
- Editor/Content manager: vuole idee, priorita e bozze veloci.
- SEO specialist: vuole segnali, audit leggero e workflow per aggiornamenti.
- Owner/PM: vuole un calendario e tracking di cosa si pubblica e perche.

## Flusso (state machine alto livello)
- Setup: API key backend AI, selezione sito/progetto, toggle integrazioni.
- Ingest: selezione "ultimi N" + filtri (post type, categorie, date range).
- Analysis job: estrazione topic/cluster + keyword candidate + mappa contenuti.
- (Opzionale) GSC sync: query/page metrics, quick wins, cannibalizzazione.
- Planning: lista keyword -> aggiungi a calendario -> definisci date e owner.
- Drafting: genera bozza -> revisione -> iterazioni -> pronto per pubblicazione.

## Milestones (dall'inizio allo state of the art)

### M0 - Fondazioni (Setup, dev env, sicurezza)
Obiettivo: plugin installabile, backend-only (wp-admin), configurabile e testabile in tempo reale in un WP env.

Deliverables (spuntabili):
- [ ] D0.1 WP env locale creato e documentato (start/stop, URL wp-admin, credenziali dev).
- [ ] D0.2 Plugin skeleton installabile: header, autoload minimo, attivazione/disattivazione safe.
- [ ] D0.3 Admin UI: Dashboard + Settings (solo wp-admin).
- [ ] D0.4 Config backend AI: endpoint + credenziali + "connection test".
- [ ] D0.5 Security baseline: capabilities/roles + nonces + sanitizzazione input + escaping output.
- [ ] D0.6 Logging minimo (errori + job) e tracciamento versione (`VERSION`) nei log.
- [ ] D0.7 MAP baseline: `MAP.md` con mappa file/flow iniziale.

Tasks (operativi):
- T0.1 (D0.1) Scegli runtime WP env (wp-env o docker-compose) e definisci script avvio.
- T0.2 (D0.2) Crea struttura plugin e wiring per admin menu.
- T0.3 (D0.3) Implementa le 2 pagine admin con routing e UI minimale.
- T0.4 (D0.4) Implementa settings storage (wp_options) + endpoint test.
- T0.5 (D0.5) Applica standard WP security su tutte le azioni admin.
- T0.6 (D0.6) Definisci schema log (job id, step, status, kb version, timestamps).
- T0.7 (D0.7) Aggiorna `MAP.md` con punti di integrazione e flussi.

Subtasks:
- ST0.1.1 (T0.1) Aggiungi script `scripts/wp_env_start.*` e `scripts/wp_env_stop.*` (o equivalente) e documenta in `README.md`.
- ST0.1.2 (T0.1) Automatizza "start + open browser" come da regole operative.
- ST0.2.1 (T0.2) Definisci namespace PHP e struttura `includes/` + `admin/` + `assets/`.
- ST0.2.2 (T0.2) Aggiungi hook activation/deactivation con checks non distruttivi.
- ST0.3.1 (T0.3) Dashboard: 2 CTA (start from zero / read existing articles) + stato backend.
- ST0.3.2 (T0.3) Settings: form validato + salvataggio + feedback error/success.
- ST0.4.1 (T0.4) Implementa "test connessione" asincrono (AJAX) con timeout e messaggi chiari.
- ST0.5.1 (T0.5) Aggiungi capability custom (es. `manage_blogeditorai`) e limita menu/pagine.
- ST0.6.1 (T0.6) Crea tabella custom o CPT per job (decisione documentata) e policy retention.
- ST0.7.1 (T0.7) Scrivi la mappa: UI -> controller -> service -> backend API -> storage.

Done quando:
- Un admin configura il backend AI e vede "connection OK" nella Dashboard, dentro un WP env avviabile con uno script.

### M1 - Lettura contenuti (Ingest)
Obiettivo: leggere articoli e metadati WP e normalizzarli in un formato stabile per l'analisi.

Deliverables (spuntabili):
- [ ] D1.1 UI scelta: "parti da zero" vs "leggi articoli".
- [ ] D1.2 Input ingest: N (default 10) + filtri (post type, category/tag, date range, status).
- [ ] D1.3 Normalizzazione: modello stabile per post (id, title, slug, content, excerpt, author, dates, taxonomies).
- [ ] D1.4 Preview elenco contenuti selezionati + summary (conteggio, range date, lingue se rilevabili).
- [ ] D1.5 MAP aggiornato per ingest (punti di accesso e shape dati).

Tasks (operativi):
- T1.1 (D1.1) Implementa stato wizard in Dashboard (step selection).
- T1.2 (D1.2) Implementa query WP (WP_Query) con validazione filtri.
- T1.3 (D1.3) Implementa normalizer e versiona lo schema (es. `schema_version`).
- T1.4 (D1.4) Render lista con paginazione/light preview e CTA "avvia analisi".
- T1.5 (D1.5) Aggiorna `MAP.md` e `README.md` se cambia flusso.

Subtasks:
- ST1.2.1 (T1.2) Gestisci edge cases: post vuoti, blocchi, shortcodes, HTML sporco.
- ST1.3.1 (T1.3) Definisci policy: strip vs keep HTML, handling immagini, handling code blocks.
- ST1.4.1 (T1.4) Aggiungi stima token/size per batch e warning se troppo grande.

Done quando:
- La UI mostra l'elenco contenuti selezionati e puo avviare l'analisi con payload deterministico.

### M2 - Analisi contenuti (Insight on-site)
Obiettivo: ottenere output utile senza dipendenze esterne, usando KB SEO come guardrail di qualita'.

Deliverables (spuntabili):
- [ ] D2.1 Topic extraction + clustering per batch ingest.
- [ ] D2.2 Keyword candidates (20-50) con motivazione, intent stimato, tipo contenuto suggerito.
- [ ] D2.3 Content map: coperto vs scoperto (gap) + suggerimento "nuovo vs update".
- [ ] D2.4 Persistenza risultati (job results) con audit (input hash, kb version, model, timestamps).
- [ ] D2.5 MAP aggiornato per analisi (pipeline e storage).

Tasks (operativi):
- T2.1 (D2.1) Definisci prompt/task spec per topic clustering (output schema JSON).
- T2.2 (D2.2) Definisci prompt/task spec per keyword proposal (con intent-first, anti-spam).
- T2.3 (D2.3) Definisci logica gap: mapping cluster->contenuti esistenti vs nuovi.
- T2.4 (D2.4) Implementa job runner asincrono (queue o cron) con retry/backoff.
- T2.5 (D2.5) Aggiorna `MAP.md` con flusso end-to-end ingest->analysis->results.

Subtasks:
- ST2.1.1 (T2.1) Standardizza output: cluster id, label, confidence, sample urls/posts.
- ST2.2.1 (T2.2) Aggiungi scoring: business relevance (manuale), effort stimato, risk/YMYL flag.
- ST2.4.1 (T2.4) Aggiungi cancella job e gestione stato (queued/running/success/fail).
- ST2.4.2 (T2.4) Registra model id (target GPT 5.2) e parametri.

Done quando:
- La Dashboard mostra cluster + 20-50 focus keyword suggerite, ciascuna con motivazione e segnali di priorita', e i risultati sono auditabili.

### M2-KB - Studio e redazione Knowledge Base SEO (KB)
Obiettivo: costruire una KB SEO interna, tracciabile e prompt-ready, per aumentare qualita' e coerenza degli output.

Deliverables (spuntabili):
- [ ] DKB.1 `base_di_conoscenza.md` aggiornato con fonti utili (solo quando necessario) e senza duplicati.
- [ ] DKB.2 `kb/index.md` con indice operativo per aree chiave (intent, on-page, internal linking, cannibalizzazione, refresh, CWV/performance, structured data, governance/E-E-A-T, GSC).
- [ ] DKB.3 `kb/prompt_pack.md` con regole/checklist iniettabili (no prose lunga), allineate alle fonti.
- [ ] DKB.4 `kb/entries/` creato solo per deep dive necessari (template: Sources + Accessed + Summary + Rules + Failure modes + Examples).
- [ ] DKB.5 Tracciabilita': ogni regola importante ha almeno 1 fonte e data Accessed.
- [ ] DKB.6 Quality gate KB (manuale): 3 casi d'uso documentati in `kb/quality_gate.md`.

Tasks (operativi):
- TKB.1 (DKB.1) Raccogli fonti, deduplica, e definisci criteri affidabilita' (ufficiale, industry, blog).
- TKB.2 (DKB.2) Definisci tassonomia e criteri di "done" per ogni area (copertura minima).
- TKB.3 (DKB.3) Converti best practice in regole operative (input/output, constraints, failure modes).
- TKB.4 (DKB.4) Scrivi entries solo quando serve dettaglio (evita KB prolissa).
- TKB.5 (DKB.5) Applica template e aggiungi "Accessed: YYYY-MM-DD".
- TKB.6 (DKB.6) Esegui i 3 casi d'uso e annota gap/azioni.

Subtasks:
- STKB.3.1 (TKB.3) Definisci policy anti-spam: niente keyword stuffing, niente FAQ inventate, niente claim non verificati.
- STKB.3.2 (TKB.3) Definisci policy intent: soddisfare bisogno prima di inserire CTA.
- STKB.6.1 (TKB.6) Caso 1: proposta KW da 10 post, valida coerenza e non cannibalizzazione.
- STKB.6.2 (TKB.6) Caso 2: outline per query YMYL, richiede "fonti consigliate" e "punti da verificare".
- STKB.6.3 (TKB.6) Caso 3: bozza completa, check brand voice baseline e controlli rischio.

Done quando (livello "adeguato" per integrazione):
- La KB copre le aree chiave e `kb/prompt_pack.md` guida output senza ambiguita'; regole tracciabili e aggiornabili.

### M2-KB-INF - Infrastruttura KB (integrazione con plugin + motore AI)
Obiettivo: rendere la KB usabile dall'infrastruttura del plugin e dal backend AI, in modo versionato e auditabile, cosi' che GPT 5.2 la applichi correttamente.

Deliverables (spuntabili):
- [ ] DKBI.1 Strategia prompt assembly documentata (ordine blocchi, limiti lunghezza, fallback).
- [ ] DKBI.2 Versioning KB: `VERSION` + hash prompt pack salvati per ogni job (analysis/draft/refresh).
- [ ] DKBI.3 Contratto API backend AI include: kb version/hash + feature flags + model id.
- [ ] DKBI.4 Runtime injection controllata: separazione tra KB, contesto sito, dati GSC, richiesta utente.
- [ ] DKBI.5 Quality gate tecnico E2E: 3 richieste con verifica applicazione regole KB.
- [ ] DKBI.6 `MAP.md` aggiornato (dove avviene injection KB, storage, audit).

Tasks (operativi):
- TKBI.1 (DKBI.1) Progetta template prompt: system/developer/user blocks e schema output.
- TKBI.2 (DKBI.2) Implementa hashing e storage nei job results (immutabile per audit).
- TKBI.3 (DKBI.3) Aggiorna backend contract + error codes + timeouts + retries.
- TKBI.4 (DKBI.4) Implementa compiler (kb prompt pack -> runtime string) con trimming deterministico.
- TKBI.5 (DKBI.5) Implementa test harness E2E (3 casi) e checklist attese.
- TKBI.6 (DKBI.6) Aggiorna mappa tecnica e doc operativa.

Subtasks:
- STKBI.2.1 (TKBI.2) Salva anche input hash (post set) per riproducibilita'.
- STKBI.4.1 (TKBI.4) Implementa feature flags: structured data, FAQ policy, safety/YMYL mode.
- STKBI.5.1 (TKBI.5) Verifica: no FAQ inventate, intent-first, meta coerenti, no stuffing.

Done quando:
- Esiste pipeline ripetibile che usa KB in modo versionato e auditabile e produce output piu' coerente rispetto a baseline senza KB.

### M3 - Piano editoriale (Calendario)
Obiettivo: trasformare insight in azione (piano, priorita', date).

Deliverables (spuntabili):
- [ ] D3.1 Lista focus keyword con azioni (add to plan, note, priority).
- [ ] D3.2 Calendario: data pubblicazione, owner, status (idea/writing/review).
- [ ] D3.3 Persistenza piano (custom table/CPT) con audit e versioning minimo.
- [ ] D3.4 Export/Import (CSV minimo) per lavorare offline.
- [ ] D3.5 MAP aggiornato per piano editoriale.

Tasks (operativi):
- T3.1 (D3.1) UI: tabella keyword + filtri + ordinamento + bulk add.
- T3.2 (D3.2) UI: calendario (anche semplice list-by-date) + drag/reschedule (fase 2).
- T3.3 (D3.3) Storage schema + migrazioni + policy retention.
- T3.4 (D3.4) CSV: columns stabili + escaping + encoding safe.
- T3.5 (D3.5) Aggiorna `MAP.md` e `README.md` se serve.

Subtasks:
- ST3.1.1 (T3.1) Aggiungi campi: intent, content type, notes, risk/YMYL, est. effort.
- ST3.3.1 (T3.3) Collega item piano a source KW suggestion (job id) per tracciabilita'.

Done quando:
- L'utente crea e gestisce un piano di almeno 10 voci, lo rivede/riordina e mantiene audit minimo.

### M4 - Generazione bozza WordPress (Drafting)
Obiettivo: generare contenuti direttamente in WP come draft, con struttura coerente e controlli base.

Deliverables (spuntabili):
- [ ] D4.1 Azione "Redigi bozza" da item del piano editoriale.
- [ ] D4.2 Creazione WP draft: title + outline H2/H3 + sezioni + takeaway.
- [ ] D4.3 Meta base SEO: meta title/description (fallback standard) e slug suggestion.
- [ ] D4.4 Iterazione: rigenera variante, aggiorna sezione, conserva audit trail (minimo).
- [ ] D4.5 MAP aggiornato per drafting.

Tasks (operativi):
- T4.1 (D4.1) Implementa handler draft (async) con stato e progress.
- T4.2 (D4.2) Definisci schema output e renderer (Gutenberg blocks vs HTML).
- T4.3 (D4.3) Implementa meta generator e policy lunghezze.
- T4.4 (D4.4) Implementa "regenerate" con confronto diff (anche solo log) e versioning bozza.
- T4.5 (D4.5) Aggiorna `MAP.md`.

Subtasks:
- ST4.2.1 (T4.2) Definisci policy immagini: placeholders vs none; alt text rules.
- ST4.3.1 (T4.3) Aggiungi controlli: title uniqueness, cannibalizzazione con contenuti esistenti (best-effort).
- ST4.4.1 (T4.4) Salva prompt metadata (kb hash, model id, input hash) per riproducibilita'.

Done quando:
- Si crea un draft per ogni item del piano e si puo iterare (rigenera/varia) mantenendo audit minimo.

### M5 - Integrazione Rank Math (SEO plugin)
Obiettivo: leggere/scrivere metadati Rank Math in modo affidabile, senza rompere l'editor.

Deliverables (spuntabili):
- [ ] D5.1 Lettura meta Rank Math esistenti (focus kw, title, description, schema base se presente).
- [ ] D5.2 Scrittura meta Rank Math su bozza generata (con fallback se RM non installato).
- [ ] D5.3 Compatibility checks (versioni RM) e feature flags.
- [ ] D5.4 MAP aggiornato per integrazione SEO plugin.

Tasks (operativi):
- T5.1 (D5.1) Mappa i meta keys RM e test su post reali.
- T5.2 (D5.2) Implementa writer con sanitizzazione e rollback su errori.
- T5.3 (D5.3) Aggiungi detection plugin/versions e fallback su meta standard WP.
- T5.4 (D5.4) Aggiorna `MAP.md` e doc.

Subtasks:
- ST5.1.1 (T5.1) Definisci schema mapping: field -> meta key -> UI.
- ST5.2.1 (T5.2) Evita di sovrascrivere manual edits: policy "write once" o "overwrite with confirm".

Done quando:
- I draft generati hanno meta Rank Math valorizzati e visibili nel post editor (o fallback stabile se RM assente).

### M6 - Aggiornamento contenuti esistenti (Refresh)
Obiettivo: migliorare contenuti esistenti con suggerimenti verificabili e workflow controllato.

Deliverables (spuntabili):
- [ ] D6.1 Suggerimenti refresh: sezioni mancanti, intent mismatch, FAQ (solo se utile), internal links.
- [ ] D6.2 Azione refresh: crea bozza aggiornamento (revision flow o duplicazione controllata).
- [ ] D6.3 Checklist QA per refresh (anti-spam, E-E-A-T/YMYL, factual checks).
- [ ] D6.4 MAP aggiornato per refresh.

Tasks (operativi):
- T6.1 (D6.1) Definisci prompt spec refresh con output "change plan" strutturato.
- T6.2 (D6.2) Implementa workflow WP (revision/duplicate) con policy.
- T6.3 (D6.3) Implementa checklist UI e gating prima di salvare.
- T6.4 (D6.4) Aggiorna `MAP.md`.

Subtasks:
- ST6.2.1 (T6.2) Se duplicate: conserva canonical/redirect notes; evita regressioni SEO.
- ST6.3.1 (T6.3) Se YMYL: forza "fonti consigliate" + "punti da verificare" nel risultato.

Done quando:
- Un post esistente entra in workflow di refresh con suggerimenti verificabili e output draft controllato.

### M7 - Integrazione Google Search Console (Dati reali del sito)
Obiettivo: prioritizzare con dati reali (impressions, CTR, position) e scoprire quick wins, con cache e audit.

Deliverables (spuntabili):
- [ ] D7.1 OAuth Google + selezione property GSC.
- [ ] D7.2 Sync incrementale (28/90/365 giorni) con cache e rate-limit handling.
- [ ] D7.3 Insight: CTR opportunities, pos 8-20, query/page mapping, cannibalizzazione (best-effort).
- [ ] D7.4 UI badges/metriche GSC su keyword suggerite e su items piano.
- [ ] D7.5 Audit: log sync (scope, property, date ranges, last sync, errors).
- [ ] D7.6 MAP aggiornato per GSC.

Tasks (operativi):
- T7.1 (D7.1) Implementa OAuth flow e storage token sicuro (WP options + encryption policy).
- T7.2 (D7.2) Implementa scheduler sync e incremental fetch (per date range).
- T7.3 (D7.3) Implementa aggregazioni: query->page, page->query, thresholds configurabili.
- T7.4 (D7.4) Integra metriche nella UI (keyword list + calendar list).
- T7.5 (D7.5) Implementa logging sync e retry/backoff.
- T7.6 (D7.6) Aggiorna `MAP.md`.

Subtasks:
- ST7.2.1 (T7.2) Gestisci edge: property non verificata, permessi insufficienti, quota exceeded.
- ST7.3.1 (T7.3) Cannibalizzazione: definisci euristica e segnala come "indicazione" non certezza.

Done quando:
- Ogni focus keyword proposta puo mostrare metriche GSC quando disponibili, e le priorita' cambiano con segnali reali.

### M8 - Trend e fonti esterne (modulare, opt-in)
Obiettivo: arricchire senza fragilita': sistema funziona bene anche senza provider esterni.

Deliverables (spuntabili):
- [ ] D8.1 Google Trends integration (topic caldi e stagionalita').
- [ ] D8.2 Provider SEO opzionali (BYO API key): keyword difficulty, competitor gap, SERP features.
- [ ] D8.3 Abstraction layer provider (interfaccia unica, fallback, cache).
- [ ] D8.4 MAP aggiornato per external providers.

Tasks (operativi):
- T8.1 (D8.1) Implementa fetch Trends + caching e UI preview.
- T8.2 (D8.2) Seleziona 1 provider pilot e integra (solo se utile).
- T8.3 (D8.3) Definisci interfaccia provider e schema normalizzato risultati.
- T8.4 (D8.4) Aggiorna `MAP.md`.

Subtasks:
- ST8.2.1 (T8.2) Policy legale/ToS: no scraping fragile; preferisci API ufficiali.
- ST8.3.1 (T8.3) Rate limiting + circuit breaker per provider instabili.

Done quando:
- Senza provider tutto funziona; con provider la prioritizzazione migliora senza rompere i flussi.

### M9 - Quality system (Brand voice e guardrail)
Obiettivo: bozze piu' vicine al brand e meno rischio, con controlli chiari e verificabili.

Deliverables (spuntabili):
- [ ] D9.1 Style profile configurabile (tone, target, lessico, lunghezza, CTA, policy).
- [ ] D9.2 Guardrail: anti-spam, factual/YMYL, duplicazione, compliance (settori sensibili).
- [ ] D9.3 Citazioni/Fonti: suggerimenti di fonti e "punti da verificare" quando richiesto o in YMYL.
- [ ] D9.4 QA report su bozza (score + checklist pass/fail) visibile in wp-admin.
- [ ] D9.5 MAP aggiornato per quality system.

Tasks (operativi):
- T9.1 (D9.1) Definisci schema style profile e UI settings.
- T9.2 (D9.2) Implementa checker (pre-save) e policy di blocco/warn.
- T9.3 (D9.3) Integra nel prompt assembly regole fonti/verifica.
- T9.4 (D9.4) Render QA report e storico per bozza.
- T9.5 (D9.5) Aggiorna `MAP.md`.

Subtasks:
- ST9.2.1 (T9.2) Duplicazione: integrazione con simil-check base (hash/near-dup) senza scraping.
- ST9.2.2 (T9.2) Claim rischiosi: flagga e richiede conferma/nota.

Done quando:
- L'utente imposta regole di stile e vede il rispetto nel draft, con QA report e guardrail applicati.

### M10 - State of the art (Workflow + automazioni controllate)
Obiettivo: sistema editoriale completo e misurabile, con governance, audit, e automazioni controllate (no autopublish).

Deliverables (spuntabili):
- [ ] D10.1 Multi-sito / multi-progetto con isolamenti (settings, KB, style, creds).
- [ ] D10.2 Workflow avanzato: approvazioni, ruoli, audit trail, commenti, history.
- [ ] D10.3 Content decay alerts (da GSC) e task automatici di refresh (non autopubblica).
- [ ] D10.4 Suggerimenti internal linking con grafi e topic cluster (con explainability).
- [ ] D10.5 Esperimenti: varianti title/meta e tracking (se integrabile e consentito).
- [ ] D10.6 Multilingua (solo dopo consolidamento IT) con KB per lingua.
- [ ] D10.7 MAP aggiornato e "operational handbook" aggiornato.

Tasks (operativi):
- T10.1 (D10.1) Progetta storage multi-tenant e migrazioni.
- T10.2 (D10.2) Implementa workflow engine leggero (stati + transizioni + audit).
- T10.3 (D10.3) Scheduler decay + thresholds + notifiche.
- T10.4 (D10.4) Costruisci graph linking (nodes=posts, edges=links/topic) e suggerimenti.
- T10.5 (D10.5) Implementa esperimenti controllati e logging risultati.
- T10.6 (D10.6) Progetta i18n: UI + prompt + KB per lingua.
- T10.7 (D10.7) Aggiorna `MAP.md` e doc operativa.

Subtasks:
- ST10.2.1 (T10.2) Aggiungi "approval required" gates per azioni rischiose.
- ST10.4.1 (T10.4) Evita suggerimenti non naturali: regole KB internal linking.
- ST10.5.1 (T10.5) No auto deploy: solo suggerimenti + user click, sempre audit.

Done quando:
- L'utente gestisce un ciclo continuo: idee -> calendario -> bozze -> refresh -> misurazione, con controllo costi, governance e audit.

## Non-obiettivi (per evitare scope creep)
- Scraping SERP come requisito di base.
- Autopubblicazione senza revisione umana (almeno fino a quando non esistono guardrail e audit).
- "SEO autopilot" o promesse di ranking: il sistema supporta decisioni, non garantisce risultati.

## Deliverable per milestone (checklist sintetica)
- UI admin: Dashboard, Settings, Jobs/History, Editorial Plan.
- Backend AI: endpoints per ingest, analysis, planning suggestions, drafting.
- Storage: risultati analisi, piano editoriale, mapping keyword<->post, log job.
- Knowledge base: `base_di_conoscenza.md` + `kb/` (index, prompt_pack, entries) e processo di aggiornamento.
- Integrazioni: Rank Math (prima), GSC (poi), provider esterni (opt-in).
