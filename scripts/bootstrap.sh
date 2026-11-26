#!/usr/bin/env bash
# One-time setup before the first terraform init.
#   AWS:   creates the S3 bucket that will hold Terraform STATE
#   Local: writes infra/backend.hcl and infra/terraform.tfvars on THIS machine
#          (both git-ignored, never uploaded anywhere)
# Safe to re-run (e.g. when your home IP changes).
# Usage: bash scripts/bootstrap.sh [region]
set -euo pipefail

cd "$(dirname "$0")/.."

REGION="${1:-$(aws configure get region || true)}"
REGION="${REGION:-us-east-1}"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
BUCKET="tfstate-${ACCOUNT_ID}-${REGION}"

echo "Account: ${ACCOUNT_ID}"
echo "Region:  ${REGION}"
echo "Bucket:  ${BUCKET}"

# --- 1. State bucket ---------------------------------------------------------
if aws s3api head-bucket --bucket "${BUCKET}" 2>/dev/null; then
  echo "State bucket already exists - reusing it."
else
  echo "Creating state bucket..."
  if [ "${REGION}" = "us-east-1" ]; then
    # us-east-1 is the one region that must NOT send a LocationConstraint.
    aws s3api create-bucket --bucket "${BUCKET}" --region "${REGION}" >/dev/null
  else
    aws s3api create-bucket --bucket "${BUCKET}" --region "${REGION}" \
      --create-bucket-configuration "LocationConstraint=${REGION}" >/dev/null
  fi
fi

# Versioning: recover an older state file if one gets corrupted.
aws s3api put-bucket-versioning --bucket "${BUCKET}" \
  --versioning-configuration Status=Enabled

# Never public (state can contain sensitive values).
aws s3api put-public-access-block --bucket "${BUCKET}" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# Encrypted at rest.
aws s3api put-bucket-encryption --bucket "${BUCKET}" \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

# --- 2. backend.hcl ----------------------------------------------------------
cat > infra/backend.hcl <<EOF
bucket       = "${BUCKET}"
key          = "eks-argocd-lab/terraform.tfstate"
region       = "${REGION}"
encrypt      = true
use_lockfile = true
EOF
echo "Wrote infra/backend.hcl"

# --- 3. terraform.tfvars -----------------------------------------------------
MY_IP="$(curl -fsS https://checkip.amazonaws.com | tr -d '[:space:]')"
cat > infra/terraform.tfvars <<EOF
region     = "${REGION}"
admin_cidr = "${MY_IP}/32"
EOF
echo "Wrote infra/terraform.tfvars (admin_cidr = ${MY_IP}/32)"

echo
echo "Next:  cd infra && terraform init -backend-config=backend.hcl"
