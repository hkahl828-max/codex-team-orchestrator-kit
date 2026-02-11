param(
  [Parameter(Mandatory = $true)]
  [string]$BoardPath,
  [string]$ProjectRoot = "",
  [string]$LogsDir = "",
  [switch]$SkipValidation
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $BoardPath)) {
  throw "Task board not found: $BoardPath"
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$validateScript = Join-Path $ScriptDir "validate_team_board.ps1"
$renderScript = Join-Path $ScriptDir "render_prompts_from_board.ps1"
$runScript = Join-Path $ScriptDir "run_subagents_from_prompts.ps1"

$board = Get-Content -Raw -LiteralPath $BoardPath | ConvertFrom-Json

if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
  if ($board.project_root) {
    $ProjectRoot = [string]$board.project_root
  } else {
    $ProjectRoot = (Get-Location).Path
  }
}

if ([string]::IsNullOrWhiteSpace($LogsDir)) {
  $LogsDir = Join-Path (Split-Path -Parent $BoardPath) "logs"
}

if (-not $SkipValidation) {
  & $validateScript -BoardPath $BoardPath
}

$promptPaths = @(& $renderScript -BoardPath $BoardPath)
if ($promptPaths.Count -eq 0) {
  throw "No prompts generated from board: $BoardPath"
}

& $runScript @promptPaths -ProjectRoot $ProjectRoot -LogsDir $LogsDir
