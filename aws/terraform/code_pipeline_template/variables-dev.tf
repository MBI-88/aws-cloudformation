variable "github_repo" {
    description = "Github repository"
    type = string
    default = "" 
}
variable "github_branch" {
  default = "main"
  type = string
}
variable "codedeploy_service_role_arn" {
  type =  string
}
variable "tag_key" {
  default = "CodeDeployTag"
  type = string
}
variable "tag_value" {
  default = "CodeDeployDemo"
  type = string
}
variable "github_user" {
  default = "MBI-88"
  type = string
}
variable "aws_region" {
  default = "us-east-1c"
  type =  string
}