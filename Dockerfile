# ---------------------------------------------------------------------------- #
#                         Part 1: Download the files                           #
# ---------------------------------------------------------------------------- #
FROM alpine/git:2.45.2 as download
COPY builder/clone.sh /clone.sh

# Clone the repos
# Fooocus-API
RUN . /clone.sh /workspace https://github.com/mrhan1993/Fooocus-API.git 966853794c527f5a08dcc190777022fe6e2e782a

# ---------------------------------------------------------------------------- #
#                        Part 2: Build the final image                         #
# ---------------------------------------------------------------------------- #
FROM python:3.10.14-slim as build_final_image
ENV DEBIAN_FRONTEND=noninteractive \
    PIP_PREFER_BINARY=1 \
    PYTHONUNBUFFERED=1
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Update and upgrade the system packages
RUN apt-get update && \
    apt install -y \
    fonts-dejavu-core rsync git jq moreutils aria2 wget libgoogle-perftools-dev procps libgl1 libglib2.0-0 && \
    apt-get autoremove -y && rm -rf /var/lib/apt/lists/* && apt-get clean -y

RUN --mount=type=cache,target=/cache --mount=type=cache,target=/root/.cache/pip \
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Copy downloaded data to the final image
COPY --from=download /workspace/ /workspace/
# Change Fooocus configs
COPY src/default.json /workspace/repositories/Fooocus/presets/default.json

# Install Python dependencies
COPY builder/requirements.txt /requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip && \
    pip install --upgrade -r /requirements.txt --no-cache-dir && \
    rm /requirements.txt

ADD src .

# Cleanup
RUN apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

#                        Upload or download models                             #
# ---------------------------------------------------------------------------- #
# Use either RUN wget for download or COPY for local files on your disk
# These are all the models Fooocus needs by default (you can also download them from https://huggingface.co/3WaD/RunPod-Fooocus-API/tree/main, civit.ai and Fooocus/Stability.ai huggingface)
COPY models/pandorasBoxNSFW_v1PussBoots.safetensors /workspace/repositories/Fooocus/models/checkpoints/pandorasBoxNSFW_v1PussBoots.safetensors
COPY models/sd_xl_offset_example-lora_1.0.safetensors /workspace/repositories/Fooocus/models/loras/sd_xl_offset_example-lora_1.0.safetensors

COPY models/sdxl_lcm_lora.safetensors /workspace/repositories/Fooocus/models/loras/sdxl_lcm_lora.safetensors
COPY models/sdxl_lightning_4step_lora.safetensors /workspace/repositories/Fooocus/models/loras/sdxl_lightning_4step_lora.safetensors
COPY models/fooocus_inpaint_head.pth /workspace/repositories/Fooocus/models/inpaint/fooocus_inpaint_head.pth
COPY models/inpaint.fooocus.patch /workspace/repositories/Fooocus/models/inpaint/inpaint.fooocus.patch
COPY models/inpaint_v25.fooocus.patch /workspace/repositories/Fooocus/models/inpaint/inpaint_v25.fooocus.patch
COPY models/inpaint_v26.fooocus.patch /workspace/repositories/Fooocus/models/inpaint/inpaint_v26.fooocus.patch
COPY models/control-lora-canny-rank128.safetensors /workspace/repositories/Fooocus/models/controlnet/control-lora-canny-rank128.safetensors
COPY models/fooocus_xl_cpds_128.safetensors /workspace/repositories/Fooocus/models/controlnet/fooocus_xl_cpds_128.safetensors
COPY models/fooocus_ip_negative.safetensors /workspace/repositories/Fooocus/models/controlnet/fooocus_ip_negative.safetensors
COPY models/ip-adapter-plus_sdxl_vit-h.bin /workspace/repositories/Fooocus/models/controlnet/ip-adapter-plus_sdxl_vit-h.bin
COPY models/ip-adapter-plus-face_sdxl_vit-h.bin /workspace/repositories/Fooocus/models/controlnet/ip-adapter-plus-face_sdxl_vit-h.bin
COPY models/fooocus_upscaler_s409985e5.bin /workspace/repositories/Fooocus/models/upscale_models/fooocus_upscaler_s409985e5.bin
COPY models/clip_vision_vit_h.safetensors /workspace/repositories/Fooocus/models/clip_vision/clip_vision_vit_h.safetensors
COPY models/xlvaeapp.pth /workspace/repositories/Fooocus/models/vae_approx/xlvaeapp.pth
COPY models/vaeapp_sd15.pt /workspace/repositories/Fooocus/models/vae_approx/vaeapp_sd15.pth
COPY models/xl-to-v1_interposer-v3.1.safetensors /workspace/repositories/Fooocus/models/vae_approx/xl-to-v1_interposer-v3.1.safetensors
COPY models/fooocus_expansion.bin /workspace/repositories/Fooocus/models/prompt_expansion/fooocus_expansion/pytorch_model.bin
COPY models/detection_Resnet50_Final.pth /workspace/repositories/Fooocus/models/controlnet/detection_Resnet50_Final.pth
COPY models/detection_mobilenet0.25_Final.pth /workspace/repositories/Fooocus/models/controlnet/detection_mobilenet0.25_Final.pth
COPY models/parsing_parsenet.pth /workspace/repositories/Fooocus/models/controlnet/parsing_parsenet.pth
COPY models/parsing_bisenet.pth /workspace/repositories/Fooocus/models/controlnet/parsing_bisenet.pth
COPY models/model_base_caption_capfilt_large.pth /workspace/repositories/Fooocus/models/clip_vision/model_base_caption_capfilt_large.pth
COPY models/sdxl_hyper_sd_4step_lora.safetensors /workspace/repositories/Fooocus/models/loras/sdxl_hyper_sd_4step_lora.safetensors
COPY models/stable-diffusion-safety-checker.bin /workspace/repositories/Fooocus/models/safety_checker/stable-diffusion-safety-checker.bin

#RUN wget -O /workspace/repositories/Fooocus/models/checkpoints/juggernautXL_v8Rundiffusion.safetensors https://huggingface.co/lllyasviel/fav_models/resolve/main/fav/juggernautXL_v8Rundiffusion.safetensors?download=true
#RUN wget -O /workspace/repositories/Fooocus/models/loras/sd_xl_offset_example-lora_1.0.safetensors https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_offset_example-lora_1.0.safetensors?download=true

#RUN wget -O /workspace/repositories/Fooocus/models/loras/sdxl_lcm_lora.safetensors https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/sdxl_lcm_lora.safetensors?download=true
#RUN wget -O /workspace/repositories/Fooocus/models/loras/sdxl_lightning_4step_lora.safetensors https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/sdxl_lightning_4step_lora.safetensors?download=true
#RUN wget -O /workspace/repositories/Fooocus/models/inpaint/fooocus_inpaint_head.pth https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/fooocus_inpaint_head.pth?download=true
#RUN wget -O /workspace/repositories/Fooocus/models/inpaint/inpaint.fooocus.patch https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/inpaint.fooocus.patch?download=true
#RUN wget -O /workspace/repositories/Fooocus/models/inpaint/inpaint_v25.fooocus.patch https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/inpaint_v25.fooocus.patch?download=true
#RUN wget -O /workspace/repositories/Fooocus/models/inpaint/inpaint_v26.fooocus.patch https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/inpaint_v26.fooocus.patch?download=true
#RUN wget -O /workspace/repositories/Fooocus/models/controlnet/control-lora-canny-rank128.safetensors https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/control-lora-canny-rank128.safetensors?download=true
#RUN wget -O /workspace/repositories/Fooocus/models/controlnet/fooocus_xl_cpds_128.safetensors https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/fooocus_xl_cpds_128.safetensors?download=true
#RUN wget -O /workspace/repositories/Fooocus/models/controlnet/fooocus_ip_negative.safetensors https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/fooocus_ip_negative.safetensors?download=true
#RUN wget -O /workspace/repositories/Fooocus/models/controlnet/ip-adapter-plus_sdxl_vit-h.bin https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/ip-adapter-plus_sdxl_vit-h.bin?download=true
#RUN wget -O /workspace/repositories/Fooocus/models/controlnet/ip-adapter-plus-face_sdxl_vit-h.bin https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/ip-adapter-plus-face_sdxl_vit-h.bin?download=true
#RUN wget -O /workspace/repositories/Fooocus/models/upscale_models/fooocus_upscaler_s409985e5.bin https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/fooocus_upscaler_s409985e5.bin?download=true
#RUN wget -O /workspace/repositories/Fooocus/models/clip_vision/clip_vision_vit_h.safetensors https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/clip_vision_vit_h.safetensors?download=true
#RUN wget -O /workspace/repositories/Fooocus/models/vae_approx/xlvaeapp.pth https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/xlvaeapp.pth?download=true
#RUN wget -O /workspace/repositories/Fooocus/models/vae_approx/vaeapp_sd15.pth https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/vaeapp_sd15.pt?download=true
#RUN wget -O /workspace/repositories/Fooocus/models/vae_approx/xl-to-v1_interposer-v3.1.safetensors https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/xl-to-v1_interposer-v3.1.safetensors?download=true
#RUN wget -O /workspace/repositories/Fooocus/models/prompt_expansion/fooocus_expansion/pytorch_model.bin https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/fooocus_expansion.bin?download=true
#RUN wget -O /workspace/repositories/Fooocus/models/controlnet/detection_Resnet50_Final.pth https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/detection_Resnet50_Final.pth?download=true
#RUN wget -O /workspace/repositories/Fooocus/models/controlnet/detection_mobilenet0.25_Final.pth https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/detection_mobilenet0.25_Final.pth?download=true
#RUN wget -O /workspace/repositories/Fooocus/models/controlnet/parsing_parsenet.pth https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/parsing_parsenet.pth?download=true
#RUN wget -O /workspace/repositories/Fooocus/models/controlnet/parsing_bisenet.pth https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/parsing_bisenet.pth?download=true
#RUN wget -O /workspace/repositories/Fooocus/models/clip_vision/model_base_caption_capfilt_large.pth https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/model_base_caption_capfilt_large.pth?download=true
#RUN wget -O /workspace/repositories/Fooocus/models/loras/sdxl_hyper_sd_4step_lora.safetensors https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/sdxl_hyper_sd_4step_lora.safetensors?download=true
#RUN wget -O /workspace/repositories/Fooocus/models/safety_checker/stable-diffusion-safety-checker.bin https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/stable-diffusion-safety-checker.bin?download=true

RUN chmod +x /start.sh
CMD /start.sh

EXPOSE 8888