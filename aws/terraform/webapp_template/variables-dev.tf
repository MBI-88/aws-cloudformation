variable "image_id" {
  default = "ami-0d5eff06f840b45e9"
  type = string
}
variable "instance_type" {
  default = "t2.micro"
  type = string
}
variable "key_name" {
  default = "mbi"
  type = string
}

variable "region" {
  default = "us-east-1c"
  type = string
}