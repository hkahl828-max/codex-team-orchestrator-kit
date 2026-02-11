param(
  [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
  [string[]]$PromptPaths,
  [string]$ProjectRoot = (Get-Location).Path,
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

if ([string]::IsNullOrWhiteSpace($LogsDir)) {
  $LogsDir = Join-Path $SetRoot "logs"
}
New-Item -ItemType Directory -Force -Path $LogsDir | Out-Null

$jobs = @()
foreach ($pp in $PromptPaths) {
  $promptPath = if ([IO.Path]::IsPathRooted($pp)) { $pp } else { Join-Path $ProjectRoot $pp }
  if (-not (Test-Path -LiteralPath $promptPath)) { throw "Missing prompt file: $promptPath" }

  $name = [IO.Path]::GetFileNameWithoutExtension($promptPath)
  $stdout = Join-Path $LogsDir ("{0}.out.txt" -f $name)
  $stderr = Join-Path $LogsDir ("{0}.err.txt" -f $name)

  # Feed prompt via stdin to avoid argument splitting.
  $cmd = @"
Set-Location -LiteralPath '$ProjectRoot'
Get-Content -Raw -LiteralPath '$promptPath' | & '$CodexBinary' -a '$ApprovalMode' -s '$SandboxMode' --search '$SearchMode' -C '$ProjectRoot' -
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
