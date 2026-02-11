param(
  [Parameter(Mandatory = $true)]
  [string]$ContextPath,
  [string]$GuardrailsPath = "",
  [string[]]$Domains = @(),
  [string]$TeamName = "adaptive-team",
  [string]$ProjectRoot = (Get-Location).Path,
  [string]$RunsDir = ""
)

$ErrorActionPreference = "Stop"

function Get-MatchScore {
  param(
    [string]$Text,
    [string[]]$Keywords
  )
  $score = 0
  foreach ($k in $Keywords) {
    if ($Text -match [regex]::Escape($k)) {
      $score++
    }
  }
  return $score
}

if (-not (Test-Path -LiteralPath $ContextPath)) {
  throw "Context file not found: $ContextPath"
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SetRoot = Split-Path -Parent $ScriptDir

if ([string]::IsNullOrWhiteSpace($GuardrailsPath)) {
  $GuardrailsPath = Join-Path $SetRoot "templates/guardrails.template.json"
}
if (-not (Test-Path -LiteralPath $GuardrailsPath)) {
  throw "Guardrails file not found: $GuardrailsPath"
}

if ([string]::IsNullOrWhiteSpace($RunsDir)) {
  $RunsDir = Join-Path $SetRoot "team_runs"
}

$guardrails = Get-Content -Raw -LiteralPath $GuardrailsPath | ConvertFrom-Json
$context = Get-Content -Raw -LiteralPath $ContextPath
$contextLower = $context.ToLowerInvariant()

$maxSubagents = [int]$guardrails.max_subagents_total
$maxParallel = [int]$guardrails.max_parallel_workers
if ($maxSubagents -lt 1) { $maxSubagents = 1 }
if ($maxParallel -lt 1) { $maxParallel = 1 }

$domainCatalog = @($guardrails.domain_catalog | ForEach-Object { [string]$_ })
if ($domainCatalog.Count -eq 0) {
  $domainCatalog = @("general-code-quality-review")
}

$selectedDomains = @()
if ($Domains.Count -gt 0) {
  $selectedDomains = @($Domains | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
} else {
  $domainSignals = @(
    @{ domain = "frontend-ux-review"; keywords = @("frontend","ui","ux","react","css","accessibility","a11y","design") },
    @{ domain = "backend-api-review"; keywords = @("backend","api","endpoint","service","controller","route") },
    @{ domain = "testing-quality-review"; keywords = @("test","coverage","qa","unit","integration","e2e") },
    @{ domain = "data-persistence-review"; keywords = @("db","database","sql","migration","schema","query","persistence") },
    @{ domain = "infra-runtime-review"; keywords = @("deploy","docker","kubernetes","infra","runtime","ci","cd") },
    @{ domain = "docs-developer-experience"; keywords = @("docs","documentation","readme","onboarding","developer experience") },
    @{ domain = "security-risk-review"; keywords = @("security","auth","token","vulnerability","owasp","permission") },
    @{ domain = "performance-hotspots-review"; keywords = @("performance","latency","slow","bottleneck","optimization","profiling") },
    @{ domain = "general-code-quality-review"; keywords = @("refactor","maintainability","code quality","tech debt") }
  )

  $scored = @()
  foreach ($item in $domainSignals) {
    $score = Get-MatchScore -Text $contextLower -Keywords $item.keywords
    if ($score -gt 0) {
      $scored += [PSCustomObject]@{
        domain = $item.domain
        score = $score
      }
    }
  }

  if ($scored.Count -gt 0) {
    $selectedDomains = @(
      $scored |
        Sort-Object score -Descending |
        Select-Object -ExpandProperty domain -Unique
    )
  } else {
    $selectedDomains = @($domainCatalog)
  }
}

if ($selectedDomains.Count -eq 0) {
  $selectedDomains = @("general-code-quality-review")
}

$selectedDomains = @($selectedDomains | Select-Object -Unique)
if ($selectedDomains.Count -gt $maxSubagents) {
  $selectedDomains = $selectedDomains[0..($maxSubagents - 1)]
}

$teammateCount = [Math]::Min($maxParallel, $selectedDomains.Count)
if ($teammateCount -lt 1) {
  $teammateCount = 1
}

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$runId = "{0}-{1}" -f $TeamName, $stamp
$runRoot = Join-Path $RunsDir $runId
New-Item -ItemType Directory -Force -Path $runRoot | Out-Null
foreach ($dir in @("prompts", "logs", "mailbox", "reports", "state")) {
  New-Item -ItemType Directory -Force -Path (Join-Path $runRoot $dir) | Out-Null
}

$members = @()
for ($i = 1; $i -le $teammateCount; $i++) {
  $memberId = "tm-{0:D2}" -f $i
  $members += [PSCustomObject]@{
    id = $memberId
    role = "adaptive-worker-{0:D2}" -f $i
    model = "inherit"
  }
}

$tasks = @()
$tasks += [PSCustomObject]@{
  id = "T-000"
  title = "Validate adaptive plan and ownership"
  owner = "lead"
  status = "pending"
  depends_on = @()
  scope = "Review generated tasks, enforce guardrails, confirm ownership."
  target_files = @()
  done_when = @(
    "Tasks respect guardrails",
    "Ownership and dependencies are valid"
  )
  deliverable = "reports/T-000.md"
}

$taskNum = 1
$memberIndex = 0
foreach ($domain in $selectedDomains) {
  $taskId = "T-{0:D3}" -f $taskNum
  $owner = $members[$memberIndex % $members.Count].id
  $memberIndex++

  $allowCode = [bool]$guardrails.allow_code_changes
  $targetFiles = @()
  $doneWhen = @()
  if ($allowCode) {
    $targetFiles = @("<set-target-file-for-$domain>")
    $doneWhen = @(
      "Domain objective completed",
      "Changes reviewed by lead before merge"
    )
  } else {
    $targetFiles = @("reports/{0}.md" -f $domain)
    $doneWhen = @(
      "Report includes findings and recommendations",
      "No non-report files modified"
    )
  }

  $tasks += [PSCustomObject]@{
    id = $taskId
    title = "Adaptive domain task: $domain"
    owner = $owner
    status = "pending"
    depends_on = @("T-000")
    scope = "Analyze and execute domain '$domain' based on project context in $ContextPath."
    target_files = $targetFiles
    done_when = $doneWhen
    deliverable = "reports/$taskId.md"
  }
  $taskNum++
}

$board = [PSCustomObject]@{
  schema_version = "1.0"
  profile = "adaptive"
  team_name = $TeamName
  run_id = $runId
  created_at = (Get-Date).ToString("s")
  project_root = $ProjectRoot
  lead = [PSCustomObject]@{
    id = "lead"
    role = "orchestrator"
  }
  members = $members
  tasks = $tasks
  rules = [PSCustomObject]@{
    no_recursive_subagents = [bool]$guardrails.no_recursive_subagents
    no_target_file_overlap = [bool]$guardrails.require_disjoint_target_files
    lead_handles_cleanup = $true
    teammate_reports_required = $true
    require_lead_approval_for_code_changes = [bool]$guardrails.require_lead_approval_for_code_changes
  }
  metadata = [PSCustomObject]@{
    context_path = $ContextPath
    guardrails_path = $GuardrailsPath
    selected_domains = $selectedDomains
  }
}

$boardPath = Join-Path $runRoot "task_board.json"
$board | ConvertTo-Json -Depth 16 | Out-File -FilePath $boardPath -Encoding utf8

$guardrailsCopyPath = Join-Path $runRoot "guardrails.applied.json"
$guardrails | ConvertTo-Json -Depth 10 | Out-File -FilePath $guardrailsCopyPath -Encoding utf8

$leadTemplatePath = Join-Path $SetRoot "templates/team_lead_prompt_template.txt"
$leadPromptPath = Join-Path $runRoot "prompts/team_lead.txt"
$leadPrompt = Get-Content -Raw -LiteralPath $leadTemplatePath
$leadPrompt = $leadPrompt.Replace("<TEAM_NAME>", $TeamName)
$leadPrompt = $leadPrompt.Replace("<RUN_ID>", $runId)
$leadPrompt = $leadPrompt.Replace("<PROJECT_ROOT>", $ProjectRoot)
$leadPrompt = $leadPrompt.Replace("<TASK_BOARD_PATH>", $boardPath)
$leadPrompt = $leadPrompt.Replace("<MAILBOX_PATH>", (Join-Path $runRoot "mailbox"))
$leadPrompt | Out-File -FilePath $leadPromptPath -Encoding utf8

Write-Output $runRoot
Write-Output $boardPath
Write-Output $leadPromptPath
