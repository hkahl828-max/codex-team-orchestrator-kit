param(
  [Parameter(Mandatory = $true)]
  [string]$CsvPath,
  [string]$OutputDir = "",
  [string]$TemplatePath = ""
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $CsvPath)) {
  throw "CSV file not found: $CsvPath"
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SetRoot = Split-Path -Parent $ScriptDir

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
  $OutputDir = Join-Path $SetRoot "prompts/generated"
}
if ([string]::IsNullOrWhiteSpace($TemplatePath)) {
  $TemplatePath = Join-Path $SetRoot "prompts/TEMPLATE_subagent_prompt.txt"
}
if (-not (Test-Path -LiteralPath $TemplatePath)) {
  throw "Template not found: $TemplatePath"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$template = Get-Content -Raw -LiteralPath $TemplatePath
$rows = Import-Csv -LiteralPath $CsvPath
if (-not $rows -or $rows.Count -eq 0) {
  throw "CSV has no rows: $CsvPath"
}

$paths = @()
foreach ($row in $rows) {
  $taskId = [string]$row.task_id
  if ([string]::IsNullOrWhiteSpace($taskId)) {
    throw "Missing task_id in CSV row."
  }

  $goal = [string]$row.goal
  if ([string]::IsNullOrWhiteSpace($goal)) {
    $goal = "Complete assigned task."
  }

  $targetFile = [string]$row.target_file
  if ([string]::IsNullOrWhiteSpace($targetFile)) {
    $targetFile = "reports/$taskId.md"
  }

  $deliverable = [string]$row.deliverable
  if ([string]::IsNullOrWhiteSpace($deliverable)) {
    $deliverable = "reports/$taskId.md"
  }

  $sourceItems = @()
  $rawSources = [string]$row.sources
  if (-not [string]::IsNullOrWhiteSpace($rawSources)) {
    $sourceItems = $rawSources.Split(";") | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
  }
  if ($sourceItems.Count -eq 0) {
    $sourceItems = @("<PRIMARY_SOURCE_1>", "<PRIMARY_SOURCE_2>")
  }

  $prompt = $template
  $prompt = $prompt.Replace("<TASK_ID>", $taskId)
  $prompt = $prompt.Replace("<ONE_CLEAR_GOAL>", $goal)
  $prompt = $prompt.Replace("<TARGET_FILE_1>", $targetFile)
  $prompt = $prompt.Replace("<TARGET_FILE_2>", $deliverable)
  $source2 = $sourceItems[0]
  if ($sourceItems.Count -gt 1) {
    $source2 = $sourceItems[1]
  }

  $prompt = $prompt.Replace("<PRIMARY_SOURCE_1>", $sourceItems[0])
  $prompt = $prompt.Replace("<PRIMARY_SOURCE_2>", $source2)
  $prompt = $prompt.Replace("<DELIVERABLE_PATH>", $deliverable)

  $outPath = Join-Path $OutputDir ("{0}.txt" -f $taskId)
  $prompt | Out-File -FilePath $outPath -Encoding utf8
  $paths += $outPath
}

$paths | ForEach-Object { Write-Output $_ }
