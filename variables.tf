variable "aws_region" {
  default = "us-east-1"
}

variable "application_id" {
  type        = string
  description = "The uniuqe Id for the application"
  default     = "covid19etl"
}

variable "envionment" {
  type        = string
  description = "Envionment type of the application eg. dev, test, prod."
  default     = "dev"
}

variable "runtime" {
  default     = "python3.6"
  type        = string
  description = "Runtime for lambda function."
}

variable "landing_zone_bucket_name" {
  type        = string
  description = "A unique bucket name for landing zone."
}

variable "trigger_time" {
  type        = string
  description = "Time of the day when you want to trigger your ETL job."
}


variable "nyt_url" {
  default     = "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us.csv"
  type        = string
  description = "URL for NYT Covid19 data."
}

variable "jh_url" {
  default     = "https://raw.githubusercontent.com/datasets/covid-19/master/data/time-series-19-covid-combined.csv"
  type        = string
  description = "URL for NYT Covid19 data."
}

variable "table_name" {
  default     = "covid19us"
  type        = string
  description = "Table name to store the data."
}

variable "database_name" {
  default     = "uscovid19db"
  type        = string
  description = "Database name for the Postgres."
}

variable "databse_secret_name" {
  type        = string
  description = "Secret name for the Postgres database."
  default     = "uscovid19db_secrets"
}

variable "business_subscription_email_address_list" {
  type = string
  description = "List of email addresses as string(space separated) of business users."
  default = "er.ankit.cs@gmail.com"
}

variable "technology_subscription_email_address_list" {
  type = string
  description = "List of email addresses as string(space separated) of Teachnology team."
  default = "er.ankit.cs@gmail.com"
}