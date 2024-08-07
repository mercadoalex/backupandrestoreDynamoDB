#!/bin/bash

# Set AWS profile if necessary
# AWS_PROFILE=default

# Set AWS Region
AWS_REGION='us-east-1' # Example: us-west-2

# Retrieve and list all DynamoDB backups ending with -backup
aws dynamodb list-backups --region $AWS_REGION --query 'BackupSummaries[?ends_with(BackupName, `-backup`)].[BackupName,TableArn,BackupArn]' --output table