param(
  [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
  [string[]]$PromptPaths
)

$ErrorActionPreference = "Stop"

$Root = (Get-Location).Path
New-Item -ItemType Directory -Force -Path (Join-Path $Root "subagent_logs") | Out-Null

$procs = @()
foreach ($pp in $PromptPaths) {
  $promptPath = Join-Path $Root $pp
  if (-not (Test-Path $promptPath)) { throw "Missing prompt file: $promptPath" }

  $name = [IO.Path]::GetFileNameWithoutExtension($promptPath)
  $stdout = Join-Path $Root ("subagent_logs/{0}.out.txt" -f $name)
  $stderr = Join-Path $Root ("subagent_logs/{0}.err.txt" -f $name)

  # Feed prompt via stdin to avoid argument splitting. Run in separate PowerShell process.
  $cmd = @"
Set-Location -LiteralPath '$Root'
Get-Content -Raw -LiteralPath '$promptPath' | codex -a never -s workspace-write --search exec -C '$Root' -
"@

  $psArgs = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", $cmd)
  $procs += Start-Process -FilePath "powershell" -ArgumentList $psArgs -WindowStyle Normal -RedirectStandardOutput $stdout -RedirectStandardError $stderr -PassThru
}

$procs | ForEach-Object { $_ | Wait-Process }
$procs | ForEach-Object { Write-Output ("{0}:{1}" -f $_.Id, $_.ExitCode) }
