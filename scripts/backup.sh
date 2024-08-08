#!/bin/bash
#!/bin/bash
# Use the AWS_REGION environment variable from GitHub
REGION=${AWS_REGION:-us-east-1}
echo "Using AWS region: $REGION"

# Get a list of all DynamoDB table names
tables=$(aws dynamodb list-tables --region "$REGION" --query "TableNames[]" --output json | jq -r '.[]')

# Backup each table
for table in $tables
do
  echo "Initiating backup for table $table..."
  aws dynamodb create-backup --table-name $table --backup-name "${table}-backup"
done

echo "Backup process completed."