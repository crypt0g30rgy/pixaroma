#!/bin/sh
# Install the official ComfyUI on Linux or macOS with a shared model folder.
#
# Usage:
#   ./install-comfyui.sh --models-root /mnt/ai/models
#   ./install-comfyui.sh --dir ~/AI/ComfyUI --models-root /mnt/ai/models --cpu
#
# Existing checkouts, venvs, and model files are reused. Nothing is deleted.
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
CONF="$SCRIPT_DIR/pixaroma.conf"

INSTALL_DIR=""
MODELS_ROOT=""
CPU=0
DRY=0
SKIP_CONFIG=0
DO_TEST=0
PYTHON_OVERRIDE=""

usage() {
    cat <<'EOF'
Install official ComfyUI (git) on Linux or macOS.

Options:
  --dir PATH          Install directory (default: ~/AI/ComfyUI)
  --models-root PATH  Shared model store. Default: <install>/models
  --python PATH       Python 3.10-3.13 to use for the venv
  --cpu               Install CPU PyTorch instead of CUDA wheels
  --dry-run           Print the plan; make no changes
  --skip-config       Do not write extra_model_paths.yaml / pixaroma.conf
  --test              Boot ComfyUI on port 8189 and check it responds
  -h, --help          Show this help

The shared store uses ComfyUI folder names (checkpoints, loras, vae, ...), so
the same files can be used by ComfyUI and Stable Diffusion WebUI.
EOF
}

die() { printf 'error: %s\n' "$*" >&2; exit 2; }
say() { printf '   %s\n' "$*"; }
step() { printf '\n== %s ==\n' "$*"; }

while [ $# -gt 0 ]; do
    case "$1" in
        --dir) [ $# -ge 2 ] || die "--dir needs a value"; INSTALL_DIR=$2; shift 2 ;;
        --dir=*) INSTALL_DIR=${1#*=}; shift ;;
        --models-root) [ $# -ge 2 ] || die "--models-root needs a value"; MODELS_ROOT=$2; shift 2 ;;
        --models-root=*) MODELS_ROOT=${1#*=}; shift ;;
        --python) [ $# -ge 2 ] || die "--python needs a value"; PYTHON_OVERRIDE=$2; shift 2 ;;
        --python=*) PYTHON_OVERRIDE=${1#*=}; shift ;;
        --cpu) CPU=1; shift ;;
        --dry-run) DRY=1; shift ;;
        --skip-config) SKIP_CONFIG=1; shift ;;
        --test) DO_TEST=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) die "unknown argument: $1 (try --help)" ;;
    esac
done

# Saved defaults from install-comfyui.ps1 / this script.
if [ -f "$CONF" ]; then
    [ -n "$MODELS_ROOT" ] || MODELS_ROOT=$(sed -n 's/^MODELS_ROOT=//p' "$CONF" | head -n 1)
    [ -n "$INSTALL_DIR" ] || INSTALL_DIR=$(sed -n 's/^COMFYUI=//p' "$CONF" | head -n 1)
fi
[ -n "$INSTALL_DIR" ] || INSTALL_DIR="$HOME/AI/ComfyUI"
[ -n "$MODELS_ROOT" ] || MODELS_ROOT="$INSTALL_DIR/models"

case "$(uname -s)" in
    Linux|Darwin) ;;
    *) die "this installer supports Linux and macOS; use install-comfyui.ps1 on Windows" ;;
esac

if [ -n "$PYTHON_OVERRIDE" ]; then
    BASE_PYTHON=$PYTHON_OVERRIDE
else
    BASE_PYTHON=""
    for c in python3.12 python3.11 python3.10 python3.13 python3; do
        command -v "$c" >/dev/null 2>&1 || continue
        v=$("$c" -c 'import sys; print("%d.%d" % sys.version_info[:2])' 2>/dev/null || true)
        case "$v" in
            3.10|3.11|3.12|3.13) BASE_PYTHON=$(command -v "$c"); break ;;
        esac
    done
    [ -n "$BASE_PYTHON" ] || {
        if [ "$DRY" = 1 ]; then
            BASE_PYTHON="(not found; a real run needs Python 3.10-3.13)"
        else
            die "Python 3.10-3.13 not found. Install it and re-run, or pass --python PATH."
        fi
    }
fi

step "Plan"
say "install dir:  $INSTALL_DIR"
say "models root:  $MODELS_ROOT"
say "python:       $BASE_PYTHON"
[ "$CPU" = 1 ] && say "torch:        CPU"
[ "$DRY" = 1 ] && say "mode:         dry run (no changes)"

if [ "$DRY" != 1 ]; then
    mkdir -p "$INSTALL_DIR" "$MODELS_ROOT"
    free_kb=$(df -Pk "$MODELS_ROOT" | awk 'NR==2 {print $4}')
    if [ -n "$free_kb" ]; then
        free_gb=$((free_kb / 1024 / 1024))
        say "free space:   ${free_gb} GB"
        [ "$free_gb" -ge 850 ] || say "warning: the full Pixaroma catalog is 782.61 GB"
    fi
fi

step "ComfyUI checkout"
if [ -f "$INSTALL_DIR/main.py" ]; then
    say "already present: $INSTALL_DIR/main.py"
else
    if [ "$DRY" != 1 ]; then
        command -v git >/dev/null 2>&1 || die "git is required"
    fi
    if [ -d "$INSTALL_DIR" ] && [ -n "$(ls -A "$INSTALL_DIR" 2>/dev/null || true)" ]; then
        die "$INSTALL_DIR is not empty and has no main.py"
    fi
    if [ "$DRY" = 1 ]; then
        command -v git >/dev/null 2>&1 || say "warning: git not found; a real run needs it to clone ComfyUI"
        say "[dry-run] git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git $INSTALL_DIR"
    else
        git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git "$INSTALL_DIR"
    fi
fi

VENV_DIR="$INSTALL_DIR/venv"
VENV_PY="$VENV_DIR/bin/python"
if [ -x "$VENV_PY" ]; then
    say "venv already present: $VENV_DIR"
else
    if [ "$DRY" = 1 ]; then
        say "[dry-run] $BASE_PYTHON -m venv $VENV_DIR"
    else
        "$BASE_PYTHON" -m venv "$VENV_DIR" || die "venv creation failed (install python3-venv?)"
    fi
fi

if [ "$DRY" = 1 ]; then
    step "Python packages"
    say "[dry-run] pip install --upgrade pip wheel setuptools"
    if [ "$CPU" = 1 ]; then
        say "[dry-run] pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu"
    elif [ "$(uname -s)" = "Darwin" ]; then
        say "[dry-run] pip install torch torchvision torchaudio"
    else
        say "[dry-run] pip install torch torchvision torchaudio (cu128, then cu126, then cu121)"
    fi
    say "[dry-run] pip install -r $INSTALL_DIR/requirements.txt"
else
    step "Python packages"
    "$VENV_PY" -m pip install --upgrade pip wheel setuptools
    installed=0
    if [ "$CPU" = 1 ]; then
        "$VENV_PY" -m pip install --upgrade torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu && installed=1
    elif [ "$(uname -s)" = "Darwin" ]; then
        "$VENV_PY" -m pip install --upgrade torch torchvision torchaudio && installed=1
    else
        for idx in cu128 cu126 cu121; do
            say "trying PyTorch $idx wheels"
            if "$VENV_PY" -m pip install --upgrade torch torchvision torchaudio --index-url "https://download.pytorch.org/whl/$idx"; then
                installed=1
                break
            fi
            say "warning: PyTorch $idx failed; trying the next wheel set"
        done
    fi
    [ "$installed" = 1 ] || die "could not install PyTorch; see https://pytorch.org/"
    "$VENV_PY" -m pip install -r "$INSTALL_DIR/requirements.txt"

    step "Verifying PyTorch"
    "$VENV_PY" -c "import torch; print('torch', torch.__version__); print('cuda available:', torch.cuda.is_available()); print('mps available:', getattr(torch.backends, 'mps', None) is not None and torch.backends.mps.is_available())" || die "PyTorch import failed"

    cat > "$INSTALL_DIR/run_comfyui.sh" <<'EOF'
#!/bin/sh
cd "$(dirname "$0")"
exec ./venv/bin/python main.py "$@"
EOF
    chmod +x "$INSTALL_DIR/run_comfyui.sh"
    say "wrote launcher: $INSTALL_DIR/run_comfyui.sh"
fi

if [ "$SKIP_CONFIG" != 1 ]; then
    step "Shared model store"
    if [ "$DRY" = 1 ]; then
        say "[dry-run] create model folders under $MODELS_ROOT"
        say "[dry-run] write $INSTALL_DIR/extra_model_paths.yaml"
        say "[dry-run] write $CONF"
    else
        for f in checkpoints diffusion_models text_encoders clip clip_vision vae loras embeddings \
                 controlnet upscale_models latent_upscale_models model_patches audio_encoders \
                 background_removal detection sam3 geometry_estimation SEEDVR2 style_models \
                 gligen photomaker classifiers frame_interpolation optical_flow hypernetworks \
                 configs diffusers vae_approx; do
            mkdir -p "$MODELS_ROOT/$f"
        done
        YAML="$INSTALL_DIR/extra_model_paths.yaml"
        if [ -f "$YAML" ] && grep -q '^pixaroma_shared:' "$YAML"; then
            say "extra_model_paths.yaml already contains pixaroma_shared; left unchanged"
        else
            {
                if [ ! -f "$YAML" ]; then
                    echo "# Added by the Pixaroma installer"
                else
                    echo ""
                fi
                cat <<EOF
pixaroma_shared:
    base_path: "$MODELS_ROOT"
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
EOF
            } >> "$YAML"
            say "wrote $YAML"
        fi

        OLD_SD=$(sed -n 's/^SD_WEBUI=//p' "$CONF" 2>/dev/null | head -n 1 || true)
        {
            echo "# Generated by the Pixaroma installers. Command-line flags override these values."
            echo "COMFYUI=$INSTALL_DIR"
            echo "MODELS_ROOT=$MODELS_ROOT"
            [ -n "$OLD_SD" ] && echo "SD_WEBUI=$OLD_SD"
        } > "$CONF.tmp"
        mv "$CONF.tmp" "$CONF"
        say "wrote $CONF"
    fi
fi

if [ "$DO_TEST" = 1 ] && [ "$DRY" != 1 ]; then
    step "Boot test"
    command -v curl >/dev/null 2>&1 || die "curl is required for --test"
    LOG="$INSTALL_DIR/.boot-test.log"
    "$VENV_PY" main.py --cpu --port 8189 --dont-print-server >"$LOG" 2>&1 &
    pid=$!
    ok=0
    i=0
    while [ "$i" -lt 90 ]; do
        sleep 2
        if curl -fsS "http://127.0.0.1:8189/" >/dev/null 2>&1; then ok=1; break; fi
        kill -0 "$pid" 2>/dev/null || break
        i=$((i + 1))
    done
    kill "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
    if [ "$ok" = 1 ]; then
        say "boot test passed on port 8189"
    else
        say "boot test failed; last log lines:"
        tail -n 20 "$LOG" 2>/dev/null || true
        exit 1
    fi
fi

step "Summary"
say "ComfyUI:  $INSTALL_DIR"
say "models:   $MODELS_ROOT"
say "launch:   $INSTALL_DIR/run_comfyui.sh"
say "workflows: ./setup.sh workflows --comfyui $INSTALL_DIR"
say "models:    ./setup.sh models --episode 6"
