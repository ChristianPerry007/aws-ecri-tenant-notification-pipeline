# Lambda Function for Input Bucket

import json
import boto3
import csv
import os
from datetime import datetime, timedelta

# Initialize AWS clients
s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

# Environment variables
DYNAMODB_TABLE = os.environ['DYNAMODB_TABLE']

def lambda_handler(event, context):
    # Get bucket and file key from S3 event
    input_bucket = event['Records'][0]['s3']['bucket']['name']
    raw_key = event['Records'][0]['s3']['object']['key']
    
    # Get the CSV file from S3
    response = s3.get_object(Bucket=input_bucket, Key=raw_key)
    csv_content = response['Body'].read().decode('utf-8').splitlines()
    
    # Read CSV rows
    reader = csv.DictReader(csv_content)
    
    table = dynamodb.Table(DYNAMODB_TABLE)
    
    for row in reader:
        # Calculate notification_date as ecri_date minus 30 days
        ecri_date = datetime.strptime(row['ecri_date'], '%Y-%m-%d')
        notification_date = (ecri_date - timedelta(days=30)).strftime('%Y-%m-%d')
        
        # Write to DynamoDB
        table.put_item(
            Item={
                'notification_date': notification_date,
                'account_number':    row['account_number'],
                'name':              row['name'],
                'email':             row['email'],
                'phone':             row['phone'],
                'unit':              row['unit'],
                'current_rate':      row['current_rate'],
                'new_rate':         row['new_rate'],
                'ecri_date':         row['ecri_date'],
                'notified':          False
            }
        )
    
    return {
        'statusCode': 200,
        'body': json.dumps('CSV successfully loaded into DynamoDB')
    }