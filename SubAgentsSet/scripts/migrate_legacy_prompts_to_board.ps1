param(
  [string]$PromptDir = "",
  [string[]]$PromptPaths = @(),
  [Parameter(Mandatory = $true)]
  [string]$OutputBoardPath,
  [string]$TeamName = "legacy-prompts-team",
  [int]$Teammates = 2,
  [string]$ProjectRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

function Extract-Field {
  param(
    [string]$Text,
    [string]$Pattern
  )
  $m = [regex]::Match($Text, $Pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::Multiline)
  if ($m.Success -and $m.Groups.Count -gt 1) {
    return $m.Groups[1].Value.Trim()
  }
  return ""
}

if ($Teammates -lt 1) {
  throw "Teammates must be >= 1"
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SetRoot = Split-Path -Parent $ScriptDir
if ([string]::IsNullOrWhiteSpace($PromptDir)) {
  $PromptDir = Join-Path $SetRoot "prompts"
}

$resolvedPromptPaths = @()
if ($PromptPaths.Count -gt 0) {
  foreach ($p in $PromptPaths) {
    $candidate = if ([IO.Path]::IsPathRooted($p)) { $p } else { Join-Path (Get-Location).Path $p }
    if (-not (Test-Path -LiteralPath $candidate)) {
      throw "Missing prompt file: $candidate"
    }
    $resolvedPromptPaths += (Resolve-Path $candidate).Path
  }
} else {
  if (-not (Test-Path -LiteralPath $PromptDir)) {
    throw "Prompt directory not found: $PromptDir"
  }
  $resolvedPromptPaths = @(
    Get-ChildItem -LiteralPath $PromptDir -File -Filter *.txt |
      Where-Object { $_.BaseName -notmatch "^TEMPLATE" } |
      Sort-Object Name |
      ForEach-Object { $_.FullName }
  )
}

if ($resolvedPromptPaths.Count -eq 0) {
  throw "No legacy prompts found."
}

$members = @()
for ($i = 1; $i -le $Teammates; $i++) {
  $memberId = "tm-{0:D2}" -f $i
  $members += [PSCustomObject]@{
    id = $memberId
    role = "migrated-worker-{0:D2}" -f $i
    model = "inherit"
  }
}

$tasks = @()
$tasks += [PSCustomObject]@{
  id = "T-000"
  title = "Review migrated legacy prompts and finalize ownership"
  owner = "lead"
  status = "pending"
  depends_on = @()
  scope = "Validate migrated tasks before execution."
  target_files = @()
  done_when = @(
    "All migrated tasks reviewed",
    "No target file overlaps"
  )
  deliverable = "reports/T-000.md"
}

$taskIndex = 1
$memberIndex = 0
foreach ($promptPath in $resolvedPromptPaths) {
  $text = Get-Content -Raw -LiteralPath $promptPath
  $taskId = "T-{0:D3}" -f $taskIndex
  $owner = $members[$memberIndex % $members.Count].id
  $memberIndex++

  $targetFile = Extract-Field -Text $text -Pattern "^Create ONLY the file\s+(.+?)\.\s*$"
  if ([string]::IsNullOrWhiteSpace($targetFile)) {
    $targetFile = "reports/{0}.md" -f $taskId
  }
  $topic = Extract-Field -Text $text -Pattern "^Topic:\s*(.+)\s*$"
  if ([string]::IsNullOrWhiteSpace($topic)) {
    $topic = [IO.Path]::GetFileNameWithoutExtension($promptPath)
  }
  $sourceHint = Extract-Field -Text $text -Pattern "^(Use primary sources.+|Prefer authoritative sources.+)\s*$"
  if ([string]::IsNullOrWhiteSpace($sourceHint)) {
    $sourceHint = "Use authoritative sources relevant to the topic."
  }

  $tasks += [PSCustomObject]@{
    id = $taskId
    title = "Migrated task: $topic"
    owner = $owner
    status = "pending"
    depends_on = @("T-000")
    scope = "$topic. $sourceHint"
    target_files = @($targetFile)
    done_when = @(
      "Task objective met",
      "Requested sections included",
      "Deliverable report written"
    )
    deliverable = "reports/$taskId.md"
  }

  $taskIndex++
}

$board = [PSCustomObject]@{
  schema_version = "1.0"
  profile = "legacy-prompt-migration"
  team_name = $TeamName
  run_id = "$TeamName-migrated"
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
  metadata = [PSCustomObject]@{
    migrated_from = $resolvedPromptPaths
  }
}

$outDir = Split-Path -Parent $OutputBoardPath
if (-not (Test-Path -LiteralPath $outDir)) {
  New-Item -ItemType Directory -Force -Path $outDir | Out-Null
}
$board | ConvertTo-Json -Depth 16 | Out-File -FilePath $OutputBoardPath -Encoding utf8

Write-Output $OutputBoardPath
