# Pixaroma workflow packs

The 40 episode packs in `archives/`, with every workflow and the model files it loads. Workflow paths are relative to the pack root after unzipping. Model names are filenames; folders and sizes are in [MODELS.md](MODELS.md).

> The curated portrait workflow pack is separate: `shorts/workflows/` (16 workflows in four categories), copied by `./setup.sh --short --install`. Seven of its permissively licensed generative workflows also carry local Qwen3-VL 4B prompt enhancer and post writer nodes. See [`SHORTS.md`](SHORTS.md). This document covers only the episode packs.

## Summary

- **40 episode packs**, **353 workflow JSONs**.
- **284 workflows** reference at least one model; the rest are utility, API-node, or auto-download workflows.
- **132 unique model files**, 782.61 GB total download.
- `all-workflows.zip` contains the same 40 packs under one `Pixaroma All Workflows/` folder.

| Ep | Pack | Workflows | Model files | Download size |
|---|---|---:|---:|---:|
| 01 | [EP01 Workflows.zip](archives/EP01%20Workflows.zip) | 10 | 11 | 37.28 GB |
| 02 | [EP02 Workflows.zip](archives/EP02%20Workflows.zip) | 3 | 9 | 47.30 GB |
| 03 | [EP03 Workflows.zip](archives/EP03%20Workflows.zip) | 1 | 0 | 0 B |
| 04 | [EP04 Workflows.zip](archives/EP04%20Workflows.zip) | 8 | 5 | 30.55 GB |
| 05 | [EP05 Workflows.zip](archives/EP05%20Workflows.zip) | 8 | 9 | 33.24 GB |
| 06 | [Ep06 Workflows.zip](archives/Ep06%20Workflows.zip) | 17 | 34 | 207.25 GB |
| 07 | [Ep07 Workflows.zip](archives/Ep07%20Workflows.zip) | 8 | 0 | 0 B |
| 08 | [Ep08 Workflows.zip](archives/Ep08%20Workflows.zip) | 14 | 3 | 18.43 GB |
| 09 | [Ep09 Workflows.zip](archives/Ep09%20Workflows.zip) | 8 | 3 | 18.82 GB |
| 10 | [Ep10 Workflows.zip](archives/Ep10%20Workflows.zip) | 3 | 0 | 0 B |
| 11 | [Ep11 Workflows.zip](archives/Ep11%20Workflows.zip) | 7 | 3 | 18.43 GB |
| 12 | [Ep12 Workflows.zip](archives/Ep12%20Workflows.zip) | 0 | 0 | 0 B |
| 13 | [Ep13 Workflows.zip](archives/Ep13%20Workflows.zip) | 9 | 3 | 18.43 GB |
| 14 | [Ep14 Workflows.zip](archives/Ep14%20Workflows.zip) | 2 | 3 | 16.75 GB |
| 15 | [Ep15 Workflows.zip](archives/Ep15%20Workflows.zip) | 2 | 4 | 19.88 GB |
| 16 | [Ep16 Workflows.zip](archives/Ep16%20Workflows.zip) | 5 | 4 | 27.75 GB |
| 17 | [Ep17 Workflows.zip](archives/Ep17%20Workflows.zip) | 3 | 3 | 18.43 GB |
| 18 | [Ep18 Workflows.zip](archives/Ep18%20Workflows.zip) | 24 | 8 | 40.06 GB |
| 19 | [Ep19 Workflows.zip](archives/Ep19%20Workflows.zip) | 4 | 3 | 19.47 GB |
| 20 | [Ep20 Workflows.zip](archives/Ep20%20Workflows.zip) | 5 | 9 | 45.44 GB |
| 21 | [Ep21 Workflows.zip](archives/Ep21%20Workflows.zip) | 2 | 4 | 21.18 GB |
| 22 | [Ep22 Workflows.zip](archives/Ep22%20Workflows.zip) | 3 | 3 | 18.43 GB |
| 23 | [Ep23 Workflows.zip](archives/Ep23%20Workflows.zip) | 7 | 5 | 27.42 GB |
| 24 | [Ep24 Workflows.zip](archives/Ep24%20Workflows.zip) | 11 | 6 | 24.82 GB |
| 25 | [Ep25 Workflows.zip](archives/Ep25%20Workflows.zip) | 13 | 13 | 88.26 GB |
| 26 | [Ep26 Workflows.zip](archives/Ep26%20Workflows.zip) | 4 | 4 | 19.22 GB |
| 27 | [Ep27 Workflows.zip](archives/Ep27%20Workflows.zip) | 1 | 4 | 18.56 GB |
| 28 | [Ep28 Workflows.zip](archives/Ep28%20Workflows.zip) | 4 | 3 | 18.58 GB |
| 29 | [Ep29 Workflows.zip](archives/Ep29%20Workflows.zip) | 11 | 5 | 63.44 GB |
| 30 | [Ep30 Workflows.zip](archives/Ep30%20Workflows.zip) | 7 | 6 | 31.57 GB |
| 31 | [Ep31 Workflows.zip](archives/Ep31%20Workflows.zip) | 5 | 10 | 48.35 GB |
| 32 | [Ep32 Workflows.zip](archives/Ep32%20Workflows.zip) | 5 | 6 | 65.40 GB |
| 33 | [Ep33 Workflows.zip](archives/Ep33%20Workflows.zip) | 7 | 10 | 33.64 GB |
| 34 | [Ep34 Workflows.zip](archives/Ep34%20Workflows.zip) | 7 | 8 | 27.72 GB |
| 35 | [Ep35 Workflows.zip](archives/Ep35%20Workflows.zip) | 3 | 4 | 43.63 GB |
| 36 | [Ep36 Workflows.zip](archives/Ep36%20Workflows.zip) | 27 | 6 | 18.28 GB |
| 37 | [Ep37 Workflows.zip](archives/Ep37%20Workflows.zip) | 17 | 4 | 43.22 GB |
| 38 | [Ep38 Workflows.zip](archives/Ep38%20Workflows.zip) | 50 | 7 | 33.88 GB |
| 39 | [Ep39 Workflows.zip](archives/Ep39%20Workflows.zip) | 19 | 9 | 30.24 GB |
| 40 | [Ep40 Workflows.zip](archives/Ep40%20Workflows.zip) | 9 | 5 | 14.26 GB |
| **Total** | 40 packs | **353** | **132 download + 1 manual** | **782.61 GB** |

## Workflows by episode

### Ep01 — EP01 Workflows.zip

10 workflows · 11 model files · 37.28 GB. 3 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| 0 Help and Resources.json | — |
| 1 Juggernaut Reborn txt2img.json | `juggernaut_reborn.safetensors` |
| 2 Juggernaut Reborn img2img.json | `juggernaut_reborn.safetensors` |
| 3 Juggernaut Reborn txt2img + Lora.json | `CakeStyle.safetensors`, `juggernaut_reborn.safetensors` |
| 4 Juggernaut Reborn txt2img + ControlNet.json | `control_v11p_sd15_canny_fp16.safetensors`, `juggernaut_reborn.safetensors` |
| 5a Z-Image Turbo Fp8 AIO txt2img.json | `z-image-turbo-fp8-aio.safetensors` |
| 5b Z-Image Turbo Fp8 txt2img.json | `ae.safetensors`, `qwen_3_4b_fp8_mixed.safetensors`, `z-image-turbo_fp8_scaled_e5m2_KJ.safetensors` |
| 5c Z-Image Turbo GGUF txt2img.json | `ae.safetensors`, `qwen-4b-zimage-heretic-q8.gguf`, `z-image-turbo-q4_k_s.gguf` |
| 6 Z-Image Turbo Fp8 AIO txt2img + Lora.json | `pixag1rlwh1t3.safetensors`, `z-image-turbo-fp8-aio.safetensors` |
| 7 Z-Image Turbo Fp8 AIO txt2img + ControlNet.json | `z-image-turbo-fp8-aio.safetensors`, `Z-Image-Turbo-Fun-Controlnet-Union.safetensors` |

### Ep02 — EP02 Workflows.zip

3 workflows · 9 model files · 47.30 GB. 4 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| Nunchaku Flux1 Dev txt2img.json | `ae.safetensors`, `clip_l.safetensors`, `svdq-int4_r32-flux.1-dev.safetensors`, `t5-v1_1-xxl-encoder-Q8_0.gguf` |
| Nunchaku Qwen Image txt2img.json | `qwen_2.5_vl_7b_fp8_scaled.safetensors`, `qwen_image_vae.safetensors`, `svdq-int4_r128-qwen-image-lightningv1.1-8steps.safetensors` |
| Nunchaku Z-Image Turbo txt2img.json | `ae.safetensors`, `Huihui-Qwen3-4B-abliterated-v2_fp8mixed.safetensors`, `svdq-int4_r256-z-image-turbo.safetensors` |

### Ep03 — EP03 Workflows.zip

1 workflows · 0 model files · 0 B.

| Workflow | Models |
|---|---|
| QwenVL 3.json | — |

### Ep04 — EP04 Workflows.zip

8 workflows · 5 model files · 30.55 GB. 3 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| Flux 2 Klein 4B FP8 (Distilled)/Flux 2 Klein 4B FP8 (Distilled) - Image Generation.json | `flux-2-klein-4b-fp8.safetensors`, `flux2-vae.safetensors`, `qwen_3_4b.safetensors` |
| Flux 2 Klein 4B FP8 (Distilled)/Flux 2 Klein 4B FP8 (Distilled) - One Image (Inpaint).json | `flux-2-klein-4b-fp8.safetensors`, `flux2-vae.safetensors`, `qwen_3_4b.safetensors` |
| Flux 2 Klein 4B FP8 (Distilled)/Flux 2 Klein 4B FP8 (Distilled) - One Image Edit.json | `flux-2-klein-4b-fp8.safetensors`, `flux2-vae.safetensors`, `qwen_3_4b.safetensors` |
| Flux 2 Klein 4B FP8 (Distilled)/Flux 2 Klein 4B FP8 (Distilled) - Two Images Edit.json | `flux-2-klein-4b-fp8.safetensors`, `flux2-vae.safetensors`, `qwen_3_4b.safetensors` |
| Flux 2 Klein 9B FP8 (Distilled)/Flux 2 Klein 9B FP8 (Distilled) - Image Generation.json | `flux-2-klein-9b-fp8mixed.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| Flux 2 Klein 9B FP8 (Distilled)/Flux 2 Klein 9B FP8 (Distilled) - One Image (Inpaint).json | `flux-2-klein-9b-fp8mixed.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| Flux 2 Klein 9B FP8 (Distilled)/Flux 2 Klein 9B FP8 (Distilled) - One Image Edit.json | `flux-2-klein-9b-fp8mixed.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| Flux 2 Klein 9B FP8 (Distilled)/Flux 2 Klein 9B FP8 (Distilled) - Two Images Edit.json | `flux-2-klein-9b-fp8mixed.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |

### Ep05 — EP05 Workflows.zip

8 workflows · 9 model files · 33.24 GB. 8 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| 1 Upscale Simple No Model.json | — |
| 2 Upscale Simple With Model.json | `4x_NMKD-Siax_200k.pth` |
| 3 Z-Image Upscaler.json | `4x_NMKD-Siax_200k.pth`, `ae.safetensors`, `qwen_3_4b_fp8_mixed.safetensors`, `z-image-turbo_fp8_scaled_e5m2_KJ.safetensors` |
| 4 Nunchaku Fluxmania Upscaler.json | `4x_NMKD-Siax_200k.pth`, `ae.safetensors`, `clip_l.safetensors`, `svdq-int4_r32-fluxmania-legacy.safetensors`, `t5-v1_1-xxl-encoder-Q8_0.gguf` |
| 5 SeedVR2 Upscale.json | `ema_vae_fp16.safetensors`, `seedvr2_ema_7b_fp8_e4m3fn_mixed_block35_fp16.safetensors` |
| 6 PAID (51 Credits) - Nano Banana Pro Upscale.json | — |
| 7 PAID (53 Credits) - Recraft Creative Upscale.json | — |
| 8 PAID (8.5Credits) - SeeDream 4.5 Upscale.json | — |

### Ep06 — Ep06 Workflows.zip

17 workflows · 34 model files · 207.25 GB. 4 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| LTX-2/LTX-2 Image to Video with Audio.json | `gemma_3_12B_it_fp4_mixed.safetensors`, `ltx-2-19b-distilled-fp8.safetensors`, `ltx-2-spatial-upscaler-x2-1.0.safetensors` |
| LTX-2/LTX-2 Image to Video with Custom Audio.json | `gemma_3_12B_it_fp8_e4m3fn.safetensors`, `ltx-2-19b-dev-fp8.safetensors`, `ltx-2-19b-distilled-lora-384.safetensors`, `ltx-2-19b-ic-lora-detailer.safetensors`, `ltx-2-19b-lora-camera-control-static.safetensors`, `ltx-2-spatial-upscaler-x2-1.0.safetensors`, `MelBandRoformer_fp16.safetensors` |
| Video Upscale SeedVR2/Video Upscale SeedVR2.json | `ema_vae_fp16.safetensors`, `seedvr2_ema_3b_fp16.safetensors` |
| Wan 2.2 Animate/Wan 2.2 Animate 16FPS - Replace Character and Background.json | `clip_vision_h.safetensors`, `FastWan_T2V_14B_480p_lora_rank_64_bf16.safetensors`, `sam3.pt`, `umt5-xxl-enc-fp8_e4m3fn.safetensors`, `vitpose_h_wholebody_model.onnx`, `Wan2.2-Fun-A14B-InP-LOW-HPS2.1_resized_dynamic_avg_rank_15_bf16.safetensors`, `Wan2.2-Lightning_I2V-A14B-4steps-lora_LOW_fp16.safetensors`, `Wan21_PusaV1_LoRA_14B_rank512_bf16.safetensors`, `Wan2_2-Animate-14B_fp8_scaled_e4m3fn_KJ_v2.safetensors`, `wan_2.1_vae.safetensors`, `WanAnimate_relight_lora_fp16.safetensors`, `yolov10m.onnx` |
| Wan 2.2 Animate/Wan 2.2 Animate 16FPS - Replace Only Character.json | `clip_vision_h.safetensors`, `FastWan_T2V_14B_480p_lora_rank_64_bf16.safetensors`, `sam3.pt`, `umt5-xxl-enc-fp8_e4m3fn.safetensors`, `vitpose_h_wholebody_model.onnx`, `Wan2.2-Fun-A14B-InP-LOW-HPS2.1_resized_dynamic_avg_rank_15_bf16.safetensors`, `Wan2.2-Lightning_I2V-A14B-4steps-lora_LOW_fp16.safetensors`, `Wan21_PusaV1_LoRA_14B_rank512_bf16.safetensors`, `Wan2_2-Animate-14B_fp8_scaled_e4m3fn_KJ_v2.safetensors`, `wan_2.1_vae.safetensors`, `WanAnimate_relight_lora_fp16.safetensors`, `yolov10m.onnx` |
| Wan 2.2 Animate/Wan 2.2 Animate 24FPS -  Replace Character and Background HD.json | `clip_vision_h.safetensors`, `FastWan_T2V_14B_480p_lora_rank_64_bf16.safetensors`, `sam3.pt`, `umt5-xxl-enc-fp8_e4m3fn.safetensors`, `vitpose_h_wholebody_model.onnx`, `Wan2.2-Fun-A14B-InP-LOW-HPS2.1_resized_dynamic_avg_rank_15_bf16.safetensors`, `Wan2.2-Lightning_I2V-A14B-4steps-lora_LOW_fp16.safetensors`, `Wan21_PusaV1_LoRA_14B_rank512_bf16.safetensors`, `Wan2_2-Animate-14B_fp8_scaled_e4m3fn_KJ_v2.safetensors`, `wan_2.1_vae.safetensors`, `WanAnimate_relight_lora_fp16.safetensors`, `yolov10m.onnx` |
| Wan 2.2 Animate/Wan 2.2 Animate 24FPS -  Replace Character and Background.json | `clip_vision_h.safetensors`, `FastWan_T2V_14B_480p_lora_rank_64_bf16.safetensors`, `sam3.pt`, `umt5-xxl-enc-fp8_e4m3fn.safetensors`, `vitpose_h_wholebody_model.onnx`, `Wan2.2-Fun-A14B-InP-LOW-HPS2.1_resized_dynamic_avg_rank_15_bf16.safetensors`, `Wan2.2-Lightning_I2V-A14B-4steps-lora_LOW_fp16.safetensors`, `Wan21_PusaV1_LoRA_14B_rank512_bf16.safetensors`, `Wan2_2-Animate-14B_fp8_scaled_e4m3fn_KJ_v2.safetensors`, `wan_2.1_vae.safetensors`, `WanAnimate_relight_lora_fp16.safetensors`, `yolov10m.onnx` |
| Wan 2.2 Animate/Wan 2.2 Animate 24FPS - Replace Only Character.json | `clip_vision_h.safetensors`, `FastWan_T2V_14B_480p_lora_rank_64_bf16.safetensors`, `sam3.pt`, `umt5-xxl-enc-fp8_e4m3fn.safetensors`, `vitpose_h_wholebody_model.onnx`, `Wan2.2-Fun-A14B-InP-LOW-HPS2.1_resized_dynamic_avg_rank_15_bf16.safetensors`, `Wan2.2-Lightning_I2V-A14B-4steps-lora_LOW_fp16.safetensors`, `Wan21_PusaV1_LoRA_14B_rank512_bf16.safetensors`, `Wan2_2-Animate-14B_fp8_scaled_e4m3fn_KJ_v2.safetensors`, `wan_2.1_vae.safetensors`, `WanAnimate_relight_lora_fp16.safetensors`, `yolov10m.onnx` |
| Wan 2.2/Wan 2.2 Image to Video + Lora.json | `eye-highnoise.safetensors`, `umt5_xxl_fp8_e4m3fn_scaled.safetensors`, `wan2.2_i2v_A14b_high_noise_lightx2v_4step-Q6_K.gguf`, `wan2.2_i2v_A14b_low_noise_lightx2v_4step-Q6_K.gguf`, `wan_2.1_vae.safetensors` |
| Wan 2.2/Wan 2.2 Image to Video.json | `umt5_xxl_fp8_e4m3fn_scaled.safetensors`, `wan2.2_i2v_A14b_high_noise_lightx2v_4step-Q6_K.gguf`, `wan2.2_i2v_A14b_low_noise_lightx2v_4step-Q6_K.gguf`, `wan_2.1_vae.safetensors` |
| Wan InfiniteTalk/Wan InfiniteTalk - Duration 10, 11 Seconds.json | `lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors`, `umt5_xxl_fp8_e4m3fn_scaled.safetensors`, `wan2.1_infiniteTalk_single_fp16.safetensors`, `Wan2_1-I2V-14B-480p_fp8_e4m3fn_scaled_KJ.safetensors`, `Wan2_1_VAE_bf16.safetensors`, `wav2vec2-chinese-base_fp16.safetensors` |
| Wan InfiniteTalk/Wan InfiniteTalk - Duration 4, 5, 6 Seconds.json | `lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors`, `umt5_xxl_fp8_e4m3fn_scaled.safetensors`, `wan2.1_infiniteTalk_single_fp16.safetensors`, `Wan2_1-I2V-14B-480p_fp8_e4m3fn_scaled_KJ.safetensors`, `Wan2_1_VAE_bf16.safetensors`, `wav2vec2-chinese-base_fp16.safetensors` |
| Wan InfiniteTalk/Wan InfiniteTalk - Duration 7, 8, 9 Seconds.json | `lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors`, `umt5_xxl_fp8_e4m3fn_scaled.safetensors`, `wan2.1_infiniteTalk_single_fp16.safetensors`, `Wan2_1-I2V-14B-480p_fp8_e4m3fn_scaled_KJ.safetensors`, `Wan2_1_VAE_bf16.safetensors`, `wav2vec2-chinese-base_fp16.safetensors` |
| Wan InfiniteTalk/Wan InfiniteTalk- Easy Extend from 3 to 34 Seconds.json | `lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors`, `umt5_xxl_fp8_e4m3fn_scaled.safetensors`, `wan2.1_infiniteTalk_single_fp16.safetensors`, `Wan2_1-I2V-14B-480p_fp8_e4m3fn_scaled_KJ.safetensors`, `Wan2_1_VAE_bf16.safetensors`, `wav2vec2-chinese-base_fp16.safetensors` |
| Wan InfiniteTalk/Wan InfiniteTalk- Manual Extend from 3 to 34 Seconds.json | `lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors`, `umt5_xxl_fp8_e4m3fn_scaled.safetensors`, `wan2.1_infiniteTalk_single_fp16.safetensors`, `Wan2_1-I2V-14B-480p_fp8_e4m3fn_scaled_KJ.safetensors`, `Wan2_1_VAE_bf16.safetensors`, `wav2vec2-chinese-base_fp16.safetensors` |
| Wan Scail/Wan Scail Image to Video - Multi Character 9 To 16 Ratio Only.json | `clip_vision_h.safetensors`, `lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors`, `umt5-xxl-enc-fp8_e4m3fn.safetensors`, `vitpose_h_wholebody_model.onnx`, `Wan21-14B-SCAIL-preview_fp8_e4m3fn_scaled_KJ.safetensors`, `Wan21_Uni3C_controlnet_fp16.safetensors`, `wan_2.1_vae.safetensors`, `yolov10m.onnx` |
| Wan Scail/Wan Scail Image to Video - Single Character.json | `clip_vision_h.safetensors`, `lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors`, `umt5-xxl-enc-fp8_e4m3fn.safetensors`, `vitpose_h_wholebody_model.onnx`, `Wan21-14B-SCAIL-preview_fp8_e4m3fn_scaled_KJ.safetensors`, `Wan21_Uni3C_controlnet_fp16.safetensors`, `wan_2.1_vae.safetensors`, `yolov10m.onnx` |

### Ep07 — Ep07 Workflows.zip

8 workflows · 0 model files · 0 B.

| Workflow | Models |
|---|---|
| 1. Qwen3-TTS CustomVoice.json | — |
| 2. Qwen3-TTS VoiceDesign.json | — |
| 3. Qwen3-TTS VoiceClone.json | — |
| 4. Qwen3-TTS VoiceClone + SaveVoice.json | — |
| 5. Qwen3-TTS VoiceDesign + SaveVoice.json | — |
| 6. Qwen3-TTS VoiceClone + Load A Previous Saved Voice.json | — |
| 7. Qwen3-TTS VoiceClone + Load Saved Multi Voice + Dialogue.json | — |
| 8. Qwen3-TTS VoiceDesign + Dialogue.json | — |

### Ep08 — Ep08 Workflows.zip

14 workflows · 3 model files · 18.43 GB. 3 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| 01. Remove Background.json | — |
| 02. Remove Background with Sam3.json | — |
| 03. Remove Background from Transparent Items.json | — |
| 04. Image Combiner.json | — |
| 05. Image Combiner for Transparent Items.json | — |
| 06. Image Blend.json | — |
| 07. Image Compare.json | — |
| 08. Image Stitch.json | — |
| 09. Image Filters.json | — |
| 10. Image Filters Example.json | — |
| 11. Image Transformation.json | — |
| 12. Image Scale.json | — |
| 13. Lama Remover.json | — |
| 14. Flux 2 Klein Multi Steps Workflow Example.json | `flux-2-klein-9b-fp8mixed.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |

### Ep09 — Ep09 Workflows.zip

8 workflows · 3 model files · 18.82 GB. 2 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| 1a. Flux 2 Klein 9B KV FP8 - 1 Image Edit (Same Ratio).json | `flux-2-klein-9b-kv-fp8.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 1c. Flux 2 Klein 9B KV FP8 - 1 Image Edit (Custom Ratio).json | `flux-2-klein-9b-kv-fp8.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 1i. Flux 2 Klein 9B KV FP8 - 1 Image Edit Inpaint.json | `flux-2-klein-9b-kv-fp8.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 1o. Flux 2 Klein 9B KV FP8 - 1 Image Edit Outpaint (Custom Ratio).json | `flux-2-klein-9b-kv-fp8.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 2. Flux 2 Klein 9B KV FP8 - 2 Images Edit.json | `flux-2-klein-9b-kv-fp8.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 3. Flux 2 Klein 9B KV FP8 - 3 Images Edit.json | `flux-2-klein-9b-kv-fp8.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 4. Flux 2 Klein 9B KV FP8 - 4 Images Edit.json | `flux-2-klein-9b-kv-fp8.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 5. Flux 2 Klein 9B KV FP8 - Image Blend.json | `flux-2-klein-9b-kv-fp8.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |

### Ep10 — Ep10 Workflows.zip

3 workflows · 0 model files · 0 B.

| Workflow | Models |
|---|---|
| Fish S2 Multi-Speaker TTS.json | — |
| Fish S2 TTS.json | — |
| Fish S2 Voice Clone TTS.json | — |

### Ep11 — Ep11 Workflows.zip

7 workflows · 3 model files · 18.43 GB. 3 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| 3D Builder Pixaroma Workflow.json | — |
| Crop Pixaroma Workflow.json | — |
| Flux 2 Klein 9B FP8 (Distilled) - One Image Edit with Paint Pixaroma Node.json | `flux-2-klein-9b-fp8mixed.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| Image Compare Pixaroma Workflow.json | — |
| Image Composer Pixaroma Workflow.json | — |
| Labels Pixaroma Workflow.json | — |
| Paint Pixaroma Workflow.json | — |

### Ep12 — Ep12 Workflows.zip

0 workflows · 0 model files · 0 B.

_This pack contains custom-node examples (Python/JS), not workflow JSONs._

### Ep13 — Ep13 Workflows.zip

9 workflows · 3 model files · 18.43 GB. 3 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| 1. Image Composer - Flux Klein 9B.json | `flux-2-klein-9b-fp8mixed.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 2. Paint - Flux Klein 9B.json | `flux-2-klein-9b-fp8mixed.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 3. 3D Builder - Flux Klein 9B.json | `flux-2-klein-9b-fp8mixed.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 3D Builder Pixaroma Workflow.json | — |
| Crop Pixaroma Workflow.json | — |
| Image Compare Pixaroma Workflow.json | — |
| Image Composer Pixaroma Workflow.json | — |
| Labels Pixaroma Workflow.json | — |
| Paint Pixaroma Workflow.json | — |

### Ep14 — Ep14 Workflows.zip

2 workflows · 3 model files · 16.75 GB. 1 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| Ernie Image Turbo GGUF t2i Workflow.json | `ernie-image-turbo-Q8_0.gguf`, `flux2-vae.safetensors`, `ministral-3-3b.safetensors` |
| Note Pixaroma Workflow.json | — |

### Ep15 — Ep15 Workflows.zip

2 workflows · 4 model files · 19.88 GB.

| Workflow | Models |
|---|---|
| Acestep v1.5 xl Turbo Text to Music.json | `ace_1.5_vae.safetensors`, `acestep_v1.5_xl_turbo_bf16.safetensors`, `qwen_0.6b_ace15.safetensors`, `qwen_4b_ace15.safetensors` |
| AudioReact Workflow.json | — |

### Ep16 — Ep16 Workflows.zip

5 workflows · 4 model files · 27.75 GB. 3 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| Flux Klein 9b + Qwen 3.5 - img2prompt2img.json | `flux-2-klein-9b-fp8mixed.safetensors`, `flux2-vae.safetensors`, `qwen3.5_4b_bf16.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| Flux Klein 9b + Qwen 3.5 - txt2prompt2img.json | `flux-2-klein-9b-fp8mixed.safetensors`, `flux2-vae.safetensors`, `qwen3.5_4b_bf16.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| Flux Klein 9b txt2img.json | `flux-2-klein-9b-fp8mixed.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| Qwen 3.5 - Image 2 Prompt.json | `qwen3.5_4b_bf16.safetensors` |
| Qwen 3.5 - Text 2 Prompt.json | `qwen3.5_4b_bf16.safetensors` |

### Ep17 — Ep17 Workflows.zip

3 workflows · 3 model files · 18.43 GB. 3 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| Flux 2 Klein 9B - One Image Edit V1.json | `flux-2-klein-9b-fp8mixed.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| Flux 2 Klein 9B - One Image Edit V2 + Notify and Switch.json | `flux-2-klein-9b-fp8mixed.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| Flux 2 Klein 9B - One Image Edit V3 + Get filename and Export in Today Folder.json | `flux-2-klein-9b-fp8mixed.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |

### Ep18 — Ep18 Workflows.zip

24 workflows · 8 model files · 40.06 GB. 8 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| 01a. Gemma 4 - Prompt Enhancer.json | `gemma4_e4b_it_fp8_scaled.safetensors` |
| 01b. Gemma 4 - Prompt Enhancer + Z-Image Turbo txt2img.json | `ae.safetensors`, `gemma4_e4b_it_fp8_scaled.safetensors`, `qwen_3_4b_fp8_mixed.safetensors`, `z-image-turbo_fp8_scaled_e5m2_KJ.safetensors` |
| 02a. Gemma 4 - Image to Prompt.json | `gemma4_e4b_it_fp8_scaled.safetensors` |
| 02b. Gemma 4 - Image to Prompt + Z-Image Turbo txt2img.json | `ae.safetensors`, `gemma4_e4b_it_fp8_scaled.safetensors`, `qwen_3_4b_fp8_mixed.safetensors`, `z-image-turbo_fp8_scaled_e5m2_KJ.safetensors` |
| 03. Gemma 4 - Audio to Text.json | `gemma4_e4b_it_fp8_scaled.safetensors` |
| 04a. Gemma 4 - Video to Prompt.json | `gemma4_e4b_it_fp8_scaled.safetensors` |
| 04b. Gemma 4 - Video to Description.json | `gemma4_e4b_it_fp8_scaled.safetensors` |
| 05. Switch Node.json | — |
| 06a. Prompt Stack.json | — |
| 06b. Prompt Stack + Z-Image Turbo txt2img.json | `ae.safetensors`, `qwen_3_4b_fp8_mixed.safetensors`, `z-image-turbo_fp8_scaled_e5m2_KJ.safetensors` |
| 07a. Prompt Pack - Line.json | — |
| 07b. Prompt Pack - Line + Z-Image Turbo txt2img.json | `ae.safetensors`, `qwen_3_4b_fp8_mixed.safetensors`, `z-image-turbo_fp8_scaled_e5m2_KJ.safetensors` |
| 07c. Prompt Pack - Paragraph.json | — |
| 07d. Prompt Pack - Paragraph + Z-Image Turbo txt2img.json | `ae.safetensors`, `qwen_3_4b_fp8_mixed.safetensors`, `z-image-turbo_fp8_scaled_e5m2_KJ.safetensors` |
| 08a. Prompt Multi - From List.json | — |
| 08b. Prompt Multi - From List + Flux Klein 9b.json | `flux-2-klein-9b-fp8mixed.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 08c. Prompt Multi - Queue Text.json | — |
| 08d. Prompt Multi - Queue Text + Z-Image Turbo txt2img.json | `ae.safetensors`, `qwen_3_4b_fp8_mixed.safetensors`, `z-image-turbo_fp8_scaled_e5m2_KJ.safetensors` |
| 09. Read Prompt From Image.json | — |
| 10a. Text Overlay.json | — |
| 10b. Text Overlay + Z-Image Turbo txt2img.json | `ae.safetensors`, `qwen_3_4b_fp8_mixed.safetensors`, `z-image-turbo_fp8_scaled_e5m2_KJ.safetensors` |
| 11. Remove Image Background.json | `birefnet.safetensors` |
| 12. Change Node Color.json | — |
| Z-Image Turbo txt2img.json | `ae.safetensors`, `qwen_3_4b_fp8_mixed.safetensors`, `z-image-turbo_fp8_scaled_e5m2_KJ.safetensors` |

### Ep19 — Ep19 Workflows.zip

4 workflows · 3 model files · 19.47 GB. 1 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| Stable Audio 3 - img2music with Gemma 4.json | `gemma4_e4b_it_fp8_scaled.safetensors`, `stable_audio_3_medium.safetensors`, `t5gemma_b_b_ul2.safetensors` |
| Stable Audio 3 - txt2audio.json | `stable_audio_3_medium.safetensors`, `t5gemma_b_b_ul2.safetensors` |
| Stable Audio 3 - txt2music with Gemma 4.json | `gemma4_e4b_it_fp8_scaled.safetensors`, `stable_audio_3_medium.safetensors`, `t5gemma_b_b_ul2.safetensors` |
| Stable Audio 3 - txt2sound with Gemma 4.json | `gemma4_e4b_it_fp8_scaled.safetensors`, `stable_audio_3_medium.safetensors`, `t5gemma_b_b_ul2.safetensors` |

### Ep20 — Ep20 Workflows.zip

5 workflows · 9 model files · 45.44 GB. 5 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| Anima Base v1.0 + Gemma 4 txt2img.json | `anima-base-v1.0.safetensors`, `gemma4_e4b_it_fp8_scaled.safetensors`, `qwen_3_06b_base.safetensors`, `qwen_image_vae.safetensors` |
| Anima Base v1.0 txt2img + SeedVR2 Upscale.json | `anima-base-v1.0.safetensors`, `ema_vae_fp16.safetensors`, `qwen_3_06b_base.safetensors`, `qwen_image_vae.safetensors`, `seedvr2_ema_7b_fp8_e4m3fn_mixed_block35_fp16.safetensors` |
| Anima Base v1.0 txt2img.json | `anima-base-v1.0.safetensors`, `qwen_3_06b_base.safetensors`, `qwen_image_vae.safetensors` |
| Gemma 4 - Anima Prompt Enhancer.json | `gemma4_e4b_it_fp8_scaled.safetensors` |
| Lens txt2img.json | `flux2-vae.safetensors`, `gpt_oss_20b_nvfp4.safetensors`, `lens_bf16.safetensors` |

### Ep21 — Ep21 Workflows.zip

2 workflows · 4 model files · 21.18 GB. 4 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| Z-Image Turbo txt2img + Gemma 4 + Find and Replace.json | `ae.safetensors`, `gemma4_e4b_it_fp8_scaled.safetensors`, `qwen_3_4b_fp8_mixed.safetensors`, `z-image-turbo_fp8_scaled_e5m2_KJ.safetensors` |
| Z-Image Turbo txt2img + XY Plot.json | `ae.safetensors`, `qwen_3_4b_fp8_mixed.safetensors`, `z-image-turbo_fp8_scaled_e5m2_KJ.safetensors` |

### Ep22 — Ep22 Workflows.zip

3 workflows · 3 model files · 18.43 GB. 3 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| Flux Klein 9b + Load Images from Folder.json | `flux-2-klein-9b-fp8mixed.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| Flux Klein 9b Inpaint.json | `flux-2-klein-9b-fp8mixed.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| Load Images from Folder + Crop.json | — |

### Ep23 — Ep23 Workflows.zip

7 workflows · 5 model files · 27.42 GB. 3 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| Combine Pixaroma - Join Two Images.json | — |
| Group Compare - ComfyUI vs Pixaroma.json | — |
| Loop Pixaroma - Build a List.json | — |
| Loop Pixaroma - Build an Image Batch.json | — |
| Loop Pixaroma - Carry Two Values.json | — |
| Scail 2 Video - Compact.json | `clip_vision_h.safetensors`, `lightx2v_I2V_14B_480p_cfg_step_distill_rank128_bf16.safetensors`, `umt5_xxl_fp8_e4m3fn_scaled.safetensors`, `wan2.1_14B_SCAIL_2_fp8_scaled.safetensors`, `Wan2_1_VAE_bf16.safetensors` |
| Scail 2 Video - Long.json | `clip_vision_h.safetensors`, `lightx2v_I2V_14B_480p_cfg_step_distill_rank128_bf16.safetensors`, `umt5_xxl_fp8_e4m3fn_scaled.safetensors`, `wan2.1_14B_SCAIL_2_fp8_scaled.safetensors`, `Wan2_1_VAE_bf16.safetensors` |

### Ep24 — Ep24 Workflows.zip

11 workflows · 6 model files · 24.82 GB. 3 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| 1a. Krea 2 Text to Image - Simple.json | `krea2_turbo_fp8_scaled.safetensors`, `qwen3vl_4b_fp8_scaled.safetensors`, `qwen_image_vae.safetensors` |
| 1b. Krea 2 Text to Image - Simple + Lora.json | `krea2_turbo_fp8_scaled.safetensors`, `krea2_vintagetarot.safetensors`, `qwen3vl_4b_fp8_scaled.safetensors`, `qwen_image_vae.safetensors` |
| 1c. Krea 2 Text to Image - Simple + Prompt Enhancer.json | `krea2_turbo_fp8_scaled.safetensors`, `qwen3vl_4b_fp8_scaled.safetensors`, `qwen_image_vae.safetensors` |
| 1d. Krea 2 Text to Image - Simple Low Vram.json | `krea2_turbo_fp8_scaled.safetensors`, `qwen3vl_4b_fp8_scaled.safetensors`, `qwen_image_vae.safetensors` |
| 2a. Krea 2 Text to Image + Extra Pass.json | `krea2_turbo_fp8_scaled.safetensors`, `qwen3vl_4b_fp8_scaled.safetensors`, `qwen_image_vae.safetensors` |
| 2b. Krea 2 Text to Image + Extra Pass + Lora.json | `krea2_kidsdrawing.safetensors`, `krea2_turbo_fp8_scaled.safetensors`, `qwen3vl_4b_fp8_scaled.safetensors`, `qwen_image_vae.safetensors` |
| 2c. Krea 2 Text to Image + Extra Pass + Prompt Enhancer.json | `krea2_turbo_fp8_scaled.safetensors`, `qwen3vl_4b_fp8_scaled.safetensors`, `qwen_image_vae.safetensors` |
| 2d. Krea 2 Text to Image - 2K.json | `krea2_turbo_fp8_scaled.safetensors`, `qwen3vl_4b_fp8_scaled.safetensors`, `qwen_image_vae.safetensors` |
| 3u. Krea 2 Text to Image + Extra Pass + Prompt Enhancer (Uncensored).json | `Huihui-Qwen3-VL-4B-Instruct-abliterated-fp8_scaled.safetensors`, `krea2_turbo_fp8_scaled.safetensors`, `qwen_image_vae.safetensors` |
| 3u. Krea 2 Text to Image + Prompt Enhancer (Uncensored).json | `Huihui-Qwen3-VL-4B-Instruct-abliterated-fp8_scaled.safetensors`, `krea2_turbo_fp8_scaled.safetensors`, `qwen_image_vae.safetensors` |
| 3u. Krea 2 Text to Image - 2K (Uncensored).json | `Huihui-Qwen3-VL-4B-Instruct-abliterated-fp8_scaled.safetensors`, `krea2_turbo_fp8_scaled.safetensors`, `qwen_image_vae.safetensors` |

### Ep25 — Ep25 Workflows.zip

13 workflows · 13 model files · 88.26 GB. 10 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| Boogu/1. Boogu Image - Text to Image.json | `ae.safetensors`, `boogu_image_turbo_hotfix_int8_convrot.safetensors`, `qwen3vl_8b_fp8_scaled.safetensors` |
| Boogu/2. Boogu Image - Text to Image + Prompt Enhancer.json | `ae.safetensors`, `boogu_image_turbo_hotfix_int8_convrot.safetensors`, `qwen3vl_8b_fp8_scaled.safetensors` |
| Boogu/3. Boogu Edit - One Image.json | `ae.safetensors`, `boogu_image_edit_turbo_int8_convrot.safetensors`, `qwen3vl_8b_fp8_scaled.safetensors` |
| Flux 2/1. Flux Klein 9b txt2img.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| Flux 2/2. Flux Klein 9b - One Image Edit.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| Flux 2/3. Flux Klein 9b Inpaint.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| Krea 2/1. Krea 2 Text to Image - Simple.json | `krea2_turbo_int8_convrot.safetensors`, `qwen3vl_4b_fp8_scaled.safetensors`, `qwen_image_vae.safetensors` |
| Krea 2/2. Krea 2 Text to Image - Simple + Prompt Enhancer.json | `krea2_turbo_int8_convrot.safetensors`, `qwen3vl_4b_fp8_scaled.safetensors`, `qwen_image_vae.safetensors` |
| Krea 2/3. Krea 2 Text to Image - Simple + Prompt from Image.json | `Huihui-Qwen3-VL-4B-Instruct-abliterated-fp8_scaled.safetensors`, `krea2_turbo_int8_convrot.safetensors`, `qwen_image_vae.safetensors` |
| Krea 2/4. Krea 2 Text to Image + Extra Pass.json | `krea2_turbo_int8_convrot.safetensors`, `qwen3vl_4b_fp8_scaled.safetensors`, `qwen_image_vae.safetensors` |
| Krea 2/5. Krea 2 Text to Image + Extra Pass + Prompt Enhancer.json | `krea2_turbo_int8_convrot.safetensors`, `qwen3vl_4b_fp8_scaled.safetensors`, `qwen_image_vae.safetensors` |
| Krea 2/6. Krea 2 Text to Image + Extra Pass + Prompt from Image.json | `Huihui-Qwen3-VL-4B-Instruct-abliterated-fp8_scaled.safetensors`, `krea2_turbo_int8_convrot.safetensors`, `qwen_image_vae.safetensors` |
| Z-Image/1. Z-Image Turbo txt2img.json | `ae.safetensors`, `qwen_3_4b_fp8_mixed.safetensors`, `z_image_turbo_int8_convrot.safetensors` |

### Ep26 — Ep26 Workflows.zip

4 workflows · 4 model files · 19.22 GB. Plus 1 manual file. 3 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| Krea 2 Lora Converter.json | `krea2-questpaint26.safetensors` |
| Krea 2 Text to Image + Extra Pass + Lora.json | `krea2-questpaint26_comfyui.safetensors`, `krea2_turbo_int8_convrot.safetensors`, `qwen3vl_4b_fp8_scaled.safetensors`, `qwen_image_vae.safetensors` |
| Krea 2 Text to Image - Simple + Lora XY Plot.json | `krea2-questpaint26_comfyui.safetensors`, `krea2_turbo_int8_convrot.safetensors`, `qwen3vl_4b_fp8_scaled.safetensors`, `qwen_image_vae.safetensors` |
| Krea 2 Text to Image - Simple + Lora.json | `krea2-questpaint26_comfyui.safetensors`, `krea2_turbo_int8_convrot.safetensors`, `qwen3vl_4b_fp8_scaled.safetensors`, `qwen_image_vae.safetensors` |

### Ep27 — Ep27 Workflows.zip

1 workflows · 4 model files · 18.56 GB. 3 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| Flux 2 Klein 9B Outpaint.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `pixaoutpaint.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |

### Ep28 — Ep28 Workflows.zip

4 workflows · 3 model files · 18.58 GB. 3 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| Krea 2 Text to Image + Prompt Enhancer.json | `krea2_turbo_int8_convrot.safetensors`, `qwen3-vl-4b-heretic_int8.safetensors`, `qwen_image_vae.safetensors` |
| Krea 2 Text to Image + Prompt from Image.json | `krea2_turbo_int8_convrot.safetensors`, `qwen3-vl-4b-heretic_int8.safetensors`, `qwen_image_vae.safetensors` |
| Krea 2 Text to Image.json | `krea2_turbo_int8_convrot.safetensors`, `qwen3-vl-4b-heretic_int8.safetensors`, `qwen_image_vae.safetensors` |
| Prompt from Image.json | `qwen3-vl-4b-heretic_int8.safetensors` |

### Ep29 — Ep29 Workflows.zip

11 workflows · 5 model files · 63.44 GB. 5 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| 1. Generate Video H3 (fl2va)/Minimax H3 - Image to video FF (First Frame).json | `minimax_h3_audio_vae_fp32.safetensors`, `minimax_h3_fl2va_pruned_int8_convrot.safetensors`, `minimax_h3_video_vae_fp16.safetensors`, `qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors` |
| 1. Generate Video H3 (fl2va)/Minimax H3 - Image to video FFLF.json | `minimax_h3_audio_vae_fp32.safetensors`, `minimax_h3_fl2va_pruned_int8_convrot.safetensors`, `minimax_h3_video_vae_fp16.safetensors`, `qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors` |
| 1. Generate Video H3 (fl2va)/Minimax H3 - Image to video LF (Last Frame).json | `minimax_h3_audio_vae_fp32.safetensors`, `minimax_h3_fl2va_pruned_int8_convrot.safetensors`, `minimax_h3_video_vae_fp16.safetensors`, `qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors` |
| 1. Generate Video H3 (fl2va)/Minimax H3 - Text to video.json | `minimax_h3_audio_vae_fp32.safetensors`, `minimax_h3_fl2va_pruned_int8_convrot.safetensors`, `minimax_h3_video_vae_fp16.safetensors`, `qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors` |
| 2. Generate Video H3 (ref2va)/Minimax H3 - Reference Three Images.json | `minimax_h3_audio_vae_fp32.safetensors`, `minimax_h3_ref2va_pruned_int8_convrot.safetensors`, `minimax_h3_video_vae_fp16.safetensors`, `qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors` |
| 2. Generate Video H3 (ref2va)/Minimax H3 - Reference Two Images.json | `minimax_h3_audio_vae_fp32.safetensors`, `minimax_h3_ref2va_pruned_int8_convrot.safetensors`, `minimax_h3_video_vae_fp16.safetensors`, `qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors` |
| 3. Generate Video H3 Audio Sync (ref2va)/Minimax H3 - Reference Image + Audio Sync - SING.json | `minimax_h3_audio_vae_fp32.safetensors`, `minimax_h3_ref2va_pruned_int8_convrot.safetensors`, `minimax_h3_video_vae_fp16.safetensors`, `qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors` |
| 3. Generate Video H3 Audio Sync (ref2va)/Minimax H3 - Reference Image + Audio Sync - SPEAK.json | `minimax_h3_audio_vae_fp32.safetensors`, `minimax_h3_ref2va_pruned_int8_convrot.safetensors`, `minimax_h3_video_vae_fp16.safetensors`, `qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors` |
| 4. Generate Image H3 (fl2va)/Minimax H3 - Image Edit.json | `minimax_h3_fl2va_pruned_int8_convrot.safetensors`, `minimax_h3_video_vae_fp16.safetensors`, `qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors` |
| 4. Generate Image H3 (fl2va)/Minimax H3 - Text to image.json | `minimax_h3_fl2va_pruned_int8_convrot.safetensors`, `minimax_h3_video_vae_fp16.safetensors`, `qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors` |
| Low Vram/Minimax H3 - Text to video (Low VRAM 8GB).json | `minimax_h3_audio_vae_fp32.safetensors`, `minimax_h3_fl2va_pruned_int8_convrot.safetensors`, `minimax_h3_video_vae_fp16.safetensors`, `qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors` |

### Ep30 — Ep30 Workflows.zip

7 workflows · 6 model files · 31.57 GB. 3 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| H3 Video Prompts/Minimax H3 First Frame 2 Video Prompt Generator.json | `qwen3-vl-8b-heretic-1.3.0_fp8_e4m3fn.safetensors` |
| H3 Video Prompts/Minimax H3 Text 2 Video Prompt Generator.json | `qwen3-vl-8b-heretic-1.3.0_fp8_e4m3fn.safetensors` |
| Krea2 Edit/Krea 2 + Edit Lora - Character and Background.json | `krea2_identity_edit_v1_2.safetensors`, `krea2_turbo_int8_convrot.safetensors`, `qwen3-vl-4b-heretic_int8.safetensors`, `qwen_image_vae.safetensors` |
| Krea2 Edit/Krea 2 + Edit Lora - Custom Ratio.json | `krea2_identity_edit_v1_2.safetensors`, `krea2_turbo_int8_convrot.safetensors`, `qwen3-vl-4b-heretic_int8.safetensors`, `qwen_image_vae.safetensors` |
| Krea2 Edit/Krea 2 + Edit Lora.json | `krea2_identity_edit_v1_2.safetensors`, `krea2_turbo_int8_convrot.safetensors`, `qwen3-vl-4b-heretic_int8.safetensors`, `qwen_image_vae.safetensors` |
| Krea2 Edit/Krea 2 + One Image Outfit Lora.json | `krea2_turbo_int8_convrot.safetensors`, `krea_outfittransfer.safetensors`, `qwen3-vl-4b-heretic_int8.safetensors`, `qwen_image_vae.safetensors` |
| Krea2 Edit/Krea 2 + Outfit Transfer 2.json | `krea2_turbo_int8_convrot.safetensors`, `krea_outfittransfer.safetensors`, `qwen3-vl-4b-heretic_int8.safetensors`, `qwen_image_vae.safetensors` |

### Ep31 — Ep31 Workflows.zip

5 workflows · 10 model files · 48.35 GB. 7 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| AI Prompts/Krea 2 Text to Image + Prompt Enhance.json | `krea2_turbo_int8_convrot.safetensors`, `qwen3-vl-4b-heretic_int8.safetensors`, `qwen_image_vae.safetensors` |
| AI Prompts/Krea 2 Text to Image + Prompt From Image.json | `krea2_turbo_int8_convrot.safetensors`, `qwen3-vl-4b-heretic_int8.safetensors`, `qwen_image_vae.safetensors` |
| AI Prompts/Z-Image Turbo Text to Image + Prompt Enhance.json | `ae.safetensors`, `qwen_3_4b_fp8_mixed.safetensors`, `z_image_turbo_int8_convrot.safetensors` |
| Minimax Music 3/Minimax Music 3 - Caption and Lyrics Generator.json | `qwen3.5_4b_int8_convrot.safetensors` |
| Minimax Music 3/Minimax Music 3 - Text to Music.json | `minimax_music3_dav.safetensors`, `minimax_music3_dit_int8_convrot.safetensors`, `minimax_music3_text_encoder_pruned_int8_convrot.safetensors` |

### Ep32 — Ep32 Workflows.zip

5 workflows · 6 model files · 65.40 GB. 5 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| Minimax H3 - Image to video FF + Speed Lora.json | `minimax_h3_audio_vae_fp32.safetensors`, `minimax_h3_fl2v_turbo_4step_v1.1_768p_comfyui_bf16.safetensors`, `minimax_h3_fl2va_pruned_int8_convrot.safetensors`, `minimax_h3_video_vae_fp16.safetensors`, `qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors` |
| Minimax H3 - Image to video FFLF + Speed Lora.json | `minimax_h3_audio_vae_fp32.safetensors`, `minimax_h3_fl2v_turbo_4step_v1.1_768p_comfyui_bf16.safetensors`, `minimax_h3_fl2va_pruned_int8_convrot.safetensors`, `minimax_h3_video_vae_fp16.safetensors`, `qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors` |
| Minimax H3 - Reference Image + Audio Sync - SING + Speed Lora.json | `minimax_h3_audio_vae_fp32.safetensors`, `minimax_h3_fl2v_turbo_4step_v1.1_768p_comfyui_bf16.safetensors`, `minimax_h3_ref2va_pruned_int8_convrot.safetensors`, `minimax_h3_video_vae_fp16.safetensors`, `qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors` |
| Minimax H3 - Reference Image + Audio Sync - SPEAK + Speed Lora.json | `minimax_h3_audio_vae_fp32.safetensors`, `minimax_h3_fl2v_turbo_4step_v1.1_768p_comfyui_bf16.safetensors`, `minimax_h3_ref2va_pruned_int8_convrot.safetensors`, `minimax_h3_video_vae_fp16.safetensors`, `qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors` |
| Minimax H3 - Text to Video + Speed Lora.json | `minimax_h3_audio_vae_fp32.safetensors`, `minimax_h3_fl2v_turbo_4step_v1.1_768p_comfyui_bf16.safetensors`, `minimax_h3_fl2va_pruned_int8_convrot.safetensors`, `minimax_h3_video_vae_fp16.safetensors`, `qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors` |

### Ep33 — Ep33 Workflows.zip

7 workflows · 10 model files · 33.64 GB. 7 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| 1. Trellis 2 - Image to 3D Model - Low VRAM.json | `birefnet.safetensors`, `dino_v3_L_naf_fp32.safetensors`, `trellis_2_int8_convrot.safetensors`, `trellis_2_shape_vae_bf16.safetensors`, `trellis_2_texture_vae_bf16.safetensors` |
| 1.2 Trellis 2 - Image to 3D Model - High VRAM.json | `birefnet.safetensors`, `dino_v3_L_naf_fp32.safetensors`, `trellis_2_int8_convrot.safetensors`, `trellis_2_shape_vae_bf16.safetensors`, `trellis_2_texture_vae_bf16.safetensors` |
| 2. Trellis 2 - Image to 3D Model - HQ + PBR Textures.json | `birefnet.safetensors`, `dino_v3_L_naf_fp32.safetensors`, `trellis_2_int8_convrot.safetensors`, `trellis_2_shape_vae_bf16.safetensors`, `trellis_2_texture_vae_bf16.safetensors` |
| 3. Pixal3D - Image to 3D Model - Low VRAM.json | `birefnet.safetensors`, `dino_v3_L_naf_fp32.safetensors`, `moge_2_vitl_normal_fp16.safetensors`, `pixal3d_int8_convrot.safetensors`, `trellis_2_shape_vae_bf16.safetensors`, `trellis_2_texture_vae_bf16.safetensors` |
| 4. Pixal3D - Image to 3D Model - HQ + PBR Textures.json | `birefnet.safetensors`, `dino_v3_L_naf_fp32.safetensors`, `moge_2_vitl_normal_fp16.safetensors`, `pixal3d_int8_convrot.safetensors`, `trellis_2_shape_vae_bf16.safetensors`, `trellis_2_texture_vae_bf16.safetensors` |
| 5. Flux Klein 9b - 3D Model to Image.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 6. Flux Klein 9b - 3D Model to Image - Keep the Angle.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |

### Ep34 — Ep34 Workflows.zip

7 workflows · 8 model files · 27.72 GB. 7 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| 1. Pixal3D Multi-View - Model - No colours.json | `birefnet.safetensors`, `dino_v3_L_naf_fp32.safetensors`, `pixal3d_multiview_int8_convrot.safetensors`, `trellis_2_shape_vae_bf16.safetensors` |
| 2. Pixal3D Multi-View - Model - No colours - HQ.json | `birefnet.safetensors`, `dino_v3_L_naf_fp32.safetensors`, `pixal3d_multiview_int8_convrot.safetensors`, `trellis_2_shape_vae_bf16.safetensors` |
| 3. Pixal3D Multi-View - Model + Colours.json | `birefnet.safetensors`, `dino_v3_L_naf_fp32.safetensors`, `pixal3d_multiview_int8_convrot.safetensors`, `trellis_2_shape_vae_bf16.safetensors`, `trellis_2_texture_vae_bf16.safetensors` |
| 4. Pixal3D Multi-View - Model + PBR Textures - LQ.json | `birefnet.safetensors`, `dino_v3_L_naf_fp32.safetensors`, `pixal3d_multiview_int8_convrot.safetensors`, `trellis_2_shape_vae_bf16.safetensors`, `trellis_2_texture_vae_bf16.safetensors` |
| 5. Pixal3D Multi-View - Model + PBR Textures - HQ.json | `birefnet.safetensors`, `dino_v3_L_naf_fp32.safetensors`, `pixal3d_multiview_int8_convrot.safetensors`, `trellis_2_shape_vae_bf16.safetensors`, `trellis_2_texture_vae_bf16.safetensors` |
| 6. Flux Klein 9b - 3D Model to Image.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 7. Flux Klein 9b - 3D Model to Image - Keep the Angle.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |

### Ep35 — Ep35 Workflows.zip

3 workflows · 4 model files · 43.63 GB. 3 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| 1. Minimax FastH3 - Text to Video.json | `fastvideo_fasth3_8step_v2_pruned_int8_convrot.safetensors`, `minimax_h3_audio_vae_fp32.safetensors`, `minimax_h3_video_vae_fp16.safetensors`, `qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors` |
| 2. Minimax FastH3 - FirstFrame to Video.json | `fastvideo_fasth3_8step_v2_pruned_int8_convrot.safetensors`, `minimax_h3_audio_vae_fp32.safetensors`, `minimax_h3_video_vae_fp16.safetensors`, `qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors` |
| 3. Minimax FastH3 - First and Last Frame.json | `fastvideo_fasth3_8step_v2_pruned_int8_convrot.safetensors`, `minimax_h3_audio_vae_fp32.safetensors`, `minimax_h3_video_vae_fp16.safetensors`, `qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors` |

### Ep36 — Ep36 Workflows.zip

27 workflows · 6 model files · 18.28 GB. 1 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| 1. Text to Image/1. Qwen Image 2.1 - Text to Image.json | `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 1. Text to Image/2. Qwen Image 2.1 - Text to Image - Low VRAM.json | `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 1. Text to Image/3. Qwen Image 2.1 - Text to Image + Prompt Enhancer.json | `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 1. Text to Image/4. Qwen Image 2.1 - Image to Prompt to Image.json | `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 1. Text to Image/5. Qwen Image 2.1 - Text to Image - Transparent PNG.json | `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 1. Text to Image/6. Qwen Image 2.1 - Text to Image - Turbo.json | `Qwen-Image-2.1-viggle-turbo-v0.2.1-6step-lora-r128.safetensors`, `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 1. Text to Image/7. Qwen Image 2.1 - Image to Prompt.json | `qwen3vl_8b_int8_convrot.safetensors` |
| 2. One Image Edit/1. Qwen Image 2.1 - One Image Edit.json | `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 2. One Image Edit/10. Qwen Image 2.1 - One Image Edit - Turbo.json | `Qwen-Image-2.1-viggle-turbo-v0.2.1-6step-lora-r128.safetensors`, `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 2. One Image Edit/11. Qwen Image 2.1 - Character Sheet.json | `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 2. One Image Edit/2. Qwen Image 2.1 - One Image Edit - Low VRAM.json | `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 2. One Image Edit/3. Qwen Image 2.1 - Image Edit - Inpaint.json | `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 2. One Image Edit/4. Qwen Image 2.1 - Remove Background.json | `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 2. One Image Edit/5. Qwen Image 2.1 - One Image Edit + Prompt Enhancer.json | `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 2. One Image Edit/6. Qwen Image 2.1 - Image Edit - Sketch.json | `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 2. One Image Edit/7. Qwen Image 2.1 - Image Edit - Sketch + Consistency LoRA.json | `qwen-image-2.1-consistency.safetensors`, `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 2. One Image Edit/8. Qwen Image 2.1 - One Image Edit + Consistency LoRA.json | `qwen-image-2.1-consistency.safetensors`, `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 2. One Image Edit/9. Qwen Image 2.1 - Outpaint.json | `qwen-image-2.1-outpaint-v2.safetensors`, `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 3. Multi Image Edit/1. Qwen Image 2.1 - Image Edit - Outfit Change.json | `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 3. Multi Image Edit/2. Qwen Image 2.1 - Image Edit - Logo on a Product.json | `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 3. Multi Image Edit/3. Qwen Image 2.1 - Image Edit - Character in a Scene.json | `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 3. Multi Image Edit/4. Qwen Image 2.1 - Image Edit - Pose from a Picture.json | `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 3. Multi Image Edit/5. Qwen Image 2.1 - Image Edit - 3 Images.json | `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 3. Multi Image Edit/6. Qwen Image 2.1 - Image Edit - 4 Images.json | `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 3. Multi Image Edit/7. Qwen Image 2.1 - Image Edit - Group Photo from 6 Images.json | `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 3. Multi Image Edit/8. Qwen Image 2.1 - Two Image Edit + Prompt Enhancer.json | `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |
| 3. Multi Image Edit/9. Qwen Image 2.1 - Image Edit - Outfit Change - Turbo.json | `Qwen-Image-2.1-viggle-turbo-v0.2.1-6step-lora-r128.safetensors`, `qwen3vl_8b_int8_convrot.safetensors`, `qwen_image_2.1_int8_convrot.safetensors`, `qwen_image_2.1_vae_bf16.safetensors` |

### Ep37 — Ep37 Workflows.zip

17 workflows · 4 model files · 43.22 GB.

| Workflow | Models |
|---|---|
| 1. Text to Image/1. Ming Image 0.1 - Text to Image.json | `ming_image_0.1_design_int8_convrot.safetensors`, `ming_image_0.1_ling_mini_2.0_int8_convrot.safetensors`, `ming_image_vae_bf16.safetensors` |
| 1. Text to Image/10. Ming Image 0.1 - Social Media Post.json | `ming_image_0.1_design_int8_convrot.safetensors`, `ming_image_0.1_ling_mini_2.0_int8_convrot.safetensors`, `ming_image_vae_bf16.safetensors` |
| 1. Text to Image/11. Ming Image 0.1 - Logo Variations.json | `ming_image_0.1_design_int8_convrot.safetensors`, `ming_image_0.1_ling_mini_2.0_int8_convrot.safetensors`, `ming_image_vae_bf16.safetensors` |
| 1. Text to Image/12. Ming Image 0.1 - 3D Lettering.json | `ming_image_0.1_design_int8_convrot.safetensors`, `ming_image_0.1_ling_mini_2.0_int8_convrot.safetensors`, `ming_image_vae_bf16.safetensors` |
| 1. Text to Image/2. Ming Image 0.1 - Text to Image + Prompt Enhancer.json | `ming_image_0.1_design_int8_convrot.safetensors`, `ming_image_0.1_ling_mini_2.0_int8_convrot.safetensors`, `ming_image_vae_bf16.safetensors`, `qwen3.8_27b_w4a8.safetensors` |
| 1. Text to Image/3. Ming Image 0.1 - Transparent PNG.json | `ming_image_0.1_design_int8_convrot.safetensors`, `ming_image_0.1_ling_mini_2.0_int8_convrot.safetensors`, `ming_image_vae_bf16.safetensors` |
| 1. Text to Image/4. Ming Image 0.1 - YouTube Thumbnail.json | `ming_image_0.1_design_int8_convrot.safetensors`, `ming_image_0.1_ling_mini_2.0_int8_convrot.safetensors`, `ming_image_vae_bf16.safetensors` |
| 1. Text to Image/5. Ming Image 0.1 - Logo Design.json | `ming_image_0.1_design_int8_convrot.safetensors`, `ming_image_0.1_ling_mini_2.0_int8_convrot.safetensors`, `ming_image_vae_bf16.safetensors` |
| 1. Text to Image/6. Ming Image 0.1 - App and Website Screens.json | `ming_image_0.1_design_int8_convrot.safetensors`, `ming_image_0.1_ling_mini_2.0_int8_convrot.safetensors`, `ming_image_vae_bf16.safetensors` |
| 1. Text to Image/7. Ming Image 0.1 - Game Screens and Icons.json | `ming_image_0.1_design_int8_convrot.safetensors`, `ming_image_0.1_ling_mini_2.0_int8_convrot.safetensors`, `ming_image_vae_bf16.safetensors` |
| 1. Text to Image/8. Ming Image 0.1 - Infographic.json | `ming_image_0.1_design_int8_convrot.safetensors`, `ming_image_0.1_ling_mini_2.0_int8_convrot.safetensors`, `ming_image_vae_bf16.safetensors` |
| 1. Text to Image/9. Ming Image 0.1 - Event Poster.json | `ming_image_0.1_design_int8_convrot.safetensors`, `ming_image_0.1_ling_mini_2.0_int8_convrot.safetensors`, `ming_image_vae_bf16.safetensors` |
| 2. Image Edit/1. Ming Image 0.1 - Image Edit.json | `ming_image_0.1_design_int8_convrot.safetensors`, `ming_image_0.1_ling_mini_2.0_int8_convrot.safetensors`, `ming_image_vae_bf16.safetensors` |
| 2. Image Edit/2. Ming Image 0.1 - Sketch to Photo.json | `ming_image_0.1_design_int8_convrot.safetensors`, `ming_image_0.1_ling_mini_2.0_int8_convrot.safetensors`, `ming_image_vae_bf16.safetensors` |
| 2. Image Edit/3. Ming Image 0.1 - Restyle a Design to 3D.json | `ming_image_0.1_design_int8_convrot.safetensors`, `ming_image_0.1_ling_mini_2.0_int8_convrot.safetensors`, `ming_image_vae_bf16.safetensors` |
| 2. Image Edit/4. Ming Image 0.1 - Product Ad from Two Pictures.json | `ming_image_0.1_design_int8_convrot.safetensors`, `ming_image_0.1_ling_mini_2.0_int8_convrot.safetensors`, `ming_image_vae_bf16.safetensors` |
| 2. Image Edit/5. Ming Image 0.1 - Social Media Pack.json | `ming_image_0.1_design_int8_convrot.safetensors`, `ming_image_0.1_ling_mini_2.0_int8_convrot.safetensors`, `ming_image_vae_bf16.safetensors` |

### Ep38 — Ep38 Workflows.zip

50 workflows · 7 model files · 33.88 GB. 7 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| 1. Image Folder Automation/1. Resize All Images in a Folder.json | — |
| 1. Image Folder Automation/2. Social Media Sizes for All Images in a Folder.json | — |
| 1. Image Folder Automation/3. Watermark All Images in a Folder.json | — |
| 1. Image Folder Automation/4. Rename and Convert All Images in a Folder.json | — |
| 1. Image Folder Automation/5. Remove the Background from All Images in a Folder.json | `birefnet.safetensors` |
| 1. Image Folder Automation/6. Slideshow Video from All Images in a Folder.json | — |
| 1. Image Folder Automation/7. Contact Sheet of All Images in a Folder.json | — |
| 1. Image Folder Automation/8. Upscale All Images in a Folder.json | `4x_NMKD-Siax_200k.pth` |
| 1. Image Folder Automation/9. Add Your Logo to All Images in a Folder.json | — |
| 2. Edit Image Folders with Flux Klein/1. Edit All Images in a Folder with One Prompt.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 2. Edit Image Folders with Flux Klein/2. Edit Each Image with Its Own Prompt.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 2. Edit Image Folders with Flux Klein/3. Coloring Pages from All Images in a Folder.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 2. Edit Image Folders with Flux Klein/4. Make All Images in a Folder Wide (Outpaint).json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 2. Edit Image Folders with Flux Klein/5. Product Photos from All Images in a Folder.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 2. Edit Image Folders with Flux Klein/6. Restore and Colorize Old Photos in a Folder.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 3. Many Prompts in One Run/1. One Image per Prompt.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 3. Many Prompts in One Run/10. Character Turnaround Sheet from One Image.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 3. Many Prompts in One Run/2. Every Prompt Combination with Brackets.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 3. Many Prompts in One Run/3. One Subject in Many Styles.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 3. Many Prompts in One Run/4. One Image, Many Edits.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 3. Many Prompts in One Run/5. Queue a List of Prompts.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 3. Many Prompts in One Run/6. Random Prompts Every Run.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 3. Many Prompts in One Run/7. Build a Prompt from Switches.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 3. Many Prompts in One Run/8. Short Ideas into Finished Images.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen3.5_4b_int8_convrot.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 3. Many Prompts in One Run/9. Turn a Short Story into a Storyboard.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen3.5_4b_int8_convrot.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 4. Loops/1. Loop Basics - Four Versions of One Prompt.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 4. Loops/2. Loop - Build Up an Image Step by Step.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 4. Loops/3. Loop - Photo Strip from All Images in a Folder.json | — |
| 4. Loops/4. Loop - Comic Strip with the Same Character.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 5. Test and Compare/1. XY Plot - Steps and Samplers.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 5. Test and Compare/2. XY Plot - Styles and Subjects.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 5. Test and Compare/3. Draft First, Then Finish.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 6. Control, Logic and Math/1. One Control Panel for the Whole Workflow.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 6. Control, Logic and Math/2. One Workflow, Two Jobs.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 6. Control, Logic and Math/3. Turn Steps On and Off.json | `birefnet.safetensors` |
| 6. Control, Logic and Math/4. Style Presets from a Dropdown.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 6. Control, Logic and Math/5. Math - Scale All Images in a Folder by Percent.json | — |
| 6. Control, Logic and Math/6. Set and Get - No Long Wires.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 7. AI and Prompts for Image Folders/1. Collect the Prompts from All Images in a Folder.json | — |
| 7. AI and Prompts for Image Folders/2. Re-create Old Images from Their Prompts.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 7. AI and Prompts for Image Folders/3. Caption All Images in a Folder for LoRA Training.json | `qwen3vl_8b_int8_convrot.safetensors` |
| 7. AI and Prompts for Image Folders/4. Rename Every Image by What Is in It.json | `qwen3vl_8b_int8_convrot.safetensors` |
| 7. AI and Prompts for Image Folders/5. The AI Writes an Edit for Every Image.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen3vl_8b_int8_convrot.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 7. AI and Prompts for Image Folders/6. Re-imagine All Images in a Folder in Another Style.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen3vl_8b_int8_convrot.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 8. Check, Filter and Review Image Folders/1. Before and After Grid for All Images in a Folder.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 8. Check, Filter and Review Image Folders/2. Keep Only the Images the AI Says Yes To.json | `qwen3vl_8b_int8_convrot.safetensors` |
| 8. Check, Filter and Review Image Folders/3. Sort All Images in a Folder into Subfolders by What Is in Them.json | `qwen3vl_8b_int8_convrot.safetensors` |
| 8. Check, Filter and Review Image Folders/4. Fix the Caption Text Files, Then Make the Images Again.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 8. Check, Filter and Review Image Folders/5. Do a Big Image Folder in Parts.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |
| 8. Check, Filter and Review Image Folders/6. One Image per Text File.json | `flux-2-klein-9b-int8-convrot.safetensors`, `flux2-vae.safetensors`, `qwen_3_8b_fp8mixed.safetensors` |

### Ep39 — Ep39 Workflows.zip

19 workflows · 9 model files · 30.24 GB. 5 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| 1. Text to Image/1. Flux 3 Klein - Text to Image.json | `flux2-vae.safetensors`, `flux3-image-klein-int8-convrot.safetensors`, `qwen3vl_4b_int8_convrot.safetensors` |
| 1. Text to Image/2. Flux 3 Klein - Text to Image + Z-Image Realism Pass.json | `4x_NMKD-Siax_200k.pth`, `ae.safetensors`, `flux2-vae.safetensors`, `flux3-image-klein-int8-convrot.safetensors`, `qwen3vl_4b_int8_convrot.safetensors`, `qwen_3_4b_fp8_mixed.safetensors`, `z_image_turbo_int8_convrot.safetensors` |
| 1. Text to Image/3. Flux 3 Klein - Text to Image + Prompt Upsampler.json | `flux2-vae.safetensors`, `flux3-image-klein-int8-convrot.safetensors`, `qwen3.5_9b_flux3_prompt_upsampler_w4a8.safetensors`, `qwen3vl_4b_int8_convrot.safetensors` |
| 1. Text to Image/4. Flux 3 Klein - Text in Images.json | `flux2-vae.safetensors`, `flux3-image-klein-int8-convrot.safetensors`, `qwen3vl_4b_int8_convrot.safetensors` |
| 1. Text to Image/5. Flux 3 Klein - Layout with Boxes.json | `flux2-vae.safetensors`, `flux3-image-klein-int8-convrot.safetensors`, `qwen3vl_4b_int8_convrot.safetensors` |
| 1. Text to Image/6. Flux 3 Klein - Image to Prompt to Image.json | `flux2-vae.safetensors`, `flux3-image-klein-int8-convrot.safetensors`, `qwen3.5_9b_flux3_prompt_upsampler_w4a8.safetensors`, `qwen3vl_4b_int8_convrot.safetensors` |
| 2. One Image Edit/07. Flux 3 Klein - Image Edit.json | `flux2-vae.safetensors`, `flux3-image-klein-int8-convrot.safetensors`, `qwen3vl_4b_int8_convrot.safetensors` |
| 2. One Image Edit/08. Flux 3 Klein - Edit inside a Box.json | `flux2-vae.safetensors`, `flux3-image-klein-int8-convrot.safetensors`, `qwen3vl_4b_int8_convrot.safetensors` |
| 2. One Image Edit/09. Flux 3 Klein - Edit Text in a Picture.json | `flux2-vae.safetensors`, `flux3-image-klein-int8-convrot.safetensors`, `qwen3vl_4b_int8_convrot.safetensors` |
| 2. One Image Edit/10. Flux 3 Klein - Restyle.json | `flux2-vae.safetensors`, `flux3-image-klein-int8-convrot.safetensors`, `qwen3vl_4b_int8_convrot.safetensors` |
| 2. One Image Edit/11. Flux 3 Klein - Relight and Seasons.json | `flux2-vae.safetensors`, `flux3-image-klein-int8-convrot.safetensors`, `qwen3vl_4b_int8_convrot.safetensors` |
| 2. One Image Edit/12. Flux 3 Klein - Restore and Colorize.json | `flux2-vae.safetensors`, `flux3-image-klein-int8-convrot.safetensors`, `qwen3vl_4b_int8_convrot.safetensors` |
| 2. One Image Edit/13. Flux 3 Klein - Character Sheet.json | `flux2-vae.safetensors`, `flux3-image-klein-int8-convrot.safetensors`, `qwen3vl_4b_int8_convrot.safetensors` |
| 2. One Image Edit/14. Flux 3 Klein - Outpaint.json | `flux-3-image-klein-outpaint.safetensors`, `flux2-vae.safetensors`, `flux3-image-klein-int8-convrot.safetensors`, `qwen3vl_4b_int8_convrot.safetensors` |
| 3. Multi Image Edit/15. Flux 3 Klein - Character in a Scene.json | `flux2-vae.safetensors`, `flux3-image-klein-int8-convrot.safetensors`, `qwen3vl_4b_int8_convrot.safetensors` |
| 3. Multi Image Edit/16. Flux 3 Klein - Outfit Change.json | `flux2-vae.safetensors`, `flux3-image-klein-int8-convrot.safetensors`, `qwen3vl_4b_int8_convrot.safetensors` |
| 3. Multi Image Edit/17. Flux 3 Klein - Logo on a Product.json | `flux2-vae.safetensors`, `flux3-image-klein-int8-convrot.safetensors`, `qwen3vl_4b_int8_convrot.safetensors` |
| 3. Multi Image Edit/18. Flux 3 Klein - Group Photo.json | `flux2-vae.safetensors`, `flux3-image-klein-int8-convrot.safetensors`, `qwen3vl_4b_int8_convrot.safetensors` |
| 3. Multi Image Edit/19. Flux 3 Klein - Product Ad.json | `flux2-vae.safetensors`, `flux3-image-klein-int8-convrot.safetensors`, `qwen3vl_4b_int8_convrot.safetensors` |

### Ep40 — Ep40 Workflows.zip

9 workflows · 5 model files · 14.26 GB. 1 of the model files are shared with other episodes.

| Workflow | Models |
|---|---|
| 1. MOSS Image - Text to Image.json | `flux2-vae_small.safetensors`, `moss_image_sft_int8_convrot.safetensors`, `qwen3.5_9b_w4a8_gptq.safetensors` |
| 2. MOSS Image - Text to Image + Prompt Helper.json | `flux2-vae_small.safetensors`, `moss_image_sft_int8_convrot.safetensors`, `qwen3.5_9b_w4a8_gptq.safetensors` |
| 3. MOSS Image - Fast 4 Steps with a Speed LoRA.json | `flux2-vae_small.safetensors`, `moss_image_sft_4step_v2.0.safetensors`, `moss_image_sft_int8_convrot.safetensors`, `qwen3.5_9b_w4a8_gptq.safetensors` |
| 4. MOSS Image - Words in Pictures.json | `flux2-vae_small.safetensors`, `moss_image_sft_int8_convrot.safetensors`, `qwen3.5_9b_w4a8_gptq.safetensors` |
| 5. MOSS Image - Layout with Boxes.json | `flux2-vae_small.safetensors`, `moss_image_sft_int8_convrot.safetensors`, `qwen3.5_9b_w4a8_gptq.safetensors` |
| 6. MOSS Image - Same Picture, New Words.json | `flux2-vae_small.safetensors`, `moss_image_sft_int8_convrot.safetensors`, `qwen3.5_9b_w4a8_gptq.safetensors` |
| 7. MOSS Image - Image to Prompt to Image.json | `flux2-vae_small.safetensors`, `moss_image_sft_int8_convrot.safetensors`, `qwen3.5_9b_w4a8_gptq.safetensors` |
| 8. MOSS Image - Upscale 2x, Keep the Picture.json | `flux2-vae_small.safetensors`, `moss_image_sft_int8_convrot.safetensors`, `qwen3.5_9b_w4a8_gptq.safetensors` |
| 9. MOSS Image - Upscale a Picture.json | `4x_NMKD-Siax_200k.pth`, `flux2-vae_small.safetensors`, `moss_image_sft_int8_convrot.safetensors`, `qwen3.5_9b_w4a8_gptq.safetensors` |
