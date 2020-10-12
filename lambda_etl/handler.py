import pandas as pd
import numpy as np
import os
from modules import datatransform
from modules import postgresload
import json
import boto3
import botocore
import datetime

#s3 = boto3.client('s3')
s3 = boto3.client('s3', 'us-east-1', config=botocore.config.Config(s3={'addressing_style':'path'}))
def lambda_handler(event, context):
    message = json.loads(event['Records'][0]['Sns']['Message'])
    print(message)
    bucket = os.environ['BUCKET']
    table_name = os.environ['TABLE_NAME']
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
    print("Getting Database connection.")
    conn = postgresload.create_conn()
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
    print(nyt_data.head())
    print(jh_data.head())
    print(covid19us_data.head())
    
    if covid19us_data.empty:
        print("Latest data not available. Failing gracefully.")
        return "Failed"

    # Calling DB 
    print("Loading final data into database.")
    postgresload.insert_table(conn, table_name, covid19us_data)

    print("Reading Data from Table.")
    query_cmd = "SELECT * FROM {} LIMIT 5".format(table_name)
    result = postgresload.fetch(conn, query_cmd)
    print(result)
    conn.close()
    return "Successful."