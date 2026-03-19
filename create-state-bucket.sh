#!/bin/bash
# Create S3 bucket for Terraform remote state
# Run: bash create-state-bucket.sh

set -e

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="cloudpulse-tfstate-${ACCOUNT_ID}"
REGION="eu-west-1"

echo "Account ID: ${ACCOUNT_ID}"
echo "Creating bucket: ${BUCKET_NAME}"

aws s3api create-bucket \
  --bucket "${BUCKET_NAME}" \
  --region "${REGION}" \
  --create-bucket-configuration LocationConstraint="${REGION}"

aws s3api put-bucket-versioning \
  --bucket "${BUCKET_NAME}" \
  --versioning-configuration Status=Enabled

echo ""
echo "State bucket created with versioning: ${BUCKET_NAME}"
echo ""
echo "Next steps:"
echo "  1. Open main.tf in nano"
echo "  2. Uncomment the backend block (around line 20)"
echo "  3. Replace YOUR_ACCOUNT_ID with: ${ACCOUNT_ID}"
echo "  4. Run: terraform init"