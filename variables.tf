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