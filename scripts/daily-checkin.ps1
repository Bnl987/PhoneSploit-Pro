param(
    [string]$Summary
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

if (-not (Test-Path '.git')) {
    throw 'Run this script inside a git repository.'
}

if ([string]::IsNullOrWhiteSpace($Summary)) {
    $Summary = Read-Host 'What did you actually work on today?'
}

if ([string]::IsNullOrWhiteSpace($Summary)) {
    throw 'Summary is required. Aborting to avoid empty/noise commits.'
}

$today = Get-Date -Format 'yyyy-MM-dd'
$entry = "- $Summary"

if (-not (Test-Path 'DAILY_LOG.md')) {
    @"
# Daily Work Log

Use this file for short, real updates about what you built, fixed, learned, or reviewed.
"@ | Set-Content -Path 'DAILY_LOG.md' -Encoding UTF8
}

$logText = Get-Content 'DAILY_LOG.md' -Raw
if ($logText -notmatch "(?m)^## $today\r?$") {
    Add-Content 'DAILY_LOG.md' "`n## $today"
}
Add-Content 'DAILY_LOG.md' $entry

git add DAILY_LOG.md
$commitMessage = "docs: daily update $today"
git commit -m $commitMessage | Out-Host

Write-Host "Committed: $commitMessage"
Write-Host 'Next: run git push origin main'
