#!/bin/bash
# Use the AWS_REGION environment variable or default to 'us-east-1'
REGION=${AWS_REGION:-us-east-1}
echo "Using AWS region: $REGION"

# List all S3 buckets in the specified region
buckets=$(aws s3api list-buckets --query "Buckets[].Name" --output text --region "$REGION")

# Print the names of the buckets
echo "S3 Buckets in region $REGION:"
for bucket in $buckets; do
  echo "- $bucket"
done