import json
import datetime
import os
import boto3
import botocore.vendored.requests.packages.urllib3 as urllib3
#import requests

s3 = boto3.client('s3')
# Create an SNS client
sns = boto3.client('sns')

def lambda_handler(event, context):
  try:
    ## Getting URLs to load into Pandas
    NYT_URL = os.environ['New_York_Times_COVID19_Data_URL']
    JH_URL = os.environ['Johns_Hopkins_COVID19_Data_URL']
    BUCKET =  os.environ['BUCKET']
    TOPIC =  os.environ['TOPIC']
    ERROR_TOPIC =  os.environ['ERROR_TOPIC']

    datetimestamp = datetime.datetime.today().strftime('%Y%m%dT%H%M%S')
    ## Uploading NYT file
    http = urllib3.PoolManager()
    filename = "nyt_covid19_"+datetimestamp + ".csv"
    nyt_key = 'NYT/' + filename
    #r = requests.get(NYT_URL)
    r = http.request('GET',NYT_URL ,preload_content=False)
    #r.raise_for_status()
    if r.status != 200 :
      raise Exception("NYT File: {}".format(r.data.decode('utf-8')))
    s3.upload_fileobj(r, BUCKET, nyt_key)
    
    ## Uploading JH file
    http = urllib3.PoolManager()
    filename = "jh_covid19_"+datetimestamp + ".csv"
    jh_key = 'JH/' + filename
    #r = requests.get(JH_URL)
    r = http.request('GET',JH_URL ,preload_content=False)
    if r.status != 200 :
      raise Exception("JH File: {}".format(r.data.decode('utf-8')))
    #r.raise_for_status()
    s3.upload_fileobj(r, BUCKET, jh_key)
    response = sns.publish(
      TopicArn= TOPIC,    
      Message= json.dumps({'NYT': nyt_key, 'JH':jh_key}),    
    )
    print(response)
    msg = "Files loaded to S3 successfully. SNS Notification sent to kick start ETL function. ID: {}".format(response["MessageId"])
    return {
        'statusCode': 200,
        'body': json.dumps(msg)
    }
  except Exception as e:
    print("Error occured during execution.")
    msg = "File download lambda function failed. Error msg : {}".format(e)
    response = sns.publish(
      TopicArn= ERROR_TOPIC,    
      Message= json.dumps(msg),    
    )
    msg = "Files are not loaded into S3. SNS notification sent. ID: {}".format(response["MessageId"])
    return {
        'statusCode': 200,
        'body': json.dumps(msg)
    }







    