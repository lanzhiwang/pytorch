DOCKER_REGISTRY          ?= docker.io
# DOCKER_REGISTRY: docker.io

DOCKER_ORG               ?= $(shell docker info 2>/dev/null | sed '/Username:/!d;s/.* //')
# DOCKER_ORG: lanzhiwang

DOCKER_IMAGE             ?= pytorch
# DOCKER_IMAGE: pytorch

DOCKER_FULL_NAME          = $(DOCKER_REGISTRY)/$(DOCKER_ORG)/$(DOCKER_IMAGE)
# DOCKER_FULL_NAME: docker.io/lanzhiwang/pytorch

ifeq ("$(DOCKER_ORG)","")
$(warning WARNING: No docker user found using results from whoami)
DOCKER_ORG                = $(shell whoami)
endif

CUDA_VERSION              = 12.1.1
# CUDA_VERSION: 12.1.1

CUDNN_VERSION             = 8
# CUDNN_VERSION: 8

BASE_RUNTIME              = ubuntu:22.04
# BASE_RUNTIME: ubuntu:22.04

BASE_DEVEL                = nvidia/cuda:$(CUDA_VERSION)-cudnn$(CUDNN_VERSION)-devel-ubuntu22.04
# BASE_DEVEL: nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

CMAKE_VARS               ?=
# CMAKE_VARS:

# The conda channel to use to install cudatoolkit
CUDA_CHANNEL              = nvidia
# CUDA_CHANNEL: nvidia

# The conda channel to use to install pytorch / torchvision
INSTALL_CHANNEL          ?= pytorch
# INSTALL_CHANNEL: pytorch

PYTHON_VERSION           ?= 3.10
# PYTHON_VERSION: 3.10

PYTORCH_VERSION          ?= $(shell git describe --tags --always)
# PYTORCH_VERSION: ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8

# Can be either official / dev
BUILD_TYPE               ?= dev
# BUILD_TYPE: dev

BUILD_PROGRESS           ?= auto
# BUILD_PROGRESS: auto

# Intentionally left blank
TRITON_VERSION           ?=
# TRITON_VERSION:

BUILD_ARGS                = --build-arg BASE_IMAGE=$(BASE_IMAGE) \
							--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
							--build-arg CUDA_VERSION=$(CUDA_VERSION) \
							--build-arg CUDA_CHANNEL=$(CUDA_CHANNEL) \
							--build-arg PYTORCH_VERSION=$(PYTORCH_VERSION) \
							--build-arg INSTALL_CHANNEL=$(INSTALL_CHANNEL) \
							--build-arg TRITON_VERSION=$(TRITON_VERSION) \
							--build-arg CMAKE_VARS="$(CMAKE_VARS)"
# BUILD_ARGS: --build-arg BASE_IMAGE= --build-arg PYTHON_VERSION=3.10 --build-arg CUDA_VERSION=12.1.1 --build-arg CUDA_CHANNEL=nvidia --build-arg PYTORCH_VERSION=ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8 --build-arg INSTALL_CHANNEL=pytorch --build-arg TRITON_VERSION= --build-arg CMAKE_VARS=""

EXTRA_DOCKER_BUILD_FLAGS ?=
# EXTRA_DOCKER_BUILD_FLAGS:

BUILD                    ?= build
# BUILD: build

# Intentionally left blank
PLATFORMS_FLAG           ?=
# PLATFORMS_FLAG:

PUSH_FLAG                ?=
# PUSH_FLAG:

USE_BUILDX               ?=
# USE_BUILDX:

BUILD_PLATFORMS          ?=
# BUILD_PLATFORMS:

WITH_PUSH                ?= false
# WITH_PUSH: false

# Setup buildx flags
ifneq ("$(USE_BUILDX)","")
BUILD                     = buildx build
ifneq ("$(BUILD_PLATFORMS)","")
PLATFORMS_FLAG            = --platform="$(BUILD_PLATFORMS)"
endif
# Only set platforms flags if using buildx
ifeq ("$(WITH_PUSH)","true")
PUSH_FLAG                 = --push
endif
endif

DOCKER_BUILD              = DOCKER_BUILDKIT=1 \
							docker $(BUILD) \
								--progress=$(BUILD_PROGRESS) \
								$(EXTRA_DOCKER_BUILD_FLAGS) \
								$(PLATFORMS_FLAG) \
								$(PUSH_FLAG) \
								--target $(BUILD_TYPE) \
								-t $(DOCKER_FULL_NAME):$(DOCKER_TAG) \
								$(BUILD_ARGS) .
# DOCKER_BUILD: DOCKER_BUILDKIT=1 docker build --progress=auto    --target dev -t docker.io/lanzhiwang/pytorch: --build-arg BASE_IMAGE= --build-arg PYTHON_VERSION=3.10 --build-arg CUDA_VERSION=12.1.1 --build-arg CUDA_CHANNEL=nvidia --build-arg PYTORCH_VERSION=ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8 --build-arg INSTALL_CHANNEL=pytorch --build-arg TRITON_VERSION= --build-arg CMAKE_VARS="" .

DOCKER_PUSH               = docker push $(DOCKER_FULL_NAME):$(DOCKER_TAG)
# DOCKER_PUSH: docker push docker.io/lanzhiwang/pytorch:

print-var:
	$(info DOCKER_REGISTRY: $(DOCKER_REGISTRY))
	$(info DOCKER_ORG: $(DOCKER_ORG))
	$(info DOCKER_IMAGE: $(DOCKER_IMAGE))
	$(info DOCKER_FULL_NAME: $(DOCKER_FULL_NAME))
	$(info CUDA_VERSION: $(CUDA_VERSION))
	$(info CUDNN_VERSION: $(CUDNN_VERSION))
	$(info BASE_RUNTIME: $(BASE_RUNTIME))
	$(info BASE_DEVEL: $(BASE_DEVEL))
	$(info CMAKE_VARS: $(CMAKE_VARS))
	$(info CUDA_CHANNEL: $(CUDA_CHANNEL))
	$(info INSTALL_CHANNEL: $(INSTALL_CHANNEL))
	$(info PYTHON_VERSION: $(PYTHON_VERSION))
	$(info PYTORCH_VERSION: $(PYTORCH_VERSION))
	$(info BUILD_TYPE: $(BUILD_TYPE))
	$(info BUILD_PROGRESS: $(BUILD_PROGRESS))
	$(info TRITON_VERSION: $(TRITON_VERSION))
	$(info BUILD_ARGS: $(BUILD_ARGS))
	$(info EXTRA_DOCKER_BUILD_FLAGS: $(EXTRA_DOCKER_BUILD_FLAGS))
	$(info BUILD: $(BUILD))
	$(info PLATFORMS_FLAG: $(PLATFORMS_FLAG))
	$(info PUSH_FLAG: $(PUSH_FLAG))
	$(info USE_BUILDX: $(USE_BUILDX))
	$(info BUILD_PLATFORMS: $(BUILD_PLATFORMS))
	$(info WITH_PUSH: $(WITH_PUSH))
	$(info DOCKER_BUILD: $(DOCKER_BUILD))
	$(info DOCKER_PUSH: $(DOCKER_PUSH))
	$(info -------------------------------------------------------------)

.PHONY: all
all: devel-image
# $ make -f docker.Makefile -n --just-print DOCKER_ORG=lanzhiwang all
# DOCKER_REGISTRY: docker.io
# DOCKER_ORG: lanzhiwang
# DOCKER_IMAGE: pytorch
# DOCKER_FULL_NAME: docker.io/lanzhiwang/pytorch
# CUDA_VERSION: 12.1.1
# CUDNN_VERSION: 8
# BASE_RUNTIME: ubuntu:22.04
# BASE_DEVEL: nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04
# CMAKE_VARS:
# CUDA_CHANNEL: nvidia
# INSTALL_CHANNEL: pytorch
# PYTHON_VERSION: 3.10
# PYTORCH_VERSION: ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8
# BUILD_TYPE: dev
# BUILD_PROGRESS: auto
# TRITON_VERSION:
# BUILD_ARGS: --build-arg BASE_IMAGE=nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04 --build-arg PYTHON_VERSION=3.10 --build-arg CUDA_VERSION=12.1.1 --build-arg CUDA_CHANNEL=nvidia --build-arg PYTORCH_VERSION=ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8 --build-arg INSTALL_CHANNEL=pytorch --build-arg TRITON_VERSION= --build-arg CMAKE_VARS=""
# EXTRA_DOCKER_BUILD_FLAGS:
# BUILD: build
# PLATFORMS_FLAG:
# PUSH_FLAG:
# USE_BUILDX:
# BUILD_PLATFORMS:
# WITH_PUSH: false
# DOCKER_BUILD: DOCKER_BUILDKIT=1 docker build --progress=auto    --target dev -t docker.io/lanzhiwang/pytorch:ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8-devel --build-arg BASE_IMAGE=nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04 --build-arg PYTHON_VERSION=3.10 --build-arg CUDA_VERSION=12.1.1 --build-arg CUDA_CHANNEL=nvidia --build-arg PYTORCH_VERSION=ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8 --build-arg INSTALL_CHANNEL=pytorch --build-arg TRITON_VERSION= --build-arg CMAKE_VARS="" .
# DOCKER_PUSH: docker push docker.io/lanzhiwang/pytorch:ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8-devel
# -------------------------------------------------------------
# DOCKER_BUILDKIT=1 docker build --progress=auto    --target dev -t docker.io/lanzhiwang/pytorch:ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8-devel --build-arg BASE_IMAGE=nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04 --build-arg PYTHON_VERSION=3.10 --build-arg CUDA_VERSION=12.1.1 --build-arg CUDA_CHANNEL=nvidia --build-arg PYTORCH_VERSION=ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8 --build-arg INSTALL_CHANNEL=pytorch --build-arg TRITON_VERSION= --build-arg CMAKE_VARS="" .
# $

.PHONY: devel-image
devel-image: BASE_IMAGE := $(BASE_DEVEL)
devel-image: DOCKER_TAG := $(PYTORCH_VERSION)-devel
devel-image: print-var
	$(DOCKER_BUILD)
# $ make -f docker.Makefile -n --just-print DOCKER_ORG=lanzhiwang devel-image
# DOCKER_REGISTRY: docker.io
# DOCKER_ORG: lanzhiwang
# DOCKER_IMAGE: pytorch
# DOCKER_FULL_NAME: docker.io/lanzhiwang/pytorch
# CUDA_VERSION: 12.1.1
# CUDNN_VERSION: 8
# BASE_RUNTIME: ubuntu:22.04
# BASE_DEVEL: nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04
# CMAKE_VARS:
# CUDA_CHANNEL: nvidia
# INSTALL_CHANNEL: pytorch
# PYTHON_VERSION: 3.10
# PYTORCH_VERSION: ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8
# BUILD_TYPE: dev
# BUILD_PROGRESS: auto
# TRITON_VERSION:
# BUILD_ARGS: --build-arg BASE_IMAGE=nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04 --build-arg PYTHON_VERSION=3.10 --build-arg CUDA_VERSION=12.1.1 --build-arg CUDA_CHANNEL=nvidia --build-arg PYTORCH_VERSION=ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8 --build-arg INSTALL_CHANNEL=pytorch --build-arg TRITON_VERSION= --build-arg CMAKE_VARS=""
# EXTRA_DOCKER_BUILD_FLAGS:
# BUILD: build
# PLATFORMS_FLAG:
# PUSH_FLAG:
# USE_BUILDX:
# BUILD_PLATFORMS:
# WITH_PUSH: false
# DOCKER_BUILD: DOCKER_BUILDKIT=1 docker build --progress=auto    --target dev -t docker.io/lanzhiwang/pytorch:ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8-devel --build-arg BASE_IMAGE=nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04 --build-arg PYTHON_VERSION=3.10 --build-arg CUDA_VERSION=12.1.1 --build-arg CUDA_CHANNEL=nvidia --build-arg PYTORCH_VERSION=ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8 --build-arg INSTALL_CHANNEL=pytorch --build-arg TRITON_VERSION= --build-arg CMAKE_VARS="" .
# DOCKER_PUSH: docker push docker.io/lanzhiwang/pytorch:ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8-devel
# -------------------------------------------------------------
# DOCKER_BUILDKIT=1 docker build --progress=auto    --target dev -t docker.io/lanzhiwang/pytorch:ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8-devel --build-arg BASE_IMAGE=nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04 --build-arg PYTHON_VERSION=3.10 --build-arg CUDA_VERSION=12.1.1 --build-arg CUDA_CHANNEL=nvidia --build-arg PYTORCH_VERSION=ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8 --build-arg INSTALL_CHANNEL=pytorch --build-arg TRITON_VERSION= --build-arg CMAKE_VARS="" .
# $

.PHONY: devel-push
devel-push: BASE_IMAGE := $(BASE_DEVEL)
devel-push: DOCKER_TAG := $(PYTORCH_VERSION)-devel
devel-push: print-var
	$(DOCKER_PUSH)
# $ make -f docker.Makefile -n --just-print DOCKER_ORG=lanzhiwang devel-push
# DOCKER_REGISTRY: docker.io
# DOCKER_ORG: lanzhiwang
# DOCKER_IMAGE: pytorch
# DOCKER_FULL_NAME: docker.io/lanzhiwang/pytorch
# CUDA_VERSION: 12.1.1
# CUDNN_VERSION: 8
# BASE_RUNTIME: ubuntu:22.04
# BASE_DEVEL: nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04
# CMAKE_VARS:
# CUDA_CHANNEL: nvidia
# INSTALL_CHANNEL: pytorch
# PYTHON_VERSION: 3.10
# PYTORCH_VERSION: ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8
# BUILD_TYPE: dev
# BUILD_PROGRESS: auto
# TRITON_VERSION:
# BUILD_ARGS: --build-arg BASE_IMAGE=nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04 --build-arg PYTHON_VERSION=3.10 --build-arg CUDA_VERSION=12.1.1 --build-arg CUDA_CHANNEL=nvidia --build-arg PYTORCH_VERSION=ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8 --build-arg INSTALL_CHANNEL=pytorch --build-arg TRITON_VERSION= --build-arg CMAKE_VARS=""
# EXTRA_DOCKER_BUILD_FLAGS:
# BUILD: build
# PLATFORMS_FLAG:
# PUSH_FLAG:
# USE_BUILDX:
# BUILD_PLATFORMS:
# WITH_PUSH: false
# DOCKER_BUILD: DOCKER_BUILDKIT=1 docker build --progress=auto    --target dev -t docker.io/lanzhiwang/pytorch:ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8-devel --build-arg BASE_IMAGE=nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04 --build-arg PYTHON_VERSION=3.10 --build-arg CUDA_VERSION=12.1.1 --build-arg CUDA_CHANNEL=nvidia --build-arg PYTORCH_VERSION=ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8 --build-arg INSTALL_CHANNEL=pytorch --build-arg TRITON_VERSION= --build-arg CMAKE_VARS="" .
# DOCKER_PUSH: docker push docker.io/lanzhiwang/pytorch:ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8-devel
# -------------------------------------------------------------
# docker push docker.io/lanzhiwang/pytorch:ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8-devel
# $

.PHONY: runtime-image
runtime-image: BASE_IMAGE := $(BASE_RUNTIME)
runtime-image: DOCKER_TAG := $(PYTORCH_VERSION)-runtime
runtime-image: print-var
	$(DOCKER_BUILD)
# $ make -f docker.Makefile -n --just-print DOCKER_ORG=lanzhiwang runtime-image
# DOCKER_REGISTRY: docker.io
# DOCKER_ORG: lanzhiwang
# DOCKER_IMAGE: pytorch
# DOCKER_FULL_NAME: docker.io/lanzhiwang/pytorch
# CUDA_VERSION: 12.1.1
# CUDNN_VERSION: 8
# BASE_RUNTIME: ubuntu:22.04
# BASE_DEVEL: nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04
# CMAKE_VARS:
# CUDA_CHANNEL: nvidia
# INSTALL_CHANNEL: pytorch
# PYTHON_VERSION: 3.10
# PYTORCH_VERSION: ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8
# BUILD_TYPE: dev
# BUILD_PROGRESS: auto
# TRITON_VERSION:
# BUILD_ARGS: --build-arg BASE_IMAGE=ubuntu:22.04 --build-arg PYTHON_VERSION=3.10 --build-arg CUDA_VERSION=12.1.1 --build-arg CUDA_CHANNEL=nvidia --build-arg PYTORCH_VERSION=ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8 --build-arg INSTALL_CHANNEL=pytorch --build-arg TRITON_VERSION= --build-arg CMAKE_VARS=""
# EXTRA_DOCKER_BUILD_FLAGS:
# BUILD: build
# PLATFORMS_FLAG:
# PUSH_FLAG:
# USE_BUILDX:
# BUILD_PLATFORMS:
# WITH_PUSH: false
# DOCKER_BUILD: DOCKER_BUILDKIT=1 docker build --progress=auto    --target dev -t docker.io/lanzhiwang/pytorch:ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8-runtime --build-arg BASE_IMAGE=ubuntu:22.04 --build-arg PYTHON_VERSION=3.10 --build-arg CUDA_VERSION=12.1.1 --build-arg CUDA_CHANNEL=nvidia --build-arg PYTORCH_VERSION=ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8 --build-arg INSTALL_CHANNEL=pytorch --build-arg TRITON_VERSION= --build-arg CMAKE_VARS="" .
# DOCKER_PUSH: docker push docker.io/lanzhiwang/pytorch:ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8-runtime
# -------------------------------------------------------------
# DOCKER_BUILDKIT=1 docker build --progress=auto    --target dev -t docker.io/lanzhiwang/pytorch:ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8-runtime --build-arg BASE_IMAGE=ubuntu:22.04 --build-arg PYTHON_VERSION=3.10 --build-arg CUDA_VERSION=12.1.1 --build-arg CUDA_CHANNEL=nvidia --build-arg PYTORCH_VERSION=ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8 --build-arg INSTALL_CHANNEL=pytorch --build-arg TRITON_VERSION= --build-arg CMAKE_VARS="" .
# $

.PHONY: runtime-push
runtime-push: BASE_IMAGE := $(BASE_RUNTIME)
runtime-push: DOCKER_TAG := $(PYTORCH_VERSION)-runtime
runtime-push: print-var
	$(DOCKER_PUSH)
# $ make -f docker.Makefile -n --just-print DOCKER_ORG=lanzhiwang runtime-push
# DOCKER_REGISTRY: docker.io
# DOCKER_ORG: lanzhiwang
# DOCKER_IMAGE: pytorch
# DOCKER_FULL_NAME: docker.io/lanzhiwang/pytorch
# CUDA_VERSION: 12.1.1
# CUDNN_VERSION: 8
# BASE_RUNTIME: ubuntu:22.04
# BASE_DEVEL: nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04
# CMAKE_VARS:
# CUDA_CHANNEL: nvidia
# INSTALL_CHANNEL: pytorch
# PYTHON_VERSION: 3.10
# PYTORCH_VERSION: ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8
# BUILD_TYPE: dev
# BUILD_PROGRESS: auto
# TRITON_VERSION:
# BUILD_ARGS: --build-arg BASE_IMAGE=ubuntu:22.04 --build-arg PYTHON_VERSION=3.10 --build-arg CUDA_VERSION=12.1.1 --build-arg CUDA_CHANNEL=nvidia --build-arg PYTORCH_VERSION=ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8 --build-arg INSTALL_CHANNEL=pytorch --build-arg TRITON_VERSION= --build-arg CMAKE_VARS=""
# EXTRA_DOCKER_BUILD_FLAGS:
# BUILD: build
# PLATFORMS_FLAG:
# PUSH_FLAG:
# USE_BUILDX:
# BUILD_PLATFORMS:
# WITH_PUSH: false
# DOCKER_BUILD: DOCKER_BUILDKIT=1 docker build --progress=auto    --target dev -t docker.io/lanzhiwang/pytorch:ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8-runtime --build-arg BASE_IMAGE=ubuntu:22.04 --build-arg PYTHON_VERSION=3.10 --build-arg CUDA_VERSION=12.1.1 --build-arg CUDA_CHANNEL=nvidia --build-arg PYTORCH_VERSION=ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8 --build-arg INSTALL_CHANNEL=pytorch --build-arg TRITON_VERSION= --build-arg CMAKE_VARS="" .
# DOCKER_PUSH: docker push docker.io/lanzhiwang/pytorch:ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8-runtime
# -------------------------------------------------------------
# docker push docker.io/lanzhiwang/pytorch:ciflow/inductor/d6744a698c80b576affef7204af983ac3105d412-95-ga911b4db9d8-runtime
# $

.PHONY: clean
clean:
	-docker rmi -f $(shell docker images -q $(DOCKER_FULL_NAME))
# $ make -f docker.Makefile -n --just-print DOCKER_ORG=lanzhiwang clean
# docker rmi -f
# $
