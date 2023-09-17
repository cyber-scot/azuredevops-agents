#!/usr/bin/env bash

echo "You may want to install podman-docker if you are running Podman and echo > /etc/containers/nodocker :)"


# Parameters with default values
RepoOwner=${RepoOwner:-"cyber-scot"}
RepoName=${RepoName:-"azuredevops-agents-ubuntu"}
ImageTag=${ImageTag:-"latest"}
GHCRToken=${GHCRToken:-$GH_PAT}
AZP_URL=${AZP_URL:-$AZP_URL}
AZP_TOKEN=${AZP_TOKEN:-$AZP_TOKEN}
AZP_AGENT_DIR=${AZP_AGENT_DIR:-$AZP_AGENT_DIR}
AZP_AGENT_NAME=${AZP_AGENT_NAME:-$AZP_AGENT_NAME}
AZP_POOL=${AZP_POOL:-$AZP_POOL}
AZP_WORK=${AZP_WORK:-$AZP_WORK}
NORMAL_USER=${NORMAL_USER:-$NORMAL_USER}
TFENV_TERRAFORM_VERSION=${TFENV_TERRAFORM_VERSION:-$TFENV_TERRAFORM_VERSION}

# Check for GitHub Personal Access Token (PAT)
if [ -z "$GHCRToken" ]; then
    echo "GitHub Personal Access Token (PAT) for GHCR not found. Please provide it as a parameter or set it as GHCR_TOKEN in the environment." >&2
    exit 1
fi

# Check for required parameters/environment variables
requiredVariables=("AZP_URL" "AZP_TOKEN" "AZP_POOL")

for var in "${requiredVariables[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Parameter or environment variable $var is not set. Please provide it or set it in the environment." >&2
        exit 1
    fi
done

# Login to GitHub Container Registry
echo "$GHCRToken" | docker login ghcr.io -u "$RepoOwner" --password-stdin

# Pull the Docker image
docker pull "ghcr.io/$RepoOwner/$RepoName:$ImageTag"

# Run the Docker container with environment variables
docker run -d \
    -e AZP_URL="$AZP_URL" \
    -e AZP_TOKEN="$AZP_TOKEN" \
    -e AZP_POOL="$AZP_POOL" \
    "ghcr.io/$RepoOwner/$RepoName:$ImageTag"
