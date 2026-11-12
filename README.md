# Pixaroma workflows + models — setup scripts

Self-contained installers for the 40 Pixaroma workflow packs and the exact model
files those workflows load. Everything is idempotent: re-running a script never
re-downloads a file that already exists.

A separate **shorts profile** installs a curated portrait social-media model
stack and workflow pack for vertical video, photo posts, and stories, with a
local post-copy generator. See [`SHORTS.md`](SHORTS.md).

## What is in this folder

| File | Purpose |
|---|---|
| `setup.ps1` | Windows: install workflows and/or models |
| `setup.sh` | Linux/macOS: install workflows and/or models |
| `install-comfyui.ps1` | Windows: official ComfyUI portable or git install |
| `install-comfyui-easy.ps1` | Windows: Tavris1 ComfyUI-Easy-Install wrapper |
| `install-stablediffusion.ps1` | Windows: AUTOMATIC1111 or Forge WebUI |
| `install-comfyui.sh` | Linux/macOS: official ComfyUI git install |
| `install-stablediffusion.sh` | Linux/macOS: A1111 or Forge WebUI |
| `models.psv` | Machine-readable catalog of all 133 model files |
| `shorts.psv` | Curated catalog for the portrait shorts/photo/story profile |
| `shorts/workflows/` | Portrait workflow pack copied by `shorts --install` |
| `shorts_post.py` | Local post-copy generator (templates + optional local Ollama) |
| `shorts-post.sh` / `shorts-post.ps1` | Thin wrappers for the copy generator |
| `MODELS.md` | Human-readable model catalog, sizes, shared files, special cases |
| `WORKFLOWS.md` | Every workflow in every episode pack |
| `SHORTS.md` | Shorts profile: types, pipelines, licensing, post copy |
| `AI-SETUP.md` | Recommended plan for the Windows 11 / RTX 3090 / 64 GB machine |
| `archives/` | The 40 episode zips plus `all-workflows.zip` (52 MB) |

## Catalog at a glance

- **40 episode packs**, **353 workflow JSON files**.
- **133 model files**: **132 downloadable** from Hugging Face, **1 manual**.
- **782.61 GB** total download size (782,613,056,329 bytes / 728.87 GiB).
- **33 files are shared across episodes**. Installing each episode separately
  would transfer 1.31 TB; sharing saves **525.02 GB**.
- 3 files are gated behind the FLUX 3 license; 3 more are downloaded by their
  ComfyUI nodes on first use and are intentionally not in the catalog.
- The optional **shorts profile** is separate: **18 permissively licensed
  files / 108.67 GB**, plus **4 FastH3 files / 43.63 GB** behind an explicit
  license gate. It reuses shared files already installed by the episodes.

Sizes are exact byte counts from `hf models list <repo> -R --format json`.
`models.psv` is the source of truth used by both setup scripts.

## Requirements

Common:

- Internet access to `huggingface.co` and `github.com`.
- The Hugging Face CLI, version 2.x:
  ```sh
  pip install -U "huggingface_hub[cli]"
  hf --version
  ```
- Free space for the models you select. The full catalog needs about **850 GB**
  free on the model volume (782.61 GB plus staging and output headroom). The
  largest single file is 27.08 GB.

Windows installers:

- Windows 10/11, PowerShell 5.1 or later.
- `winget` for automatic Git/Python installation (optional; the scripts fail
  with a hint if neither the tool nor winget is available).
- `7z`, `7za`, or Windows' `tar.exe` for extracting the ComfyUI portable
  archive. If none can read it, the installer downloads `7zr.exe` itself.
- Allow scripts in the current terminal:
  ```powershell
  Set-ExecutionPolicy -Scope Process Bypass
  ```

Linux/macOS installers:

- `git`, `unzip` (required by `setup.sh` for workflows), and Python 3.10–3.13
  (ComfyUI) or Python 3.10/3.11 (A1111/Forge).

## Quick start — Windows

```powershell
Set-ExecutionPolicy -Scope Process Bypass

# 1. Install ComfyUI and create the shared model store (pick one)
.\install-comfyui.ps1 -ModelsRoot D:\AI\models
# or: .\install-comfyui-easy.ps1 -ParentDir C:\AI -ModelsRoot D:\AI\models

# 2. Optional: Stable Diffusion WebUI sharing the same models
.\install-stablediffusion.ps1 -Flavor forge -ModelsRoot D:\AI\models

# 3. Install the 353 workflow files
.\setup.ps1 workflows

# 4. Download models for one episode first
.\setup.ps1 models -Episode 6

# 5. Later, install everything (782.61 GB)
.\setup.ps1 models -All -Yes
```

On the target RTX 3090 machine, follow `AI-SETUP.md` for the exact drive layout
and install order. `D:` there means the 1.8 TB HDD; adjust if your letters
differ.

## Quick start — Linux/macOS

```sh
chmod +x setup.sh install-comfyui.sh install-stablediffusion.sh

./install-comfyui.sh --dir ~/AI/ComfyUI --models-root /mnt/ai/models
./setup.sh workflows
./setup.sh models --episode 6
./setup.sh models --all --yes
```

## Pixaroma setup scripts

Both `setup.ps1` and `setup.sh` support the same targets and behavior:

| Target | What it does |
|---|---|
| `workflows` | Extracts selected episode zips into `ComfyUI/user/default/workflows/Pixaroma/` |
| `models` | Downloads the model files used by the selected episodes |
| `all` | Both, workflows first |
| `list` | Prints the catalog; writes nothing |
| `shorts` | Portrait models; add `--install` for the shorts workflow pack |

### Selection

- `--episode N` / `-Episode N` accepts `6`, `06`, `Ep06`, repeated flags, or a
  comma/space separated list (`-Episode 6,7,8`). Values are normalized.
- `--all` / `-All` selects every episode. Required for `models`/`all` when no
  episode is given.
- `list` with no filters shows the whole catalog.

### Options

| `setup.sh` | `setup.ps1` | Meaning |
|---|---|---|
| `--comfyui PATH` | `-ComfyUI PATH` | ComfyUI root (contains `models/` and `user/`) |
| `--models-root PATH` | `-ModelsRoot PATH` | Shared model store; defaults to `<ComfyUI>/models` |
| `--dry-run` | `-DryRun` | Show the plan; write and download nothing |
| `--yes` | `-Yes` | Skip the full-install confirmation prompt |
| `--verify` | `-Verify` | Check installed sizes; download nothing; exit 1 on problems |
| `--force-models` | `-ForceModels` | Re-download files that already exist |
| `--sort-size asc\|desc` | `-SortSize asc\|desc` | Download order by size; default `asc` (smallest first), `desc` largest first |
| `--force-workflows` | `-ForceWorkflows` | Overwrite existing workflow files |
| `--all-zip` | `-AllZip` | Extract `all-workflows.zip` instead of individual packs |
| `--short`, `--shorts` | `-Short`, `-Shorts` | Alias for the `shorts` target |
| `--install` | `-Install` | With `shorts`: also copy the selected workflow pack |
| `--type T` | `-Type T` | `short` (default), `photo`, `story`, or `all` |
| `--with-h3` | `-WithH3` | With `shorts`: include the 4 FastH3 files and workflows |
| `--accept-h3-license` | `-AcceptH3License` | Confirm the MiniMax H3 Community License terms |
| `--list` | `-List` | With `shorts`, print the shorts catalog and exit; alone, same as the `list` target |

`-DryRun`/`--dry-run` also asks Hugging Face for each selected file with
`hf download <repo> <path> --dry-run`. The output reports `remote: ok` or
`remote: check failed (network or access)` without downloading anything. Gated
files are still shown, with a login reminder.

`--verify` cannot be combined with `--force-models`. Verification exit codes:

- **0** — all selected files exist, sizes match, and manual files are present.
- **1** — missing files, a manual file is absent, or a size mismatch.
- **2** — invalid arguments or missing `models.psv`.

### Examples

```sh
./setup.sh list
./setup.sh list --episode 39
./setup.sh workflows --comfyui ~/ComfyUI
./setup.sh models --episode 6 --comfyui ~/ComfyUI
./setup.sh models --episode 6,7,8 --dry-run
./setup.sh models --episode 6 --sort-size desc --comfyui ~/ComfyUI
./setup.sh models --all --yes --comfyui ~/ComfyUI
./setup.sh models --all --verify
```

```powershell
.\setup.ps1 list
.\setup.ps1 list -Episode 39
.\setup.ps1 workflows -ComfyUI C:\AI\ComfyUI_windows_portable\ComfyUI
.\setup.ps1 models -Episode 6 -ComfyUI C:\AI\ComfyUI_windows_portable\ComfyUI
.\setup.ps1 models -Episode 6,7,8 -DryRun
.\setup.ps1 models -Episode 6 -SortSize desc
.\setup.ps1 models -All -Yes
.\setup.ps1 models -All -Verify
```

### Shorts profile

`shorts` is a separate target backed by `shorts.psv` and
`shorts/workflows/`. It installs portrait social-media models and, with
`--install` / `-Install`, copies the workflow pack into
`ComfyUI/user/default/workflows/Pixaroma/Shorts/`.

```sh
./setup.sh shorts --list
./setup.sh shorts --type photo --install --yes --comfyui ~/ComfyUI
./setup.sh shorts --type short --dry-run --comfyui ~/ComfyUI
./setup.sh --short --install --comfyui ~/ComfyUI
./setup.sh shorts --type all --with-h3 --accept-h3-license --dry-run
```

```powershell
.\setup.ps1 shorts -List
.\setup.ps1 -Short -Install -Yes
.\setup.ps1 shorts -Type photo -Install -Yes
.\setup.ps1 shorts -Type all -WithH3 -AcceptH3License -DryRun
```

| `--type` | Models | Workflows |
|---|---|---|
| `short` (default) | Full core stack, 18 files / 108.67 GB | Short Video, cover image, social sizes |
| `photo` | Z-Image Turbo + Qwen3-VL helper, 15.59 GB | All Photo Posts workflows |
| `story` | Z-Image Turbo + Qwen3-VL helper, 15.59 GB | Stories, 9:16 image, social sizes |
| `all` | Every core row | Every core category |

`--short` / `--shorts` is an alias for the target. `--install` is only valid
with shorts; without it, models are installed without workflows. FastH3 is
never included unless you pass `--with-h3 --accept-h3-license`. See
[`SHORTS.md`](SHORTS.md) for pipelines, VRAM notes, and the post-copy generator.

The eight permissively licensed generative shorts workflows also carry two local
Qwen3-VL 4B helper nodes: a **prompt enhancer** that rewrites your idea for the
selected model, and a **post writer** that reads the finished frames and writes
a caption, hashtags, and alt text. The copy is shown inside the workflow and
saved to `ComfyUI/output/Shorts/wan5b-post.txt` (one name per workflow) while
the workflow is open in a browser.
Both nodes can be bypassed with **Ctrl+B**. See
[`SHORTS.md`](SHORTS.md#prompt-enhancer-and-post-copy).

Generate captions, alt text, hashtags, and platform versions:

```sh
./shorts-post.sh --type short --topic "a dog surfing at sunset" \
  --platform instagram,tiktok,youtube --media output/short.mp4
```

### No re-downloading

- A file is skipped when the exact target path already exists, regardless of
  which episode requested it. Shared models are therefore downloaded once.
- `--force-models` is the only way to re-download an existing path.
- If an existing file has the wrong byte size, the script warns and leaves it
  untouched. Delete that one file and re-run, or use `--force-models`.
- Downloads are staged in `<ModelsRoot>/.pixaroma-staging/<hash>/`, verified
  against the manifest, then moved into place. Clean runs remove the staging
  folder; failed downloads keep partial data so `hf` can resume.
- Interrupted runs are safe: re-run the same command.

### Gated, renamed, substituted, manual

These are encoded in `models.psv`; see `MODELS.md` for details.

- **Gated (3 files, 17.41 GB)** — accept the license at
  <https://huggingface.co/black-forest-labs/flux-3-image-klein-comfy>, then run
  `hf auth login`. Without auth the scripts print a hint, skip those files, and
  exit 1 so you can re-run.
- **Renamed on install (2 files)** — the upstream name differs from the name the
  workflow expects; the scripts install the expected name automatically.
- **Substitute source (1 file)** — one linked repo was deleted upstream; a
  maintained 8.04 GB replacement is used.
- **Manual (1 file)** — `loras/krea2/krea2-questpaint26.safetensors` must be
  supplied by you. The script lists it at the end of a run.
- **Node-downloaded (3 files)** — QwenVL GGUF, YOLOX, and DWPose weights are
  fetched by `AILab_QwenVL_GGUF` / `DWPreprocessor` on first use and are not in
  the catalog.

## Shared model store

All installers create the same ComfyUI-style folder tree under the model root:

```
checkpoints  diffusion_models  text_encoders  clip  clip_vision  vae  loras
embeddings  controlnet  upscale_models  latent_upscale_models  model_patches
audio_encoders  background_removal  detection  sam3  geometry_estimation
SEEDVR2  style_models  gligen  photomaker  classifiers  frame_interpolation
optical_flow  hypernetworks  configs  diffusers  vae_approx
```

ComfyUI reads it through a `pixaroma_shared:` block in `extra_model_paths.yaml`
with `is_default: true`. `pixaroma.conf` next to the scripts stores:

```
COMFYUI=<path>
MODELS_ROOT=<path>
SD_WEBUI=<path>        # only after a WebUI install
```

Command-line flags override the saved values. If you move ComfyUI or the model
store, edit `pixaroma.conf` or pass the flags again.

### Stable Diffusion WebUI sharing

The WebUI installers replace empty model folders with junctions (Windows) or
symlinks (Linux/macOS):

| WebUI folder | Shared folder |
|---|---|
| `models/Stable-diffusion` | `checkpoints` |
| `models/VAE` | `vae` |
| `models/Lora` | `loras` |
| `models/ControlNet` | `controlnet` |
| `models/ESRGAN`, `models/RealESRGAN` | `upscale_models` |
| `models/CLIP` | `text_encoders` |
| `models/Unet` | `diffusion_models` |
| `models/clip_vision` | `clip_vision` |
| `embeddings` | `embeddings` |

If a folder already contains real files, the installer leaves it alone and
warns. Move those files into the shared store and re-run.

## Workflows and custom nodes

- Workflows are extracted to
  `<ComfyUI>/user/default/workflows/Pixaroma/`.
- The packs contain 353 workflow JSONs plus media, docs, and one prompt-tag
  library JSON (354 JSON files total). All pack contents are extracted.
- Existing files are kept unless `--force-workflows` / `-ForceWorkflows` is
  given.
- The zips contain workflow JSON only; they do not contain custom-node code.
  Open a workflow and use **Manager → Install Missing Custom Nodes** on a bare
  ComfyUI, then restart. Easy-Install bundles a curated node set, including
  Pixaroma nodes.

## Installers

### Official ComfyUI

```powershell
# Windows portable (default, fully automated)
.\install-comfyui.ps1 -ModelsRoot D:\AI\models

# Windows git checkout
.\install-comfyui.ps1 -Flavor git -InstallDir C:\AI\ComfyUI -ModelsRoot D:\AI\models
```

```sh
# Linux/macOS
./install-comfyui.sh --dir ~/AI/ComfyUI --models-root /mnt/ai/models
```

- Portable: downloads the latest official NVIDIA portable release, extracts it,
  writes the shared config, and prints `run_nvidia_gpu.bat`.
- Git: installs Git/Python with winget when missing, creates a venv, installs
  PyTorch cu128 → cu126 → cu121 (RTX 3090 works with all three), then
  `requirements.txt`. `--cpu` forces CPU wheels.
- Both support dry-run, `--skip-config`, and a boot test (`--test` / `-Test`).

### ComfyUI-Easy-Install (Windows)

```powershell
.\install-comfyui-easy.ps1 -ParentDir C:\AI -ModelsRoot D:\AI\models
```

Downloads the latest Tavris1 release, extracts it to a temporary folder, runs
`ComfyUI-Easy-Install.bat` interactively, then moves the finished install to
`C:\AI\ComfyUI-Easy-Install` and configures the shared model store. It refuses
to run elevated, so use a normal PowerShell window. It cannot be fully silent;
the installer itself requires user choices.

### Stable Diffusion WebUI

```powershell
.\install-stablediffusion.ps1 -Flavor a1111 -ModelsRoot D:\AI\models
.\install-stablediffusion.ps1 -Flavor forge -ModelsRoot D:\AI\models
```

```sh
./install-stablediffusion.sh --flavor forge --models-root /mnt/ai/models
```

On Windows both WebUIs require Python 3.10; the script installs it per-user if
needed. Forge is the better choice for the FLUX, Qwen, Krea, and video workflows
in this catalog. Both launchers use `--opt-sdp-attention --no-download-sd-model`.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `'hf' is not recognized` | `pip install -U "huggingface_hub[cli]"`, then reopen the terminal or add Python's `Scripts` folder to `PATH` |
| `running scripts is disabled` | `Set-ExecutionPolicy -Scope Process Bypass` |
| `ComfyUI not found` | Pass `-ComfyUI` / `--comfyui` with the folder containing `models/` and `user/` |
| Gated files skipped | Accept the FLUX 3 license, `hf auth login`, re-run |
| 403/401 from a gated repo | Same as above; confirm `hf auth whoami` shows your account |
| Wrong-size warning | Delete that one file and re-run, or use `-ForceModels` for the episode |
| Easy-Install refuses to start | Use a non-administrator PowerShell window |
| A1111 fails to install Python packages | Confirm `py -3.10` works; the WebUI does not support 3.11+ on Windows |
| Portable extraction fails | Install 7-Zip, or ensure Windows' `tar.exe` is available |
| Download interrupted | Re-run the same command; staging data is reused |
| Disk fills during a large episode | Install one episode at a time; Ep06 alone is 207.25 GB |

## License note

The workflow packs and model weights belong to their respective authors and
carry their own licenses. This folder only provides setup automation and a
catalog; review each model's license on Hugging Face before use, especially the
gated FLUX 3 files.

## More detail

- `MODELS.md` — every file, exact size, source, episode usage, shared-file
  savings, folder disagreements, renames, and gated/manual cases.
- `WORKFLOWS.md` — every workflow JSON and the models it loads, per episode.
- `SHORTS.md` — shorts profile: types, model stack, pipelines, licensing,
  hardware notes, and the post-copy generator.
- `AI-SETUP.md` — Windows 11 / RTX 3090 / 64 GB machine plan, drive layout,
  install order, disk budgets, and launch commands.
