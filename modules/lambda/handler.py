import boto3
import json
import os
import urllib.parse
import requests
import time

s3 = boto3.client('s3')
FASTAPI_URL = os.environ.get("FASTAPI_URL")

def lambda_handler(event, context):
    print("=== Incoming Event ===")
    print(json.dumps(event, indent=2))

    if 'Records' not in event:
        print("No 'Records' found in event")
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Invalid event structure. No 'Records' key."})
        }

    for record in event['Records']:
        try:
            bucket = record['s3']['bucket']['name']
            key = urllib.parse.unquote_plus(record['s3']['object']['key'])
            print(f"Fetching from S3: bucket = {bucket}, key = {key}")

            retries = 3
            for attempt in range(retries):
                try:
                    response = s3.get_object(Bucket=bucket, Key=key)
                    break
                except s3.exceptions.NoSuchKey:
                    print(f"[{attempt + 1}/{retries}] Key not available yet: {key}")
                    time.sleep(2)
            else:
                return {
                    "statusCode": 404,
                    "body": json.dumps({"error": "File not found after retries"})
                }

            logs = response['Body'].read().decode('utf-8')
            print("=== Log Content ===")
            print(logs)

            if FASTAPI_URL:
                payload = {"bucket": bucket, "key": key, "logs": logs}
                headers = {"Content-Type": "application/json"}
                api_response = requests.post(FASTAPI_URL, headers=headers, data=json.dumps(payload))
                print(f"FastAPI Response [{api_response.status_code}]: {api_response.text}")
            else:
                print("FASTAPI_URL is not set.")

        except Exception as e:
            print(f"Error processing key {key}: {e}")
            raise e

    return {"statusCode": 200, "body": json.dumps("Done")}
