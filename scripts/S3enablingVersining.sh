#!/bin/bash
# Use the AWS_REGION environment variable or default to 'us-east-1'
REGION=${AWS_REGION:-us-east-1}
echo "Using AWS region: $REGION"

# Function to enable versioning on a single S3 bucket
enable_versioning() {
  local bucket_name=$1
  
  echo "Enabling versioning for bucket: $bucket_name"
  
  aws s3api put-bucket-versioning --bucket "$bucket_name" --versioning-configuration Status=Enabled --region "$REGION"
  
  if [ $? -eq 0 ]; then
    echo "Successfully enabled versioning for $bucket_name"
  else
    echo "Failed to enable versioning for $bucket_name"
  fi
}

# List all S3 buckets
buckets=$(aws s3api list-buckets --region "$REGION" | jq -r '.Buckets[].Name')

# Enable versioning for each bucket
for bucket in $buckets; do
  enable_versioning "$bucket"
done

echo "Versioning enabled for all buckets."