#Requires -Version 5.1
<#
.SYNOPSIS
  Generate local social-media post copy for Pixaroma shorts, photos, and stories.

.EXAMPLE
  .\shorts-post.ps1 --type short --topic "golden retriever surfing at sunset"
  .\shorts-post.ps1 --type photo --topic "coffee shop portrait" --platform instagram
  .\shorts-post.ps1 --brief brief.txt --media out\clip.mp4 --ollama
#>
$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$script = Join-Path $scriptDir 'shorts_post.py'

$py = Get-Command py -ErrorAction SilentlyContinue
if ($py) {
    & py -3 -I $script @args
    exit $LASTEXITCODE
}
$python = Get-Command python -ErrorAction SilentlyContinue
if ($python) {
    & python -I $script @args
    exit $LASTEXITCODE
}
Write-Host 'error: Python 3.9+ is required (python or py launcher not found)' -ForegroundColor Red
exit 2
