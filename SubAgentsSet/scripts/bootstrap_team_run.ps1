param(
  [string]$TeamName = "codex-team",
  [Nullable[int]]$Teammates = $null,
  [ValidateSet("default", "light-report-only")]
  [string]$Profile = "default",
  [string]$ProjectRoot = (Get-Location).Path,
  [string]$RunsDir = ""
)

$ErrorActionPreference = "Stop"

if (-not $Teammates.HasValue) {
  if ($Profile -eq "light-report-only") {
    $Teammates = 2
  } else {
    $Teammates = 3
  }
}
if ($Teammates.Value -lt 1) {
  throw "Teammates must be >= 1"
}
$TeammateCount = [int]$Teammates.Value

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SetRoot = Split-Path -Parent $ScriptDir

if ([string]::IsNullOrWhiteSpace($RunsDir)) {
  $RunsDir = Join-Path $SetRoot "team_runs"
}

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$runId = "{0}-{1}" -f $TeamName, $stamp
$runRoot = Join-Path $RunsDir $runId

New-Item -ItemType Directory -Force -Path $runRoot | Out-Null
foreach ($dir in @("prompts", "logs", "mailbox", "reports", "state")) {
  New-Item -ItemType Directory -Force -Path (Join-Path $runRoot $dir) | Out-Null
}

$members = @()
for ($i = 1; $i -le $TeammateCount; $i++) {
  $memberId = "tm-{0:D2}" -f $i
  $memberRole = "teammate-{0:D2}" -f $i
  $members += [PSCustomObject]@{
    id = $memberId
    role = $memberRole
    model = "inherit"
  }
}

$tasks = @()
$tasks += [PSCustomObject]@{
  id = "T-000"
  title = "Finalize board and ownership"
  owner = "lead"
  status = "pending"
  depends_on = @()
  scope = "Split work and set explicit target_files for each teammate task."
  target_files = @()
  done_when = @(
    "Every teammate task has owner",
    "Target files are non-overlapping"
  )
  deliverable = "reports/T-000.md"
}

$n = 1
foreach ($member in $members) {
  $taskId = "T-{0:D3}" -f $n
  $isLight = $Profile -eq "light-report-only"
  $lightReportPath = "reports/{0}-{1}.md" -f $member.id, $taskId
  $scope = "<replace-with-task-scope>"
  $targetFiles = @("<set-target-file-for-$($member.id)>")
  $doneWhen = @(
    "Task objective met",
    "Deliverable report written"
  )
  if ($isLight) {
    $scope = "Analyze assigned area and produce report-only output without code changes."
    $targetFiles = @($lightReportPath)
    $doneWhen = @(
      "Report contains findings and actionable next steps",
      "No non-report files modified"
    )
  }

  $tasks += [PSCustomObject]@{
    id = $taskId
    title = if ($isLight) { "Light report task for $($member.id)" } else { "Work item for $($member.id)" }
    owner = $member.id
    status = "pending"
    depends_on = @("T-000")
    scope = $scope
    target_files = $targetFiles
    done_when = $doneWhen
    deliverable = if ($isLight) { $lightReportPath } else { "reports/$taskId.md" }
  }
  $n++
}

$board = [PSCustomObject]@{
  schema_version = "1.0"
  profile = $Profile
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
    no_recursive_subagents = $true
    no_target_file_overlap = $true
    lead_handles_cleanup = $true
    teammate_reports_required = $true
  }
}

$boardPath = Join-Path $runRoot "task_board.json"
$board | ConvertTo-Json -Depth 12 | Out-File -FilePath $boardPath -Encoding utf8

$leadTemplatePath = Join-Path $SetRoot "templates/team_lead_prompt_template.txt"
$leadPromptPath = Join-Path $runRoot "prompts/team_lead.txt"
$leadPrompt = Get-Content -Raw -LiteralPath $leadTemplatePath
$leadPrompt = $leadPrompt.Replace("<TEAM_NAME>", $TeamName)
$leadPrompt = $leadPrompt.Replace("<RUN_ID>", $runId)
$leadPrompt = $leadPrompt.Replace("<PROJECT_ROOT>", $ProjectRoot)
$leadPrompt = $leadPrompt.Replace("<TASK_BOARD_PATH>", $boardPath)
$leadPrompt = $leadPrompt.Replace("<MAILBOX_PATH>", (Join-Path $runRoot "mailbox"))
$leadPrompt | Out-File -FilePath $leadPromptPath -Encoding utf8

$runbook = @"
# Team Run $runId
Profile: $Profile
Teammates: $TeammateCount

1. Edit:
   $boardPath
2. Validate:
   powershell -ExecutionPolicy Bypass -File "$ScriptDir\validate_team_board.ps1" -BoardPath "$boardPath"
3. Render prompts:
   powershell -ExecutionPolicy Bypass -File "$ScriptDir\render_prompts_from_board.ps1" -BoardPath "$boardPath"
4. Run teammates:
   powershell -ExecutionPolicy Bypass -File "$ScriptDir\run_team_from_board.ps1" -BoardPath "$boardPath"

Logs: $(Join-Path $runRoot "logs")
Reports: $(Join-Path $runRoot "reports")
Mailbox: $(Join-Path $runRoot "mailbox")
"@

$runbookPath = Join-Path $runRoot "RUNBOOK.md"
$runbook | Out-File -FilePath $runbookPath -Encoding utf8

Write-Output $runRoot
Write-Output $boardPath
Write-Output $leadPromptPath
