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