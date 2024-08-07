#!/bin/bash
 
# Set AWS Region
AWS_REGION='us-east-1' # Example: us-west-2
SLEEP_DURATION=30 # In seconds, adjust this based on testing and AWS rate limits.
 
# Function to check if the table already exists
check_table_exists() {
local table_name=$1
aws dynamodb describe-table --region "$AWS_REGION" --table-name "$table_name" > /dev/null 2>&1
}
 
# Function to restore a table from a backup
restore_table() {
local backup_arn=$1
local original_table_name=$2
 
# Check if the target table already exists to avoid conflicts
if check_table_exists "$original_table_name"; then
echo "Table $original_table_name already exists. Skipping restore."
return
fi
# Announce restoration attempt
echo "Initiating restore for $original_table_name from backup $backup_arn..."
# Attempt to restore the table from backup
if aws dynamodb restore-table-from-backup \
--target-table-name "$original_table_name" \
--backup-arn "$backup_arn" \
--region "$AWS_REGION"
then
echo "Restore process initiated for table: $original_table_name. Waiting for $SLEEP_DURATION seconds before next operation..."
sleep $SLEEP_DURATION # Pause to help manage AWS API rate limits and service quotas
else
echo "Failed to initiate restore for table: $original_table_name. Check AWS permissions and service limits."
fi
}
 
# List and parse all backups with names ending in -backup
while IFS=$'\t' read -r backup_name backup_arn; do
original_table_name="${backup_name%-backup}" # Assumes backup name is original table name with '-backup' suffix
# Initiate table restore and notify user
restore_table "$backup_arn" "$original_table_name"
# Subshell to execute aws list-backups command and filter the output
done < <(aws dynamodb list-backups --region "$AWS_REGION" --query 'BackupSummaries[?ends_with(BackupName, `-backup`)].[BackupName,BackupArn]' --output text)
echo "The restoration process has finished for all tables."