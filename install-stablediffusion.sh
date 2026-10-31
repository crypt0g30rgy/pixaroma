#!/bin/sh
# Install Stable Diffusion WebUI (AUTOMATIC1111 or Forge) on Linux/macOS with
# the same shared model folder used by ComfyUI and the Pixaroma setup scripts.
#
# Usage:
#   ./install-stablediffusion.sh --models-root /mnt/ai/models
#   ./install-stablediffusion.sh --flavor forge --dir ~/AI/forge --cpu
#
# Existing checkouts and model files are reused. Nothing is deleted except the
# empty placeholder files shipped inside the WebUI repository.
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
CONF="$SCRIPT_DIR/pixaroma.conf"

FLAVOR="a1111"
INSTALL_DIR=""
MODELS_ROOT=""
CPU=0
DRY=0
SKIP_CONFIG=0
DO_TEST=0
PYTHON_OVERRIDE=""

usage() {
    cat <<'EOF'
Install Stable Diffusion WebUI on Linux or macOS.

Options:
  --flavor a1111|forge  WebUI flavor (default: a1111)
  --dir PATH            Install directory
  --models-root PATH    Shared model store (default: <install>/models)
  --python PATH         Python 3.10 or 3.11 for the venv
  --cpu                 Install CPU PyTorch instead of CUDA wheels
  --dry-run             Print the plan; make no changes
  --skip-config         Do not write pixaroma.conf
  --test                Start the WebUI on port 7861 and check it responds
  -h, --help            Show this help

The WebUI's model folders are symlinked to the shared ComfyUI-style store:
  models/Stable-diffusion -> checkpoints
  models/Lora             -> loras
  models/VAE              -> vae
  models/ControlNet       -> controlnet
  embeddings              -> embeddings
EOF
}

die() { printf 'error: %s\n' "$*" >&2; exit 2; }
say() { printf '   %s\n' "$*"; }
step() { printf '\n== %s ==\n' "$*"; }

while [ $# -gt 0 ]; do
    case "$1" in
        --flavor) [ $# -ge 2 ] || die "--flavor needs a value"; FLAVOR=$2; shift 2 ;;
        --flavor=*) FLAVOR=${1#*=}; shift ;;
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

case "$FLAVOR" in
    a1111) REPO=https://github.com/AUTOMATIC1111/stable-diffusion-webui.git; LEAF=stable-diffusion-webui ;;
    forge) REPO=https://github.com/lllyasviel/stable-diffusion-webui-forge.git; LEAF=stable-diffusion-webui-forge ;;
    *) die "--flavor must be a1111 or forge" ;;
esac

if [ -f "$CONF" ] && [ -z "$MODELS_ROOT" ]; then
    MODELS_ROOT=$(sed -n 's/^MODELS_ROOT=//p' "$CONF" | head -n 1)
fi
[ -n "$INSTALL_DIR" ] || INSTALL_DIR="$HOME/AI/$LEAF"
[ -n "$MODELS_ROOT" ] || MODELS_ROOT="$INSTALL_DIR/models"

case "$(uname -s)" in
    Linux|Darwin) ;;
    *) die "this installer supports Linux and macOS; use install-stablediffusion.ps1 on Windows" ;;
esac

if [ -n "$PYTHON_OVERRIDE" ]; then
    BASE_PYTHON=$PYTHON_OVERRIDE
else
    BASE_PYTHON=""
    for c in python3.10 python3.11 python3; do
        command -v "$c" >/dev/null 2>&1 || continue
        v=$("$c" -c 'import sys; print("%d.%d" % sys.version_info[:2])' 2>/dev/null || true)
        case "$v" in
            3.10|3.11) BASE_PYTHON=$(command -v "$c"); break ;;
        esac
    done
    [ -n "$BASE_PYTHON" ] || {
        if [ "$DRY" = 1 ]; then
            BASE_PYTHON="(not found; a real run needs Python 3.10 or 3.11)"
        else
            die "Python 3.10 or 3.11 not found. Install it, or pass --python PATH."
        fi
    }
fi

step "Plan"
say "flavour:      $FLAVOR"
say "install dir:  $INSTALL_DIR"
say "models root:  $MODELS_ROOT"
say "repository:   $REPO"
say "python:       $BASE_PYTHON"
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

step "WebUI checkout"
if [ -f "$INSTALL_DIR/launch.py" ]; then
    say "already present: $INSTALL_DIR/launch.py"
else
    if [ "$DRY" != 1 ]; then
        command -v git >/dev/null 2>&1 || die "git is required"
    fi
    if [ -d "$INSTALL_DIR" ] && [ -n "$(ls -A "$INSTALL_DIR" 2>/dev/null || true)" ]; then
        die "$INSTALL_DIR is not empty and has no launch.py"
    fi
    if [ "$DRY" = 1 ]; then
        command -v git >/dev/null 2>&1 || say "warning: git not found; a real run needs it to clone the WebUI"
        say "[dry-run] git clone --depth 1 $REPO $INSTALL_DIR"
    else
        git clone --depth 1 "$REPO" "$INSTALL_DIR"
    fi
fi

# ---------------------------------------------------------- shared model links
link_model() {
    link=$1
    target=$2
    if [ -L "$link" ]; then
        current=$(readlink "$link")
        if [ "$current" = "$target" ]; then
            say "symlink already correct: $link"
        else
            say "warning: $link -> $current; leaving it unchanged"
        fi
        return
    fi
    if [ -d "$link" ]; then
        real=$(ls -A "$link" 2>/dev/null | grep -v -E '^(put_.*_here|\.gitkeep|desktop\.ini)$' || true)
        if [ -n "$real" ]; then
            say "warning: $link contains files; not replacing it with a symlink"
            return
        fi
        if [ "$DRY" = 1 ]; then
            say "[dry-run] replace empty $link with a symlink to $target"
            return
        fi
        rm -f "$link"/put_*_here "$link"/.gitkeep 2>/dev/null || true
        rmdir "$link"
    elif [ -e "$link" ]; then
        say "warning: $link is not a directory; leaving it unchanged"
        return
    fi
    if [ "$DRY" = 1 ]; then
        say "[dry-run] symlink $link -> $target"
    else
        mkdir -p "$(dirname "$link")" "$target"
        ln -s "$target" "$link"
        say "symlink: $link -> $target"
    fi
}

if [ "$SKIP_CONFIG" != 1 ]; then
    step "Shared model store"
    if [ "$DRY" = 1 ]; then
        say "[dry-run] create model folders under $MODELS_ROOT"
    else
        for f in checkpoints diffusion_models text_encoders clip clip_vision vae loras embeddings \
                 controlnet upscale_models latent_upscale_models model_patches audio_encoders \
                 background_removal detection sam3 geometry_estimation SEEDVR2 style_models \
                 gligen photomaker classifiers frame_interpolation optical_flow hypernetworks \
                 configs diffusers vae_approx; do
            mkdir -p "$MODELS_ROOT/$f"
        done
    fi
    link_model "$INSTALL_DIR/models/Stable-diffusion" "$MODELS_ROOT/checkpoints"
    link_model "$INSTALL_DIR/models/VAE" "$MODELS_ROOT/vae"
    link_model "$INSTALL_DIR/models/Lora" "$MODELS_ROOT/loras"
    link_model "$INSTALL_DIR/models/ControlNet" "$MODELS_ROOT/controlnet"
    link_model "$INSTALL_DIR/models/ESRGAN" "$MODELS_ROOT/upscale_models"
    link_model "$INSTALL_DIR/models/RealESRGAN" "$MODELS_ROOT/upscale_models"
    link_model "$INSTALL_DIR/models/CLIP" "$MODELS_ROOT/text_encoders"
    link_model "$INSTALL_DIR/models/Unet" "$MODELS_ROOT/diffusion_models"
    link_model "$INSTALL_DIR/models/clip_vision" "$MODELS_ROOT/clip_vision"
    link_model "$INSTALL_DIR/embeddings" "$MODELS_ROOT/embeddings"
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
    say "[dry-run] pip install -r $INSTALL_DIR/requirements_versions.txt"
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
    REQ="$INSTALL_DIR/requirements_versions.txt"
    [ -f "$REQ" ] || REQ="$INSTALL_DIR/requirements.txt"
    "$VENV_PY" -m pip install -r "$REQ"

    step "Verifying PyTorch"
    "$VENV_PY" -c "import torch; print('torch', torch.__version__); print('cuda available:', torch.cuda.is_available()); print('mps available:', getattr(torch.backends, 'mps', None) is not None and torch.backends.mps.is_available())" || die "PyTorch import failed"

    if [ -f "$INSTALL_DIR/webui-user.sh" ] && ! grep -q 'PIXAROMA MANAGED' "$INSTALL_DIR/webui-user.sh"; then
        cp "$INSTALL_DIR/webui-user.sh" "$INSTALL_DIR/webui-user.sh.bak-$(date +%Y%m%d-%H%M%S)"
    fi
    cat > "$INSTALL_DIR/webui-user.sh" <<'EOF'
#!/bin/sh
# PIXAROMA MANAGED - generated by install-stablediffusion.sh
export COMMANDLINE_ARGS="--opt-sdp-attention --no-download-sd-model"
EOF
    cat > "$INSTALL_DIR/run_webui.sh" <<'EOF'
#!/bin/sh
cd "$(dirname "$0")"
exec ./webui.sh "$@"
EOF
    chmod +x "$INSTALL_DIR/run_webui.sh"
    say "wrote launcher: $INSTALL_DIR/run_webui.sh"
fi

if [ "$SKIP_CONFIG" != 1 ] && [ "$DRY" != 1 ]; then
    OLD_COMFY=$(sed -n 's/^COMFYUI=//p' "$CONF" 2>/dev/null | head -n 1 || true)
    {
        echo "# Generated by the Pixaroma installers. Command-line flags override these values."
        [ -n "$OLD_COMFY" ] && echo "COMFYUI=$OLD_COMFY"
        echo "MODELS_ROOT=$MODELS_ROOT"
        echo "SD_WEBUI=$INSTALL_DIR"
    } > "$CONF.tmp"
    mv "$CONF.tmp" "$CONF"
    say "wrote $CONF"
fi

if [ "$DO_TEST" = 1 ] && [ "$DRY" != 1 ]; then
    step "Boot test"
    command -v curl >/dev/null 2>&1 || die "curl is required for --test"
    LOG="$INSTALL_DIR/.boot-test.log"
    ./run_webui.sh --port 7861 --skip-torch-cuda-test >"$LOG" 2>&1 &
    pid=$!
    ok=0
    i=0
    while [ "$i" -lt 450 ]; do
        sleep 2
        if curl -fsS "http://127.0.0.1:7861/" >/dev/null 2>&1; then ok=1; break; fi
        kill -0 "$pid" 2>/dev/null || break
        i=$((i + 1))
    done
    kill "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
    if [ "$ok" = 1 ]; then
        say "boot test passed on port 7861"
    else
        say "boot test failed; last log lines:"
        tail -n 25 "$LOG" 2>/dev/null || true
        exit 1
    fi
fi

step "Summary"
say "WebUI:    $INSTALL_DIR"
say "models:   $MODELS_ROOT"
say "launch:   $INSTALL_DIR/run_webui.sh"
say "next:     ./setup.sh models --episode 6"
