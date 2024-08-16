#!/bin/bash
# Use the AWS_REGION environment variable from GitHub
REGION=${AWS_REGION:-us-east-1}
echo "Using AWS region: $REGION"

# Function to backup a single S3 bucket
backup_bucket() {
  local bucket_name=$1  #!/bin/bash
  # Use the AWS_REGION environment variable from GitHub
  REGION=${AWS_REGION:-us-east-1}
  echo "Using AWS region: $REGION"
  
  # Function to backup a single S3 bucket
  backup_bucket() {
    local bucket_name=$1
    local backup_bucket_name="${bucket_name}-backup"
    
    echo "Starting backup for bucket: $bucket_name to $backup_bucket_name"
    
    aws s3 sync "s3://$bucket_name" "s3://$backup_bucket_name" --region "$REGION"
    
    if [ $? -eq 0 ]; then
      echo "Successfully backed up $bucket_name to $backup_bucket_name"
      echo "Backup stored at: s3://$backup_bucket_name"
    else
      echo "Failed to backup $bucket_name"
    fi
  }
  
  # List all S3 buckets
  buckets=$(aws s3api list-buckets --region "$REGION" | jq -r '.Buckets[].Name')
  
  # Backup each bucket in parallel
  for bucket in $buckets; do
    backup_bucket "$bucket" &
  done
  
  # Wait for all background processes to complete
  wait
  echo "All backups completed."  #!/bin/bash
  # Use the AWS_REGION environment variable from GitHub
  REGION=${AWS_REGION:-us-east-1}
  echo "Using AWS region: $REGION"
  
  # Function to backup a single S3 bucket
  backup_bucket() {
    local bucket_name=$1
    local backup_bucket_name="${bucket_name}-backup"
    
    echo "Starting backup for bucket: $bucket_name to $backup_bucket_name"
    
    # Capture the output and error message
    output=$(aws s3 sync "s3://$bucket_name" "s3://$backup_bucket_name" --region "$REGION" 2>&1)
    
    if [ $? -eq 0 ]; then
      echo "Successfully backed up $bucket_name to $backup_bucket_name"
      echo "Backup stored at: s3://$backup_bucket_name"
    else
      if echo "$output" | grep -q "NoSuchBucket"; then
        echo "Failed to backup $bucket_name: The specified bucket does not exist."
      else
        echo "Failed to backup $bucket_name: $output"
      fi
    fi
  }
  
  # List all S3 buckets
  buckets=$(aws s3api list-buckets --region "$REGION" | jq -r '.Buckets[].Name')
  
  # Backup each bucket in parallel
  for bucket in $buckets; do
    backup_bucket "$bucket" &
  done
  
  # Wait for all background processes to complete
  wait
  echo "All backups completed."
  local backup_bucket_name="${bucket_name}-backup"
  
  echo "Starting backup for bucket: $bucket_name to $backup_bucket_name"
  
  aws s3 sync "s3://$bucket_name" "s3://$backup_bucket_name" --region "$REGION"
  
  if [ $? -eq 0 ]; then
    echo "Successfully backed up $bucket_name to $backup_bucket_name"
  else
    echo "Failed to backup $bucket_name"
  fi
}

# List all S3 buckets
buckets=$(aws s3api list-buckets --region "$REGION" | jq -r '.Buckets[].Name')

# Backup each bucket in parallel
for bucket in $buckets; do
  backup_bucket "$bucket" &
done

# Wait for all background processes to complete
wait
echo "All backups completed."