#!/bin/bash

# Default AWS Region and sleep duration
AWS_REGION='us-east-1'
SLEEP_DURATION=30

# Function to display usage information
usage() {
  echo "Usage: $0 [-r AWS_REGION] [-s SLEEP_DURATION]"
  exit 1
}

# Parse command-line arguments
while getopts ":r:s:" opt; do
  case $opt in
    r) AWS_REGION="$OPTARG" ;;
    s) SLEEP_DURATION="$OPTARG" ;;
    *) usage ;;
  esac
done

# Function to log messages with timestamps
log() {
  local message="$1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $message"
}

# Function to check if the table already exists
check_table_exists() {
  local table_name=$1
  aws dynamodb describe-table --region "$AWS_REGION" --table-name "$table_name" > /dev/null 2>&1
}

# Function to restore tables from backups
restore_tables() {
  local backup_suffix="-backup"
  local table_names=$(aws dynamodb list-tables --region "$AWS_REGION" --query "TableNames[]" --output text)

  for table_name in $table_names; do
    if [[ $table_name == *$backup_suffix ]]; then
      local original_table_name=${table_name%$backup_suffix}
      log "Found backup: $table_name. Attempting to restore to $original_table_name."

      if check_table_exists "$original_table_name"; then
        log "Table $original_table_name already exists. Skipping restore."
      else
        log "Restoring table $original_table_name from backup $table_name"
        aws dynamodb restore-table-from-backup --region "$AWS_REGION" --target-table-name "$original_table_name" --backup-arn "$table_name"
        log "Restored table $original_table_name from backup $table_name"
      fi
    fi
  done
}

# Start the restoration process
log "Starting the restoration process"
restore_tables
log "Restoration process completed"