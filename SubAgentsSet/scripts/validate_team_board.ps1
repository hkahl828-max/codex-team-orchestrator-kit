param(
  [Parameter(Mandatory = $true)]
  [string]$BoardPath
)

$ErrorActionPreference = "Stop"

function To-StringArray {
  param([object]$Value)
  if ($null -eq $Value) { return @() }
  if ($Value -is [System.Array]) {
    return @($Value | ForEach-Object { [string]$_ })
  }
  return @([string]$Value)
}

if (-not (Test-Path -LiteralPath $BoardPath)) {
  throw "Task board not found: $BoardPath"
}

try {
  $board = Get-Content -Raw -LiteralPath $BoardPath | ConvertFrom-Json
} catch {
  throw "Invalid JSON in board file: $BoardPath"
}

$errors = @()
$warnings = @()

if (-not $board.tasks -or @($board.tasks).Count -eq 0) {
  $errors += "Board has no tasks."
}

$leadId = "lead"
if ($board.lead -and $board.lead.id) {
  $leadId = [string]$board.lead.id
}

$memberIds = @($leadId)
foreach ($member in @($board.members)) {
  if ($member.id) {
    $memberIds += [string]$member.id
  }
}
$memberIds = $memberIds | Sort-Object -Unique

$taskIds = @{}
foreach ($task in @($board.tasks)) {
  $taskId = [string]$task.id
  if ([string]::IsNullOrWhiteSpace($taskId)) {
    $errors += "Task with empty id detected."
    continue
  }
  if ($taskIds.ContainsKey($taskId)) {
    $errors += "Duplicate task id: $taskId"
    continue
  }
  $taskIds[$taskId] = $true

  $owner = [string]$task.owner
  if ([string]::IsNullOrWhiteSpace($owner)) {
    $errors += "Task $taskId has no owner."
  } elseif ($memberIds -notcontains $owner) {
    $errors += "Task $taskId owner '$owner' is not in lead/members."
  }

  foreach ($dep in (To-StringArray $task.depends_on)) {
    if ($dep -eq $taskId) {
      $errors += "Task $taskId cannot depend on itself."
    }
  }

  if ($owner -ne $leadId -and (To-StringArray $task.target_files).Count -eq 0) {
    $warnings += "Task $taskId has no target_files. Use report-only scope explicitly if intended."
  }
}

foreach ($task in @($board.tasks)) {
  $taskId = [string]$task.id
  foreach ($dep in (To-StringArray $task.depends_on)) {
    if (-not $taskIds.ContainsKey($dep)) {
      $errors += "Task $taskId depends on missing task '$dep'."
    }
  }
}

$pathToTask = @{}
foreach ($task in @($board.tasks)) {
  $taskId = [string]$task.id
  $status = ([string]$task.status).ToLowerInvariant()
  if ($status -eq "completed") {
    continue
  }

  foreach ($target in (To-StringArray $task.target_files)) {
    $clean = $target.Trim()
    if ([string]::IsNullOrWhiteSpace($clean)) {
      continue
    }
    if ($clean.StartsWith("<") -and $clean.EndsWith(">")) {
      continue
    }
    if ($pathToTask.ContainsKey($clean)) {
      $errors += "Target file overlap '$clean' between tasks $($pathToTask[$clean]) and $taskId."
    } else {
      $pathToTask[$clean] = $taskId
    }
  }
}

foreach ($warning in $warnings) {
  Write-Warning $warning
}

if ($errors.Count -gt 0) {
  foreach ($errorLine in $errors) {
    Write-Error $errorLine
  }
  exit 1
}

Write-Output "OK: board is valid ($(@($board.tasks).Count) tasks, $(@($memberIds).Count) members including lead)."
