import pandas as pd
import numpy as np

def clean_nyt_data(nyt_data):
 try:
    nyt_data['date']= pd.to_datetime(nyt_data['date']).dt.date
    
    # Cleaning cases column - Converting non numeric data into NaN
    nyt_data['cases'] = pd.to_numeric(nyt_data['cases'], errors='coerce')
    # Droping NaN if any
    nyt_data = nyt_data.dropna(subset=['cases'])

    # Cleaning deaths column - Converting non numeric data into NaN
    nyt_data['deaths'] = pd.to_numeric(nyt_data['deaths'], errors='coerce')
    # Droping NaN if any
    nyt_data = nyt_data.dropna(subset=['deaths'])
    return nyt_data
 except Exception as e:
    raise Exception("NYT data cleaning failed. Error: {}".format(e))

def clean_jh_data(jh_data):
 try:
    # Filtering only US data first and then taking only required columns.
    jh_data = jh_data[(jh_data["Country/Region"]  == "US")]
    jh_data= jh_data[["Date","Recovered"]]
    jh_data.rename(columns={'Date': 'date'}, inplace=True)
    # Converting object type into date object 
    jh_data['date']= pd.to_datetime(jh_data['date']).dt.date

    # Converting non numeric data into NaN
    jh_data['Recovered'] = pd.to_numeric(jh_data['Recovered'], errors='coerce')
    # Droping NA if any
    jh_data = jh_data.dropna(subset=['Recovered'])
    jh_data['Recovered'] = jh_data['Recovered'].apply(np.int64)
    return jh_data
 except Exception as e:
    raise Exception("JH data cleaning failed. Error: {}".format(e))

def merge_datasets(nyt_data, jh_data):
    ## Merging two data sets 
 try:
    covid19US = pd.merge(nyt_data,jh_data[['date','Recovered']], how='inner', on = 'date')
    return covid19US
 except Exception as e:
    raise Exception(" Dataset merging failed. Error: {}".format(e))