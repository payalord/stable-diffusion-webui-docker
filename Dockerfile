FROM debian:stable-slim

RUN apt-get update
ARG DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1 PIP_BREAK_SYSTEM_PACKAGES=1
RUN apt-get -qq install wget curl git python3 python3-venv python3-pip libgl1 libglib2.0-0
RUN git config --global advice.detachedHead false
RUN apt-get install --no-install-recommends google-perftools -y
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /stable-diffusion

RUN pip3 install torch --extra-index-url https://download.pytorch.org/whl/cu113
RUN python3 -c "import torch; print(torch.cuda.is_available())"
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
WORKDIR /stable-diffusion/stable-diffusion-webui
RUN mkdir repositories
RUN git clone https://github.com/CompVis/stable-diffusion.git repositories/stable-diffusion-stability-ai
RUN git clone https://github.com/CompVis/taming-transformers.git repositories/taming-transformers
RUN git clone https://github.com/sczhou/CodeFormer.git repositories/CodeFormer
RUN git clone https://github.com/salesforce/BLIP.git repositories/BLIP
RUN git clone https://github.com/Stability-AI/generative-models.git repositories/generative-models
RUN git clone https://github.com/crowsonkb/k-diffusion repositories/k-diffusion
RUN apt-get install pkg-config libssl-dev -y
RUN pip3 install transformers==4.37.2 diffusers invisible-watermark
RUN pip3 install git+https://github.com/crowsonkb/k-diffusion.git
RUN pip3 install git+https://github.com/TencentARC/GFPGAN.git
RUN pip3 install -r repositories/CodeFormer/requirements.txt
RUN pip3 install -r requirements.txt
RUN pip3 install -r requirements_versions.txt
RUN pip3 install -U numpy
RUN pip3 install xformers

CMD ["./webui.sh", "-f", "--xformers", "--listen"]