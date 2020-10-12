import json
import datetime
import os
import boto3
import botocore.vendored.requests.packages.urllib3 as urllib3

s3 = boto3.client('s3')
# Create an SNS client
sns = boto3.client('sns')

def lambda_handler(event, context):
    ## Getting URLs to load into Pandas
    NYT_URL = os.environ['New_York_Times_COVID19_Data_URL']
    JH_URL = os.environ['Johns_Hopkins_COVID19_Data_URL']
    BUCKET =  os.environ['BUCKET']
    TOPIC =  os.environ['TOPIC']

    datetimestamp = datetime.datetime.today().strftime('%Y%m%dT%H%M%S')
    ## Uploading NYT file
    http = urllib3.PoolManager()
    filename = "nyt_covid19_"+datetimestamp + ".csv"
    nyt_key = 'NYT/' + filename
    s3.upload_fileobj(http.request('GET',NYT_URL ,preload_content=False), BUCKET, nyt_key)
    
    ## Uploading JH file
    http = urllib3.PoolManager()
    filename = "jh_covid19_"+datetimestamp + ".csv"
    jh_key = 'JH/' + filename
    s3.upload_fileobj(http.request('GET',JH_URL ,preload_content=False), BUCKET, jh_key)
    response = sns.publish(
      TopicArn= TOPIC,    
      Message= json.dumps({'NYT': nyt_key, 'JH':jh_key}),    
    )
    print(response)
    return {
        'statusCode': 200,
        'body': json.dumps('Files loaded to S3 successfully.')
    }







    