param(
  [string]$Root = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

New-Item -ItemType Directory -Force -Path (Join-Path $Root "subagent_logs") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $Root "subagent_prompts") | Out-Null

$jobs = @(
  @{
    Name = "internal_linking"
    PromptPath = (Join-Path $Root "subagent_prompts/internal_linking.txt")
    Stdout = (Join-Path $Root "subagent_logs/internal_linking.out.txt")
    Stderr = (Join-Path $Root "subagent_logs/internal_linking.err.txt")
  },
  @{
    Name = "snippets_meta"
    PromptPath = (Join-Path $Root "subagent_prompts/snippets_meta.txt")
    Stdout = (Join-Path $Root "subagent_logs/snippets_meta.out.txt")
    Stderr = (Join-Path $Root "subagent_logs/snippets_meta.err.txt")
  },
  @{
    Name = "sitemaps_robots"
    PromptPath = (Join-Path $Root "subagent_prompts/sitemaps_robots.txt")
    Stdout = (Join-Path $Root "subagent_logs/sitemaps_robots.out.txt")
    Stderr = (Join-Path $Root "subagent_logs/sitemaps_robots.err.txt")
  }
)

$procs = @()
foreach ($j in $jobs) {
  if (-not (Test-Path $j.PromptPath)) {
    throw "Missing prompt file: $($j.PromptPath)"
  }

  # Run Codex as a separate process (sub-agent). Pass the prompt via stdin to avoid argument splitting.
  # Note: `--search`, `-a`, `-s`, `-C` are global flags and must precede `exec`.
  $cmd = @"
Set-Location -LiteralPath '$Root'
Get-Content -Raw -LiteralPath '$($j.PromptPath)' | codex -a never -s workspace-write --search exec -C '$Root' -
"@

  $psArgs = @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-Command", $cmd
  )

  $procs += Start-Process -FilePath "powershell" -ArgumentList $psArgs -WindowStyle Normal -RedirectStandardOutput $j.Stdout -RedirectStandardError $j.Stderr -PassThru
}

$procs | ForEach-Object { $_ | Wait-Process }
$procs | ForEach-Object { Write-Output ("{0}:{1}" -f $_.Id, $_.ExitCode) }
