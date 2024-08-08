#!/bin/bash
# Use the AWS_REGION environment variable from GitHub
REGION=${AWS_REGION:-us-east-1}
echo "Using AWS region: $REGION"

# Function to restore a single DynamoDB table
restore_table() {
  local backup_table=$1
  local original_table=${backup_table%-backup}
  
  echo "Starting restore for table: $backup_table to $original_table"
  
  aws dynamodb restore-table-from-backup \
    --region "$REGION" \
    --target-table-name "$original_table" \
    --backup-arn "arn:aws:dynamodb:REGION:ACCOUNT_ID:table/$backup_table/backup/BACKUP_ID"
  
  if [ $? -eq 0 ]; then
    echo "Successfully restored $backup_table to $original_table"
  else
    echo "Failed to restore $backup_table"
  fi
}

# List all DynamoDB tables with the suffix '-backup'
backup_tables=$(aws dynamodb list-tables --region "$REGION" | jq -r '.TableNames[]' | grep '-backup')

# Restore each table in parallel
for table in $backup_tables; do
  restore_table "$table" &
done

# Wait for all background processes to complete
wait

echo "All restore operations completed."