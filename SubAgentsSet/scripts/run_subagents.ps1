param(
  [string]$ProjectRoot = (Get-Location).Path,
  [string]$PromptDir = "",
  [string]$LogsDir = "",
  [string]$CodexBinary = "codex",
  [string]$ApprovalMode = "never",
  [string]$SandboxMode = "workspace-write",
  [string]$SearchMode = "exec",
  [ValidateSet("Hidden", "Minimized", "Normal")]
  [string]$WindowStyle = "Normal"
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SetRoot = Split-Path -Parent $ScriptDir

if ([string]::IsNullOrWhiteSpace($PromptDir)) {
  $PromptDir = Join-Path $SetRoot "prompts"
}
if ([string]::IsNullOrWhiteSpace($LogsDir)) {
  $LogsDir = Join-Path $SetRoot "logs"
}

if (-not (Test-Path -LiteralPath $PromptDir)) {
  throw "Prompt directory not found: $PromptDir"
}
New-Item -ItemType Directory -Force -Path $LogsDir | Out-Null

$promptFiles = Get-ChildItem -LiteralPath $PromptDir -File -Filter *.txt |
  Where-Object { $_.BaseName -notmatch "^TEMPLATE" }

if (-not $promptFiles -or $promptFiles.Count -eq 0) {
  throw "No runnable prompt file found in: $PromptDir"
}

$jobs = @()
foreach ($pf in $promptFiles) {
  $name = $pf.BaseName
  $stdout = Join-Path $LogsDir ("{0}.out.txt" -f $name)
  $stderr = Join-Path $LogsDir ("{0}.err.txt" -f $name)

  # Run Codex in a separate process per prompt.
  $cmd = @"
Set-Location -LiteralPath '$ProjectRoot'
Get-Content -Raw -LiteralPath '$($pf.FullName)' | & '$CodexBinary' -a '$ApprovalMode' -s '$SandboxMode' --search '$SearchMode' -C '$ProjectRoot' -
"@

  $psArgs = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", $cmd)
  $proc = Start-Process -FilePath "powershell" -ArgumentList $psArgs -WindowStyle $WindowStyle -RedirectStandardOutput $stdout -RedirectStandardError $stderr -PassThru
  $jobs += [PSCustomObject]@{
    Name = $name
    Process = $proc
    StdOut = $stdout
    StdErr = $stderr
  }
}

$jobs | ForEach-Object { $_.Process | Wait-Process }
$jobs | ForEach-Object { Write-Output ("{0}:{1}:{2}" -f $_.Name, $_.Process.Id, $_.Process.ExitCode) }
