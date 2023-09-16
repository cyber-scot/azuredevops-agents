FROM ubuntu:latest

LABEL org.opencontainers.image.source=https://github.com/cyber-scot/azuredevops-agents

RUN rm -rf /bin/sh && ln -sf /bin/bash /bin/sh

#Set args with blank values - these will be over-written with the CLI
ARG NORMAL_USER=builder
ARG DEBIAN_FRONTEND=noninteractive

ENV ACCEPT_EULA ${ACCEPT_EULA}
ENV DEBIAN_FRONTEND=noninteractive

#Set args with blank values - these will be over-written with the CLI
ARG AZP_URL=https://dev.azure.com/Example
ARG AZP_TOKEN=ExamplePatToken
ARG AZP_AGENT_NAME=Example
ARG AZP_POOL=PoolName
ARG AZP_WORK=_work
ARG NORMAL_USER=azp
ARG AZP_AGENT_DIR=/opt/azp
ARG TFENV_TERRAFORM_VERSION=latest

#Set the environment with the CLI-passed arguements
ENV AZP_URL ${AZP_URL}
ENV AZP_TOKEN ${AZP_TOKEN}
ENV AZP_AGENT_DIR ${AZP_AGENT_DIR}
ENV AZP_AGENT_NAME ${AZP_AGENT_NAME}
ENV AZP_POOL ${AZP_POOL}
ENV AZP_WORK ${AZP_WORK}
ENV NORMAL_USER ${NORMAL_USER}
ENV TFENV_TERRAFORM_VERSION ${TFENV_TERRAFORM_VERSION}

# Environment variables for pyenv
ENV HOME /home/${NORMAL_USER}
ENV PYENV_ROOT ${AZP_AGENT_DIR}/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

#Set path vars
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt:/opt/bin:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.local/bin:/home/${NORMAL_USER}/.local:${AZP_AGENT_DIR}:${AZP_AGENT_DIR}/.tfenv:${AZP_AGENT_DIR}/.tfenv/bin:${AZP_AGENT_DIR}/.pkenv:${AZP_AGENT_DIR}/.pkenv/bin:/${AZP_AGENT_DIR}/.pyenv:${AZP_AGENT_DIR}/.pyenv/bin:${AZP_AGENT_DIR}/.pyenv/shims:/home/${NORMAL_USER}/.local/bin"
ENV PATHVAR="PATH=${PATH}"

USER root

# Install necessary libraries for pyenv and other dependencies
RUN mkdir -p ${AZP_AGENT_DIR} && \
    useradd -ms /bin/bash ${NORMAL_USER} && \
    mkdir -p /home/linuxbrew && \
    chown -R ${NORMAL_USER}:${NORMAL_USER} /home/linuxbrew && \
    apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y \
    apt-transport-https \
    bash \
    libbz2-dev \
    ca-certificates \
    curl \
    gcc \
    gnupg \
    gnupg2 \
    git \
    jq \
    libffi-dev \
    libicu-dev \
    make \
    software-properties-common \
    libsqlite3-dev \
    libssl-dev \
    unzip \
    wget \
    zip \
    zlib1g-dev \
    build-essential \
    sudo \
    libreadline-dev \
    llvm \
    libncurses5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    liblzma-dev && \
    echo $PATHVAR > /etc/environment

# Install pyenv and the latest stable version of Python
RUN git clone https://github.com/pyenv/pyenv.git ${AZP_AGENT_DIR}/.pyenv && \
    eval "$(pyenv init --path)" && \
    pyenvLatestStable=$(pyenv install --list | grep -v - | grep -E "^  [0-9]" | grep -vE 'dev|alpha|beta|rc' | tail -1) && \
    pyenv install $pyenvLatestStable && \
    pyenv global $pyenvLatestStable && \
    pip install --upgrade pip

# Install PowerShell
RUN curl -sSLO https://packages.microsoft.com/config/ubuntu/$(grep -oP '(?<=^DISTRIB_RELEASE=).+' /etc/lsb-release | tr -d '"')/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm -f packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y powershell && \
    ln -s /usr/bin/pwsh /usr/bin/powershell

#Install Azure Modules for Powershell - This can take a while, so setting as final step to shorten potential rebuilds
RUN pwsh -Command Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted && \
    pwsh -Command Install-Module -Name Az -Force -AllowClobber -Scope AllUsers -Repository PSGallery && \
    pwsh -Command Install-Module -Name Microsoft.Graph -Force -AllowClobber -Scope AllUsers -Repository PSGallery && \
    pwsh -Command Install-Module -Name Pester -Force -AllowClobber -Scope AllUsers -Repository PSGallery


RUN git clone --depth=1 https://github.com/tfutils/tfenv.git ${AZP_AGENT_DIR}/.tfenv && \
    tfenv install && \
    tfenv use

# Install Packer Env
RUN git clone https://github.com/iamhsa/pkenv.git ${AZP_AGENT_DIR}/.pkenv && \
    PACKER_LATEST_URL=$(curl -sL https://releases.hashicorp.com/packer/index.json | jq -r '.versions[].builds[].url' | egrep -v 'rc|beta|alpha' | egrep 'linux.*amd64'  | tail -1) && \
    PACKER_LATEST_VERSION=$(echo "$PACKER_LATEST_URL" | awk -F '/' '{print $6}' | sed 's/packer_//' | sed 's/_linux_amd64.zip//') && \
    pkenv install ${PACKER_LATEST_VERSION} && \
    pkenv use ${PACKER_LATEST_VERSION}

COPY start.sh /home/${NORMAL_USER}/start.sh

RUN chown -R ${NORMAL_USER}:${NORMAL_USER} /opt && \
    chown -R ${NORMAL_USER}:${NORMAL_USER} /home/${NORMAL_USER} && \
    chmod +x /home/${NORMAL_USER}/start.sh && \
    apt-get update && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER ${NORMAL_USER}
WORKDIR /home/${NORMAL_USER}
CMD [ "./start.sh" ]

RUN pip3 install --user \
    pipenv \
    virtualenv \
    terraform-compliance \
    checkov \
    pywinrm

# Install Azure-CLI as seperate step for cacheing speed
RUN pip3 install --user azure-cli

# Install homebrew and gcc per recomendation as well a PHP
RUN echo -en "\n" | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/${NORMAL_USER}/.bashrc && \
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
    brew install gcc && \
    brew install tfsec

