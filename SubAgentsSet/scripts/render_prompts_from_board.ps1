param(
  [Parameter(Mandatory = $true)]
  [string]$BoardPath,
  [string]$TemplatePath = "",
  [string]$OutputDir = ""
)

$ErrorActionPreference = "Stop"

function To-StringArray {
  param([object]$Value)
  if ($null -eq $Value) { return @() }
  if ($Value -is [System.Array]) { return @($Value | ForEach-Object { [string]$_ }) }
  return @([string]$Value)
}

function To-BulletList {
  param(
    [object]$Value,
    [string]$Fallback = "<none>"
  )
  $items = @()
  foreach ($item in (To-StringArray $Value)) {
    $clean = $item.Trim()
    if (-not [string]::IsNullOrWhiteSpace($clean)) {
      $items += $clean
    }
  }
  if ($items.Count -eq 0) {
    return "- $Fallback"
  }
  return (($items | ForEach-Object { "- $_" }) -join "`n")
}

if (-not (Test-Path -LiteralPath $BoardPath)) {
  throw "Task board not found: $BoardPath"
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SetRoot = Split-Path -Parent $ScriptDir

if ([string]::IsNullOrWhiteSpace($TemplatePath)) {
  $TemplatePath = Join-Path $SetRoot "templates/teammate_prompt_template.txt"
}
if ([string]::IsNullOrWhiteSpace($OutputDir)) {
  $OutputDir = Join-Path (Split-Path -Parent $BoardPath) "prompts/generated"
}

if (-not (Test-Path -LiteralPath $TemplatePath)) {
  throw "Template not found: $TemplatePath"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$board = Get-Content -Raw -LiteralPath $BoardPath | ConvertFrom-Json
$template = Get-Content -Raw -LiteralPath $TemplatePath

$leadId = "lead"
if ($board.lead -and $board.lead.id) {
  $leadId = [string]$board.lead.id
}

$roleById = @{}
foreach ($member in @($board.members)) {
  if ($member.id) {
    $roleById[[string]$member.id] = [string]$member.role
  }
}

$rendered = @()
foreach ($task in @($board.tasks)) {
  $taskId = [string]$task.id
  $owner = [string]$task.owner
  $status = ([string]$task.status).ToLowerInvariant()

  if ([string]::IsNullOrWhiteSpace($owner)) { continue }
  if ($owner -eq $leadId) { continue }
  if ($status -eq "completed") { continue }

  $role = "teammate"
  if ($roleById.ContainsKey($owner)) {
    $role = $roleById[$owner]
  }

  $prompt = $template
  $prompt = $prompt.Replace("<TEAM_NAME>", [string]$board.team_name)
  $prompt = $prompt.Replace("<RUN_ID>", [string]$board.run_id)
  $prompt = $prompt.Replace("<PROJECT_ROOT>", [string]$board.project_root)
  $prompt = $prompt.Replace("<TEAMMATE_ID>", $owner)
  $prompt = $prompt.Replace("<TEAMMATE_ROLE>", $role)
  $prompt = $prompt.Replace("<TASK_ID>", $taskId)
  $prompt = $prompt.Replace("<TASK_TITLE>", [string]$task.title)
  $prompt = $prompt.Replace("<TASK_SCOPE>", [string]$task.scope)
  $prompt = $prompt.Replace("<DEPENDENCIES>", (To-BulletList -Value $task.depends_on -Fallback "<none>"))
  $prompt = $prompt.Replace("<TARGET_FILES>", (To-BulletList -Value $task.target_files -Fallback "<set-target-file>"))
  $prompt = $prompt.Replace("<DELIVERABLE_PATH>", [string]$task.deliverable)
  $prompt = $prompt.Replace("<DONE_WHEN>", (To-BulletList -Value $task.done_when -Fallback "<done-check>"))
  $prompt = $prompt.Replace("<TASK_BOARD_PATH>", $BoardPath)
  $prompt = $prompt.Replace("<MAILBOX_PATH>", (Join-Path (Split-Path -Parent $BoardPath) "mailbox"))

  $safeName = ("{0}_{1}.txt" -f $taskId, $owner) -replace "[^a-zA-Z0-9._-]", "_"
  $promptPath = Join-Path $OutputDir $safeName
  $prompt | Out-File -FilePath $promptPath -Encoding utf8
  $rendered += $promptPath
}

if ($rendered.Count -eq 0) {
  throw "No teammate prompts rendered. Check task owners/status in board."
}

$rendered | ForEach-Object { Write-Output $_ }
