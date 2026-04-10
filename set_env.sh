#!/bin/bash

# This script sets various Google Cloud related environment variables.
# It must be SOURCED to make the variables available in your current shell.
# Example: source ./set_gcp_env.sh

# --- Configuration ---
PROJECT_FILE="~/project_id.txt"
#GOOGLE_CLOUD_LOCATION="us-central1"
GOOGLE_CLOUD_LOCATION="europe-west4"
REPO_NAME="agentverse-repo"
# ---------------------


echo "--- Setting Google Cloud Environment Variables ---"

# --- Authentication Check ---
echo "Checking gcloud authentication status..."
# Run a command that requires authentication (like listing accounts or printing a token)
# Redirect stdout and stderr to /dev/null so we don't see output unless there's a real error
if gcloud auth print-access-token > /dev/null 2>&1; then
  echo "gcloud is authenticated."
else
  echo "Error: gcloud is not authenticated."
  echo "Please log in by running: gcloud auth login"
  # Use 'return 1' instead of 'exit 1' because the script is meant to be sourced.
  # 'exit 1' would close your current terminal session.
  return 1
fi
# --- --- --- --- --- ---


# 1. Check if project file exists
PROJECT_FILE_PATH=$(eval echo $PROJECT_FILE) # Expand potential ~
if [ ! -f "$PROJECT_FILE_PATH" ]; then
  echo "Error: Project file not found at $PROJECT_FILE_PATH"
  echo "Please create $PROJECT_FILE_PATH containing your Google Cloud project ID."
  return 1 # Return 1 as we are sourcing
fi

# 2. Set the default gcloud project configuration
PROJECT_ID_FROM_FILE=$(cat "$PROJECT_FILE_PATH")
echo "Setting gcloud config project to: $PROJECT_ID_FROM_FILE"
# Adding --quiet; set -e will handle failure if the project doesn't exist or access is denied
gcloud config set project "$PROJECT_ID_FROM_FILE" --quiet

# 3. Export PROJECT_ID (Get from config to confirm it was set correctly)
export PROJECT_ID=$(gcloud config get project)
echo "Exported PROJECT_ID=$PROJECT_ID"

# 4. Export PROJECT_NUMBER
# Using --format to extract just the projectNumber value
export PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")
echo "Exported PROJECT_NUMBER=$PROJECT_NUMBER"

# 5. Export SERVICE_ACCOUNT_NAME (Default Compute Service Account)
export SERVICE_ACCOUNT_NAME=$(gcloud compute project-info describe --format="value(defaultServiceAccount)")
echo "Exported SERVICE_ACCOUNT_NAME=$SERVICE_ACCOUNT_NAME"

# 6. Export GOOGLE_CLOUD_PROJECT (Often used by client libraries)
# This is usually the same as PROJECT_ID
export GOOGLE_CLOUD_PROJECT="$PROJECT_ID"
echo "Exported GOOGLE_CLOUD_PROJECT=$GOOGLE_CLOUD_PROJECT"

# 9. Export GOOGLE_GENAI_USE_VERTEXAI
export GOOGLE_GENAI_USE_VERTEXAI="TRUE"
echo "Exported GOOGLE_GENAI_USE_VERTEXAI=$GOOGLE_GENAI_USE_VERTEXAI"

# 10. Export GOOGLE_CLOUD_LOCATION
export GOOGLE_CLOUD_LOCATION="$GOOGLE_CLOUD_LOCATION"
echo "Exported GOOGLE_CLOUD_LOCATION=$GOOGLE_CLOUD_LOCATION"

# 11. Export REPO_NAME
export REPO_NAME="$REPO_NAME"
echo "Exported REPO_NAME=$REPO_NAME"

# 12. Export REGION
export REGION="$GOOGLE_CLOUD_LOCATION"
echo "Exported REGION=$GOOGLE_CLOUD_LOCATION"
# 12. Export OLLAMA_URL
# First, try to get the base URL, hiding any errors.
OLLAMA_URL_BASE=$(gcloud run services describe gemma-ollama-baked-service --platform=managed --region=$REGION --format='value(status.url)' 2>/dev/null)
# If the command succeeded and returned a URL, append /sse. Otherwise, set to empty string.
if [[ -n "$OLLAMA_URL_BASE" ]]; then
  export OLLAMA_URL="${OLLAMA_URL_BASE}"
else
  export OLLAMA_URL=""
fi
echo "Exported OLLAMA_URL=$OLLAMA_URL"

# 13. Export VLLM_URL
# First, try to get the base URL, hiding any errors.
VLLM_URL_BASE=$(gcloud run services describe gemma-vllm-fuse-service --platform=managed --region=$REGION --format='value(status.url)' 2>/dev/null)
# If the command succeeded and returned a URL, append /sse. Otherwise, set to empty string.
if [[ -n "$VLLM_URL_BASE" ]]; then
  export VLLM_URL="${VLLM_URL_BASE}"
else
  export VLLM_URL=""
fi
echo "Exported VLLM_URL=$VLLM_URL"


# 14. Export LB_IP
# First, try to get the IP address, hiding any errors.
LB_IP_BASE=$(gcloud compute addresses describe agentverse-lb-ip --region=$REGION --format='value(address)' 2>/dev/null)
# If the command succeeded and returned an IP, construct the URL. Otherwise, set to empty string.
if [[ -n "$LB_IP_BASE" ]]; then
  export LB_IP="${LB_IP_BASE}"
else
  export LB_IP=""
fi
echo "Exported LB_IP=$LB_IP"

# Cloud Storage
export BUCKET_NAME="${PROJECT_ID}-bastion"
echo "Exported BUCKET_NAME=$BUCKET_NAME"

export VPC_SUBNET="default"
echo "Exported VPC_SUBNET=$VPC_SUBNET"

export VPC_NETWORK="default"
echo "Exported VPC_NETWORK=$VPC_NETWORK"


export MODEL_ID="google/gemma-4-E2B-it"
echo "Exported MODEL_ID=$MODEL_ID"

export ARMOR_ID=$PROJECT_ID"_ARMOR_ID"
echo "Exported ARMOR_ID=$ARMOR_ID"

export VLLM_MODEL_NAME="/mnt/models/gemma-4-E2B-it"
echo "Exported export VLLM_MODEL_NAME=$VLLM_MODEL_NAME"

export VLLM_LB_URL="${VLLM_URL}/v1"
echo "Exported VLLM_LB_URL=$VLLM_LB_URL"

export VLLM_LB_URL="${VLLM_URL}/v1"
echo "Exported VLLM_LB_URL=$VLLM_LB_URL"

export PUBLIC_URL="https://guardian-agent-${PROJECT_NUMBER}.${REGION}.run.app"
echo "Exported PUBLIC_URL=$PUBLIC_URL"



echo "--- Environment setup complete ---"
