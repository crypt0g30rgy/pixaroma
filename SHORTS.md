# Shorts profile — portrait video, photo posts, and stories

A local-first add-on profile for vertical social media. It installs a curated
model set and a matching workflow pack, then can generate the human post copy
that goes with the media.

Everything runs on your own machine. The workflows use local open-weight models;
eight of them include a local Qwen3-VL prompt enhancer and post writer. The
copy generator uses deterministic templates and, optionally, a local Ollama
instance. There are no cloud APIs, hosted nodes, or API keys.

## Quick start

```sh
# See the profile and exact sizes; writes nothing
./setup.sh shorts --list

# Validate every Hugging Face path without downloading
./setup.sh shorts --dry-run --comfyui ~/ComfyUI

# Install the full permissively licensed core + every shorts workflow
./setup.sh shorts --install --yes --comfyui ~/ComfyUI

# Photo posts only: Z-Image + the Photo Posts workflows
./setup.sh shorts --type photo --install --yes --comfyui ~/ComfyUI

# Required first installs use an explicit shared model store
./setup.sh shorts --install --yes \
  --comfyui ~/ComfyUI --models-root /mnt/ai/models
```

Windows PowerShell:

```powershell
.\setup.ps1 shorts -List
.\setup.ps1 -Short -Install -Yes
.\setup.ps1 shorts -Type photo -Install -Yes
.\setup.ps1 shorts -Type all -WithH3 -AcceptH3License -DryRun
```

`--short` / `--shorts` is an alias for the `shorts` target, so
`./setup.sh --short --install` and `./setup.sh shorts --install` are equivalent.
`--install` adds the workflow pack; without it, the target installs models only.

## What `--type` selects

| Type | Models | Workflows copied |
|---|---|---|
| `short` (default) | Full core video stack, 18 files / 108.67 GB | `Short Video/`, the 9:16 Z-Image cover, Social Media Sizes |
| `photo` | Z-Image Turbo + Qwen3-VL helper, 15.59 GB | All five `Photo Posts/` workflows |
| `story` | Z-Image Turbo + Qwen3-VL helper, 15.59 GB | `Stories/`, the 9:16 Z-Image image, Social Media Sizes |
| `all` | Same as `short` (every core row) | Every core category |

`--with-h3` adds four optional FastH3 files (43.63 GB). It requires
`--accept-h3-license`; see [Licensing](#licensing).

Workflows go to:

```
<ComfyUI>/user/default/workflows/Pixaroma/Shorts/
  Short Video/
  Photo Posts/
  Stories/
  H3 (license-restricted)/      only with --with-h3
```

Existing files are kept. Use `--force-workflows` / `-ForceWorkflows` to
overwrite, and `--force-models` / `-ForceModels` to re-download models.

## The core stack

| Role | Model | Size | License |
|---|---|---:|---|
| Fast prompt or image → video | Wan 2.2 TI2V-5B | 10.00 GB | Apache 2.0 |
| Quality image → video | Wan 2.2 I2V-A14B, 4-step GGUF hi/lo | 12.01 GB × 2 | Apache 2.0 |
| Image + motion video → character animation | SCAIL-2 (Wan 2.1 14B) | 17.69 GB | MIT |
| Image + audio → talking video | InfiniteTalk single | 5.13 GB | Apache 2.0 |
| Base for InfiniteTalk | Wan 2.1 I2V 14B fp8 | 16.64 GB | Apache 2.0 |
| Photo posts and covers | Z-Image Turbo AIO | 10.35 GB | Apache 2.0 |
| Prompt enhancer and post writer | Qwen3-VL 4B fp8 | 5.24 GB | Apache 2.0 |
| 1080p upscale | SeedVR2 3B + VAE | 7.28 GB | Apache 2.0 |
| Shared text encoder / VAEs / LoRAs | UMT5, Wan 2.1/2.2 VAEs, LightX2V, CLIP vision, wav2vec2 | ~10.85 GB | Apache 2.0 / MIT |

All core files total **108.67 GB** (108,673,617,172 bytes). Shared with the
episode packs, so files you already installed are skipped. The Qwen3-VL 4B
helper is already part of the episode catalog (Ep24–26), so it is usually
skipped too.

## Pipelines

### 1. Prompt → short (fast draft)

1. **Short Video / 1. Prompt or Image to Video - Wan 2.2 5B (9x16)**  
   704×1280, 121 frames, 24 fps, about 5 seconds, silent.
2. **Short Video / 6. Upscale to 1080p - SeedVR2 (24 fps source)**  
   Raises the short side to 1080 px.
3. Add music, captions, and a cover in your editor.

### 2. Image → short (quality)

1. **Photo Posts / 3. Story Photo - Z-Image 9x16** to make a 864×1536 first
   frame, or load your own portrait image.
2. **Short Video / 2. Image to Video - Wan 2.2 14B (9x16)**  
   480×832, 81 frames, 16 fps, about 5 seconds, silent.
3. **Short Video / 5. Upscale to 1080p - SeedVR2 (16 fps source)**.
4. Add sound and captions.

Use the 5B workflow for drafts and the 14B workflow for the final take. The 14B
workflow uses a high-noise and a low-noise 4-step model in sequence.

### 3. Your image + motion video → character animation

1. **Short Video / 3b. Character Motion - SCAIL-2 (image + video)**  
   Load a full-body image of yourself or any character and a video of the motion
   to copy. 512×896, 81-frame chunks, audio kept from the motion video.
2. **Short Video / 6. Upscale to 1080p - SeedVR2 (24 fps source)**.

The character image supplies identity and outfit; the motion video supplies the
movement — dance, martial arts, gestures, or other full-body actions. SCAIL-2
does not copy clothes from the video, so first make a character image that
already shows the target outfit: edit it in an image editor, or generate one
with the Z-Image photo workflows. Use a single full-body subject on a plain
background and a full-body clip with a steady camera; 3–10 seconds at 24 fps is
ideal. Only use images and videos you have the rights to. For general reference
+ motion restyling, use **Short Video / 3. Video to Video - SCAIL-2 (9x16)** —
same model, different defaults.

### 4. Portrait + voice → talking short

1. **Short Video / 4. Image + Audio to Talking Video - InfiniteTalk (9x16)**  
   480×832, 25 fps, audio preserved.
2. **Short Video / 7. Upscale to 1080p - SeedVR2 (25 fps source)**.

Use a clean voice track and a large, well-lit face. Re-attach audio after
upscaling if your editor does not preserve it.

### 5. Photo posts and stories

- **Photo Posts / 1. Photo Post - Z-Image 4x5** → 1024×1280
- **Photo Posts / 2. Square Post - Z-Image 1x1** → 1024×1024
- **Photo Posts / 3. Story Photo - Z-Image 9x16** → 864×1536
- **Photo Posts / 4. Social Media Sizes from Folder** → 1080×1080,
  1080×1350, 1080×1920 from any image folder (no model)
- **Photo Posts / 5. Slideshow from Folder - Square** → 1080×1080 MP4
- **Stories / 1. Story Slideshow - 9x16** → 1080×1920 MP4

The two slideshow workflows are silent. Add music in your editor.

### 6. Optional: FastH3 with synchronized audio

- **H3 (license-restricted) / 1. FastH3 - Text to Video**
- **H3 (license-restricted) / 2. FastH3 - FirstFrame to Video**
- **H3 (license-restricted) / 3. FastH3 - First and Last Frame**

FastH3 is the strongest local prompt-to-video model here and the only one that
generates synchronized audio, but it is not permissively licensed. Read the
notice in that folder first.

## Prompt enhancer and post copy

Eight of the permissively licensed generative workflows ship with a small local
helper cluster built from Pixaroma nodes. They use **Qwen3-VL 4B fp8**
(`qwen3vl_4b_fp8_scaled.safetensors`, 5.24 GB) from
`ComfyUI/models/text_encoders`, the same local file the Krea 2 episode workflows
use. Nothing is sent to a cloud service.

| Workflow | Enhancer sees | Post writer sees | Saved name |
|---|---|---|---|
| Short Video / 1. Wan 2.2 5B | idea + first frame (when the image path is enabled) | final video frames | `wan5b-post` |
| Short Video / 2. Wan 2.2 14B | idea + input image | final video frames | `wan14b-post` |
| Short Video / 3. SCAIL-2 | idea + reference image | final video frames | `scail-post` |
| Short Video / 3b. Character Motion | idea + character image | final video frames | `character-motion-post` |
| Short Video / 4. InfiniteTalk | idea + portrait image | final video frames | `talking-post` |
| Photo Posts / 1. Z-Image 4x5 | idea | finished image | `photo-4x5-post` |
| Photo Posts / 2. Square 1x1 | idea | finished image | `photo-1x1-post` |
| Photo Posts / 3. Story 9x16 | idea | finished image | `story-9x16-post` |

Each cluster sits below the main graph and has five parts:

1. **Your idea (edit this)** — a `PixaromaText` node holding the rough idea.
2. **1. Prompt enhancer (Qwen3-VL 4B)** — rewrites the idea into the prompt
   style the target model expects. Temperature 0.3, 300–400 tokens for video
   and 1500 for Z-Image. The video variants also receive the input image, so
   the description matches the actual first frame.
3. **2. Post writer (Qwen3-VL 4B)** — reads the enhanced prompt and the
   finished frames, then writes a platform-ready caption, hashtags, and alt
   text. Temperature 0.7, 600 tokens.
4. **Post copy preview** — a `PixaromaShowText` node showing the caption.
5. **3. Save post copy** — a `PixaromaSaveText` node that writes
   `ComfyUI/output/Shorts/wan5b-post.txt` (the **Post file name** value plus
   `.txt`) while the workflow is open in a browser. A headless API run passes
   the text through but writes no file. Re-running replaces the same name; edit
   the **Post file name** node to keep separate versions.

The enhanced prompt feeds the positive `CLIPTextEncode`; the original idea is
also wired into the enhancer's `text` input, so pressing **Ctrl+B** on the
enhancer passes your own idea straight through to the image or video model.
Bypassing the post writer simply skips the copy pass. Both helpers set
`release_model`, so the 5.24 GB model is unloaded before Wan, SCAIL, or Z-Image
start sampling and again after the post pass — it does not compete for VRAM
during generation.

To tune quality, edit the formula in the enhancer node, raise its temperature
slightly for more variation, or replace the idea text. To skip the helpers
entirely, select both and press Ctrl+B.

## Post copy

`shorts_post.py` turns a topic or brief into a complete post kit:

```sh
# Templates only, no model runtime
./shorts-post.sh \
  --type short \
  --topic "a golden retriever surfing a small wave at sunset" \
  --tone warm \
  --platform instagram,tiktok,youtube \
  --media ~/ComfyUI/output/Shorts/wan5b_00001.mp4

# Photo post, local Ollama if it is installed
./shorts-post.sh \
  --type photo --topic "coffee shop portrait in morning window light" \
  --tone calm --brand "@yourhandle" --ollama
```

Windows:

```powershell
.\shorts-post.ps1 --type photo --topic "coffee shop portrait" `
  --platform instagram --media C:\ComfyUI\output\Shorts\photo.png
```

Outputs:

```
shorts-posts/<topic>/
  post.md                 full kit + publishing checklist
  caption.txt             primary caption with hashtags
  alt-text.txt            alt text for accessibility
  hashtags.txt
  platforms/
    instagram.txt
    tiktok.txt
    youtube.txt
    x.txt                 only the platforms you asked for
```

Options:

| Flag | Meaning |
|---|---|
| `--type short\|photo\|story` | Media type; changes hooks, alt text, defaults |
| `--topic TEXT` / `--brief FILE` | What the media is about |
| `--platform a,b` | `instagram`, `tiktok`, `youtube`, `facebook`, `x`, `linkedin`, `pinterest` |
| `--tone warm\|funny\|bold\|calm\|educational` | Voice of the copy |
| `--hashtags N` | 0–30, default 8 |
| `--media PATH` | Repeatable; recorded in `post.md` |
| `--brand "@handle"` | Adds a follow call to action |
| `--link URL` | Facebook/LinkedIn link |
| `--disclose` | Appends "AI-generated media." to captions |
| `--no-ollama` | Templates only |
| `--ollama` | Require local Ollama; fail if unavailable |
| `--model NAME` | Ollama model; auto-picks a known local one |
| `--out DIR` | Output folder; defaults under `./shorts-posts/` |

The script never contacts a non-loopback host. It checks `127.0.0.1:11434`
(or `--ollama-url`, still loopback-only), lists installed models, and falls
back to templates when no model is available. The output is a starting point:
review claims, music rights, and disclosure before posting.

## Licensing

| Model | License | Notes |
|---|---|---|
| Wan 2.2 5B / 14B, Wan 2.1 | Apache 2.0 | Commercial use allowed |
| SCAIL-2 | MIT | Commercial use allowed |
| InfiniteTalk | Apache 2.0 | Commercial use allowed |
| SeedVR2 | Apache 2.0 | Commercial use allowed |
| Z-Image Turbo | Apache 2.0 | Commercial use allowed |
| Qwen3-VL 4B | Apache 2.0 | Prompt enhancer and post writer |
| MiniMax H3 / FastH3 | MiniMax H3 Community License | **Not** permissive |

FastH3 terms (summary, not legal advice): use is excluded in the **United
States, European Union, United Kingdom, and South Korea**; companies over $20M
annual revenue need written permission; commercial products must display
"MiniMax H3"; outputs may not train other models; public content must be
disclosed as AI-generated.

The default install never downloads H3. Enabling it requires both flags:

```sh
./setup.sh shorts --type all --with-h3 --accept-h3-license --install
```

The H3 workflows are copied only when `--with-h3` is set, into a folder named
`H3 (license-restricted)/` with a `LICENSE-NOTICE.txt`.

## Hardware notes

Tested target: **RTX 3090 24 GB, 64 GB RAM** (see `AI-SETUP.md`).

- Wan 2.2 5B, Z-Image, and SeedVR2 3B fit comfortably.
- Qwen3-VL 4B adds 5.24 GB while it runs. The helper nodes unload it before
  sampling starts, so it only overlaps with the prompt and post passes.
- Wan 2.2 14B GGUF Q6 and SCAIL-2 14B fp8 are tight; keep ComfyUI's normal
  model offloading enabled and close other GPU apps.
- InfiniteTalk loads the Wan 2.1 14B base and the 5.13 GB patch sequentially;
  expect a slower first run while weights page in.
- FastH3 needs the 22.13 GB diffusion model plus a 15.69 GB text encoder. It
  relies on system-RAM offload; 64 GB is enough, 32 GB is not.
- SeedVR2 at 1080p is the slowest step per second of video. Upscale once at the
  end, not after every draft.
- Generation times depend on steps and length. The 5B/4-step workflows are the
  fast iteration path; the 14B/SCAIL/InfiniteTalk workflows are the quality
  path.

## Custom nodes

The model and workflow installers do not install ComfyUI custom nodes. On first
open, a workflow may list missing nodes. Use **ComfyUI Manager → Install
Missing Custom Nodes**, restart ComfyUI, and reopen the workflow. The main ones:

- ComfyUI-GGUF (Wan 2.2 14B GGUF loaders)
- ComfyUI-VideoHelperSuite (VHS load/preview)
- ComfyUI-SeedVR2_VideoUpscaler
- The Pixaroma node pack used by the SCAIL-2, InfiniteTalk, and utility
  workflows, and by the prompt enhancer and post writer
- The SCAIL-2 and InfiniteTalk node packs referenced by those workflows

## Troubleshooting

- **Loader cannot find a GGUF on Linux.** Some Pixaroma workflows store
  Windows-style paths such as `wan2.2\file.gguf`. On Linux, open the loader and
  select the file, or replace the backslash with `/`.
- **Wrong playback speed after upscale.** Match the SeedVR2 variant to the
  source fps: 16 for Wan 2.2 14B, 24 for Wan 2.2 5B/SCAIL-2, 25 for
  InfiniteTalk.
- **Output is the wrong shape.** Wan 2.2 14B needs a 9:16 input image. Use the
  9:16 Z-Image workflow or crop first.
- **`--verify` says a shared file is missing.** Add `--models-root` if the
  models live outside ComfyUI, and make sure the same root was used at install.
- **PowerShell refuses to run the script.** Use
  `Set-ExecutionPolicy -Scope Process Bypass` in that terminal.
- **Ollama is not used.** The generator only accepts loopback URLs, and the
  model must already be pulled (`ollama list`). Use `--model` to choose one.
- **The enhancer outputs your idea unchanged.** The Qwen3-VL file is missing
  from `models/text_encoders`, or the Pixaroma node pack is not installed. The
  node passes input through rather than failing the run.
- **No `-post.txt` file appears.** Save Text writes only while the workflow is
  open in a browser; a headless API run does not write copy. The preview node
  still shows the text in the browser.
- **Post copy looks generic.** The writer only sees the enhanced prompt and the
  frames. Put subject, tone, and platform in the enhancer's idea text, or edit
  the formula in the post writer.

## Exit codes

The shorts target follows the repository contract:

- **0** success (including `--list` and a clean `--verify`)
- **1** failed downloads, missing files, or gated files skipped
- **2** invalid arguments, missing manifest, missing tooling, or an unaccepted
  H3 license
