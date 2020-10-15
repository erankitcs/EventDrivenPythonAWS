aws_region     = "us-east-1"
application_id = "covid19etl"
envionment     = "dev"
##runtime = "python3.6"
## Update a unique bucket name here.
landing_zone_bucket_name = "covid19ankitlandingzone14578"
## 1 meand 1 AM and 23 means 11 PM
trigger_time   = 1
#nyt_url = "https://testfilebucket123.s3.amazonaws.com/nyt_covid19_success.csv"
#jh_url  = "https://testfilebucket123.s3.amazonaws.com/jh_covid19_success.csv"
nyt_url        = "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us.csv"
jh_url          = "https://raw.githubusercontent.com/datasets/covid-19/master/data/time-series-19-covid-combined.csv"
table_name  = "covid19us"
database_name = "uscovid19db"
## Update your secrete name here.
databse_secret_name   = "uscovid19db_secrets"
business_subscription_email_address_list  = "er.ankit.cs@gmail.com"
technology_subscription_email_address_list = "er.ankit.cs@gmail.com"