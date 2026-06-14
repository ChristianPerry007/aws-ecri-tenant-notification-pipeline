# Lambda Function for Audit Bucket

import json
import boto3
import os
from datetime import datetime, date

# Initialize AWS clients
dynamodb = boto3.resource('dynamodb')
ses = boto3.client('ses')
sns = boto3.client('sns')
s3 = boto3.client('s3')

# Environment variables
DYNAMODB_TABLE = os.environ['DYNAMODB_TABLE']
AUDIT_BUCKET = os.environ['AUDIT_BUCKET']
# SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN'] since there is no phone number to send the message from AWS, I have commented out the SNS topic ARN and the code that sends the SMS message.
SES_SENDER_EMAIL = os.environ['SES_SENDER_EMAIL']

def lambda_handler(event, context):
    table = dynamodb.Table(DYNAMODB_TABLE)
    today = date.today().strftime('%Y-%m-%d')

    # Query DynamoDB for tenants whose notification_date is today
    response = table.query(
        KeyConditionExpression=boto3.dynamodb.conditions.Key('notification_date').eq(today)
    )

    tenants = response.get('Items', [])

    if not tenants:
        return {
            'statusCode': 200,
            'body': json.dumps(f'No notifications scheduled for {today}.')
        }

    audit_log = {
        'date': today,
        'total_notified': 0,
        'tenants': []
    }

    for tenant in tenants:
        # Skip if already notified (idempotency check)
        if tenant.get('notified'):
            continue

        # Send email via SES
        email_subject = f"Rent Increase Notice - Unit {tenant['unit']}"
        email_body = (
            f"Hello {tenant['name']},\n\n"
            f"This is a notice that your rent for unit {tenant['unit']} "
            f"will increase from ${tenant['current_rate']} to ${tenant['new_rate']} "
            f"effective {tenant['ecri_date']}.\n\n"
            f"Thank you,\nCube World Management"
        )

        ses.send_email(
            Source=SES_SENDER_EMAIL,
            Destination={'ToAddresses': [tenant['email']]},
            Message={
                'Subject': {'Data': email_subject},
                'Body': {'Text': {'Data': email_body}}
            }
        )


    #     Send SMS via SNS
    #    sns_message = (
    #        f"Reminder: Your rent for unit {tenant['unit']} will increase "
    #        f"from ${tenant['current_rate']} to ${tenant['new_rate']} "
    #       f"on {tenant['ecri_date']}."
    #    )

    #    sns.publish(
    #        Message=sns_message,
    #        PhoneNumber=tenant['phone']
    #     )


        # Update DynamoDB - mark as notified
        table.update_item(
            Key={
                'notification_date': tenant['notification_date'],
                'account_number': tenant['account_number']
            },
            UpdateExpression='SET notified = :val',
            ExpressionAttributeValues={':val': True}
        )

        audit_log['total_notified'] += 1
        audit_log['tenants'].append({
            'account_number': tenant['account_number'],
            'name': tenant['name'],
            'email_sent': True,
            'sms_sent': False  # Set false because SMS sending is currently commented out since there is no phone number to send the message from AWS 
        })

    # Write audit log to S3
    s3.put_object(
        Bucket=AUDIT_BUCKET,
        Key=f"notification_log_{today}.json",
        Body=json.dumps(audit_log, indent=4),
        ContentType='application/json'
    )

    return {
        'statusCode': 200,
        'body': json.dumps(f"Notified {audit_log['total_notified']} tenant(s) for {today}.")
    }