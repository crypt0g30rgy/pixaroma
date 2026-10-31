#Requires -Version 5.1
<#
.SYNOPSIS
  Install Pixaroma workflow packs and the exact models those workflows load.

.DESCRIPTION
  Reads models.psv (generated from every workflow JSON) and downloads only the
  files that are missing. Existing files are never downloaded again unless
  -ForceModels is given. Workflow packs are extracted from .\archives into
  ComfyUI\user\default\workflows\Pixaroma.

  Paths can be saved once by install-comfyui.ps1 in pixaroma.conf; command-line
  flags override the saved values.

.EXAMPLE
  .\setup.ps1 workflows
  .\setup.ps1 models --episode 6
  .\setup.ps1 all --episode 25 --dry-run
  .\setup.ps1 models --all --yes
  .\setup.ps1 list --episode 39

.NOTES
  Requires the Hugging Face CLI for downloads: pip install -U "huggingface_hub[cli]"
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('workflows', 'models', 'all', 'list')]
    [string]$Target,

    [string[]]$Episode = @(),

    [switch]$All,

    [string]$ComfyUI,

    [string]$ModelsRoot,

    [switch]$DryRun,

    [switch]$Yes,

    [switch]$Verify,

    [switch]$ForceModels,

    [switch]$ForceWorkflows,

    [switch]$AllZip
)

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$manifest = Join-Path $scriptDir 'models.psv'
$confPath = Join-Path $scriptDir 'pixaroma.conf'
$isWindowsHost = ($env:OS -eq 'Windows_NT')

function Fail([string]$Message) {
    Write-Host "error: $Message" -ForegroundColor Red
    exit 2
}

function Format-Human([int64]$Bytes) {
    if ($Bytes -ge 1000000000000) { return ('{0:N2} TB' -f ($Bytes / 1e12)) }
    if ($Bytes -ge 1000000000) { return ('{0:N2} GB' -f ($Bytes / 1e9)) }
    if ($Bytes -ge 1000000) { return ('{0:N2} MB' -f ($Bytes / 1e6)) }
    if ($Bytes -ge 1000) { return ('{0:N1} KB' -f ($Bytes / 1e3)) }
    return "$Bytes B"
}

function Read-PixaromaConf {
    $values = @{}
    if (Test-Path -LiteralPath $confPath) {
        foreach ($line in Get-Content -LiteralPath $confPath) {
            if ($line -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$') {
                $values[$Matches[1]] = $Matches[2].Trim()
            }
        }
    }
    return $values
}

function Normalize-Episodes {
    param([string[]]$Values)
    $set = New-Object System.Collections.Generic.List[string]
    foreach ($value in $Values) {
        foreach ($part in ($value -split '[, ]+')) {
            if (-not $part) { continue }
            $m = [regex]::Match($part, '^(?i)(?:ep)?0*(\d+)$')
            if (-not $m.Success) { Fail "invalid episode: $part" }
            $n = [int]$m.Groups[1].Value
            $key = $n.ToString('00')
            if (-not $set.Contains($key)) { $set.Add($key) }
        }
    }
    return $set.ToArray()
}

function Test-RowSelected {
    param($Row, [string[]]$SelectedEpisodes, [bool]$AllEpisodes)
    if ($AllEpisodes) { return $true }
    if (-not $SelectedEpisodes -or $SelectedEpisodes.Count -eq 0) { return $false }
    foreach ($ep in ($Row.episodes -split ',')) {
        if ($SelectedEpisodes -contains $ep) { return $true }
    }
    return $false
}

function Test-ComfyDir {
    param([string]$Path)
    if (-not $Path) { return $null }
    if ((Split-Path -Leaf $Path) -eq 'models') { $Path = Split-Path -Parent $Path }
    if (Test-Path -LiteralPath (Join-Path $Path 'models') -PathType Container) {
        return (Resolve-Path -LiteralPath $Path).Path
    }
    return $null
}

function Find-ComfyUI {
    $candidates = New-Object System.Collections.Generic.List[string]
    if ($ComfyUI) { $candidates.Add($ComfyUI) }
    if ($env:COMFYUI_DIR) { $candidates.Add($env:COMFYUI_DIR) }
    $saved = Read-PixaromaConf
    if ($saved.ContainsKey('COMFYUI') -and $saved['COMFYUI']) { $candidates.Add($saved['COMFYUI']) }
    $roots = @($scriptDir, (Join-Path $scriptDir '..'), $PWD.Path, (Join-Path $PWD.Path '..'), $HOME)
    foreach ($root in $roots) {
        $candidates.Add((Join-Path $root 'ComfyUI'))
        $candidates.Add((Join-Path $root 'ComfyUI_windows_portable\ComfyUI'))
        $candidates.Add((Join-Path $root 'ComfyUI\ComfyUI'))
        $candidates.Add((Join-Path $root 'ComfyUI-Easy-Install\ComfyUI'))
        $candidates.Add((Join-Path $root 'AI\ComfyUI'))
        $candidates.Add((Join-Path $root 'AI\ComfyUI_windows_portable\ComfyUI'))
    }
    foreach ($candidate in $candidates) {
        if (-not $candidate) { continue }
        $resolved = Test-ComfyDir -Path $candidate
        if ($resolved) { return $resolved }
    }
    return $null
}

function Get-FreeOrThrow {
    param([string]$Path)
    $drive = [IO.Path]::GetPathRoot($Path)
    if (-not $drive) { return }
    try {
        $d = Get-PSDrive -Name $drive.Substring(0, 1) -ErrorAction Stop
        if ($null -ne $d.Free) { Write-Host ("   free space: {0}" -f (Format-Human $d.Free)) }
    } catch { }
}

# ------------------------------------------------------------------ validation
if (-not $Target) {
    Write-Host 'Usage: .\setup.ps1 <workflows|models|all|list> [options]'
    Write-Host 'Run .\setup.ps1 list to see the model catalog; see README.md for all options.'
    exit 2
}
if (-not (Test-Path -LiteralPath $manifest)) { Fail "models.psv not found next to this script" }

$selectedEpisodes = @(Normalize-Episodes -Values $Episode)
if ($All -and $selectedEpisodes.Count -gt 0) { Fail 'use -Episode or -All, not both' }
if ($AllZip -and $selectedEpisodes.Count -gt 0) { Fail '-AllZip extracts the aggregate pack; it cannot be filtered by episode' }
if ($Target -eq 'models' -and -not $All -and $selectedEpisodes.Count -eq 0) {
    Fail 'models needs -Episode N (repeatable) or -All'
}
if ($Target -eq 'all' -and -not $All -and $selectedEpisodes.Count -eq 0) {
    Fail 'all needs -Episode N (repeatable) or -All'
}
if ($Verify -and $Target -ne 'models') {
    Fail '-Verify is only supported with the models target'
}
if ($Verify -and $ForceModels) {
    Fail '-Verify cannot be combined with -ForceModels'
}

$rows = @(Import-Csv -LiteralPath $manifest -Delimiter '|')
if ($rows.Count -eq 0) { Fail 'models.psv is empty' }
if (-not ($rows[0].PSObject.Properties.Name -contains 'folder')) { Fail 'models.psv has an unexpected header' }

# list defaults to everything when no episode filter is given
$listAll = ($Target -eq 'list' -and -not $All -and $selectedEpisodes.Count -eq 0)

# --------------------------------------------------------------------- paths
$comfy = $null
if ($Target -ne 'list' -or $ComfyUI) {
    $comfy = Find-ComfyUI
    if ($ComfyUI -and -not $comfy) {
        Fail "$ComfyUI does not look like a ComfyUI folder (no models\ inside)"
    }
}
if (($Target -eq 'workflows' -or $Target -eq 'all') -and -not $comfy) {
    Fail 'ComfyUI not found. Pass -ComfyUI C:\path\to\ComfyUI'
}
if ($Target -eq 'models' -and -not $comfy -and -not $ModelsRoot) {
    $saved = Read-PixaromaConf
    if ($saved.ContainsKey('MODELS_ROOT') -and $saved['MODELS_ROOT']) { $ModelsRoot = $saved['MODELS_ROOT'] }
}
if (-not $ModelsRoot -and $comfy) { $ModelsRoot = Join-Path $comfy 'models' }
if ($Target -eq 'models' -and -not $ModelsRoot) {
    Fail 'models needs -ModelsRoot D:\AI\models (or a ComfyUI install)'
}
if ($ModelsRoot) { $ModelsRoot = [IO.Path]::GetFullPath($ModelsRoot) }

# ----------------------------------------------------------------- work flows
function Expand-ZipSafe {
    param([string]$ZipPath, [string]$DestRoot, [switch]$Overwrite)
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $rootFull = [IO.Path]::GetFullPath($DestRoot).TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
    $archive = [IO.Compression.ZipFile]::OpenRead($ZipPath)
    $written = 0
    $skipped = 0
    try {
        foreach ($entry in $archive.Entries) {
            if ([string]::IsNullOrEmpty($entry.Name)) { continue }
            $rel = $entry.FullName -replace '\\', '/'
            if ($rel.StartsWith('/') -or $rel -match '^[A-Za-z]:' -or $rel -match '(^|/)\.\.(/|$)') {
                Write-Host "   warning: skipped unsafe zip entry: $rel" -ForegroundColor Yellow
                continue
            }
            $dest = Join-Path $DestRoot $rel
            $full = [IO.Path]::GetFullPath($dest)
            if (-not $full.StartsWith($rootFull, [StringComparison]::OrdinalIgnoreCase)) {
                Write-Host "   warning: skipped zip entry outside target: $rel" -ForegroundColor Yellow
                continue
            }
            if ($DryRun) {
                Write-Host "   [dry-run] $rel"
                $written++
                continue
            }
            $parent = Split-Path -Parent $full
            if (-not (Test-Path -LiteralPath $parent)) {
                New-Item -ItemType Directory -Force -Path $parent | Out-Null
            }
            if ((Test-Path -LiteralPath $full) -and -not $Overwrite) {
                $skipped++
                continue
            }
            [IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $full, $true)
            if (-not $isWindowsHost) {
                # .NET can inherit the zip's Windows attributes as a bogus Unix
                # mode (observed as --x------); give extracted data files 0644.
                try {
                    [IO.File]::SetUnixFileMode($full,
                        [IO.UnixFileMode]::UserRead -bor [IO.UnixFileMode]::UserWrite -bor
                        [IO.UnixFileMode]::GroupRead -bor [IO.UnixFileMode]::OtherRead)
                } catch { }
            }
            $written++
        }
    } finally {
        $archive.Dispose()
    }
    return @{ Written = $written; Skipped = $skipped }
}

function Get-ZipEpisode {
    param([string]$Name)
    $m = [regex]::Match($Name, '^(?i)ep0*(\d+)[^0-9]')
    if (-not $m.Success) { return $null }
    $n = [int]$m.Groups[1].Value
    return $n.ToString('00')
}

function Install-Workflows {
    Write-Host "`n== Workflows ==" -ForegroundColor Cyan
    $wfRoot = Join-Path (Join-Path (Join-Path $comfy 'user') 'default') 'workflows'
    $wfRoot = Join-Path $wfRoot 'Pixaroma'
    $archives = Join-Path $scriptDir 'archives'
    if (-not (Test-Path -LiteralPath $archives)) { $archives = $scriptDir }
    if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $wfRoot | Out-Null }

    $zips = @()
    if ($AllZip) {
        $zip = Join-Path $archives 'all-workflows.zip'
        if (-not (Test-Path -LiteralPath $zip)) { Fail "all-workflows.zip not found in $archives" }
        $zips = @($zip)
    } else {
        foreach ($zip in Get-ChildItem -LiteralPath $archives -Filter '*.zip' -File) {
            if ($zip.Name -eq 'all-workflows.zip') { continue }
            $ep = Get-ZipEpisode -Name $zip.Name
            if (-not $ep) { continue }
            if ($selectedEpisodes.Count -gt 0 -and -not ($selectedEpisodes -contains $ep)) { continue }
            $zips += $zip
        }
    }
    if ($zips.Count -eq 0) { Fail "no matching workflow zips found in $archives" }

    $before = 0
    if (-not $DryRun -and (Test-Path -LiteralPath $wfRoot)) {
        $before = @(Get-ChildItem -LiteralPath $wfRoot -Filter '*.json' -Recurse -ErrorAction SilentlyContinue).Count
    }
    foreach ($zip in $zips) {
        Write-Host "   $($zip.Name)" -NoNewline
        if ($DryRun) {
            $r = Expand-ZipSafe -ZipPath $zip.FullName -DestRoot $wfRoot -Overwrite:$ForceWorkflows
            Write-Host " -> $($r.Written) entries"
        } else {
            $r = Expand-ZipSafe -ZipPath $zip.FullName -DestRoot $wfRoot -Overwrite:$ForceWorkflows
            Write-Host " -> $($r.Written) written, $($r.Skipped) existing kept"
        }
    }
    if (-not $DryRun) {
        $after = @(Get-ChildItem -LiteralPath $wfRoot -Filter '*.json' -Recurse -ErrorAction SilentlyContinue).Count
        Write-Host "   destination: $wfRoot"
        Write-Host "   JSON files now: $after"
        if (-not $ForceWorkflows) {
            Write-Host '   existing workflow files were kept (use -ForceWorkflows to overwrite)'
        }
    }
}

if ($Target -eq 'workflows' -or $Target -eq 'all') {
    Install-Workflows
}
if ($Target -eq 'workflows') { exit 0 }

# --------------------------------------------------------------------- listing
if ($Target -eq 'list') {
    $header = '{0,10}  {1,-68}  {2,-20}  {3}' -f 'SIZE', 'FOLDER/FILE', 'EPISODES', 'SOURCE'
    Write-Host $header
    [int64]$total = 0
    $count = 0
    $manual = 0
    foreach ($row in $rows) {
        if (-not (Test-RowSelected -Row $row -SelectedEpisodes $selectedEpisodes -AllEpisodes:($All -or $listAll))) { continue }
        $count++
        if ($row.repo -eq '-') {
            $size = 'manual'
            $src = 'manual'
            $manual++
        } else {
            [int64]$bytes = [int64]$row.bytes
            $total += $bytes
            $size = Format-Human $bytes
            $src = $row.repo
            if ($row.gated -eq 'yes') { $src = "$src (gated)" }
        }
        $name = "$($row.folder)/$($row.filename)"
        Write-Host ('{0,10}  {1,-68}  {2,-20}  {3}' -f $size, $name, $row.episodes, $src)
    }
    Write-Host ''
    Write-Host ("{0} files selected, {1} downloadable{2}." -f $count, (Format-Human $total), $(if ($manual -gt 0) { ", $manual manual" } else { '' }))
    exit 0
}

# ---------------------------------------------------------------------- models
if (-not $DryRun -and -not $Verify -and -not (Get-Command hf -ErrorAction SilentlyContinue)) {
    Fail 'the hf CLI is not installed. Run: pip install -U "huggingface_hub[cli]"'
}

$selected = @($rows | Where-Object { Test-RowSelected -Row $_ -SelectedEpisodes $selectedEpisodes -AllEpisodes:$All })
if ($selected.Count -eq 0) {
    Write-Host 'No model files are referenced by the selected episode(s).'
    exit 0
}

[int64]$selectedBytes = 0
[int64]$presentBytes = 0
[int64]$toFetchBytes = 0
[int64]$downloadedBytes = 0
[int64]$failedBytes = 0
$presentFiles = 0
$toFetch = 0
$manualRows = @()
$gatedRows = @()
$mismatched = @()
$missing = @()

Write-Host "`n== Models ==" -ForegroundColor Cyan
Write-Host "   folder: $ModelsRoot"
Get-FreeOrThrow -Path $ModelsRoot

foreach ($row in $selected) {
    $folderPath = $row.folder.Replace('/', [IO.Path]::DirectorySeparatorChar)
    $targetDir = Join-Path $ModelsRoot $folderPath
    $targetPath = Join-Path $targetDir $row.filename
    if ($row.repo -eq '-') {
        $manualRows += $row
        if (Test-Path -LiteralPath $targetPath) { $presentFiles++ } else { $missing += $targetPath }
        continue
    }
    [int64]$bytes = [int64]$row.bytes
    $selectedBytes += $bytes
    if ($row.gated -eq 'yes') { $gatedRows += $row }
    if ((Test-Path -LiteralPath $targetPath) -and -not $ForceModels) {
        $actual = (Get-Item -LiteralPath $targetPath).Length
        $presentFiles++
        $presentBytes += $bytes
        if ($actual -ne $bytes) {
            $mismatched += [pscustomobject]@{ Path = $targetPath; Actual = $actual; Expected = $bytes }
            Write-Host "   warning: size mismatch, leaving untouched: $targetPath ($actual bytes, expected $bytes)" -ForegroundColor Yellow
        }
    } else {
        $toFetch++
        $toFetchBytes += $bytes
        if ($Verify) { $missing += $targetPath }
    }
}

Write-Host ("   selected:    {0} files, {1} downloadable{2}" -f $selected.Count, (Format-Human $selectedBytes), $(if ($manualRows.Count -gt 0) { ", $($manualRows.Count) manual" } else { '' }))
Write-Host ("   present:     {0} files ({1})" -f $presentFiles, (Format-Human $presentBytes))
Write-Host ("   to download: {0} files ({1})" -f $toFetch, (Format-Human $toFetchBytes))
if ($mismatched.Count -gt 0) { Write-Host "   size issues: $($mismatched.Count) existing file(s)" -ForegroundColor Yellow }
if ($gatedRows.Count -gt 0) { Write-Host "   gated:       $($gatedRows.Count) file(s) from black-forest-labs/flux-3-image-klein-comfy" }

if ($Verify) {
    Write-Host "`nVerification only; nothing downloaded."
    foreach ($path in $missing) { Write-Host "   missing: $path" -ForegroundColor Yellow }
    foreach ($m in $mismatched) { Write-Host "   wrong size: $($m.Path) ($($m.Actual) vs $($m.Expected))" -ForegroundColor Yellow }
    if ($toFetch -eq 0 -and $missing.Count -eq 0 -and $mismatched.Count -eq 0) { exit 0 }
    exit 1
}

if ($All -and -not $DryRun -and -not $Yes -and $toFetch -gt 0) {
    Write-Host ''
    Write-Host ("This will download {0}. Continue? [y/N] " -f (Format-Human $toFetchBytes)) -NoNewline
    if ([Console]::IsInputRedirected) {
        Write-Host ''
        Fail 'not a terminal; re-run with -Yes to confirm'
    }
    $answer = Read-Host
    if ($answer -notmatch '^(?i)y(es)?$') { Write-Host 'Aborted.'; exit 1 }
}

$hfAuthOk = $false
if ($gatedRows.Count -gt 0 -and (Get-Command hf -ErrorAction SilentlyContinue)) {
    & hf auth whoami *> $null
    $hfAuthOk = ($LASTEXITCODE -eq 0)
}

$stageRoot = Join-Path $ModelsRoot '.pixaroma-staging'
$downloadedFiles = 0
$failedFiles = 0
$gateSkipped = 0
$index = 0

foreach ($row in $selected) {
    $index++
    $folderPath = $row.folder.Replace('/', [IO.Path]::DirectorySeparatorChar)
    $targetDir = Join-Path $ModelsRoot $folderPath
    $targetPath = Join-Path $targetDir $row.filename
    if ($row.repo -eq '-') {
        if (Test-Path -LiteralPath $targetPath) {
            Write-Host ("[{0,3}/{1,3}] [manual-present] {2}/{3}" -f $index, $selected.Count, $row.folder, $row.filename)
        } else {
            Write-Host ("[{0,3}/{1,3}] [manual] {2}/{3} - supply this file yourself" -f $index, $selected.Count, $row.folder, $row.filename)
        }
        continue
    }
    if ((Test-Path -LiteralPath $targetPath) -and -not $ForceModels) {
        Write-Host ("[{0,3}/{1,3}] [skip] {2}/{3} ({4})" -f $index, $selected.Count, $row.folder, $row.filename, (Format-Human ([int64]$row.bytes)))
        continue
    }
    if ($DryRun) {
        Write-Host ("[{0,3}/{1,3}] [dry-run] {2}  {3}/{4}" -f $index, $selected.Count, (Format-Human ([int64]$row.bytes)), $row.folder, $row.filename)
        Write-Host "                $($row.url)"
        if ($row.gated -eq 'yes') { Write-Host '                gated: accept the license and run hf auth login' -ForegroundColor Yellow }
        & hf download $row.repo $row.repo_path --dry-run --quiet *> $null
        if ($LASTEXITCODE -eq 0) {
            Write-Host '                remote: ok'
        } else {
            Write-Host '                remote: check failed (network or access)' -ForegroundColor Yellow
        }
        continue
    }
    if ($row.gated -eq 'yes' -and -not $hfAuthOk) {
        Write-Host ("[{0,3}/{1,3}] [gate] {2}/{3} - accept the license and run: hf auth login" -f $index, $selected.Count, $row.folder, $row.filename) -ForegroundColor Yellow
        $gateSkipped++
        continue
    }

    Write-Host ("[{0,3}/{1,3}] [dl] {2}  {3}/{4}" -f $index, $selected.Count, (Format-Human ([int64]$row.bytes)), $row.folder, $row.filename)
    Write-Host "                $($row.url)"

    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        $hashBytes = $sha.ComputeHash([Text.Encoding]::UTF8.GetBytes("$($row.repo)/$($row.repo_path)"))
    } finally {
        $sha.Dispose()
    }
    $hash = -join ($hashBytes[0..7] | ForEach-Object { $_.ToString('x2') })
    $stage = Join-Path $stageRoot $hash
    if (-not (Test-Path -LiteralPath $stage)) { New-Item -ItemType Directory -Force -Path $stage | Out-Null }

    & hf download $row.repo $row.repo_path --local-dir $stage
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   [fail] download failed: $($row.folder)/$($row.filename)" -ForegroundColor Red
        if ($row.gated -eq 'yes') {
            Write-Host "          Accept the license at https://huggingface.co/$($row.repo) and run: hf auth login" -ForegroundColor Yellow
        }
        Write-Host "          partial data kept in $stage (re-run to resume)"
        $failedFiles++
        $failedBytes += [int64]$row.bytes
        continue
    }

    $source = Join-Path $stage $row.repo_path
    if (-not (Test-Path -LiteralPath $source)) {
        Write-Host "   [fail] hf reported success but $source is missing" -ForegroundColor Red
        $failedFiles++
        $failedBytes += [int64]$row.bytes
        continue
    }
    $actual = (Get-Item -LiteralPath $source).Length
    if ($actual -ne [int64]$row.bytes) {
        Write-Host "   warning: downloaded size $actual differs from expected $($row.bytes); installing anyway" -ForegroundColor Yellow
    }
    if (-not (Test-Path -LiteralPath $targetDir)) { New-Item -ItemType Directory -Force -Path $targetDir | Out-Null }
    Move-Item -LiteralPath $source -Destination $targetPath -Force
    Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
    $downloadedFiles++
    $downloadedBytes += [int64]$row.bytes
}

# Remove the staging root only when every download moved out cleanly.
Remove-Item -LiteralPath $stageRoot -Force -ErrorAction SilentlyContinue

Write-Host "`n== Summary ==" -ForegroundColor Cyan
Write-Host ("   downloaded:      {0} files ({1})" -f $downloadedFiles, (Format-Human $downloadedBytes))
Write-Host ("   already present: {0} files ({1})" -f $presentFiles, (Format-Human $presentBytes))
Write-Host ("   failed:          {0} files ({1})" -f $failedFiles, (Format-Human $failedBytes))
if ($gateSkipped -gt 0) { Write-Host "   gated, skipped:  $gateSkipped file(s)" -ForegroundColor Yellow }
if ($manualRows.Count -gt 0) {
    Write-Host "`n   Manual file(s):"
    foreach ($row in $manualRows) {
        Write-Host "     $($row.folder)/$($row.filename)"
        Write-Host "       $($row.note)"
    }
}
if ($failedFiles -gt 0 -or $gateSkipped -gt 0) { exit 1 }
exit 0
