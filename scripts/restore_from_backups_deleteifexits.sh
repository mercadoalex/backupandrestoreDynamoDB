#!/bin/bash

# Set AWS Region
AWS_REGION='us-east-1' # Example: us-west-2
SLEEP_DURATION=30 # In seconds, adjust this based on testing and AWS rate limits.

# Function to check if the table already exists
check_table_exists() {
  local table_name=$1
  aws dynamodb describe-table --region "$AWS_REGION" --table-name "$table_name" > /dev/null 2>&1
}

# Function to delete a table
delete_table() {
  local table_name=$1
  echo "Deleting table $table_name..."
  aws dynamodb delete-table --region "$AWS_REGION" --table-name "$table_name"
  echo "Table $table_name deleted."
}

# Function to check the status of a table
check_table_status() {
  local table_name=$1
  aws dynamodb describe-table --region "$AWS_REGION" --table-name "$table_name" --query "Table.TableStatus" --output text
}

# Function to restore a table from a backup
restore_table() {
  local backup_table_name=$1
  local original_table_name=${backup_table_name%-backup}

  # Check if the target table already exists to avoid conflicts
  if check_table_exists "$original_table_name"; then
    echo "Table $original_table_name already exists. Do you want to delete it? (YES/NO)"
    read -r response
    if [[ "$response" == "YES" ]]; then
      delete_table "$original_table_name"
      echo "Restoring table $original_table_name from backup $backup_table_name..."
      aws dynamodb restore-table-from-backup --region "$AWS_REGION" --target-table-name "$original_table_name" --backup-arn "$backup_table_name"
      echo "Restored table $original_table_name."
    else
      echo "Skipping restore for table $original_table_name."
    fi
  else
    echo "Restoring table $original_table_name from backup $backup_table_name..."
    aws dynamodb restore-table-from-backup --region "$AWS_REGION" --target-table-name "$original_table_name" --backup-arn "$backup_table_name"
    echo "Restored table $original_table_name."
  fi

  # Check the status of the restored table
  echo "Checking status of table $original_table_name..."
  local status
  status=$(check_table_status "$original_table_name")
  echo "Table $original_table_name status: $status"
}

export -f check_table_exists
export -f delete_table
export -f check_table_status
export -f restore_table
export AWS_REGION

# List all tables and filter those with the -backup suffix, then restore them in parallel
aws dynamodb list-tables --region "$AWS_REGION" --query "TableNames[]" --output text | tr '\t' '\n' | grep '\-backup$' | xargs -n 1 -P 4 -I {} bash -c 'restore_table "$@"' _ {}