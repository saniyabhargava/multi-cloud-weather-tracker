#!/usr/bin/env bash
set -euo pipefail

# From infra outputs
AWS_BUCKET="$(terraform -chdir=../infra output -raw aws_s3_website_endpoint | cut -d'.' -f1)"
# S3 website endpoint looks like: <bucket>.s3-website-<region>.amazonaws.com
# Extract real bucket name more reliably via state (alternate):
AWS_BUCKET_NAME=$(terraform -chdir=../infra state show aws_s3_bucket.site | awk -F'= ' '/bucket =/{print $2}' | tr -d '"')

if [ -z "${AWS_BUCKET_NAME:-}" ]; then
  echo "Could not determine S3 bucket name. Falling back to parsing endpoint."
  AWS_BUCKET_NAME="${AWS_BUCKET}"
fi

echo "Uploading frontend/dist to s3://${AWS_BUCKET_NAME}"
aws s3 sync ../frontend/dist "s3://${AWS_BUCKET_NAME}" --delete --acl public-read
echo "Deployed to AWS S3 website."
