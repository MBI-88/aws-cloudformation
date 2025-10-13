
variable "lambda_name" {
    type = string
    default = "lambda-python"
    description = "lambda python for testing in terraform"
}

variable "api_gateway" {
  type = string
  default = "api-python"
  description = "api gateway in python for testing in terraform"
}

variable "role" {
  type = string
  default = "role-python"
  description = "role to access resources"
}

variable "policy" {
    type = string
    default = "policy-python"
    description = "policy to interact with services"
}

variable "region" {
  type = string 
  default = "us-east-1"
}