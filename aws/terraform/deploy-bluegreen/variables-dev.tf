variable "vpc_id" {
    type = string
    default = "vpc-08f53ec4c13d47c08"
    description = "virtual private server"
}
variable "subnet_1" {
  type = string
  default = "subnet-0053acfccbeccb228"
}
variable "subnet_2" {
  type = string
  default = "subnet-084b562c5fcf5c8a5"
}
variable "image" {
  type = string
  default = "mbi8807/edugo:unir"
}
