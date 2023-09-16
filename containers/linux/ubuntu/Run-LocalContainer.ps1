param(
    $RepoOwner = "cyber-scot",
    $RepoName = "azuredevops-agents-ubuntu",
    $ImageTag = "latest", # or specify another tag if needed
    $GHCRToken = $env:GH_PAT,
    $AZP_URL = $env:AZP_URL,
    $AZP_TOKEN = $env:AZP_TOKEN,
    $AZP_AGENT_DIR = $env:AZP_AGENT_DIR,
    $AZP_AGENT_NAME = $env:AZP_AGENT_NAME,
    $AZP_POOL = $env:AZP_POOL,
    $AZP_WORK = $env:AZP_WORK,
    $NORMAL_USER = $env:NORMAL_USER,
    $TFENV_TERRAFORM_VERSION = $env:TFENV_TERRAFORM_VERSION
)

# Check for GitHub Personal Access Token (PAT)
if (-not $GHCRToken) {
    Write-Error "GitHub Personal Access Token (PAT) for GHCR not found. Please provide it as a parameter or set it as GHCR_TOKEN in the environment."
    exit 1
}

# Check for required parameters/environment variables
$requiredVariables = @("AZP_URL", "AZP_TOKEN", "AZP_POOL")

foreach ($var in $requiredVariables) {
    if (-not (Get-Variable -Name $var -ErrorAction SilentlyContinue)) {
        Write-Error "Parameter or environment variable $var is not set. Please provide it or set it in the environment."
        exit 1
    }
}

# Login to GitHub Container Registry
Write-Output $GHCRToken | docker login ghcr.io -u $RepoOwner --password-stdin

# Pull the Docker image
docker pull "ghcr.io/${RepoOwner}/${RepoName}:${ImageTag}"

# Run the Docker container with environment variables
docker run -it `
    -e AZP_URL=$AZP_URL `
    -e AZP_TOKEN=$AZP_TOKEN `
    -e AZP_POOL=$AZP_POOL `
    "ghcr.io/${RepoOwner}/${RepoName}:${ImageTag}"
