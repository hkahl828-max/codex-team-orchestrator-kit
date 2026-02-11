param(
  [string]$TeamName = "light-team",
  [string]$ProjectRoot = (Get-Location).Path,
  [string]$RunsDir = ""
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$bootstrapScript = Join-Path $ScriptDir "bootstrap_team_run.ps1"

& $bootstrapScript `
  -TeamName $TeamName `
  -Profile "light-report-only" `
  -Teammates 2 `
  -ProjectRoot $ProjectRoot `
  -RunsDir $RunsDir
