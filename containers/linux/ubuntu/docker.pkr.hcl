packer {
  required_plugins {
    docker = {
      version = "~> 1.0.0"
      source  = "github.com/hashicorp/docker"
    }
  }
}

variable "NORMAL_USER" {
  description = "Normal user"
  type        = string
  default     = "builder"
}

variable "DEBIAN_FRONTEND" {
  description = "Debian frontend setting"
  type        = string
  default     = "noninteractive"
}

variable "AZP_URL" {
  description = "Azure DevOps URL"
  type        = string
  default     = "https://dev.azure.com/Example"
}

variable "AZP_TOKEN" {
  description = "Azure DevOps Token"
  type        = string
  default     = "ExamplePatToken"
}

variable "AZP_AGENT_NAME" {
  description = "Azure DevOps Agent Name"
  type        = string
  default     = "Example"
}

variable "AZP_POOL" {
  description = "Azure DevOps Pool Name"
  type        = string
  default     = "PoolName"
}

variable "AZP_WORK" {
  description = "Azure DevOps Work Directory"
  type        = string
  default     = "_work"
}

variable "AZP_AGENT_DIR" {
  description = "Azure DevOps Agent Directory"
  type        = string
  default     = "/opt/azp"
}

variable "TFENV_TERRAFORM_VERSION" {
  description = "Terraform Version for tfenv"
  type        = string
  default     = "latest"
}

locals {
  PYENV_ROOT = "${var.AZP_AGENT_DIR}/.pyenv"
  PATH = "${local.PYENV_ROOT}/shims:${local.PYENV_ROOT}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt:/opt/bin:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.local/bin:/home/${var.NORMAL_USER}/.local:${var.AZP_AGENT_DIR}:${var.AZP_AGENT_DIR}/.tfenv:${var.AZP_AGENT_DIR}/.tfenv/bin:${var.AZP_AGENT_DIR}/.pkenv:${var.AZP_AGENT_DIR}/.pkenv/bin:${var.AZP_AGENT_DIR}/.pyenv:${var.AZP_AGENT_DIR}/.pyenv/bin:${var.AZP_AGENT_DIR}/.pyenv/shims:/home/${var.NORMAL_USER}/.local/bin"
  PATHVAR = "PATH=${local.PATH}"
}

source "docker" "ubuntu" {
  image  = "ubuntu:latest"
  commit = true
}

build {
  sources = ["source.docker.ubuntu"]

  provisioner "shell" {
    inline = [
      "rm -rf /bin/sh && ln -sf /bin/bash /bin/sh",
      "apt-get update",
      "apt-get dist-upgrade -y",
      "mkdir -p ${var.AZP_AGENT_DIR}",
      "useradd -ms /bin/bash ${var.NORMAL_USER}",
      "mkdir -p /home/linuxbrew",
      "chown -R ${var.NORMAL_USER}:${var.NORMAL_USER} /home/linuxbrew",
      "apt-get update",
      "apt-get dist-upgrade -y",
      "apt-get install -y apt-transport-https bash libbz2-dev ca-certificates curl gcc gnupg gnupg2 git jq libffi-dev libicu-dev make software-properties-common libsqlite3-dev libssl-dev unzip wget zip zlib1g-dev build-essential sudo libreadline-dev llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev liblzma-dev",
      "echo $PATHVAR > /etc/environment"
    ]
    environment_vars = [
      "AZP_AGENT_DIR=${var.AZP_AGENT_DIR}",
      "NORMAL_USER=${var.NORMAL_USER}",
      "PATHVAR=${local.PATHVAR}",
      "DEBIAN_FRONTEND=noninteractive"
    ]
  }

  provisioner "shell" {
  inline = [
    "git clone https://github.com/pyenv/pyenv.git ${var.AZP_AGENT_DIR}/.pyenv",
    "eval \"$(pyenv init --path)\"",
    "pyenvLatestStable=$(pyenv install --list | grep -v - | grep -E \"^  [0-9]\" | grep -vE 'dev|alpha|beta|rc' | tail -1)",
    "pyenv install $pyenvLatestStable",
    "pyenv global $pyenvLatestStable",
    "pip install --upgrade pip"
  ]
  environment_vars = [
    "AZP_AGENT_DIR=${var.AZP_AGENT_DIR}"
  ]
}


  post-processor "docker-tag" {
    repository = "your-image-name"
    tags       = ["latest"]
  }
}


## unfinished
