#Requires -Version 5.1
<#
.SYNOPSIS
  Install Stable Diffusion WebUI (AUTOMATIC1111 or Forge) with the same shared
  model folder used by ComfyUI and the Pixaroma setup scripts.

.DESCRIPTION
  Clones the chosen WebUI, installs Python 3.10 and git with winget when they
  are missing, creates a venv, installs PyTorch (CUDA 12.8 by default) plus the
  WebUI requirements, and links the WebUI's model folders to the shared store
  with directory junctions.

  The shared store uses ComfyUI folder names (checkpoints, loras, vae, ...), so
  one copy of each checkpoint/LoRA serves ComfyUI, A1111, and Forge.

.PARAMETER Flavor
  a1111 (default) clones AUTOMATIC1111/stable-diffusion-webui.
  forge clones lllyasviel/stable-diffusion-webui-forge (better support for
  newer architectures such as Flux and SDXL).

.PARAMETER Test
  Start the WebUI once on port 7861, wait for HTTP 200, then stop it. First run
  can take 10-30 minutes because launch.py finishes installing assets.

.EXAMPLE
  Set-ExecutionPolicy -Scope Process Bypass
  .\install-stablediffusion.ps1 -Flavor forge -ModelsRoot D:\AI\models

.NOTES
  A1111 and Forge expect Python 3.10; the script installs it per-user if needed.
  Tested by dry-run on PowerShell 7.5.4; Windows-only actions require Windows 10/11.
#>
[CmdletBinding()]
param(
    [ValidateSet('a1111', 'forge')]
    [string]$Flavor = 'a1111',

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

function Write-TextFile {
    param([string]$Path, [string]$Text)
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($Path, $Text, $utf8)
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

function Get-DefaultInstallDir {
    param([string]$ForFlavor)
    $leaf = if ($ForFlavor -eq 'forge') { 'stable-diffusion-webui-forge' } else { 'stable-diffusion-webui' }
    if (-not $isWindowsHost) { return (Join-Path $HOME "AI/$leaf") }
    $systemDrive = $env:SystemDrive
    if (-not $systemDrive) { $systemDrive = 'C:' }
    return (Join-Path $systemDrive "AI\$leaf")
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
    param([string]$SdDir, [string]$Root)
    $values = Read-PixaromaConf
    if ($SdDir) { $values['SD_WEBUI'] = $SdDir }
    if ($Root) { $values['MODELS_ROOT'] = $Root }
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
        $p = Join-Path $Root $f
        if ($DryRun) { Write-Info "[dry-run] mkdir $p" }
        elseif (-not (Test-Path -LiteralPath $p)) { New-Item -ItemType Directory -Force -Path $p | Out-Null }
    }
}

function Set-ModelJunction {
    param([string]$Link, [string]$Target)
    if (Test-Path -LiteralPath $Link) {
        $item = Get-Item -LiteralPath $Link -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            $current = @($item.Target) | Select-Object -First 1
            if ($current -and ([IO.Path]::GetFullPath($current) -ieq [IO.Path]::GetFullPath($Target))) {
                Write-Info "junction already correct: $Link"
                return
            }
            Write-Warn2 "$Link already points at $current; leaving it unchanged"
            return
        }
        if (-not $item.PSIsContainer) {
            Fail "$Link is a file, but a model folder is expected there"
        }
        $children = @(Get-ChildItem -LiteralPath $Link -Force)
        $real = @($children | Where-Object { $_.Name -notmatch '^(put_.*_here|\.gitkeep|desktop\.ini)$' })
        if ($real.Count -gt 0) {
            Write-Warn2 "$Link contains files; not replacing it with a junction"
            return
        }
        if ($DryRun) {
            Write-Info "[dry-run] replace empty $Link with a junction to $Target"
            return
        }
        foreach ($c in $children) { Remove-Item -LiteralPath $c.FullName -Force }
        Remove-Item -LiteralPath $Link -Force
    }
    if ($DryRun) { Write-Info "[dry-run] junction $Link -> $Target"; return }
    $parent = Split-Path -Parent $Link
    if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    New-Item -ItemType Junction -Path $Link -Target $Target | Out-Null
    Write-Info "junction: $Link -> $Target"
}

function Set-SharedJunctions {
    param([string]$WebUiDir, [string]$Root)
    $maps = @(
        @('models\Stable-diffusion', 'checkpoints'),
        @('models\VAE', 'vae'),
        @('models\Lora', 'loras'),
        @('models\ControlNet', 'controlnet'),
        @('models\ESRGAN', 'upscale_models'),
        @('models\RealESRGAN', 'upscale_models'),
        @('models\CLIP', 'text_encoders'),
        @('models\Unet', 'diffusion_models'),
        @('models\clip_vision', 'clip_vision'),
        @('embeddings', 'embeddings')
    )
    foreach ($m in $maps) {
        $link = Join-Path $WebUiDir $m[0]
        $target = Join-Path $Root $m[1]
        if (-not (Test-Path -LiteralPath $target)) {
            if ($DryRun) { Write-Info "[dry-run] mkdir $target" }
            else { New-Item -ItemType Directory -Force -Path $target | Out-Null }
        }
        Set-ModelJunction -Link $link -Target $target
    }
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
    if ($git) { return $git.Source }
    $fallback = Join-Path $env:ProgramFiles 'Git\cmd\git.exe'
    if (Test-Path -LiteralPath $fallback) { return $fallback }
    Fail "Git was installed but is not on PATH; open a new terminal and re-run"
}

function Find-Python310 {
    $py = Get-Command py.exe -ErrorAction SilentlyContinue
    if (-not $py) { $py = Get-Command py -ErrorAction SilentlyContinue }
    if ($py) {
        $out = & $py.Source '-3.10' -c "import sys; print(sys.executable)" 2>$null
        if ($LASTEXITCODE -eq 0 -and $out) { return ([string]$out).Trim() }
    }
    foreach ($name in @('python.exe', 'python3.exe', 'python', 'python3')) {
        $c = Get-Command $name -ErrorAction SilentlyContinue
        if (-not $c) { continue }
        $ver = & $c.Source -c "import sys; print('%d.%d' % sys.version_info[:2])" 2>$null
        if ($LASTEXITCODE -eq 0 -and $ver -eq '3.10') { return $c.Source }
    }
    return $null
}

function Ensure-Python310 {
    $found = Find-Python310
    if ($found) { return $found }
    if ($NoPrereqInstall) { Fail "Python 3.10 is required. Install it with: winget install Python.Python.3.10" }

    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    if ($winget) {
        Write-Info "Python 3.10 not found; installing it with winget"
        & $winget.Source install --id Python.Python.3.10 -e --source winget --scope user --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -eq 0) {
            $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
            $found = Find-Python310
            if ($found) { return $found }
        } else {
            Write-Warn2 "winget could not install Python 3.10; using the python.org installer"
        }
    }

    $exe = Join-Path $env:TEMP 'python-3.10.6-amd64.exe'
    if (-not (Test-Path -LiteralPath $exe)) {
        Write-Info "downloading Python 3.10.6 from python.org"
        $curl = Get-Command curl.exe -ErrorAction SilentlyContinue
        if (-not $curl) { $curl = Get-Command curl -ErrorAction SilentlyContinue }
        if ($curl) {
            & $curl.Source -L --fail --retry 5 -o $exe 'https://www.python.org/ftp/python/3.10.6/python-3.10.6-amd64.exe'
            if ($LASTEXITCODE -ne 0) { Fail "could not download the Python 3.10.6 installer" }
        } else {
            Invoke-WebRequest -UseBasicParsing -Uri 'https://www.python.org/ftp/python/3.10.6/python-3.10.6-amd64.exe' -OutFile $exe
        }
    }
    Write-Info "running the Python 3.10.6 installer (per-user)"
    $p = Start-Process -FilePath $exe -ArgumentList @('/quiet', 'InstallAllUsers=0', 'PrependPath=0', 'Include_launcher=1', 'Include_test=0', 'Shortcuts=0') -Wait -PassThru
    if ($p.ExitCode -ne 0) { Fail "Python 3.10.6 installer failed with exit code $($p.ExitCode)" }

    $found = Find-Python310
    if ($found) { return $found }
    $fallback = Join-Path $env:LOCALAPPDATA 'Programs\Python\Python310\python.exe'
    if (Test-Path -LiteralPath $fallback) { return $fallback }
    Fail "Python 3.10 was installed but could not be located; open a new terminal and re-run"
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

function Write-WebUiLauncher {
    param([string]$WebUiDir, [string]$PythonExe)
    $managed = Join-Path $WebUiDir 'webui-user.bat'
    $custom = Join-Path $WebUiDir 'webui-user.pixaroma.bat'
    $bat = @"
@echo off
rem PIXAROMA MANAGED - generated by install-stablediffusion.ps1
set PYTHON="$PythonExe"
set GIT=
set VENV_DIR=
set COMMANDLINE_ARGS=--opt-sdp-attention --no-download-sd-model
call webui.bat %*
"@
    $target = $managed
    if (Test-Path -LiteralPath $managed) {
        $text = Get-Content -LiteralPath $managed -Raw
        if ($text -notmatch 'PIXAROMA MANAGED') {
            $meaningful = @(Get-Content -LiteralPath $managed | Where-Object {
                $t = $_.Trim()
                $t -and -not $t.StartsWith('@REM') -and -not $t.StartsWith('::')
            })
            $stock = @($meaningful | Where-Object {
                $_ -notmatch '^@echo off$' -and
                $_ -notmatch '^set (PYTHON|GIT|VENV_DIR|COMMANDLINE_ARGS)=$' -and
                $_ -notmatch '^call webui\.bat$'
            })
            if ($stock.Count -eq 0) {
                Copy-Item -LiteralPath $managed -Destination "$managed.stock" -Force
            } else {
                Write-Warn2 "existing webui-user.bat is customized; writing webui-user.pixaroma.bat instead"
                $target = $custom
            }
        }
    }
    if ($DryRun) { Write-Info "[dry-run] write $target"; return $target }
    Write-TextFile -Path $target -Text $bat
    Write-Info "wrote launcher: $target"
    return $target
}

function Invoke-WebUiBootTest {
    param([string]$Launcher, [string]$WebUiDir, [int]$Port = 7861)
    $outLog = Join-Path $env:TEMP 'pixaroma-sd-test.out.log'
    $errLog = Join-Path $env:TEMP 'pixaroma-sd-test.err.log'
    Write-Info "starting the WebUI on port $Port for a boot test (first run can take a while)"
    $proc = Start-Process -FilePath 'cmd.exe' -ArgumentList @('/c', "`"$Launcher`" --port $Port --skip-torch-cuda-test") -WorkingDirectory $WebUiDir -PassThru -WindowStyle Hidden -RedirectStandardOutput $outLog -RedirectStandardError $errLog
    $ok = $false
    try {
        for ($i = 0; $i -lt 450; $i++) {
            Start-Sleep -Seconds 2
            if ($proc.HasExited) { break }
            try {
                $r = Invoke-WebRequest -UseBasicParsing -Uri "http://127.0.0.1:$Port/" -TimeoutSec 3
                if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 500) { $ok = $true; break }
            } catch { }
        }
    } finally {
        if (-not $proc.HasExited) {
            & taskkill.exe /PID $proc.Id /T /F 2>$null | Out-Null
        }
    }
    if ($ok) {
        Write-Info "boot test passed: WebUI responded on port $Port"
        return
    }
    Write-Warn2 "boot test did not get a response. Last log lines:"
    foreach ($log in @($outLog, $errLog)) {
        if (Test-Path -LiteralPath $log) {
            Get-Content -LiteralPath $log -Tail 20 | ForEach-Object { Write-Host "     $_" }
        }
    }
    Fail "the WebUI did not start"
}

# --------------------------------------------------------------------- defaults
if (-not $isWindowsHost -and -not $DryRun) {
    Fail "This installer is for Windows. On Linux use ./install-stablediffusion.sh"
}

if (-not $InstallDir) { $InstallDir = Get-DefaultInstallDir -ForFlavor $Flavor }
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

$repoUrl = 'https://github.com/AUTOMATIC1111/stable-diffusion-webui.git'
if ($Flavor -eq 'forge') { $repoUrl = 'https://github.com/lllyasviel/stable-diffusion-webui-forge.git' }

Write-Step 'Plan'
Write-Info "flavour:      $Flavor"
Write-Info "install dir:  $InstallDir"
Write-Info "models root:  $ModelsRoot"
Write-Info "repository:   $repoUrl"
if ($DryRun) { Write-Info "mode:         dry run (no changes)" }
if (Test-IsAdmin) { Write-Warn2 "A1111/Forge are happiest as a normal user; administrator rights are not required" }

if (-not $DryRun) {
    if (-not (Test-Path -LiteralPath $InstallDir)) { New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null }
    New-Item -ItemType Directory -Force -Path $ModelsRoot | Out-Null
    $driveRoot = [IO.Path]::GetPathRoot($ModelsRoot)
    try {
        $free = (Get-PSDrive -Name $driveRoot.Substring(0, 1) -ErrorAction Stop).Free
        Write-Info "free space at models root: $(Format-Bytes $free)"
        if ($free -lt 850GB) {
            Write-Warn2 "the full Pixaroma catalog is 782.61 GB; $(Format-Bytes $free) free may not fit everything"
        }
    } catch { }
}

# ------------------------------------------------------------------------ clone
$mainPy = Join-Path $InstallDir 'launch.py'
if (Test-Path -LiteralPath $mainPy) {
    Write-Step 'WebUI checkout already present'
    Write-Info "found $mainPy"
} else {
    Write-Step 'Cloning the WebUI'
    if ((Test-Path -LiteralPath $InstallDir) -and @(Get-ChildItem -LiteralPath $InstallDir -Force).Count -gt 0) {
        Fail "$InstallDir is not empty and does not contain launch.py"
    }
    if ($DryRun) {
        Write-Info "[dry-run] git clone --depth 1 $repoUrl $InstallDir"
    } else {
        $git = Ensure-Git
        Invoke-Native -Exe $git -Arguments @('clone', '--depth', '1', $repoUrl, $InstallDir)
        if (-not (Test-Path -LiteralPath $mainPy)) { Fail "clone did not produce $mainPy" }
    }
}

# ---------------------------------------------------------- shared model links
if (-not $SkipConfig) {
    Write-Step 'Linking the WebUI model folders to the shared store'
    Initialize-SharedModels -Root $ModelsRoot
    Set-SharedJunctions -WebUiDir $InstallDir -Root $ModelsRoot
}

# ------------------------------------------------------------------- python + pip
$venvDir = Join-Path $InstallDir 'venv'
$venvPython = Join-Path $venvDir 'Scripts\python.exe'
if (-not (Test-Path -LiteralPath $venvPython)) {
    Write-Step 'Creating the Python 3.10 virtual environment'
    if ($DryRun) {
        Write-Info "[dry-run] locate/install Python 3.10"
        Write-Info "[dry-run] python -m venv $venvDir"
    } else {
        $basePython = Ensure-Python310
        Write-Info "using $basePython"
        Invoke-Native -Exe $basePython -Arguments @('-m', 'venv', $venvDir)
    }
}

if (-not $DryRun) {
    if (-not (Test-Path -LiteralPath $venvPython)) { Fail "venv was not created at $venvDir" }
    Write-Step 'Installing pip, PyTorch, and WebUI requirements'
    Invoke-Native -Exe $venvPython -Arguments @('-m', 'pip', 'install', '--upgrade', 'pip', 'wheel', 'setuptools')
    $wheelSet = Install-PyTorch -PythonExe $venvPython -CpuOnly:$Cpu
    Write-Info "PyTorch wheel set: $wheelSet"
    $requirements = Join-Path $InstallDir 'requirements_versions.txt'
    if (-not (Test-Path -LiteralPath $requirements)) { $requirements = Join-Path $InstallDir 'requirements.txt' }
    Invoke-Native -Exe $venvPython -Arguments @('-m', 'pip', 'install', '-r', $requirements)

    Write-Step 'Verifying PyTorch and CUDA'
    & $venvPython -c "import torch; print('torch', torch.__version__); print('cuda available:', torch.cuda.is_available()); print('device:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'CPU')"
    if ($LASTEXITCODE -ne 0) { Fail "PyTorch import failed" }
}

$launcher = Write-WebUiLauncher -WebUiDir $InstallDir -PythonExe $venvPython
if (-not $SkipConfig) {
    Write-PixaromaConf -SdDir $InstallDir -Root $ModelsRoot
}

# ---------------------------------------------------------------------- verify
Write-Step 'Summary'
Write-Info "WebUI:    $InstallDir"
Write-Info "models:   $ModelsRoot"
Write-Info "launch:   $launcher"
Write-Info "python:   $venvPython"
Write-Info "shared:   models\Stable-diffusion -> checkpoints, models\Lora -> loras, ..."
Write-Info "next:     .\setup.ps1 models --episode 6"

if ($Test -and -not $DryRun) {
    Invoke-WebUiBootTest -Launcher $launcher -WebUiDir $InstallDir
}
