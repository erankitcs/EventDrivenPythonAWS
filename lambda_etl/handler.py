import pandas as pd
import numpy as np
import os
from modules import datatransform
from modules import postgresload
import json
import boto3
import botocore
import datetime
import base64
from botocore.exceptions import ClientError
import json
import datetime

# Create an SNS client
sns = boto3.client('sns')
runtime_region = os.environ['AWS_REGION']
#s3 = boto3.client('s3')
s3 = boto3.client('s3', runtime_region, config=botocore.config.Config(s3={'addressing_style':'path'}))

def lambda_handler(event, context):
 try:
    message = json.loads(event['Records'][0]['Sns']['Message'])
    print(message)
    bucket = os.environ['BUCKET']
    table_name = os.environ['TABLE_NAME']
    ERROR_TOPIC = os.environ['ERROR_TOPIC']
    SUCCESS_TOPIC = os.environ['SUCCESS_TOPIC']
    SECRET_NAME = os.environ['SECRET_NAME']
    ## Reading Data
    print("Reading File from S3 bucket.")
    obj = s3.get_object(Bucket=bucket, Key=message['NYT'])
    nyt_data = pd.read_csv(obj['Body'])

    obj = s3.get_object(Bucket=bucket, Key=message['JH'])
    jh_data = pd.read_csv(obj['Body'])
    
    print("Cleaning the data sets.")
    nyt_data = datatransform.clean_nyt_data(nyt_data)
    jh_data = datatransform.clean_jh_data(jh_data)
    
    ## Checking Full load or increamental. 
    ## Getting database credentials
    print("Getting Database credentials.")
    db_cred = get_secret()
    #print(db_cred)
    #print(db_cred['username'])
    #print(db_cred['password'])
    print("Getting Database connection.")
    conn = postgresload.create_conn(db_cred['username'], db_cred['password'] )
    print("Creating Database Table if not exist.")
    postgresload.create_table(conn,table_name)  
    print("Checking if it is first load or increamental load via record count check.")
    res = postgresload.check_fullload(conn, table_name)
    if res == True:
       print("Its Full Load. Stating data load ...")
    else:
       print("Its Incremental Load. Getting max date from database.")
       max_date = postgresload.get_max_date(conn, table_name)
       print("Filtering the data set to load only incremental data.")
       nyt_data = nyt_data[(nyt_data['date'] > max_date)]
       jh_data  = jh_data[(jh_data['date'] > max_date)]

    print("Merging two data sets.")
    covid19us_data = datatransform.merge_datasets(nyt_data,jh_data)
    #Printing data
    #print(nyt_data.head())
    #print(jh_data.head())
    #print(covid19us_data.head())
    
    if covid19us_data.empty:
        print("Latest data not available. Failing gracefully.")
        raise Exception("INFO : Latest Data is not available into files.")

    # Calling DB 
    print("Loading final data into database.")
    postgresload.insert_table(conn, table_name, covid19us_data)

    #print("Reading Data from Table.")
    #query_cmd = "SELECT * FROM {} LIMIT 5".format(table_name)
    #result = postgresload.fetch(conn, query_cmd)
    #print(result)
    print("Getting date of latest data into database for email to business.")
    max_date = postgresload.get_max_date(conn, table_name)
    conn.close()
    msg = "ETL Process is successful. Data is available now to use. Latest date available: {}".format(max_date.strftime("%d %b, %Y"))
    response = sns.publish(
      TopicArn= SUCCESS_TOPIC,    
      Message= json.dumps(msg),    
    )
    msg = "ETL Lambda function successful. SNS notification sent. ID: {}".format(response["MessageId"])
    print(msg)
    return {
        'statusCode': 200,
        'body': json.dumps(msg)
    }
 except Exception as e:
    print("Error occured during execution.")
    msg = "ETL Lambda function failed. Error msg : {}".format(e)
    print(msg)
    response = sns.publish(
      TopicArn= ERROR_TOPIC,    
      Message= json.dumps(msg),    
    )
    msg = "ETL Lambda function failed. SNS notification sent. ID: {}".format(response["MessageId"])
    print(msg)
    return {
        'statusCode': 200,
        'body': json.dumps(msg)
    }

def get_secret():
   secret_name = "uscovid19db_secrets"
   region_name = runtime_region
   # Create a Secrets Manager client
   session = boto3.session.Session()
   client = session.client(
        service_name='secretsmanager',
        region_name=region_name
   )
   try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
        secret = get_secret_value_response['SecretString']
        secret_json = json.loads(secret)
        #print(secret)
        return secret_json
   except ClientError as e:
        print(e)
        if e.response['Error']['Code'] == 'DecryptionFailureException':
            # Secrets Manager can't decrypt the protected secret text using the provided KMS key.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InternalServiceErrorException':
            # An error occurred on the server side.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            # You provided an invalid value for a parameter.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            # You provided a parameter value that is not valid for the current state of the resource.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'ResourceNotFoundException':
            # We can't find the resource that you asked for.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e 
       