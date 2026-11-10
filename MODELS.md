# Pixaroma model catalog

Every model file referenced by the 40 Pixaroma workflow packs, resolved to a Hugging Face source and an exact size. The list is generated from the workflow JSON itself, not from filenames guessed off the notes.

> The optional shorts profile is cataloged separately in `shorts.psv` (18 core files / 108.67 GB, plus 4 FastH3 files / 43.63 GB). See [`SHORTS.md`](SHORTS.md); this document covers only the 40 episode packs. The shorts helper model `qwen3vl_4b_fp8_scaled.safetensors` is already part of this episode catalog (Ep24–26).

## Summary

- **133 model files** are referenced by **353 workflows** across **40 episode packs**.
- **132 can be downloaded automatically** from Hugging Face; **1 must be supplied manually**.
- **Total download size: 782.61 GB** (782,613,056,329 bytes / 728.87 GiB).
- **33 files are shared by two or more episodes.** Because the setup scripts skip files that already exist, each is downloaded once. Installing every episode separately would move 1.31 TB; sharing saves **525.02 GB**.
- Sizes are exact byte counts from `hf models list <repo> -R --format json`.
- Sizes use decimal units in this document (1 GB = 1,000,000,000 bytes). `models.psv` holds the exact bytes for every file.

### How the list was built

All 353 workflow JSONs were parsed. Model names were read from loader widgets, `properties.models` metadata, Markdown/Pixaroma notes, and nested state objects used by custom nodes (`PixaromaLoraLoader`, `Power Lora Loader (rgthree)`, `PixaromaVideoPrompt`, `PixaromaMusicPrompt`). Only files that a workflow actually loads are installed; the notes sometimes advertise extra quants or alternates, which are listed under [Multiple sources](#multiple-sources-for-the-same-filename) instead of being downloaded.

## All referenced models

Sorted by the ComfyUI folder they must be placed in. `Eps` is the number of episode packs that use the file; `WFs` is the number of workflows. Episode numbers refer to `archives/EpNN Workflows.zip`.

| Folder | File | Size | Eps | WFs | Source |
|---|---|---:|---:|---:|---|
| `audio_encoders` | `wav2vec2-chinese-base_fp16.safetensors` | 190.12 MB | 1 | 5 | [Kijai/wav2vec2_safetensors](https://huggingface.co/Kijai/wav2vec2_safetensors/resolve/main/wav2vec2-chinese-base_fp16.safetensors) |
| `background_removal` | `birefnet.safetensors` | 444.47 MB | 4 | 13 | [Comfy-Org/BiRefNet](https://huggingface.co/Comfy-Org/BiRefNet/resolve/main/background_removal/birefnet.safetensors) |
| `checkpoints/ltx2` | `ltx-2-19b-dev-fp8.safetensors` | 27.08 GB | 1 | 1 | [Lightricks/LTX-2](https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-19b-dev-fp8.safetensors) |
| `checkpoints/ltx2` | `ltx-2-19b-distilled-fp8.safetensors` | 27.08 GB | 1 | 1 | [Lightricks/LTX-2](https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-19b-distilled-fp8.safetensors) |
| `checkpoints/sd15` | `juggernaut_reborn.safetensors` | 2.13 GB | 1 | 4 | [HyperX-Sentience/Juggernaut-Reborn](https://huggingface.co/HyperX-Sentience/Juggernaut-Reborn/resolve/main/juggernaut_reborn.safetensors) |
| `checkpoints/stableaudio3` | `stable_audio_3_medium.safetensors` | 9.22 GB | 1 | 4 | [Comfy-Org/stable-audio-3](https://huggingface.co/Comfy-Org/stable-audio-3/resolve/main/checkpoints/stable_audio_3_medium.safetensors) |
| `checkpoints/z-image` | `z-image-turbo-fp8-aio.safetensors` | 10.35 GB | 1 | 3 | [SeeSee21/Z-Image-Turbo-AIO](https://huggingface.co/SeeSee21/Z-Image-Turbo-AIO/resolve/main/z-image-turbo-fp8-aio.safetensors) |
| `clip_vision` | `clip_vision_h.safetensors` | 1.26 GB | 2 | 9 | [Comfy-Org/Wan_2.1_ComfyUI_repackaged](https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors) |
| `clip_vision` | `dino_v3_L_naf_fp32.safetensors` | 1.22 GB | 2 | 10 | [Comfy-Org/Pixal3D](https://huggingface.co/Comfy-Org/Pixal3D/resolve/main/clip_vision/dino_v3_L_naf_fp32.safetensors) |
| `controlnet` | `Wan21_Uni3C_controlnet_fp16.safetensors` | 2.00 GB | 1 | 2 | [Kijai/WanVideo_comfy](https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan21_Uni3C_controlnet_fp16.safetensors) |
| `controlnet/sd15` | `control_v11p_sd15_canny_fp16.safetensors` | 722.60 MB | 1 | 1 | [comfyanonymous/ControlNet-v1-1_fp16_safetensors](https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_v11p_sd15_canny_fp16.safetensors) |
| `detection` | `vitpose_h_wholebody_model.onnx` | 420.3 KB | 1 | 7 | [Kijai/vitpose_comfy](https://huggingface.co/Kijai/vitpose_comfy/resolve/main/onnx/vitpose_h_wholebody_model.onnx) |
| `detection` | `yolov10m.onnx` | 61.66 MB | 1 | 7 | [Wan-AI/Wan2.2-Animate-14B](https://huggingface.co/Wan-AI/Wan2.2-Animate-14B/resolve/main/process_checkpoint/det/yolov10m.onnx) |
| `diffusion_models/3D` | `pixal3d_int8_convrot.safetensors` | 5.58 GB | 1 | 2 | [Comfy-Org/Pixal3D](https://huggingface.co/Comfy-Org/Pixal3D/resolve/main/diffusion_models/pixal3d_int8_convrot.safetensors) |
| `diffusion_models/3D` | `pixal3d_multiview_int8_convrot.safetensors` | 5.58 GB | 1 | 5 | [Comfy-Org/Pixal3D](https://huggingface.co/Comfy-Org/Pixal3D/resolve/main/diffusion_models/pixal3d_multiview_int8_convrot.safetensors) |
| `diffusion_models/3D` | `trellis_2_int8_convrot.safetensors` | 5.25 GB | 1 | 3 | [Comfy-Org/TRELLIS.2](https://huggingface.co/Comfy-Org/TRELLIS.2/resolve/main/diffusion_models/trellis_2_int8_convrot.safetensors) |
| `diffusion_models/acestep` | `acestep_v1.5_xl_turbo_bf16.safetensors` | 9.97 GB | 1 | 1 | [Comfy-Org/ace_step_1.5_ComfyUI_files](https://huggingface.co/Comfy-Org/ace_step_1.5_ComfyUI_files/resolve/main/split_files/diffusion_models/acestep_v1.5_xl_turbo_bf16.safetensors) |
| `diffusion_models/anima` | `anima-base-v1.0.safetensors` | 4.18 GB | 1 | 3 | [circlestone-labs/Anima](https://huggingface.co/circlestone-labs/Anima/resolve/main/split_files/diffusion_models/anima-base-v1.0.safetensors) |
| `diffusion_models/boogu` | `boogu_image_edit_turbo_int8_convrot.safetensors` | 11.37 GB | 1 | 1 | [Comfy-Org/Boogu-Image](https://huggingface.co/Comfy-Org/Boogu-Image/resolve/main/diffusion_models/boogu_image_edit_turbo_int8_convrot.safetensors) |
| `diffusion_models/boogu` | `boogu_image_turbo_hotfix_int8_convrot.safetensors` | 11.37 GB | 1 | 2 | [Comfy-Org/Boogu-Image](https://huggingface.co/Comfy-Org/Boogu-Image/resolve/main/diffusion_models/boogu_image_turbo_hotfix_int8_convrot.safetensors) |
| `diffusion_models/ernie` | `ernie-image-turbo-Q8_0.gguf` | 8.69 GB | 1 | 1 | [unsloth/ERNIE-Image-Turbo-GGUF](https://huggingface.co/unsloth/ERNIE-Image-Turbo-GGUF/resolve/main/ernie-image-turbo-Q8_0.gguf) |
| `diffusion_models/flux` | `svdq-int4_r32-flux.1-dev.safetensors` | 6.77 GB | 1 | 1 | [nunchaku-ai/nunchaku-flux.1-dev](https://huggingface.co/nunchaku-ai/nunchaku-flux.1-dev/resolve/main/svdq-int4_r32-flux.1-dev.safetensors) |
| `diffusion_models/flux2` | `flux-2-klein-4b-fp8.safetensors` | 4.07 GB | 1 | 4 | [black-forest-labs/FLUX.2-klein-4b-fp8](https://huggingface.co/black-forest-labs/FLUX.2-klein-4b-fp8/resolve/main/flux-2-klein-4b-fp8.safetensors) |
| `diffusion_models/flux2` | `flux-2-klein-9b-fp8mixed.safetensors` | 9.43 GB | 8 | 18 | [silveroxides/FLUX.2-dev-fp8_scaled](https://huggingface.co/silveroxides/FLUX.2-dev-fp8_scaled/resolve/main/flux-2-klein-9b-fp8mixed.safetensors) |
| `diffusion_models/flux2` | `flux-2-klein-9b-int8-convrot.safetensors` | 9.43 GB | 5 | 41 | [Winnougan/Klein9b-Distilled-Base-INT8-Convrot](https://huggingface.co/Winnougan/Klein9b-Distilled-Base-INT8-Convrot/resolve/main/flux-2-klein-9b-int8-convrot.safetensors) |
| `diffusion_models/flux2` | `flux-2-klein-9b-kv-fp8.safetensors` | 9.82 GB | 1 | 8 | [black-forest-labs/FLUX.2-klein-9b-kv-fp8](https://huggingface.co/black-forest-labs/FLUX.2-klein-9b-kv-fp8/resolve/main/flux-2-klein-9b-kv-fp8.safetensors) |
| `diffusion_models/flux3` | `flux3-image-klein-int8-convrot.safetensors` | 5.83 GB | 1 | 19 | [black-forest-labs/flux-3-image-klein-comfy](https://huggingface.co/black-forest-labs/flux-3-image-klein-comfy/resolve/main/diffusion_models/flux3-image-klein-int8-convrot.safetensors) (gated) |
| `diffusion_models/fluxmania` | `svdq-int4_r32-fluxmania-legacy.safetensors` | 6.77 GB | 1 | 1 | [spooknik/Fluxmania-SVDQ](https://huggingface.co/spooknik/Fluxmania-SVDQ/resolve/main/svdq-int4_r32-fluxmania-legacy.safetensors) |
| `diffusion_models/h3` | `fastvideo_fasth3_8step_v2_pruned_int8_convrot.safetensors` | 22.13 GB | 1 | 3 | [FastVideo/FastVideo-FastH3-Comfy](https://huggingface.co/FastVideo/FastVideo-FastH3-Comfy/resolve/main/diffusion_models/fastvideo_fasth3_8step_v2_pruned_int8_convrot.safetensors) |
| `diffusion_models/h3` | `minimax_h3_fl2va_pruned_int8_convrot.safetensors` | 20.97 GB | 2 | 10 | [Comfy-Org/MiniMax-H3](https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors) |
| `diffusion_models/h3` | `minimax_h3_ref2va_pruned_int8_convrot.safetensors` | 20.97 GB | 2 | 6 | [Comfy-Org/MiniMax-H3](https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/diffusion_models/minimax_h3_ref2va_pruned_int8_convrot.safetensors) |
| `diffusion_models/krea2` | `krea2_turbo_fp8_scaled.safetensors` | 13.14 GB | 1 | 11 | [Comfy-Org/Krea-2](https://huggingface.co/Comfy-Org/Krea-2/resolve/main/diffusion_models/krea2_turbo_fp8_scaled.safetensors) |
| `diffusion_models/krea2` | `krea2_turbo_int8_convrot.safetensors` | 13.49 GB | 5 | 19 | [Comfy-Org/Krea-2](https://huggingface.co/Comfy-Org/Krea-2/resolve/main/diffusion_models/krea2_turbo_int8_convrot.safetensors) |
| `diffusion_models/lens` | `lens_bf16.safetensors` | 8.21 GB | 1 | 1 | [Comfy-Org/Lens](https://huggingface.co/Comfy-Org/Lens/resolve/main/diffusion_models/lens_bf16.safetensors) |
| `diffusion_models/melband` | `MelBandRoformer_fp16.safetensors` | 456.48 MB | 1 | 1 | [Kijai/MelBandRoFormer_comfy](https://huggingface.co/Kijai/MelBandRoFormer_comfy/resolve/main/MelBandRoformer_fp16.safetensors) |
| `diffusion_models/ming` | `ming_image_0.1_design_int8_convrot.safetensors` | 6.18 GB | 1 | 17 | [Comfy-Org/Ming-Image](https://huggingface.co/Comfy-Org/Ming-Image/resolve/main/diffusion_models/ming_image_0.1_design_int8_convrot.safetensors) |
| `diffusion_models/minimax-music3` | `minimax_music3_dit_int8_convrot.safetensors` | 2.50 GB | 1 | 1 | [Comfy-Org/MiniMax-Music-3](https://huggingface.co/Comfy-Org/MiniMax-Music-3/resolve/main/diffusion_models/minimax_music3_dit_int8_convrot.safetensors) |
| `diffusion_models/moss` | `moss_image_sft_int8_convrot.safetensors` | 5.41 GB | 1 | 9 | [Comfy-Org/MOSS-Image](https://huggingface.co/Comfy-Org/MOSS-Image/resolve/main/diffusion_models/moss_image_sft_int8_convrot.safetensors) |
| `diffusion_models/qwen` | `qwen_image_2.1_int8_convrot.safetensors` | 7.26 GB | 1 | 26 | [Comfy-Org/Qwen-Image-2.1](https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main/diffusion_models/qwen_image_2.1_int8_convrot.safetensors) |
| `diffusion_models/qwen` | `svdq-int4_r128-qwen-image-lightningv1.1-8steps.safetensors` | 12.65 GB | 1 | 1 | [nunchaku-ai/nunchaku-qwen-image](https://huggingface.co/nunchaku-ai/nunchaku-qwen-image/resolve/main/svdq-int4_r128-qwen-image-lightningv1.1-8steps.safetensors) |
| `diffusion_models/scail` | `Wan21-14B-SCAIL-preview_fp8_e4m3fn_scaled_KJ.safetensors` | 16.40 GB | 1 | 2 | [Kijai/WanVideo_comfy_fp8_scaled](https://huggingface.co/Kijai/WanVideo_comfy_fp8_scaled/resolve/main/SCAIL/Wan21-14B-SCAIL-preview_fp8_e4m3fn_scaled_KJ.safetensors) |
| `diffusion_models/wan2.1` | `wan2.1_14B_SCAIL_2_fp8_scaled.safetensors` | 17.69 GB | 1 | 2 | [Comfy-Org/SCAIL-2](https://huggingface.co/Comfy-Org/SCAIL-2/resolve/main/diffusion_models/wan2.1_14B_SCAIL_2_fp8_scaled.safetensors) |
| `diffusion_models/wan2.1` | `Wan2_1-I2V-14B-480p_fp8_e4m3fn_scaled_KJ.safetensors` | 16.64 GB | 1 | 5 | [Kijai/WanVideo_comfy_fp8_scaled](https://huggingface.co/Kijai/WanVideo_comfy_fp8_scaled/resolve/main/I2V/Wan2_1-I2V-14B-480p_fp8_e4m3fn_scaled_KJ.safetensors) |
| `diffusion_models/wan2.2` | `wan2.2_i2v_A14b_high_noise_lightx2v_4step-Q6_K.gguf` | 12.01 GB | 1 | 2 | [jayn7/WAN2.2-I2V_A14B-DISTILL-LIGHTX2V-4STEP-GGUF](https://huggingface.co/jayn7/WAN2.2-I2V_A14B-DISTILL-LIGHTX2V-4STEP-GGUF/resolve/main/high_noise/wan2.2_i2v_A14b_high_noise_lightx2v_4step-Q6_K.gguf) |
| `diffusion_models/wan2.2` | `wan2.2_i2v_A14b_low_noise_lightx2v_4step-Q6_K.gguf` | 12.01 GB | 1 | 2 | [jayn7/WAN2.2-I2V_A14B-DISTILL-LIGHTX2V-4STEP-GGUF](https://huggingface.co/jayn7/WAN2.2-I2V_A14B-DISTILL-LIGHTX2V-4STEP-GGUF/resolve/main/low_noise/wan2.2_i2v_A14b_low_noise_lightx2v_4step-Q6_K.gguf) |
| `diffusion_models/wan2.2` | `Wan2_2-Animate-14B_fp8_scaled_e4m3fn_KJ_v2.safetensors` | 17.32 GB | 1 | 5 | [Kijai/WanVideo_comfy_fp8_scaled](https://huggingface.co/Kijai/WanVideo_comfy_fp8_scaled/resolve/main/Wan22Animate/Wan2_2-Animate-14B_fp8_scaled_e4m3fn_KJ_v2.safetensors) |
| `diffusion_models/z-image` | `svdq-int4_r256-z-image-turbo.safetensors` | 4.55 GB | 1 | 1 | [nunchaku-ai/nunchaku-z-image-turbo](https://huggingface.co/nunchaku-ai/nunchaku-z-image-turbo/resolve/main/svdq-int4_r256-z-image-turbo.safetensors) |
| `diffusion_models/z-image` | `z-image-turbo-q4_k_s.gguf` | 4.34 GB | 1 | 1 | [gguf-org/z-image-gguf](https://huggingface.co/gguf-org/z-image-gguf/resolve/main/z-image-turbo-q4_k_s.gguf) |
| `diffusion_models/z-image` | `z-image-turbo_fp8_scaled_e5m2_KJ.safetensors` | 6.16 GB | 4 | 12 | [Kijai/Z-Image_comfy_fp8_scaled](https://huggingface.co/Kijai/Z-Image_comfy_fp8_scaled/resolve/main/z-image-turbo_fp8_scaled_e5m2_KJ.safetensors) |
| `diffusion_models/z-image` | `z_image_turbo_int8_convrot.safetensors` | 6.30 GB | 3 | 3 | [Winnougan/Z-Image-Base-Turbo-INT8-Convrot](https://huggingface.co/Winnougan/Z-Image-Base-Turbo-INT8-Convrot/resolve/main/z_image_turbo_int8_convrot.safetensors) |
| `geometry_estimation` | `moge_2_vitl_normal_fp16.safetensors` | 661.86 MB | 1 | 2 | [Comfy-Org/MoGe](https://huggingface.co/Comfy-Org/MoGe/resolve/main/geometry_estimation/moge_2_vitl_normal_fp16.safetensors) |
| `latent_upscale_models` | `ltx-2-spatial-upscaler-x2-1.0.safetensors` | 995.77 MB | 1 | 2 | [Lightricks/LTX-2](https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-spatial-upscaler-x2-1.0.safetensors) |
| `loras` | `pixag1rlwh1t3.safetensors` | 85.09 MB | 1 | 1 | [Pixaroma/experimental_loras](https://huggingface.co/Pixaroma/experimental_loras/resolve/main/pixag1rlwh1t3.safetensors) |
| `loras/flux3` | `flux-3-image-klein-outpaint.safetensors` | 160.70 MB | 1 | 1 | [ausboss/FLUX-3-Image-Klein-Outpaint-LoRA](https://huggingface.co/ausboss/FLUX-3-Image-Klein-Outpaint-LoRA/resolve/main/flux-3-image-klein-outpaint.safetensors) |
| `loras/h3` | `minimax_h3_fl2v_turbo_4step_v1.1_768p_comfyui_bf16.safetensors` | 1.96 GB | 1 | 5 | [lightx2v/Minimax-h3-Turbo](https://huggingface.co/lightx2v/Minimax-h3-Turbo/resolve/main/minimax_h3_fl2v_turbo_4step_v1.1_768p_comfyui_bf16.safetensors) |
| `loras/klein9b` | `pixaoutpaint.safetensors` | 126.67 MB | 1 | 1 | [Pixaroma/experimental_loras](https://huggingface.co/Pixaroma/experimental_loras/resolve/main/pixaoutpaint.safetensors) |
| `loras/krea2` | `krea2-questpaint26.safetensors` | manual | 1 | 1 | manual |
| `loras/krea2` | `krea2-questpaint26_comfyui.safetensors` | 234.68 MB | 1 | 3 | [Pixaroma/experimental_loras](https://huggingface.co/Pixaroma/experimental_loras/resolve/main/krea2-questpaint26_comfyui.safetensors) |
| `loras/krea2` | `krea2_identity_edit_v1_2.safetensors` | 1.83 GB | 1 | 3 | [conradlocke/krea2-identity-edit](https://huggingface.co/conradlocke/krea2-identity-edit/resolve/main/krea2_identity_edit_v1_2.safetensors) |
| `loras/krea2` | `krea2_kidsdrawing.safetensors` | 469.29 MB | 1 | 1 | [Comfy-Org/Krea-2](https://huggingface.co/Comfy-Org/Krea-2/resolve/main/loras/krea2_kidsdrawing.safetensors) |
| `loras/krea2` | `krea2_vintagetarot.safetensors` | 469.29 MB | 1 | 1 | [Comfy-Org/Krea-2](https://huggingface.co/Comfy-Org/Krea-2/resolve/main/loras/krea2_vintagetarot.safetensors) |
| `loras/krea2` | `krea_outfittransfer.safetensors` | 1.14 GB | 1 | 2 | [AliveAi/Krea-2-Edit-Outfit-Transfer](https://huggingface.co/AliveAi/Krea-2-Edit-Outfit-Transfer/resolve/main/krea_outfittransfer.safetensors) |
| `loras/ltx-2` | `ltx-2-19b-distilled-lora-384.safetensors` | 7.67 GB | 1 | 1 | [Lightricks/LTX-2](https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-19b-distilled-lora-384.safetensors) |
| `loras/ltx-2` | `ltx-2-19b-ic-lora-detailer.safetensors` | 2.62 GB | 1 | 1 | [Lightricks/LTX-2-19b-IC-LoRA-Detailer](https://huggingface.co/Lightricks/LTX-2-19b-IC-LoRA-Detailer/resolve/main/ltx-2-19b-ic-lora-detailer.safetensors) |
| `loras/ltx-2` | `ltx-2-19b-lora-camera-control-static.safetensors` | 2.21 GB | 1 | 1 | [Lightricks/LTX-2-19b-LoRA-Camera-Control-Static](https://huggingface.co/Lightricks/LTX-2-19b-LoRA-Camera-Control-Static/resolve/main/ltx-2-19b-lora-camera-control-static.safetensors) |
| `loras/moss` | `moss_image_sft_4step_v2.0.safetensors` | 1.19 GB | 1 | 1 | [akhaliq/MOSS-Image-SFT-4-steps](https://huggingface.co/akhaliq/MOSS-Image-SFT-4-steps/resolve/main/moss_image_sft_4step_v2.0.safetensors) |
| `loras/qwen2.1` | `qwen-image-2.1-consistency.safetensors` | 159.44 MB | 1 | 2 | [ausboss/Qwen-Image-2.1-Consistency-LoRA](https://huggingface.co/ausboss/Qwen-Image-2.1-Consistency-LoRA/resolve/main/qwen-image-2.1-consistency.safetensors) |
| `loras/qwen2.1` | `qwen-image-2.1-outpaint-v2.safetensors` | 159.44 MB | 1 | 1 | [ausboss/Qwen-Image-2.1-Outpaint-LoRA](https://huggingface.co/ausboss/Qwen-Image-2.1-Outpaint-LoRA/resolve/main/qwen-image-2.1-outpaint-v2.safetensors) |
| `loras/qwen2.1` | `Qwen-Image-2.1-viggle-turbo-v0.2.1-6step-lora-r128.safetensors` | 679.60 MB | 1 | 3 | [Viggle/Qwen-Image-2.1-viggle-turbo](https://huggingface.co/Viggle/Qwen-Image-2.1-viggle-turbo/resolve/main/Qwen-Image-2.1-viggle-turbo-v0.2.1-6step-lora-r128.safetensors) |
| `loras/sd15` | `CakeStyle.safetensors` | 151.11 MB | 1 | 1 | [mnemic/CakeStyle-SD1.5-LoRA](https://huggingface.co/mnemic/CakeStyle-SD1.5-LoRA/resolve/main/CakeStyle.safetensors) |
| `loras/wan2.1` | `lightx2v_I2V_14B_480p_cfg_step_distill_rank128_bf16.safetensors` | 1.47 GB | 1 | 2 | [Kijai/WanVideo_comfy](https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/lightx2v_I2V_14B_480p_cfg_step_distill_rank128_bf16.safetensors) |
| `loras/wan2.2` | `eye-highnoise.safetensors` | 306.81 MB | 1 | 1 | [NikolaSigmoid/wan2.2-i2v-loras-eye-in](https://huggingface.co/NikolaSigmoid/wan2.2-i2v-loras-eye-in/resolve/main/highnoise.safetensors) |
| `loras/wan2.2` | `FastWan_T2V_14B_480p_lora_rank_64_bf16.safetensors` | 630.70 MB | 1 | 5 | [Kijai/WanVideo_comfy](https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/FastWan/FastWan_T2V_14B_480p_lora_rank_64_bf16.safetensors) |
| `loras/wan2.2` | `lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors` | 738.01 MB | 1 | 7 | [Kijai/WanVideo_comfy](https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors) |
| `loras/wan2.2` | `Wan2.2-Fun-A14B-InP-LOW-HPS2.1_resized_dynamic_avg_rank_15_bf16.safetensors` | 101.75 MB | 1 | 5 | [Kijai/WanVideo_comfy](https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Wan22_FunReward/Wan2.2-Fun-A14B-InP-LOW-HPS2.1_resized_dynamic_avg_rank_15_bf16.safetensors) |
| `loras/wan2.2` | `Wan2.2-Lightning_I2V-A14B-4steps-lora_LOW_fp16.safetensors` | 613.56 MB | 1 | 5 | [Kijai/WanVideo_comfy](https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Wan22-Lightning/old/Wan2.2-Lightning_I2V-A14B-4steps-lora_LOW_fp16.safetensors) |
| `loras/wan2.2` | `Wan21_PusaV1_LoRA_14B_rank512_bf16.safetensors` | 4.91 GB | 1 | 5 | [Kijai/WanVideo_comfy](https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Pusa/Wan21_PusaV1_LoRA_14B_rank512_bf16.safetensors) |
| `loras/wan2.2` | `WanAnimate_relight_lora_fp16.safetensors` | 1.44 GB | 1 | 5 | [Kijai/WanVideo_comfy](https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Wan22_relight/WanAnimate_relight_lora_fp16.safetensors) |
| `model_patches` | `wan2.1_infiniteTalk_single_fp16.safetensors` | 5.13 GB | 1 | 5 | [Comfy-Org/Wan_2.1_ComfyUI_repackaged](https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/model_patches/wan2.1_infiniteTalk_single_fp16.safetensors) |
| `model_patches` | `Z-Image-Turbo-Fun-Controlnet-Union.safetensors` | 3.10 GB | 1 | 1 | [alibaba-pai/Z-Image-Turbo-Fun-Controlnet-Union](https://huggingface.co/alibaba-pai/Z-Image-Turbo-Fun-Controlnet-Union/resolve/main/Z-Image-Turbo-Fun-Controlnet-Union.safetensors) |
| `sam3` | `sam3.pt` | 3.45 GB | 1 | 5 | [pankjkkkkkk/sam3_pt](https://huggingface.co/pankjkkkkkk/sam3_pt/resolve/main/sam3.pt) |
| `SEEDVR2` | `ema_vae_fp16.safetensors` | 501.32 MB | 3 | 3 | [numz/SeedVR2_comfyUI](https://huggingface.co/numz/SeedVR2_comfyUI/resolve/main/ema_vae_fp16.safetensors) |
| `SEEDVR2` | `seedvr2_ema_3b_fp16.safetensors` | 6.78 GB | 1 | 1 | [numz/SeedVR2_comfyUI](https://huggingface.co/numz/SeedVR2_comfyUI/resolve/main/seedvr2_ema_3b_fp16.safetensors) |
| `SEEDVR2` | `seedvr2_ema_7b_fp8_e4m3fn_mixed_block35_fp16.safetensors` | 8.47 GB | 2 | 2 | [AInVFX/SeedVR2_comfyUI](https://huggingface.co/AInVFX/SeedVR2_comfyUI/resolve/main/seedvr2_ema_7b_fp8_e4m3fn_mixed_block35_fp16.safetensors) |
| `text_encoders` | `clip_l.safetensors` | 246.14 MB | 2 | 2 | [comfyanonymous/flux_text_encoders](https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors) |
| `text_encoders` | `gemma4_e4b_it_fp8_scaled.safetensors` | 9.06 GB | 4 | 13 | [Comfy-Org/gemma-4](https://huggingface.co/Comfy-Org/gemma-4/resolve/main/text_encoders/gemma4_e4b_it_fp8_scaled.safetensors) |
| `text_encoders` | `gemma_3_12B_it_fp4_mixed.safetensors` | 9.45 GB | 1 | 1 | [Comfy-Org/ltx-2](https://huggingface.co/Comfy-Org/ltx-2/resolve/main/split_files/text_encoders/gemma_3_12B_it_fp4_mixed.safetensors) |
| `text_encoders` | `gemma_3_12B_it_fp8_e4m3fn.safetensors` | 13.21 GB | 1 | 1 | [GitMylo/LTX-2-comfy_gemma_fp8_e4m3fn](https://huggingface.co/GitMylo/LTX-2-comfy_gemma_fp8_e4m3fn/resolve/main/gemma_3_12B_it_fp8_e4m3fn.safetensors) |
| `text_encoders` | `gpt_oss_20b_nvfp4.safetensors` | 13.24 GB | 1 | 1 | [Comfy-Org/Lens](https://huggingface.co/Comfy-Org/Lens/resolve/main/text_encoders/gpt_oss_20b_nvfp4.safetensors) |
| `text_encoders` | `Huihui-Qwen3-4B-abliterated-v2_fp8mixed.safetensors` | 8.04 GB | 1 | 1 | [georgehenney/Huihui-Qwen3-4B-abliterated-v2](https://huggingface.co/georgehenney/Huihui-Qwen3-4B-abliterated-v2/resolve/main/qwen3_4b_abliterated_v2.safetensors) |
| `text_encoders` | `Huihui-Qwen3-VL-4B-Instruct-abliterated-fp8_scaled.safetensors` | 5.24 GB | 2 | 5 | [artsyww/fp8mix-clips](https://huggingface.co/artsyww/fp8mix-clips/resolve/main/Huihui-Qwen3-VL-4B-Instruct-abliterated-fp8_scaled.safetensors) |
| `text_encoders` | `ming_image_0.1_ling_mini_2.0_int8_convrot.safetensors` | 19.51 GB | 1 | 17 | [Comfy-Org/Ming-Image](https://huggingface.co/Comfy-Org/Ming-Image/resolve/main/text_encoders/ming_image_0.1_ling_mini_2.0_int8_convrot.safetensors) |
| `text_encoders` | `minimax_music3_text_encoder_pruned_int8_convrot.safetensors` | 9.20 GB | 1 | 1 | [Comfy-Org/MiniMax-Music-3](https://huggingface.co/Comfy-Org/MiniMax-Music-3/resolve/main/text_encoders/minimax_music3_text_encoder_pruned_int8_convrot.safetensors) |
| `text_encoders` | `ministral-3-3b.safetensors` | 7.72 GB | 1 | 1 | [Comfy-Org/ERNIE-Image](https://huggingface.co/Comfy-Org/ERNIE-Image/resolve/main/text_encoders/ministral-3-3b.safetensors) |
| `text_encoders` | `qwen-4b-zimage-heretic-q8.gguf` | 4.28 GB | 1 | 1 | [Lockout/qwen3-4b-heretic-zimage](https://huggingface.co/Lockout/qwen3-4b-heretic-zimage/resolve/main/qwen-4b-zimage-heretic-q8.gguf) |
| `text_encoders` | `qwen3-vl-4b-heretic_int8.safetensors` | 4.84 GB | 3 | 11 | [DreamFast/Qwen3-VL-4b-Heretic-ComfyUI](https://huggingface.co/DreamFast/Qwen3-VL-4b-Heretic-ComfyUI/resolve/main/qwen3-vl-4b-heretic_int8.safetensors) |
| `text_encoders` | `qwen3-vl-8b-heretic-1.3.0_fp8_e4m3fn.safetensors` | 10.02 GB | 1 | 2 | [DreamFast/Qwen3-VL-8B-Heretic-1.3.0](https://huggingface.co/DreamFast/Qwen3-VL-8B-Heretic-1.3.0/resolve/main/comfyui/qwen3-vl-8b-heretic-1.3.0_fp8_e4m3fn.safetensors) |
| `text_encoders` | `qwen3.5_4b_bf16.safetensors` | 9.32 GB | 1 | 4 | [Comfy-Org/Qwen3.5](https://huggingface.co/Comfy-Org/Qwen3.5/resolve/main/text_encoders/qwen3.5_4b_bf16.safetensors) |
| `text_encoders` | `qwen3.5_4b_int8_convrot.safetensors` | 5.59 GB | 2 | 3 | [Winnougan/Qwen-3.5-INT8-Convrot-Comfy](https://huggingface.co/Winnougan/Qwen-3.5-INT8-Convrot-Comfy/resolve/main/qwen3.5_4b_int8_convrot.safetensors) |
| `text_encoders` | `qwen3.5_9b_flux3_prompt_upsampler_w4a8.safetensors` | 6.72 GB | 1 | 2 | [black-forest-labs/flux-3-image-klein-comfy](https://huggingface.co/black-forest-labs/flux-3-image-klein-comfy/resolve/main/text_encoders/qwen3.5_9b_flux3_prompt_upsampler_w4a8.safetensors) (gated) |
| `text_encoders` | `qwen3.5_9b_w4a8_gptq.safetensors` | 7.34 GB | 1 | 9 | [Comfy-Org/MOSS-Image](https://huggingface.co/Comfy-Org/MOSS-Image/resolve/main/text_encoders/qwen3.5_9b_w4a8_gptq.safetensors) |
| `text_encoders` | `qwen3.8_27b_w4a8.safetensors` | 17.29 GB | 1 | 1 | [Comfy-Org/Qwen3.8-27B](https://huggingface.co/Comfy-Org/Qwen3.8-27B/resolve/main/text_encoders/qwen3.8_27b_w4a8.safetensors) |
| `text_encoders` | `qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors` | 15.69 GB | 3 | 19 | [Comfy-Org/MiniMax-H3](https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors) |
| `text_encoders` | `qwen3vl_4b_fp8_scaled.safetensors` | 5.24 GB | 3 | 15 | [Comfy-Org/Krea-2](https://huggingface.co/Comfy-Org/Krea-2/resolve/main/text_encoders/qwen3vl_4b_fp8_scaled.safetensors) |
| `text_encoders` | `qwen3vl_4b_int8_convrot.safetensors` | 4.86 GB | 1 | 19 | [black-forest-labs/flux-3-image-klein-comfy](https://huggingface.co/black-forest-labs/flux-3-image-klein-comfy/resolve/main/text_encoders/qwen3vl_4b_int8_convrot.safetensors) (gated) |
| `text_encoders` | `qwen3vl_8b_fp8_scaled.safetensors` | 10.59 GB | 1 | 3 | [Comfy-Org/Boogu-Image](https://huggingface.co/Comfy-Org/Boogu-Image/resolve/main/text_encoders/qwen3vl_8b_fp8_scaled.safetensors) |
| `text_encoders` | `qwen3vl_8b_int8_convrot.safetensors` | 9.35 GB | 2 | 33 | [Comfy-Org/Qwen-Image-2.1](https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main/text_encoders/qwen3vl_8b_int8_convrot.safetensors) |
| `text_encoders` | `qwen_0.6b_ace15.safetensors` | 1.19 GB | 1 | 1 | [Comfy-Org/ace_step_1.5_ComfyUI_files](https://huggingface.co/Comfy-Org/ace_step_1.5_ComfyUI_files/resolve/main/split_files/text_encoders/qwen_0.6b_ace15.safetensors) |
| `text_encoders` | `qwen_2.5_vl_7b_fp8_scaled.safetensors` | 9.38 GB | 1 | 1 | [Comfy-Org/Qwen-Image_ComfyUI](https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors) |
| `text_encoders` | `qwen_3_06b_base.safetensors` | 1.19 GB | 1 | 3 | [circlestone-labs/Anima](https://huggingface.co/circlestone-labs/Anima/resolve/main/split_files/text_encoders/qwen_3_06b_base.safetensors) |
| `text_encoders` | `qwen_3_4b.safetensors` | 8.04 GB | 1 | 4 | [Comfy-Org/z_image_turbo](https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors) |
| `text_encoders` | `qwen_3_4b_fp8_mixed.safetensors` | 5.63 GB | 7 | 15 | [Comfy-Org/z_image_turbo](https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b_fp8_mixed.safetensors) |
| `text_encoders` | `qwen_3_8b_fp8mixed.safetensors` | 8.66 GB | 14 | 67 | [Comfy-Org/flux2-klein-9B](https://huggingface.co/Comfy-Org/flux2-klein-9B/resolve/main/split_files/text_encoders/qwen_3_8b_fp8mixed.safetensors) |
| `text_encoders` | `qwen_4b_ace15.safetensors` | 8.38 GB | 1 | 1 | [Comfy-Org/ace_step_1.5_ComfyUI_files](https://huggingface.co/Comfy-Org/ace_step_1.5_ComfyUI_files/resolve/main/split_files/text_encoders/qwen_4b_ace15.safetensors) |
| `text_encoders` | `t5-v1_1-xxl-encoder-Q8_0.gguf` | 5.06 GB | 2 | 2 | [city96/t5-v1_1-xxl-encoder-gguf](https://huggingface.co/city96/t5-v1_1-xxl-encoder-gguf/resolve/main/t5-v1_1-xxl-encoder-Q8_0.gguf) |
| `text_encoders` | `t5gemma_b_b_ul2.safetensors` | 1.19 GB | 1 | 4 | [Comfy-Org/stable-audio-3](https://huggingface.co/Comfy-Org/stable-audio-3/resolve/main/text_encoders/t5gemma_b_b_ul2.safetensors) |
| `text_encoders` | `umt5-xxl-enc-fp8_e4m3fn.safetensors` | 6.73 GB | 1 | 7 | [Kijai/WanVideo_comfy](https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/umt5-xxl-enc-fp8_e4m3fn.safetensors) |
| `text_encoders` | `umt5_xxl_fp8_e4m3fn_scaled.safetensors` | 6.74 GB | 2 | 9 | [Comfy-Org/Wan_2.1_ComfyUI_repackaged](https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors) |
| `upscale_models` | `4x_NMKD-Siax_200k.pth` | 66.96 MB | 4 | 6 | [Akumetsu971/SD_Anime_Futuristic_Armor](https://huggingface.co/Akumetsu971/SD_Anime_Futuristic_Armor/resolve/main/4x_NMKD-Siax_200k.pth) |
| `vae` | `ace_1.5_vae.safetensors` | 337.43 MB | 1 | 1 | [Comfy-Org/ace_step_1.5_ComfyUI_files](https://huggingface.co/Comfy-Org/ace_step_1.5_ComfyUI_files/resolve/main/split_files/vae/ace_1.5_vae.safetensors) |
| `vae` | `ae.safetensors` | 335.30 MB | 8 | 22 | [Comfy-Org/z_image_turbo](https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors) |
| `vae` | `flux2-vae.safetensors` | 336.21 MB | 17 | 92 | [Comfy-Org/flux2-dev](https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors) |
| `vae` | `flux2-vae_small.safetensors` | 249.52 MB | 1 | 9 | [Comfy-Org/MOSS-Image](https://huggingface.co/Comfy-Org/MOSS-Image/resolve/main/vae/flux2-vae_small.safetensors) |
| `vae` | `ming_image_vae_bf16.safetensors` | 253.82 MB | 1 | 17 | [Comfy-Org/Ming-Image](https://huggingface.co/Comfy-Org/Ming-Image/resolve/main/vae/ming_image_vae_bf16.safetensors) |
| `vae` | `minimax_h3_audio_vae_fp32.safetensors` | 605.25 MB | 3 | 17 | [Comfy-Org/MiniMax-H3](https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/vae/minimax_h3_audio_vae_fp32.safetensors) |
| `vae` | `minimax_h3_video_vae_fp16.safetensors` | 5.21 GB | 3 | 19 | [Comfy-Org/MiniMax-H3](https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/vae/minimax_h3_video_vae_fp16.safetensors) |
| `vae` | `minimax_music3_dav.safetensors` | 216.70 MB | 1 | 1 | [Comfy-Org/MiniMax-Music-3](https://huggingface.co/Comfy-Org/MiniMax-Music-3/resolve/main/vae/minimax_music3_dav.safetensors) |
| `vae` | `qwen_image_2.1_vae_bf16.safetensors` | 675.51 MB | 1 | 26 | [Comfy-Org/Qwen-Image-2.1](https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main/vae/qwen_image_2.1_vae_bf16.safetensors) |
| `vae` | `qwen_image_vae.safetensors` | 253.81 MB | 8 | 34 | [Comfy-Org/Krea-2](https://huggingface.co/Comfy-Org/Krea-2/resolve/main/vae/qwen_image_vae.safetensors) |
| `vae` | `trellis_2_shape_vae_bf16.safetensors` | 1.10 GB | 2 | 10 | [Comfy-Org/Pixal3D](https://huggingface.co/Comfy-Org/Pixal3D/resolve/main/vae/trellis_2_shape_vae_bf16.safetensors) |
| `vae` | `trellis_2_texture_vae_bf16.safetensors` | 948.46 MB | 2 | 8 | [Comfy-Org/Pixal3D](https://huggingface.co/Comfy-Org/Pixal3D/resolve/main/vae/trellis_2_texture_vae_bf16.safetensors) |
| `vae` | `Wan2_1_VAE_bf16.safetensors` | 253.81 MB | 2 | 7 | [Kijai/WanVideo_comfy](https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1_VAE_bf16.safetensors) |
| `vae` | `wan_2.1_vae.safetensors` | 253.82 MB | 1 | 9 | [Comfy-Org/Wan_2.1_ComfyUI_repackaged](https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors) |

## Shared models (repeated across episodes)

33 files are used by more than one episode. The last column shows how much download volume is avoided because each file is installed once.

| File | Size | Eps | WFs | Episodes | Saved by sharing |
|---|---:|---:|---:|---|---:|
| `flux2-vae.safetensors` | 336.21 MB | 17 | 92 | 04, 08, 09, 11, 13, 14, 16, 17, 18, 20, 22, 25, 27, 33, 34, 38, 39 | 5.38 GB |
| `qwen_3_8b_fp8mixed.safetensors` | 8.66 GB | 14 | 67 | 04, 08, 09, 11, 13, 16, 17, 18, 22, 25, 27, 33, 34, 38 | 112.64 GB |
| `qwen_image_vae.safetensors` | 253.81 MB | 8 | 34 | 02, 20, 24, 25, 26, 28, 30, 31 | 1.78 GB |
| `ae.safetensors` | 335.30 MB | 8 | 22 | 01, 02, 05, 18, 21, 25, 31, 39 | 2.35 GB |
| `flux-2-klein-9b-fp8mixed.safetensors` | 9.43 GB | 8 | 18 | 04, 08, 11, 13, 16, 17, 18, 22 | 66.03 GB |
| `qwen_3_4b_fp8_mixed.safetensors` | 5.63 GB | 7 | 15 | 01, 05, 18, 21, 25, 31, 39 | 33.79 GB |
| `flux-2-klein-9b-int8-convrot.safetensors` | 9.43 GB | 5 | 41 | 25, 27, 33, 34, 38 | 37.73 GB |
| `krea2_turbo_int8_convrot.safetensors` | 13.49 GB | 5 | 19 | 25, 26, 28, 30, 31 | 53.97 GB |
| `birefnet.safetensors` | 444.47 MB | 4 | 13 | 18, 33, 34, 38 | 1.33 GB |
| `gemma4_e4b_it_fp8_scaled.safetensors` | 9.06 GB | 4 | 13 | 18, 19, 20, 21 | 27.17 GB |
| `z-image-turbo_fp8_scaled_e5m2_KJ.safetensors` | 6.16 GB | 4 | 12 | 01, 05, 18, 21 | 18.47 GB |
| `4x_NMKD-Siax_200k.pth` | 66.96 MB | 4 | 6 | 05, 38, 39, 40 | 200.87 MB |
| `minimax_h3_video_vae_fp16.safetensors` | 5.21 GB | 3 | 19 | 29, 32, 35 | 10.42 GB |
| `qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors` | 15.69 GB | 3 | 19 | 29, 32, 35 | 31.37 GB |
| `minimax_h3_audio_vae_fp32.safetensors` | 605.25 MB | 3 | 17 | 29, 32, 35 | 1.21 GB |
| `qwen3vl_4b_fp8_scaled.safetensors` | 5.24 GB | 3 | 15 | 24, 25, 26 | 10.48 GB |
| `qwen3-vl-4b-heretic_int8.safetensors` | 4.84 GB | 3 | 11 | 28, 30, 31 | 9.67 GB |
| `ema_vae_fp16.safetensors` | 501.32 MB | 3 | 3 | 05, 06, 20 | 1.00 GB |
| `z_image_turbo_int8_convrot.safetensors` | 6.30 GB | 3 | 3 | 25, 31, 39 | 12.60 GB |
| `qwen3vl_8b_int8_convrot.safetensors` | 9.35 GB | 2 | 33 | 36, 38 | 9.35 GB |
| `dino_v3_L_naf_fp32.safetensors` | 1.22 GB | 2 | 10 | 33, 34 | 1.22 GB |
| `minimax_h3_fl2va_pruned_int8_convrot.safetensors` | 20.97 GB | 2 | 10 | 29, 32 | 20.97 GB |
| `trellis_2_shape_vae_bf16.safetensors` | 1.10 GB | 2 | 10 | 33, 34 | 1.10 GB |
| `clip_vision_h.safetensors` | 1.26 GB | 2 | 9 | 06, 23 | 1.26 GB |
| `umt5_xxl_fp8_e4m3fn_scaled.safetensors` | 6.74 GB | 2 | 9 | 06, 23 | 6.74 GB |
| `trellis_2_texture_vae_bf16.safetensors` | 948.46 MB | 2 | 8 | 33, 34 | 948.46 MB |
| `Wan2_1_VAE_bf16.safetensors` | 253.81 MB | 2 | 7 | 06, 23 | 253.81 MB |
| `minimax_h3_ref2va_pruned_int8_convrot.safetensors` | 20.97 GB | 2 | 6 | 29, 32 | 20.97 GB |
| `Huihui-Qwen3-VL-4B-Instruct-abliterated-fp8_scaled.safetensors` | 5.24 GB | 2 | 5 | 24, 25 | 5.24 GB |
| `qwen3.5_4b_int8_convrot.safetensors` | 5.59 GB | 2 | 3 | 31, 38 | 5.59 GB |
| `clip_l.safetensors` | 246.14 MB | 2 | 2 | 02, 05 | 246.14 MB |
| `seedvr2_ema_7b_fp8_e4m3fn_mixed_block35_fp16.safetensors` | 8.47 GB | 2 | 2 | 05, 20 | 8.47 GB |
| `t5-v1_1-xxl-encoder-Q8_0.gguf` | 5.06 GB | 2 | 2 | 02, 05 | 5.06 GB |

**Total saved: 525.02 GB.**  
## Multiple sources for the same filename

Six filenames are published in more than one Hugging Face repo. The canonical source below is the one cited most often in the workflow notes (ties go to Comfy-Org). The alternatives are equivalent files or different quantization of the same model; the setup scripts do not download them.

| File | Canonical source | Size | Other sources |
|---|---|---:|---|
| `4x_NMKD-Siax_200k.pth` | [Akumetsu971/SD_Anime_Futuristic_Armor](https://huggingface.co/Akumetsu971/SD_Anime_Futuristic_Armor/resolve/main/4x_NMKD-Siax_200k.pth) | 66.96 MB | [uwg/upscaler](https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4x_NMKD-Siax_200k.pth) (66.96 MB) |
| `ae.safetensors` | [Comfy-Org/z_image_turbo](https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors) | 335.30 MB | [Comfy-Org/HiDream-I1_ComfyUI](https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/vae/ae.safetensors) (335.30 MB) |
| `flux2-vae.safetensors` | [Comfy-Org/flux2-dev](https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors) | 336.21 MB | [black-forest-labs/flux-3-image-klein-comfy](https://huggingface.co/black-forest-labs/flux-3-image-klein-comfy/resolve/main/vae/flux2-vae.safetensors) (336.21 MB)<br>[Comfy-Org/Lens](https://huggingface.co/Comfy-Org/Lens/resolve/main/vae/flux2-vae.safetensors) (336.21 MB)<br>[Comfy-Org/ERNIE-Image](https://huggingface.co/Comfy-Org/ERNIE-Image/resolve/main/vae/flux2-vae.safetensors) (336.21 MB) |
| `qwen_image_vae.safetensors` | [Comfy-Org/Krea-2](https://huggingface.co/Comfy-Org/Krea-2/resolve/main/vae/qwen_image_vae.safetensors) | 253.81 MB | [circlestone-labs/Anima](https://huggingface.co/circlestone-labs/Anima/resolve/main/split_files/vae/qwen_image_vae.safetensors) (253.81 MB)<br>[Comfy-Org/Qwen-Image_ComfyUI](https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors) (253.81 MB) |
| `wan_2.1_vae.safetensors` | [Comfy-Org/Wan_2.1_ComfyUI_repackaged](https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors) | 253.82 MB | [Comfy-Org/Wan_2.2_ComfyUI_Repackaged](https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors) (253.82 MB) |
| `z_image_turbo_int8_convrot.safetensors` | [Winnougan/Z-Image-Base-Turbo-INT8-Convrot](https://huggingface.co/Winnougan/Z-Image-Base-Turbo-INT8-Convrot/resolve/main/z_image_turbo_int8_convrot.safetensors) | 6.30 GB | [Comfy-Org/z_image_turbo](https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/diffusion_models/z_image_turbo_int8_convrot.safetensors) (6.20 GB) |

## Folder disagreements between notes and workflows

When a note and a loader disagree, the file is installed where the **workflow widget** looks. Otherwise the workflow would show a red missing-model node. These are the only disagreements in the archive.

| File | Installed in | Note hint(s) | Why |
|---|---|---|---|
| `CakeStyle.safetensors` | `loras/sd15` | `checkpoints/sd15` | The loader reads it from `loras/sd15`; the note's `checkpoints/sd15` is wrong. |
| `clip_l.safetensors` | `text_encoders` | `clip`, `text_encoders` | Modern ComfyUI uses `text_encoders`; `clip` is the legacy folder name. |
| `lens_bf16.safetensors` | `diffusion_models/lens` | `diffusion_models`, `diffusion_models/lens` | The widget includes the `lens` subfolder; the note omits it. |
| `lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors` | `loras/wan2.2` | `loras`, `loras/wan2.2` | The widget includes the `wan2.2` subfolder; one note omits it. |
| `ltx-2-19b-dev-fp8.safetensors` | `checkpoints/ltx2` | `checkpoints`, `checkpoints/ltx2` | `properties.models` says `checkpoints`, the note and the widget say `checkpoints/ltx2`. |
| `ltx-2-19b-distilled-lora-384.safetensors` | `loras/ltx-2` | `loras`, `loras/ltx2` | The loader uses `ltx-2\...`; both note variants are beat by the widget path. |
| `ltx-2-19b-ic-lora-detailer.safetensors` | `loras/ltx-2` | `loras/ltx2` | The loader uses `ltx-2\...`; the note says `ltx2`. |
| `ltx-2-19b-lora-camera-control-static.safetensors` | `loras/ltx-2` | `loras/ltx2` | The loader uses `ltx-2\...`; the note says `ltx2`. |
| `pixag1rlwh1t3.safetensors` | `loras` | `loras/zimage` | The loader uses the bare filename, so the file must sit at the root of `loras`. |
| `pixal3d_int8_convrot.safetensors` | `diffusion_models/3D` | `diffusion_models`, `diffusion_models/3d` | The widget uses `3D`; notes use `3d`. Linux paths are case-sensitive, so the widget casing wins. |
| `pixal3d_multiview_int8_convrot.safetensors` | `diffusion_models/3D` | `diffusion_models`, `diffusion_models/3d` | The widget uses `3D`; notes use `3d`. Linux paths are case-sensitive, so the widget casing wins. |
| `t5-v1_1-xxl-encoder-Q8_0.gguf` | `text_encoders` | `clip`, `text_encoders` | Modern ComfyUI uses `text_encoders`; `clip` is the legacy folder name. |
| `trellis_2_int8_convrot.safetensors` | `diffusion_models/3D` | `diffusion_models`, `diffusion_models/3d` | The widget uses `3D`; notes use `3d`. Linux paths are case-sensitive, so the widget casing wins. |
| `Wan2_1-I2V-14B-480p_fp8_e4m3fn_scaled_KJ.safetensors` | `diffusion_models/wan2.1` | `diffusion_models`, `diffusion_models/wan2.1` | The widget includes the `wan2.1` subfolder; the note omits it. |

## Special cases

### Renamed on install

- **eye-highnoise.safetensors** — the upstream file is `highnoise.safetensors`. The note tells you to rename it; the scripts do that automatically. Source: [NikolaSigmoid/wan2.2-i2v-loras-eye-in](https://huggingface.co/NikolaSigmoid/wan2.2-i2v-loras-eye-in/resolve/main/highnoise.safetensors).
- **Huihui-Qwen3-4B-abliterated-v2_fp8mixed.safetensors** — the upstream file is `qwen3_4b_abliterated_v2.safetensors`. The note tells you to rename it; the scripts do that automatically. Source: [georgehenney/Huihui-Qwen3-4B-abliterated-v2](https://huggingface.co/georgehenney/Huihui-Qwen3-4B-abliterated-v2/resolve/main/qwen3_4b_abliterated_v2.safetensors).

### Substitute source (upstream repo deleted)

- **Huihui-Qwen3-4B-abliterated-v2_fp8mixed.safetensors** — SUBSTITUTE: the linked repo silveroxides/Qwen3-4B-ComfyQuants-SingleFiles was deleted from Hugging Face. This merged bf16 abliterated-v2 model is a drop-in replacement for CLIPLoader type lumina2 and is installed under the workflow's expected filename. It is ~8.0 GB instead of the original ~4.2 GB fp8mixed file.  
  Source: [georgehenney/Huihui-Qwen3-4B-abliterated-v2](https://huggingface.co/georgehenney/Huihui-Qwen3-4B-abliterated-v2/resolve/main/qwen3_4b_abliterated_v2.safetensors), 8,044,982,080 bytes.

### Manual file

- **krea2-questpaint26.safetensors** (`loras/krea2`) — Input for the Krea 2 LoRA Converter workflow. It is a fal.ai-trained LoRA the user provides; the note only links the fal.ai trainer. An already converted example (krea2-questpaint26_comfyui.safetensors) is published in Pixaroma/experimental_loras.

### Models downloaded by the node itself

`AILab_QwenVL_GGUF` and `DWPreprocessor` fetch their own weights on first run (`Qwen3VL-8B-Instruct-Q8_0.gguf`, `yolox_l.onnx`, `dw-ll_ucoco_384_bs5.torchscript.pt`). They are deliberately not in the catalog.

### Gated downloads (FLUX 3)

Three files come from `black-forest-labs/flux-3-image-klein-comfy`, which requires accepting the license and logging in before download:

- `diffusion_models/flux3/flux3-image-klein-int8-convrot.safetensors` — 5.83 GB
- `text_encoders/qwen3.5_9b_flux3_prompt_upsampler_w4a8.safetensors` — 6.72 GB
- `text_encoders/qwen3vl_4b_int8_convrot.safetensors` — 4.86 GB

Accept the terms at <https://huggingface.co/black-forest-labs/flux-3-image-klein-comfy>, then run `hf auth login`. The scripts print this hint and continue with the ungated files if you are not logged in.

## Size by episode

Distinct downloadable files used by each pack. The counts exclude the one manual file and the weights that `AILab_QwenVL_GGUF` / `DWPreprocessor` download themselves. Episode 26 also needs one manual file, so its real total is slightly higher. Shared files are counted in every episode that uses them; the scripts download them only once.

| Ep | Pack | Workflows | Model files | Download size | Notes |
|---|---|---:|---:|---:|---|
| 01 | EP01 Workflows.zip | 10 | 11 | 37.28 GB |  |
| 02 | EP02 Workflows.zip | 3 | 9 | 47.30 GB |  |
| 03 | EP03 Workflows.zip | 1 | 0 | 0 B |  |
| 04 | EP04 Workflows.zip | 8 | 5 | 30.55 GB |  |
| 05 | EP05 Workflows.zip | 8 | 9 | 33.24 GB |  |
| 06 | Ep06 Workflows.zip | 17 | 34 | 207.25 GB |  |
| 07 | Ep07 Workflows.zip | 8 | 0 | 0 B |  |
| 08 | Ep08 Workflows.zip | 14 | 3 | 18.43 GB |  |
| 09 | Ep09 Workflows.zip | 8 | 3 | 18.82 GB |  |
| 10 | Ep10 Workflows.zip | 3 | 0 | 0 B |  |
| 11 | Ep11 Workflows.zip | 7 | 3 | 18.43 GB |  |
| 12 | Ep12 Workflows.zip | 0 | 0 | 0 B | custom-node examples; no workflows |
| 13 | Ep13 Workflows.zip | 9 | 3 | 18.43 GB |  |
| 14 | Ep14 Workflows.zip | 2 | 3 | 16.75 GB |  |
| 15 | Ep15 Workflows.zip | 2 | 4 | 19.88 GB |  |
| 16 | Ep16 Workflows.zip | 5 | 4 | 27.75 GB |  |
| 17 | Ep17 Workflows.zip | 3 | 3 | 18.43 GB |  |
| 18 | Ep18 Workflows.zip | 24 | 8 | 40.06 GB |  |
| 19 | Ep19 Workflows.zip | 4 | 3 | 19.47 GB |  |
| 20 | Ep20 Workflows.zip | 5 | 9 | 45.44 GB |  |
| 21 | Ep21 Workflows.zip | 2 | 4 | 21.18 GB |  |
| 22 | Ep22 Workflows.zip | 3 | 3 | 18.43 GB |  |
| 23 | Ep23 Workflows.zip | 7 | 5 | 27.42 GB |  |
| 24 | Ep24 Workflows.zip | 11 | 6 | 24.82 GB |  |
| 25 | Ep25 Workflows.zip | 13 | 13 | 88.26 GB |  |
| 26 | Ep26 Workflows.zip | 4 | 4 | 19.22 GB | 1 manual |
| 27 | Ep27 Workflows.zip | 1 | 4 | 18.56 GB |  |
| 28 | Ep28 Workflows.zip | 4 | 3 | 18.58 GB |  |
| 29 | Ep29 Workflows.zip | 11 | 5 | 63.44 GB |  |
| 30 | Ep30 Workflows.zip | 7 | 6 | 31.57 GB |  |
| 31 | Ep31 Workflows.zip | 5 | 10 | 48.35 GB |  |
| 32 | Ep32 Workflows.zip | 5 | 6 | 65.40 GB |  |
| 33 | Ep33 Workflows.zip | 7 | 10 | 33.64 GB |  |
| 34 | Ep34 Workflows.zip | 7 | 8 | 27.72 GB |  |
| 35 | Ep35 Workflows.zip | 3 | 4 | 43.63 GB |  |
| 36 | Ep36 Workflows.zip | 27 | 6 | 18.28 GB |  |
| 37 | Ep37 Workflows.zip | 17 | 4 | 43.22 GB |  |
| 38 | Ep38 Workflows.zip | 50 | 7 | 33.88 GB |  |
| 39 | Ep39 Workflows.zip | 19 | 9 | 30.24 GB |  |
| 40 | Ep40 Workflows.zip | 9 | 5 | 14.26 GB |  |
| **Total** | 40 packs | **353** | **132 download + 1 manual** | **782.61 GB** | 1 manual |
