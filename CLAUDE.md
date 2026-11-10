# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

Cross-platform automation that installs ComfyUI (optionally A1111/Forge WebUI) and then installs the 40 Pixaroma workflow packs plus the exact Hugging Face model files those workflows load. A separate **shorts profile** installs a curated portrait social-media model stack and workflow pack, plus a local post-copy generator. The scripts and catalog are the deliverable; there is no build system, package manifest, or automated test suite.

## Commands

Run setup commands from the repo root. The scripts resolve `models.psv`, `shorts.psv`, `archives/`, `shorts/workflows/`, and `pixaroma.conf` relative to their own location.

```sh
./setup.sh list                          # print catalog; writes nothing
./setup.sh models --episode 6 --dry-run  # show plan and validate remote paths; no downloads
./setup.sh models --episode 6            # download Ep06 models
./setup.sh workflows                     # extract all 40 packs into ComfyUI
./setup.sh models --all --verify         # size-check installed files; downloads nothing
./setup.sh shorts --list                 # print the shorts catalog; writes nothing
./setup.sh shorts --type photo --dry-run # validate shorts remote paths; no downloads
./setup.sh --short --install --yes       # shorts models + workflow pack into ComfyUI
./shorts-post.sh --type short --topic "a dog surfing at sunset"
./install-comfyui.sh --dir ~/AI/ComfyUI --models-root /mnt/ai/models --dry-run
./install-stablediffusion.sh --flavor forge --models-root /mnt/ai/models
```

Windows twins use PowerShell parameter syntax (`.\setup.ps1 models -Episode 6 -DryRun`, `.\setup.ps1 -Short -Install -Yes`); `README.md` has the full flag map.

Syntax-check the shell scripts (there is no test suite to run):

```sh
sh -n setup.sh install-comfyui.sh install-stablediffusion.sh shorts-post.sh
python3 -m py_compile shorts_post.py
```

Model downloads and model dry-runs require the `hf` CLI (huggingface_hub 2.x); workflow extraction requires `unzip`. Shorts dry-runs validate remote paths without downloading. Do not run full downloads during development — use `list`, `--list`, `--dry-run`, and `--verify`.

## Architecture

### models.psv is the source of truth

`models.psv` is a pipe-delimited, header-bearing table with 9 fields:

`folder|filename|bytes|repo|repo_path|episodes|url|gated|note`

- `folder` is the destination path relative to the models root and may contain a subfolder (`loras/krea2`, `diffusion_models/3D`). Casing matters because Linux paths are case-sensitive.
- `repo_path` is the path inside the Hugging Face repo; it can differ from `filename`, which is how "renamed on install" files are handled.
- `episodes` is a comma-separated list of zero-padded keys (`06,23`). Episodes 03, 07, 10, and 12 reference no models and therefore never appear.
- `repo` = `-` marks a manual file that cannot be downloaded; `gated` = `yes` marks FLUX 3 files that require license acceptance plus `hf auth login`.
- Never put a `|` inside a field. Notes use commas and semicolons.

Both setup scripts parse this file directly; do not hardcode model lists in script logic. `MODELS.md` and `WORKFLOWS.md` are human-readable descriptions of the same data, and no generator script is checked in, so update them by hand when the manifest changes.

### shorts.psv is a second profile manifest

`shorts.psv` uses the same 9-field pipe-delimited shape, but field 6 is `types` instead of `episodes`:

`folder|filename|bytes|repo|repo_path|types|url|gated|note`

- `types` is a comma-separated list of profile types: `short`, `photo`, `story`, and `h3`. A row is selected when any requested type matches; `--type all` selects every non-H3 row.
- 18 core rows (108,673,617,172 bytes / 108.67 GB) are Apache 2.0 or MIT. The 4 `h3` rows (43,628,584,551 bytes / 43.63 GB) are the MiniMax H3 Community License and are selected only with `--with-h3`, which itself requires `--accept-h3-license` or exits 2.
- The `text_encoders/qwen3vl_4b_fp8_scaled.safetensors` row (5,242,467,968 bytes) is the local Qwen3-VL 4B prompt enhancer and post writer used by the seven generative shorts workflows. It must stay tagged `short,photo,story`; the workflows reference it by filename from `models/text_encoders`.
- The `shorts` target reuses the episode scan/stage/verify pipeline but replaces episode selection with type selection. `--episode`, `--all`, and `--all-zip` are rejected in shorts mode; `--verify` is allowed unless combined with `--install`.
- `shorts/workflows/` mirrors four categories: `Short Video/`, `Photo Posts/`, `Stories/`, and `H3 (license-restricted)/`. `--install` copies only the categories selected by `--type` (plus H3 only with `--with-h3`) into `<ComfyUI>/user/default/workflows/Pixaroma/Shorts/`. Without `--install`, the target installs models only.
- Seven generative workflows (four Short Video, three Photo Posts) carry a helper cluster of Pixaroma nodes: one `PixaromaText` for the idea, two `PixaromaAIPrompt` nodes (prompt enhancer and post writer), a `PixaromaShowText` preview, a `PixaromaSaveText`, and a `MarkdownNote`. The AIPrompt nodes self-load `qwen3vl_4b_fp8_scaled.safetensors` with `release_model: true`; their state lives in `properties.aiPromptState`. SaveText state is a JSON string in `properties.saveTextState`.
- `--short` / `--shorts` is an alias for the target; `--list` prints the shorts catalog without writing.

`shorts_post.py` is stdlib-only and local-first: deterministic templates plus an optional Ollama instance on loopback (`http://127.0.0.1:11434`). Do not add cloud APIs, API keys, or non-loopback hosts. `shorts-post.sh` and `shorts-post.ps1` are thin wrappers around the one Python implementation.

### Twin shell/PowerShell implementations

`setup.sh` ↔ `setup.ps1`, `install-comfyui.sh` ↔ `install-comfyui.ps1`, and `install-stablediffusion.sh` ↔ `install-stablediffusion.ps1` are independent implementations of the same behavior and exit codes. A change to selection, manifest parsing, staging, or output wording must be mirrored in both twins. Option names differ by platform: kebab-case for shell (`--models-root`, `--force-models`), PascalCase for PowerShell (`-ModelsRoot`, `-ForceModels`). `install-comfyui-easy.ps1` is Windows-only, has no shell twin, is interactive by design (it runs `ComfyUI-Easy-Install.bat`), and refuses to run elevated.

### Model download pipeline (setup.sh / setup.ps1)

The episode and shorts targets share this pipeline; shorts mode normalizes `--type` in step 1, selects rows from `shorts.psv`, and copies the curated workflow pack instead of extracting episode zips.

1. Parse and normalize episode selection to two-digit keys. Archive names vary in spelling (`EP01 Workflows.zip` vs `Ep06 Workflows.zip`), so zip matching accepts both `EP`/`Ep` prefixes.
2. Scan the manifest and report selected/present/to-download counts. A file is skipped solely because `<models_root>/<folder>/<filename>` exists, regardless of episode; this is what makes shared files download once. Existing files with the wrong byte size are warned about and left untouched.
3. Ask for confirmation only for an unqualified `--all` (episodes) or a shorts run that has files to fetch; `--yes` skips it, and a non-terminal without `--yes` exits 2.
4. Download each file into `<models_root>/.pixaroma-staging/<hash>/`, verify its byte size, move it into place, and remove the stage. Failed downloads keep partial staging data so a re-run can resume.
5. Gated files are skipped when `hf auth whoami` fails; the run continues and exits 1 at the end.
6. Workflows are extracted to `<ComfyUI>/user/default/workflows/Pixaroma/`; existing files are kept unless forced. `--all-zip` is mutually exclusive with episode selection. PowerShell extraction guards against zip-slip and fixes Unix modes; the shell version relies on `unzip`.

Exit codes are a contract documented for users: **0** success, **1** missing files/failed downloads/gated files (re-run to finish), **2** invalid arguments, missing manifest, or missing required tooling.

### Shared model store

Installers create a 28-folder ComfyUI-style tree under the models root (plus per-model subfolders such as `loras/krea2`). They write an `extra_model_paths.yaml` with a `pixaroma_shared:` block and `is_default: true`, and write `pixaroma.conf` next to the scripts with `COMFYUI=`, `MODELS_ROOT=`, and optionally `SD_WEBUI=`. Setup scripts read that conf, but explicit flags and `COMFYUI_DIR` override it. ComfyUI root detection requires the candidate to contain a `models/` directory. WebUI installers link the WebUI's model folders to the shared store using junctions on Windows and symlinks on POSIX; they leave non-empty folders alone and warn.

## Gotchas

- Keep `setup.sh` POSIX-compliant (`#!/bin/sh`, `set -eu`): no bashisms, arrays, or `[[`.
- Keep the `.ps1` files compatible with Windows PowerShell 5.1 (`#Requires -Version 5.1`); avoid PowerShell 7-only syntax.
- `bytes` in the manifest is exact and is used verbatim for verification and size totals; do not round it.
- `--verify` cannot be combined with `--force-models`; it is restricted to the `models` and `shorts` targets. In shorts mode, `--verify` cannot be combined with `--install`.
- `shorts.psv` follows the same no-pipe rule; `types` values must be `short`, `photo`, `story`, or `h3`. Keep the byte totals in `README.md` and `SHORTS.md` in sync when rows change.
- H3 is license-restricted (MiniMax H3 Community License): never include it in the default shorts install, never auto-accept the license, and keep the `--with-h3` + `--accept-h3-license` gate in both twins.
- When editing shorts workflow JSON, keep the helper nodes' `properties.aiPromptState` intact: it holds the model filename, formula, temperature, and `release_model`. `PixaromaSaveText` is a thin backend node that only collects text; the browser writes `<name>.txt`, so a headless API run writes no post copy. A bypassed `PixaromaAIPrompt` passes its `text` input through, which is why the original idea is wired there and duplicated in the positive encoder's widget.
- Python requirements differ: ComfyUI installer accepts 3.10–3.13, A1111/Forge accepts 3.10/3.11 (and on Windows both WebUIs need Python 3.10). `-Cpu` is rejected for the ComfyUI portable flavor because the portable build bundles CUDA PyTorch.
- `AI-SETUP.md` is machine-specific (Windows 11, RTX 3090, C: SSD / D: HDD); `README.md` is the cross-platform reference. Keep behavior changes reflected in both.
