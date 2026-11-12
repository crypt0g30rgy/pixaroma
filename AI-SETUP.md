# AI test system setup — Windows 11, RTX 3090

This is the recommended install plan for the target machine:

| Component | Spec |
|---|---|
| OS | Windows 11 Pro 10.0.26200 |
| CPU / RAM | Ryzen 7 5800X, 64 GB |
| GPU | RTX 3090 24 GB, driver 610.62 (Ampere, CUDA 12.x capable) |
| Storage | SSD 476.9 GB + HDD 1.8 TB |
| Display | 2560×1440 |

The full Pixaroma catalog is **782.61 GB** (133 files, 353 workflows), so the
model store belongs on the 1.8 TB HDD. Apps, virtual environments, and caches
belong on the SSD.

Throughout this guide **`C:` is the SSD and `D:` is the 1.8 TB HDD**. Substitute
the real drive letters from Disk Management if they differ.

## Recommended layout

| Path | Contents | Why |
|---|---|---|
| `C:\AI\ComfyUI_windows_portable` | Official ComfyUI portable | Fast app/venv access |
| `C:\AI\ComfyUI-Easy-Install` | Optional Easy-Install flavour | Alternative to the above |
| `C:\AI\stable-diffusion-webui` | Optional A1111/Forge | Shares the same models |
| `D:\AI\models` | All 133 episode model files plus optional shorts models, ComfyUI folder names | 782.61 GB episode catalog; shorts shares the same folders |
| `D:\AI\models\.pixaroma-staging` | Temporary download staging (auto-removed) | One large file at a time |

ComfyUI outputs go to the app folder by default. For long video renders, point
ComfyUI's output directory at the HDD too; 24 GB of VRAM and 64 GB of RAM are
fine for this catalog, but generated video fills an SSD quickly.

Free-space targets:

- **Model drive:** at least **850 GB free** for the full catalog, plus headroom
  for outputs. The largest single file is 27.08 GB (`ltx-2-19b-distilled-fp8`),
  so keep at least ~60 GB free while downloading even if you install by episode.
- **SSD:** roughly 20–30 GB for ComfyUI, Python, PyTorch, the WebUI, and caches.

If the HDD has less than 850 GB free, install episode by episode instead of
`-All` (see [Install by episode](#install-by-episode)). Shared files are skipped
on later runs.

## Before you start

1. Open **Windows Terminal → PowerShell** as your normal user. Do not run the
   Easy-Install wrapper as Administrator; it refuses to run elevated.
2. Allow scripts for this terminal only:
   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass
   ```
3. Install the Hugging Face CLI (needed by `setup.ps1`). Any system Python works:
   ```powershell
   py -3 -m pip install -U "huggingface_hub[cli]"
   hf --version
   ```
   If `hf` is not found, re-open the terminal or add Python's `Scripts` folder
   to `PATH`. You can also use the portable ComfyUI Python:
   ```powershell
   C:\AI\ComfyUI_windows_portable\python_embeded\python.exe -m pip install -U "huggingface_hub[cli]"
   ```
   In that case add `C:\AI\ComfyUI_windows_portable\python_embeded\Scripts` to
   `PATH` so the bare `hf` command resolves.
4. Optional but recommended: accept the FLUX 3 license before starting (three
   gated files, 17.41 GB total):
   <https://huggingface.co/black-forest-labs/flux-3-image-klein-comfy>
   Then run `hf auth login`. Without it, the scripts skip those three files and
   exit 1 so you can re-run later.
5. Keep the scripts, `models.psv`, `shorts.psv`, `archives\`, `shorts\`, and the
   Markdown files together in one folder. The scripts resolve everything
   relative to that folder.

## Step 1 — Install ComfyUI

Pick **one** ComfyUI flavour.

### Option A — official ComfyUI portable (recommended, fully automated)

```powershell
.\install-comfyui.ps1 -ModelsRoot D:\AI\models
```

What it does:

- Finds the latest official Windows portable NVIDIA release.
- Downloads and extracts it to `C:\AI\ComfyUI_windows_portable`.
- Creates the 28-folder shared model tree at `D:\AI\models`.
- Writes `extra_model_paths.yaml` inside ComfyUI and `pixaroma.conf` next to
  these scripts, so every later command finds both locations.
- Verifies `ComfyUI\main.py` and prints `run_nvidia_gpu.bat`.

Useful flags:

```powershell
.\install-comfyui.ps1 -DryRun                      # show the plan only
.\install-comfyui.ps1 -InstallDir E:\AI\ComfyUI_portable -ModelsRoot D:\AI\models
.\install-comfyui.ps1 -Flavor git -InstallDir C:\AI\ComfyUI -ModelsRoot D:\AI\models
```

The `git` flavour clones ComfyUI, creates a venv, and installs PyTorch **cu128**
first (the RTX 3090 is supported), falling back to cu126, cu121, then CPU. It
installs Git/Python with winget if they are missing. `-Cpu` forces CPU wheels.

### Option B — ComfyUI-Easy-Install (interactive)

```powershell
.\install-comfyui-easy.ps1 -ParentDir C:\AI -ModelsRoot D:\AI\models
```

This downloads the latest Tavris1 release, extracts it to a staging folder,
starts the official `ComfyUI-Easy-Install.bat` console, waits for you to finish
its prompts, then moves the result to `C:\AI\ComfyUI-Easy-Install` and applies
the shared model configuration.

- It is **interactive by design**; Easy-Install has no silent mode.
- Run it from a normal, non-elevated PowerShell window.
- It installs a curated custom-node set (including Pixaroma nodes), which makes
  the episode workflows start faster than a bare ComfyUI.
- If Easy-Install left model files inside its own `ComfyUI\models` folder, move
  them into `D:\AI\models\<same-folder>\` and delete the local copies so the
  catalog has one copy of each file.

### Option C — official ComfyUI from git (Windows)

```powershell
.\install-comfyui.ps1 -Flavor git -InstallDir C:\AI\ComfyUI -ModelsRoot D:\AI\models
```

Launch with `C:\AI\ComfyUI\run_comfyui.bat`.

Linux/macOS equivalent of Option C:

```sh
./install-comfyui.sh --dir ~/AI/ComfyUI --models-root /mnt/ai/models
```

## Step 2 — Optional: Stable Diffusion WebUI

A1111 and Forge are alternatives to ComfyUI, not requirements. Both can share
the exact same model files through directory junctions (Windows) or symlinks
(Linux), so nothing is downloaded twice.

```powershell
# AUTOMATIC1111
.\install-stablediffusion.ps1 -Flavor a1111 -InstallDir C:\AI\stable-diffusion-webui -ModelsRoot D:\AI\models

# Forge (better Flux/SDXL support)
.\install-stablediffusion.ps1 -Flavor forge -InstallDir C:\AI\stable-diffusion-webui-forge -ModelsRoot D:\AI\models
```

The installer:

- installs Python **3.10** (required on Windows by both WebUIs) and Git via
  winget or the python.org installer if missing;
- creates a venv, installs PyTorch cu128 → cu126 → cu121, then the WebUI
  requirements;
- replaces the WebUI's empty model folders with junctions:
  `Stable-diffusion → checkpoints`, `Lora → loras`, `VAE → vae`,
  `ControlNet → controlnet`, `ESRGAN/RealESRGAN → upscale_models`,
  `CLIP → text_encoders`, `Unet → diffusion_models`,
  `clip_vision → clip_vision`, `embeddings → embeddings`;
- writes `webui-user.bat` with `--opt-sdp-attention --no-download-sd-model`;
- prints the launcher and can boot-test on port 7861 with `-Test`.

If a WebUI model folder already contains files, the installer leaves it alone
and warns instead of replacing it. Move those files into the shared store, then
re-run the installer.

Forge is the better choice for the FLUX/Qwen/Krea workflows in this catalog.
A1111 is fine for SD 1.5/SDXL work but does not load most of the newer
architectures these workflows use.

Linux/macOS:

```sh
./install-stablediffusion.sh --flavor forge --dir ~/AI/forge --models-root /mnt/ai/models
```

## Step 3 — Install the Pixaroma workflows

```powershell
.\setup.ps1 workflows
```

- Extracts all 40 episode packs from `archives\` into
  `C:\AI\ComfyUI_windows_portable\ComfyUI\user\default\workflows\Pixaroma\`.
- Installs **353 workflow JSON files**, plus the packs' media/docs and one
  prompt-tag library JSON (354 JSON files total).
- Existing workflow files are kept; use `-ForceWorkflows` to overwrite them.
- `-AllZip` extracts `all-workflows.zip` (the same 40 packs under one parent
  folder) instead of the individual zips.

The script auto-detects ComfyUI. If it cannot, pass `-ComfyUI`:

```powershell
.\setup.ps1 workflows -ComfyUI C:\AI\ComfyUI-Easy-Install\ComfyUI
```

## Step 4 — Download models

Small first run (recommended):

```powershell
.\setup.ps1 models -Episode 6
```

Full catalog (782.61 GB):

```powershell
.\setup.ps1 models -All -Yes
```

How it behaves:

- Only files used by the selected episodes are considered.
- Files already present at the exact target path are skipped. Repeated models
  are downloaded once even when many episodes need them.
- Each download goes to `D:\AI\models\.pixaroma-staging\<hash>\`, is checked
  against the manifest byte count, then moved into place. The staging folder is
  removed when the run finishes cleanly. Failed downloads keep their partial
  data so a re-run resumes.
- `-DryRun` prints the selection and URLs and validates each remote path with
  `hf download --dry-run`; it writes and downloads nothing. Gated files are
  shown with a login reminder even when you are not authenticated.
- `-Verify` checks sizes of installed files and lists what is missing; it
  downloads nothing and exits 1 if anything is absent or the wrong size.
- `-ForceModels` re-downloads files that already exist. It cannot be combined
  with `-Verify`.
- Downloads are ordered smallest first by default. `-SortSize desc` starts
  with the largest instead. The byte counts in `models.psv` set the order, and
  a file that is already installed is always skipped.

### Install by episode

Episode 6 is the largest pack at 207.25 GB. Other large packs are Ep25
(88.26 GB), Ep32 (65.40 GB), and Ep29 (63.44 GB). To stay under a smaller free
-space budget, install a few episodes at a time:

```powershell
.\setup.ps1 models -Episode 1
.\setup.ps1 models -Episode 2,3,4
.\setup.ps1 models -Episode 25
```

Each later run skips everything already installed, including shared files such
as `flux2-vae.safetensors` (used by 17 episodes) and
`qwen_3_8b_fp8mixed.safetensors` (used by 14).

### Selection examples

```powershell
.\setup.ps1 list                          # whole catalog, no writes
.\setup.ps1 list -Episode 39              # only Ep39
.\setup.ps1 models -Episode 6 -DryRun     # preview Ep06
.\setup.ps1 models -Episode 6 -Verify     # check Ep06 without downloading
.\setup.ps1 all -Episode 25               # workflows + models for Ep25
```

## Optional — shorts profile (portrait video, photo posts, stories)

The shorts profile installs a curated portrait social-media stack and its
matching workflows. It uses the same `D:\AI\models` store, so files already
installed by the episode packs are reused.

```powershell
.\setup.ps1 shorts -List                 # sizes and sources; writes nothing
.\setup.ps1 shorts -Type short -DryRun   # validate remote paths
.\setup.ps1 -Short -Install -Yes         # core models + workflow pack
.\setup.ps1 shorts -Type photo -Install -Yes
```

- **Core stack:** 18 files / **108.67 GB** (Apache 2.0 or MIT). Shared files
  such as UMT5, the Wan VAEs, CLIP vision, wav2vec2, and Z-Image are skipped if
  an episode install already placed them. The Qwen3-VL 4B prompt enhancer
  (`qwen3vl_4b_fp8_scaled.safetensors`, 5.24 GB) is also used by Ep24–26, so it
  is usually already present.
- **Optional FastH3:** 4 files / **43.63 GB**, MiniMax H3 Community License.
  Use is excluded in the US, EU, UK, and South Korea; enabling it requires
  `-WithH3 -AcceptH3License`. It needs the 64 GB system RAM for offload.
- **Disk:** budget about 108 GB beyond the episode models, plus 44 GB for H3.
  The HDD is fine for the store; first loads of the 12 GB GGUFs are slower than
  from an SSD. Point ComfyUI output at `D:` — video renders fill the SSD fast.
- **Workflows:** `C:\AI\ComfyUI_windows_portable\ComfyUI\user\default\workflows\Pixaroma\Shorts\`
  (Short Video, Photo Posts, Stories, and an H3 folder only with the license
  gate). Open them from the workflow browser like the episode packs.
- **Prompt enhancer and post writer:** the eight permissively licensed
  generative workflows include two local Qwen3-VL 4B Pixaroma nodes that improve
  the prompt and write the caption, hashtags, and alt text from the finished
  frames. The copy previews on the node and saves to
  `ComfyUI\output\Shorts\wan5b-post.txt` (the **Post file name** value plus
  `.txt`) while the workflow is open in a browser. Press Ctrl+B on either node
  to bypass it.
- **Character motion:** Short Video / 3b. Character Motion - SCAIL-2 takes a
  full-body image of yourself or any character and a video of the motion to
  copy, and outputs that character performing it. Dance, martial arts, gestures,
  and other full-body actions work. It reuses the SCAIL-2 models already in the
  core stack, so it adds no downloads.
- **Post copy:** `.\shorts-post.ps1 --type short --topic "..."`
  writes captions, alt text, hashtags, and platform text locally. It uses
  templates by default and a local Ollama only if you pass `--ollama`.

The 14B GGUF and SCAIL-2 workflows are tight on 24 GB VRAM; keep ComfyUI model
offloading on and close other GPU apps. See [`SHORTS.md`](SHORTS.md) for the
pipelines, fps matching, licensing, and troubleshooting.

## Step 5 — Launch

| Install | Launcher |
|---|---|
| Official portable | `C:\AI\ComfyUI_windows_portable\run_nvidia_gpu.bat` |
| Easy-Install | `C:\AI\ComfyUI-Easy-Install\run_nvidia_gpu.bat` |
| Official git | `C:\AI\ComfyUI\run_comfyui.bat` |
| A1111 | `C:\AI\stable-diffusion-webui\webui-user.bat` |
| Forge | `C:\AI\stable-diffusion-webui-forge\webui-user.bat` |

ComfyUI listens on <http://127.0.0.1:8188>. Open the workflow browser (clock
icon), then **Pixaroma**, and pick an episode.

## Custom nodes

These workflows use custom nodes (Pixaroma nodes, rgthree's Power Lora Loader,
KJNodes, video/audio helpers, and others). The setup scripts install **model
files only**, not custom-node code.

- Easy-Install already bundles the common set.
- On a bare ComfyUI, open a workflow and use **Manager → Install Missing Custom
  Nodes** (recent ComfyUI builds include Manager; if the button is absent,
  install ComfyUI-Manager first). Restart ComfyUI after installing nodes.
- Loading a workflow before its nodes exist shows red "missing node" boxes; the
  workflow JSON is not damaged, and the boxes resolve after the node install and
  restart.

## Special model cases

These are already encoded in `models.psv`; no manual action is needed except
where noted.

| Case | File | What the scripts do |
|---|---|---|
| Gated (FLUX 3) | `flux3-image-klein-int8-convrot`, `qwen3.5_9b_flux3_prompt_upsampler_w4a8`, `qwen3vl_4b_int8_convrot` | Skip with a login hint if `hf auth whoami` fails. Accept the license, run `hf auth login`, re-run. |
| Renamed on install | `eye-highnoise.safetensors`, `Huihui-Qwen3-4B-abliterated-v2_fp8mixed.safetensors` | Download the upstream name and install under the name the workflow expects. |
| Substitute source | `Huihui-Qwen3-4B-abliterated-v2_fp8mixed.safetensors` | Uses a maintained replacement repo (8.04 GB instead of ~4.2 GB). |
| Manual | `loras/krea2/krea2-questpaint26.safetensors` | Not downloadable; the script lists it at the end. Supply your own fal.ai-trained LoRA. |
| Node-downloaded | QwenVL GGUF, YOLOX, DWPose weights | Deliberately not in the catalog; `AILab_QwenVL_GGUF` and `DWPreprocessor` fetch them on first run. |

## Verify, resume, and recover

```powershell
# Check every installed model for the selected episodes
.\setup.ps1 models -All -Verify

# Re-check one episode
.\setup.ps1 models -Episode 6 -Verify
```

- Exit 0: every selected file exists at the expected size, all manual files are
  present, and no size mismatches were found.
- Exit 1: missing files or size mismatches; the report lists each path.
- Exit 2: invalid arguments or a missing manifest.

To repair:

- Missing file → re-run the same command without `-Verify`; only missing files
  are downloaded.
- Wrong-size file → the script warns and leaves it untouched. If you are sure it
  is corrupt, delete that one file and re-run, or use
  `-ForceModels -Episode N` to re-download the whole episode. Prefer deleting
  the single file.
- Interrupted run → run the same command again. Staging data is kept for
  partial downloads and `hf` resumes when possible.

## Command cheat sheet

```powershell
# One-time
Set-ExecutionPolicy -Scope Process Bypass
.\install-comfyui.ps1 -ModelsRoot D:\AI\models

# Workflows and models
.\setup.ps1 workflows
.\setup.ps1 models -Episode 6
.\setup.ps1 models -Episode 6,7,8
.\setup.ps1 models -All -Yes

# Inspect and verify
.\setup.ps1 list
.\setup.ps1 models -All -DryRun
.\setup.ps1 models -All -Verify

# Optional WebUI
.\install-stablediffusion.ps1 -Flavor forge -ModelsRoot D:\AI\models
```

See `README.md` for the cross-platform command reference and file list.
`MODELS.md` documents every model and shared-file saving; `WORKFLOWS.md` lists
every workflow in every pack.
