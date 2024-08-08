#!/bin/bash

# Use the AWS_REGION environment variable from Github
REGION=${AWS_REGION:-us-east-1}
echo "Using AWS region: $REGION"

# Retrieve and list all DynamoDB backups ending with -backup
aws dynamodb list-backups --region $REGION --query 'BackupSummaries[?ends_with(BackupName, `-backup`)].[BackupName,TableArn,BackupArn]' --output table