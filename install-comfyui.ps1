#Requires -Version 5.1
<#
.SYNOPSIS
  Install ComfyUI (official portable or official git) and point it at a shared
  model folder that Stable Diffusion WebUI can use too.

.DESCRIPTION
  Portable flavour (default):
    Downloads the official ComfyUI Windows portable NVIDIA build, extracts it,
    and configures it. Fully automated.

  Git flavour:
    Clones ComfyUI, creates a venv, installs PyTorch (CUDA 12.8 by default) and
    requirements. Requires git and Python 3.10-3.13; the script can install
    them with winget when missing.

  Both flavours write extra_model_paths.yaml and pixaroma.conf so setup.ps1 /
  setup.sh know where ComfyUI and the shared models live.

.PARAMETER ModelsRoot
  Shared model store. Defaults to <drive with most free space>\AI\models.
  Use the 1.8 TB HDD on the test machine for the full 782 GB Pixaroma set.

.PARAMETER InstallDir
  Where the app is installed. For -Flavor portable this is the portable root
  (the folder holding ComfyUI\, python_embeded\, and run_nvidia_gpu.bat).
  For -Flavor git this is the ComfyUI checkout itself. Keep it on the SSD.

.EXAMPLE
  Set-ExecutionPolicy -Scope Process Bypass
  .\install-comfyui.ps1

.EXAMPLE
  .\install-comfyui.ps1 -Flavor git -InstallDir C:\AI\ComfyUI -ModelsRoot D:\AI\models

.NOTES
  Tested by dry-run on PowerShell 7.5.4. Windows-only actions require Windows 10/11.
#>
[CmdletBinding()]
param(
    [ValidateSet('portable', 'git')]
    [string]$Flavor = 'portable',

    [string]$InstallDir,

    [string]$ModelsRoot,

    [switch]$Cpu,

    [switch]$DryRun,

    [switch]$SkipConfig,

    [switch]$NoPrereqInstall,

    [switch]$Test
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch { }

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$isWindowsHost = ($env:OS -eq 'Windows_NT')

function Write-Step([string]$Message) { Write-Host "`n== $Message ==" -ForegroundColor Cyan }
function Write-Info([string]$Message) { Write-Host "   $Message" }
function Write-Warn2([string]$Message) { Write-Host "   warning: $Message" -ForegroundColor Yellow }
function Fail([string]$Message) { throw $Message }

function Write-TextFile {
    param([string]$Path, [string]$Text)
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($Path, $Text, $utf8)
}

function Get-DefaultComfyDir {
    param([string]$ForFlavor)
    if (-not $isWindowsHost) {
        if ($ForFlavor -eq 'portable') { return (Join-Path $HOME 'AI/ComfyUI_windows_portable') }
        return (Join-Path $HOME 'AI/ComfyUI')
    }
    $systemDrive = $env:SystemDrive
    if (-not $systemDrive) { $systemDrive = 'C:' }
    if ($ForFlavor -eq 'portable') {
        return (Join-Path $systemDrive 'AI\ComfyUI_windows_portable')
    }
    return (Join-Path $systemDrive 'AI\ComfyUI')
}

function Get-DefaultModelsRoot {
    if (-not $isWindowsHost) { return (Join-Path $HOME 'AI/models') }
    $drives = @()
    foreach ($d in Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue) {
        if ($d.Name -match '^[A-Za-z]$' -and $null -ne $d.Free -and $d.Free -gt 0) {
            $drives += $d
        }
    }
    if (-not $drives -or $drives.Count -eq 0) {
        return (Join-Path $env:USERPROFILE 'AI\models')
    }
    $best = $drives | Sort-Object -Property Free -Descending | Select-Object -First 1
    return (Join-Path ($best.Name + ':') 'AI\models')
}

function Format-Bytes([int64]$Bytes) {
    if ($Bytes -ge 1000000000000) { return ('{0:N2} TB' -f ($Bytes / 1e12)) }
    if ($Bytes -ge 1000000000) { return ('{0:N2} GB' -f ($Bytes / 1e9)) }
    if ($Bytes -ge 1000000) { return ('{0:N2} MB' -f ($Bytes / 1e6)) }
    if ($Bytes -ge 1000) { return ('{0:N1} KB' -f ($Bytes / 1e3)) }
    return "$Bytes B"
}

function Test-IsAdmin {
    try {
        $id = [Security.Principal.WindowsIdentity]::GetCurrent()
        $p = New-Object Security.Principal.WindowsPrincipal($id)
        return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch { return $false }
}

function Ensure-Directory([string]$Path) {
    if ($DryRun) { Write-Info "[dry-run] mkdir $Path"; return }
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

function Invoke-Native {
    param(
        [string]$Exe,
        [string[]]$Arguments,
        [string]$WorkDir,
        [switch]$AllowFailure
    )
    $old = $null
    if ($WorkDir) { $old = (Get-Location).Path; Set-Location -LiteralPath $WorkDir }
    try {
        & $Exe @Arguments
        $code = $LASTEXITCODE
    } finally {
        if ($old) { Set-Location -LiteralPath $old }
    }
    if ($code -ne 0 -and -not $AllowFailure) {
        Fail "$Exe $($Arguments -join ' ') failed with exit code $code"
    }
    return $code
}

function Download-File {
    param([string]$Url, [string]$Dest, [int64]$ExpectedSize = 0)
    if (Test-Path -LiteralPath $Dest) {
        $len = (Get-Item -LiteralPath $Dest).Length
        if ($ExpectedSize -le 0 -or $len -eq $ExpectedSize) {
            Write-Info "reusing downloaded file: $Dest ($(Format-Bytes $len))"
            return
        }
        Write-Warn2 "size mismatch on cached download; fetching again"
        if (-not $DryRun) { Remove-Item -LiteralPath $Dest -Force }
    }
    if ($DryRun) { Write-Info "[dry-run] download $Url -> $Dest"; return }
    Ensure-Directory (Split-Path -Parent $Dest)
    $part = "$Dest.part"
    if (Test-Path -LiteralPath $part) { Remove-Item -LiteralPath $part -Force }
    Write-Info "downloading $Url"
    $curl = Get-Command curl.exe -ErrorAction SilentlyContinue
    if (-not $curl) { $curl = Get-Command curl -ErrorAction SilentlyContinue }
    if ($curl) {
        & $curl.Source -L --fail --retry 5 --retry-delay 3 -o $part $Url
        if ($LASTEXITCODE -ne 0) {
            if (Test-Path -LiteralPath $part) { Remove-Item -LiteralPath $part -Force }
            Fail "download failed: $Url"
        }
    } else {
        try {
            Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile $part
        } catch {
            if (Test-Path -LiteralPath $part) { Remove-Item -LiteralPath $part -Force }
            Fail "download failed: $Url ($($_.Exception.Message))"
        }
    }
    if ($ExpectedSize -gt 0) {
        $got = (Get-Item -LiteralPath $part).Length
        if ($got -ne $ExpectedSize) {
            Remove-Item -LiteralPath $part -Force
            Fail "downloaded size $got does not match expected $ExpectedSize"
        }
    }
    Move-Item -LiteralPath $part -Destination $Dest -Force
}

function Find-SevenZip {
    foreach ($name in @('7z.exe', '7za.exe')) {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($cmd) { return $cmd.Source }
    }
    $roots = @($env:ProgramFiles, ${env:ProgramFiles(x86)})
    foreach ($root in $roots) {
        if (-not $root) { continue }
        $p = Join-Path $root '7-Zip\7z.exe'
        if (Test-Path -LiteralPath $p) { return $p }
    }
    return $null
}

function Get-SevenZipStandalone {
    param([string]$ToolDir)
    $exe = Join-Path $ToolDir '7zr.exe'
    if (Test-Path -LiteralPath $exe) { return $exe }
    Ensure-Directory $ToolDir
    Download-File -Url 'https://www.7-zip.org/a/7zr.exe' -Dest $exe
    return $exe
}

function Expand-SevenZip {
    param([string]$Archive, [string]$Dest, [string]$ToolDir)
    if ($DryRun) { Write-Info "[dry-run] extract $Archive -> $Dest"; return }
    Ensure-Directory $Dest
    $seven = Find-SevenZip
    if ($seven) {
        Write-Info "extracting with $seven"
        & $seven x -y "-o$Dest" $Archive | Out-Null
        if ($LASTEXITCODE -eq 0) { return }
        Write-Warn2 "7-Zip failed; trying Windows tar"
    }
    $tar = Get-Command tar.exe -ErrorAction SilentlyContinue
    if (-not $tar) { $tar = Get-Command tar -ErrorAction SilentlyContinue }
    if ($tar) {
        Write-Info "extracting with $($tar.Source)"
        & $tar.Source -xf $Archive -C $Dest
        if ($LASTEXITCODE -eq 0) { return }
        Write-Warn2 "tar could not read the archive; downloading 7zr.exe"
    }
    $seven = Get-SevenZipStandalone -ToolDir $ToolDir
    & $seven x -y "-o$Dest" $Archive | Out-Null
    if ($LASTEXITCODE -ne 0) { Fail "could not extract $Archive" }
}

function Ensure-Git {
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) { return $git.Source }
    if ($NoPrereqInstall) { Fail "git is required. Install it with: winget install Git.Git" }
    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    if (-not $winget) { Fail "git is required and winget is unavailable. Install Git from https://git-scm.com/" }
    Write-Info "git not found; installing Git with winget"
    & $winget.Source install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) { Fail "winget could not install Git" }
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
    $git = Get-Command git -ErrorAction SilentlyContinue
    if (-not $git) {
        $fallback = Join-Path $env:ProgramFiles 'Git\cmd\git.exe'
        if (Test-Path -LiteralPath $fallback) { return $fallback }
        Fail "Git was installed but is not on PATH; open a new terminal and re-run"
    }
    return $git.Source
}

function Find-Python {
    $candidates = @()
    $py = Get-Command py.exe -ErrorAction SilentlyContinue
    if (-not $py) { $py = Get-Command py -ErrorAction SilentlyContinue }
    if ($py) {
        foreach ($v in @('3.12', '3.11', '3.10', '3.13')) {
            $out = & $py.Source "-$v" -c "import sys; print(sys.executable)" 2>$null
            if ($LASTEXITCODE -eq 0 -and $out) {
                $candidates += ([string]$out).Trim()
            }
        }
    }
    foreach ($name in @('python.exe', 'python3.exe', 'python', 'python3')) {
        $c = Get-Command $name -ErrorAction SilentlyContinue
        if ($c) { $candidates += $c.Source }
    }
    foreach ($exe in ($candidates | Select-Object -Unique)) {
        if (-not (Test-Path -LiteralPath $exe)) { continue }
        $ver = & $exe -c "import sys; print('%d.%d' % sys.version_info[:2])" 2>$null
        if ($LASTEXITCODE -eq 0 -and $ver -match '^3\.(1[0-3])$') {
            return $exe
        }
    }
    return $null
}

function Ensure-Python {
    $py = Find-Python
    if ($py) { return $py }
    if ($NoPrereqInstall) { Fail "Python 3.10-3.13 is required. Install it with: winget install Python.Python.3.12" }
    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    if (-not $winget) { Fail "Python 3.10-3.13 is required and winget is unavailable. Install it from https://www.python.org/downloads/" }
    Write-Info "Python 3.10-3.13 not found; installing Python 3.12 with winget"
    & $winget.Source install --id Python.Python.3.12 -e --source winget --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) { Fail "winget could not install Python 3.12" }
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
    $py = Find-Python
    if ($py) { return $py }
    $fallback = Join-Path $env:LOCALAPPDATA 'Programs\Python\Python312\python.exe'
    if (Test-Path -LiteralPath $fallback) { return $fallback }
    Fail "Python was installed but is not on PATH; open a new terminal and re-run"
}

function Install-PyTorch {
    param([string]$PythonExe, [switch]$CpuOnly)
    $indexes = @('cu128', 'cu126', 'cu121')
    if ($CpuOnly) { $indexes = @('cpu') }
    foreach ($idx in $indexes) {
        Write-Info "installing PyTorch ($idx)"
        & $PythonExe -m pip install --upgrade torch torchvision torchaudio --index-url "https://download.pytorch.org/whl/$idx"
        if ($LASTEXITCODE -eq 0) { return $idx }
        Write-Warn2 "PyTorch $idx failed; trying the next wheel set"
    }
    Fail "could not install PyTorch. Install it manually from https://pytorch.org/ and re-run."
}

function Initialize-SharedModels {
    param([string]$Root)
    $folders = @(
        'checkpoints', 'diffusion_models', 'text_encoders', 'clip', 'clip_vision',
        'vae', 'loras', 'embeddings', 'controlnet', 'upscale_models',
        'latent_upscale_models', 'model_patches', 'audio_encoders',
        'background_removal', 'detection', 'sam3', 'geometry_estimation',
        'SEEDVR2', 'style_models', 'gligen', 'photomaker', 'classifiers',
        'frame_interpolation', 'optical_flow', 'hypernetworks', 'configs',
        'diffusers', 'vae_approx'
    )
    foreach ($f in $folders) {
        Ensure-Directory (Join-Path $Root $f)
    }
}

function Write-ExtraModelPaths {
    param([string]$ComfyRoot, [string]$Root)
    $yamlPath = Join-Path $ComfyRoot 'extra_model_paths.yaml'
    $base = ($Root -replace '\\', '/') -replace '"', '\"'
    $block = @"
pixaroma_shared:
    base_path: "$base"
    is_default: true
    checkpoints: checkpoints
    diffusion_models: diffusion_models
    text_encoders: text_encoders
    clip: text_encoders
    clip_vision: clip_vision
    vae: vae
    loras: loras
    embeddings: embeddings
    controlnet: controlnet
    upscale_models: upscale_models
    latent_upscale_models: latent_upscale_models
    model_patches: model_patches
    audio_encoders: audio_encoders
    background_removal: background_removal
    detection: detection
    sam3: sam3
    geometry_estimation: geometry_estimation
    SEEDVR2: SEEDVR2
    style_models: style_models
    gligen: gligen
    photomaker: photomaker
    classifiers: classifiers
    frame_interpolation: frame_interpolation
    optical_flow: optical_flow
    hypernetworks: hypernetworks
    configs: configs
    diffusers: diffusers
    vae_approx: vae_approx
"@
    if (-not (Test-Path -LiteralPath $yamlPath)) {
        if ($DryRun) { Write-Info "[dry-run] write $yamlPath"; return }
        Write-TextFile -Path $yamlPath -Text $block
        Write-Info "wrote $yamlPath"
        return
    }
    $existing = Get-Content -LiteralPath $yamlPath -Raw
    if ($existing -match '(?m)^pixaroma_shared:') {
        Write-Info "extra_model_paths.yaml already contains pixaroma_shared; left unchanged"
        return
    }
    if ($DryRun) { Write-Info "[dry-run] append pixaroma_shared to $yamlPath"; return }
    Add-Content -LiteralPath $yamlPath -Value "`r`n$block" -Encoding UTF8
    Write-Info "appended pixaroma_shared to $yamlPath"
}

function Read-PixaromaConf {
    $conf = Join-Path $scriptDir 'pixaroma.conf'
    $values = @{}
    if (Test-Path -LiteralPath $conf) {
        foreach ($line in Get-Content -LiteralPath $conf) {
            if ($line -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$') {
                $values[$Matches[1]] = $Matches[2].Trim()
            }
        }
    }
    return $values
}

function Write-PixaromaConf {
    param([string]$ComfyDir, [string]$Root, [string]$SdDir)
    $values = Read-PixaromaConf
    if ($ComfyDir) { $values['COMFYUI'] = $ComfyDir }
    if ($Root) { $values['MODELS_ROOT'] = $Root }
    if ($SdDir) { $values['SD_WEBUI'] = $SdDir }
    $order = @('COMFYUI', 'MODELS_ROOT', 'SD_WEBUI')
    $lines = @('# Generated by the Pixaroma installers. Command-line flags override these values.')
    foreach ($k in $order) {
        if ($values.ContainsKey($k) -and $values[$k]) { $lines += "$k=$($values[$k])" }
    }
    foreach ($k in ($values.Keys | Sort-Object)) {
        if ($order -notcontains $k -and $values[$k]) { $lines += "$k=$($values[$k])" }
    }
    $conf = Join-Path $scriptDir 'pixaroma.conf'
    if ($DryRun) { Write-Info "[dry-run] write $conf"; return }
    try {
        Write-TextFile -Path $conf -Text (($lines -join "`r`n") + "`r`n")
        Write-Info "wrote $conf"
    } catch {
        Write-Warn2 "could not write ${conf}: $($_.Exception.Message)"
    }
}

function Invoke-ComfyBootTest {
    param([string]$PythonExe, [string]$ComfyRoot)
    $port = 8189
    $outLog = Join-Path $env:TEMP 'pixaroma-comfyui-test.out.log'
    $errLog = Join-Path $env:TEMP 'pixaroma-comfyui-test.err.log'
    Write-Info "starting ComfyUI on port $port (CPU mode) for a boot test"
    $args = @('-s', 'main.py', '--cpu', '--port', "$port", '--dont-print-server')
    $proc = Start-Process -FilePath $PythonExe -ArgumentList $args -WorkingDirectory $ComfyRoot -PassThru -WindowStyle Hidden -RedirectStandardOutput $outLog -RedirectStandardError $errLog
    $ok = $false
    try {
        for ($i = 0; $i -lt 90; $i++) {
            Start-Sleep -Seconds 2
            if ($proc.HasExited) { break }
            try {
                $r = Invoke-WebRequest -UseBasicParsing -Uri "http://127.0.0.1:$port/" -TimeoutSec 3
                if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 500) { $ok = $true; break }
            } catch { }
        }
    } finally {
        if (-not $proc.HasExited) { Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue }
    }
    if ($ok) {
        Write-Info "boot test passed: ComfyUI responded on port $port"
        return
    }
    Write-Warn2 "boot test did not get a response. Last log lines:"
    foreach ($log in @($outLog, $errLog)) {
        if (Test-Path -LiteralPath $log) {
            Get-Content -LiteralPath $log -Tail 15 | ForEach-Object { Write-Host "     $_" }
        }
    }
    Fail "ComfyUI did not start"
}

# --------------------------------------------------------------------- defaults
if (-not $isWindowsHost -and -not $DryRun) {
    Fail "This installer is for Windows. On Linux/macOS use ./install-comfyui.sh"
}

if (-not $InstallDir) { $InstallDir = Get-DefaultComfyDir -ForFlavor $Flavor }
if (-not $ModelsRoot) {
    $saved = Read-PixaromaConf
    if ($saved.ContainsKey('MODELS_ROOT') -and $saved['MODELS_ROOT']) {
        $ModelsRoot = $saved['MODELS_ROOT']
    } else {
        $ModelsRoot = Get-DefaultModelsRoot
    }
}
$InstallDir = [IO.Path]::GetFullPath($InstallDir)
$ModelsRoot = [IO.Path]::GetFullPath($ModelsRoot)

if ($Flavor -eq 'portable' -and $Cpu) {
    Fail "-Cpu is not supported with -Flavor portable (the portable build bundles CUDA PyTorch). Use -Flavor git -Cpu."
}

Write-Step "Plan"
Write-Info "flavour:      $Flavor"
Write-Info "install dir:  $InstallDir"
Write-Info "models root:  $ModelsRoot"
if ($DryRun) { Write-Info "mode:         dry run (no changes)" }
if (Test-IsAdmin) { Write-Warn2 "running elevated; ComfyUI does not need administrator rights" }

if (-not $DryRun) {
    Ensure-Directory $InstallDir
    Ensure-Directory $ModelsRoot
    $driveRoot = [IO.Path]::GetPathRoot($ModelsRoot)
    try {
        $free = (Get-PSDrive -Name $driveRoot.Substring(0, 1) -ErrorAction Stop).Free
        Write-Info "free space at models root: $(Format-Bytes $free)"
        if ($free -lt 850GB) {
            Write-Warn2 "the full Pixaroma catalog is 782.61 GB; $(Format-Bytes $free) free may not fit everything"
        }
    } catch { }
}

$ComfyRoot = $null

# --------------------------------------------------------------------- portable
if ($Flavor -eq 'portable') {
    $ComfyRoot = Join-Path $InstallDir 'ComfyUI'
    $portablePython = Join-Path $InstallDir 'python_embeded\python.exe'
    $mainPy = Join-Path $ComfyRoot 'main.py'

    if (Test-Path -LiteralPath $mainPy) {
        Write-Step 'Official ComfyUI portable is already installed'
        Write-Info "found $mainPy"
    } else {
        Write-Step 'Installing official ComfyUI portable'
        $existing = @()
        if (Test-Path -LiteralPath $InstallDir) {
            $existing = @(Get-ChildItem -LiteralPath $InstallDir -Force)
        }
        if ($existing.Count -gt 0) {
            Fail "$InstallDir is not empty and does not contain ComfyUI\main.py. Choose an empty -InstallDir."
        }

        $release = $null
        if (-not $DryRun) {
            Write-Info 'querying the latest ComfyUI release'
            try {
                $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/Comfy-Org/ComfyUI/releases/latest' -Headers @{ 'User-Agent' = 'Pixaroma-Setup' } -TimeoutSec 60
            } catch {
                Write-Warn2 "GitHub API failed ($($_.Exception.Message)); using the comfyanonymous/ComfyUI endpoint"
                $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/comfyanonymous/ComfyUI/releases/latest' -Headers @{ 'User-Agent' = 'Pixaroma-Setup' } -TimeoutSec 60
            }
        }
        if ($release) {
            $asset = $release.assets | Where-Object { $_.name -eq 'ComfyUI_windows_portable_nvidia.7z' } | Select-Object -First 1
            if (-not $asset) {
                Fail "the latest release ($($release.tag_name)) has no ComfyUI_windows_portable_nvidia.7z asset"
            }
            Write-Info "release: $($release.tag_name), asset: $($asset.name) ($(Format-Bytes $asset.size))"
            $archive = Join-Path $InstallDir '.installer\ComfyUI_windows_portable_nvidia.7z'
            Download-File -Url $asset.browser_download_url -Dest $archive -ExpectedSize $asset.size
        } else {
            $archive = Join-Path $InstallDir '.installer\ComfyUI_windows_portable_nvidia.7z'
            Write-Info "[dry-run] download the latest ComfyUI_windows_portable_nvidia.7z"
        }

        $extractDir = Join-Path $InstallDir '.installer\extract'
        if (Test-Path -LiteralPath $extractDir) {
            if (-not $DryRun) { Remove-Item -LiteralPath $extractDir -Recurse -Force }
        }
        Expand-SevenZip -Archive $archive -Dest $extractDir -ToolDir (Join-Path $InstallDir '.tools')

        if (-not $DryRun) {
            $root = $null
            $direct = Join-Path $extractDir 'ComfyUI_windows_portable'
            if (Test-Path -LiteralPath (Join-Path $direct 'ComfyUI\main.py')) {
                $root = $direct
            } elseif (Test-Path -LiteralPath (Join-Path $extractDir 'ComfyUI\main.py')) {
                $root = $extractDir
            } else {
                foreach ($dir in Get-ChildItem -LiteralPath $extractDir -Directory) {
                    if (Test-Path -LiteralPath (Join-Path $dir.FullName 'ComfyUI\main.py')) {
                        $root = $dir.FullName
                        break
                    }
                }
            }
            if (-not $root) { Fail "extracted archive does not contain ComfyUI\main.py" }
            Get-ChildItem -LiteralPath $root -Force | ForEach-Object {
                Move-Item -LiteralPath $_.FullName -Destination $InstallDir -Force
            }
            Remove-Item -LiteralPath (Join-Path $InstallDir '.installer') -Recurse -Force -ErrorAction SilentlyContinue
            if (-not (Test-Path -LiteralPath $mainPy)) { Fail "portable extraction did not produce $mainPy" }
            if (-not (Test-Path -LiteralPath $portablePython)) { Fail "portable extraction did not produce $portablePython" }
            Write-Info "installed to $InstallDir"
        }
    }
}

# -------------------------------------------------------------------------- git
if ($Flavor -eq 'git') {
    $ComfyRoot = $InstallDir
    $mainPy = Join-Path $ComfyRoot 'main.py'
    $venvDir = Join-Path $InstallDir 'venv'
    $venvPython = Join-Path $venvDir 'Scripts\python.exe'
    $requirements = Join-Path $ComfyRoot 'requirements.txt'

    if (Test-Path -LiteralPath $mainPy) {
        Write-Step 'ComfyUI git checkout already present'
        Write-Info "found $mainPy"
    } else {
        Write-Step 'Cloning ComfyUI'
        if (Test-Path -LiteralPath $InstallDir) {
            $items = @(Get-ChildItem -LiteralPath $InstallDir -Force)
            if ($items.Count -gt 0) { Fail "$InstallDir is not empty and does not contain main.py" }
        }
        Ensure-Directory $InstallDir
        if ($DryRun) {
            Write-Info "[dry-run] git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git $InstallDir"
        } else {
            $git = Ensure-Git
            Invoke-Native -Exe $git -Arguments @('clone', '--depth', '1', 'https://github.com/comfyanonymous/ComfyUI.git', $InstallDir)
        }
    }

    if (-not (Test-Path -LiteralPath $venvPython)) {
        Write-Step 'Creating the Python virtual environment'
        if ($DryRun) {
            Write-Info "[dry-run] locate Python 3.10-3.13 (install with winget if missing)"
            Write-Info "[dry-run] python -m venv $venvDir"
        } else {
            $basePython = Ensure-Python
            Write-Info "using $basePython"
            Invoke-Native -Exe $basePython -Arguments @('-m', 'venv', $venvDir)
        }
    }

    if (-not $DryRun) {
        if (-not (Test-Path -LiteralPath $venvPython)) { Fail "venv was not created at $venvDir" }
        Write-Step 'Installing pip, PyTorch, and ComfyUI requirements'
        Invoke-Native -Exe $venvPython -Arguments @('-m', 'pip', 'install', '--upgrade', 'pip', 'wheel', 'setuptools')
        $wheelSet = Install-PyTorch -PythonExe $venvPython -CpuOnly:$Cpu
        Write-Info "PyTorch wheel set: $wheelSet"
        Invoke-Native -Exe $venvPython -Arguments @('-m', 'pip', 'install', '-r', $requirements)

        Write-Step 'Verifying PyTorch and CUDA'
        & $venvPython -c "import torch; print('torch', torch.__version__); print('cuda available:', torch.cuda.is_available()); print('device:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'CPU')"
        if ($LASTEXITCODE -ne 0) { Fail "PyTorch import failed" }

        $launcher = Join-Path $InstallDir 'run_comfyui.bat'
        $bat = @"
@echo off
rem PIXAROMA MANAGED - generated by install-comfyui.ps1
cd /d "%~dp0"
"%~dp0venv\Scripts\python.exe" -s "%~dp0main.py" --windows-standalone-build
pause
"@
        Write-TextFile -Path $launcher -Text $bat
        Write-Info "wrote launcher: $launcher"
    } else {
        Write-Info "[dry-run] create venv, install PyTorch (CUDA 12.8/12.6/12.1) and requirements.txt"
        Write-Info "[dry-run] write $InstallDir\run_comfyui.bat"
    }
}

if (-not $ComfyRoot) { Fail "internal error: ComfyRoot was not set" }

# ------------------------------------------------------------- shared settings
if (-not $SkipConfig) {
    Write-Step 'Configuring the shared model store'
    Initialize-SharedModels -Root $ModelsRoot
    Write-ExtraModelPaths -ComfyRoot $ComfyRoot -Root $ModelsRoot
    Write-PixaromaConf -ComfyDir $ComfyRoot -Root $ModelsRoot -SdDir $null
    Write-Info "models will live in $ModelsRoot"
    Write-Info "extra paths file: $(Join-Path $ComfyRoot 'extra_model_paths.yaml')"
}

# ---------------------------------------------------------------------- verify
if (-not $DryRun) {
    Write-Step 'Installation summary'
    if ($Flavor -eq 'portable') { Write-Info "portable root: $InstallDir" }
    Write-Info "ComfyUI:  $ComfyRoot"
    Write-Info "models:   $ModelsRoot"
    if ($Flavor -eq 'portable') {
        Write-Info "launch:   $(Join-Path $InstallDir 'run_nvidia_gpu.bat')"
        Write-Info "python:   $portablePython"
    } else {
        Write-Info "launch:   $(Join-Path $InstallDir 'run_comfyui.bat')"
        Write-Info "python:   $venvPython"
    }
    Write-Info "workflows: run .\setup.ps1 workflows (uses pixaroma.conf)"
    Write-Info "models:    run .\setup.ps1 models --episode 6"

    if ($Test) {
        if ($Flavor -eq 'portable') {
            Invoke-ComfyBootTest -PythonExe $portablePython -ComfyRoot $ComfyRoot
        } else {
            Invoke-ComfyBootTest -PythonExe $venvPython -ComfyRoot $ComfyRoot
        }
    }
} else {
    Write-Step 'Dry run complete'
    Write-Info "would configure $(Join-Path $ComfyRoot 'extra_model_paths.yaml')"
    Write-Info "would write $(Join-Path $scriptDir 'pixaroma.conf')"
}
