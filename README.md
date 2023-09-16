# Azure DevOps Agents with Ubuntu

This Docker container is designed to provide an environment suitable for Azure DevOps agents running on Ubuntu. It comes pre-configured with a variety of tools and utilities commonly used in CI/CD pipelines, making it a versatile choice for diverse build and deployment tasks.

## Container Features

- **Base Image**: The container is based on the latest version of Ubuntu.
- **Shell**: The default shell is set to Bash.
- **Python Environment**: The container comes with `pyenv` and the latest stable version of Python. Additionally, it includes `pipenv`, `virtualenv`, `terraform-compliance`, `checkov`, and `pywinrm` installed via `pip`.
- **Azure Tools**: The container has both the Azure CLI and Azure PowerShell modules installed.
- **Terraform**: The container includes `tfenv` for managing multiple Terraform versions and has the latest version of Terraform installed.
- **Packer**: The container includes `pkenv` for managing Packer versions and has the latest version of Packer installed.
- **PowerShell**: The latest version of PowerShell is installed.
- **Homebrew**: Homebrew is installed, and the container includes `gcc` and `tfsec` installed via Homebrew.
- **Other Utilities**: The container comes with various utilities like `git`, `jq`, `curl`, and more.

## Usage

### Building the Docker Image

To build the Docker image, navigate to the directory containing the Dockerfile and run:

```bash
docker build -t azuredevops-agents-ubuntu:latest .
```

### Running the Docker Container

Before running the container, ensure you have set the necessary environment variables or pass them as parameters. These variables include:

- `AZP_URL`: The Azure DevOps organization URL.
- `AZP_TOKEN`: The Personal Access Token (PAT) for Azure DevOps.
- `AZP_POOL`: The agent pool name.

To run the container with environment variables:

```bash
docker run -d \
    -e AZP_URL=$AZP_URL \
    -e AZP_TOKEN=$AZP_TOKEN \
    -e AZP_POOL=$AZP_POOL \
    azuredevops-agents-ubuntu:latest
```

### Script Purpose

The provided PowerShell script is designed to automate the process of pulling the Docker image from the GitHub Container Registry (GHCR) and running it. The script checks for the necessary environment variables or parameters and ensures they are set before pulling and running the container.

To use the script, set the required environment variables on your machine or pass them as parameters when running the script. Then execute the script to pull the Docker image and run the container with the specified configurations.
