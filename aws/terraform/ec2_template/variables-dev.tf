variable "instance_tag" {
  description = "EC2 instance name"
  type        = string
  default     = "cloudec-express"
}

variable "ec2_type" {
  description = "EC2 type"
  type        = string
  default     = "t2.micro"

}

variable "ami_type" {
  description = "AMI type"
  type        = string
  default     = "ami-04a81a99f5ec58529"
}

variable "availability_zone" {
  description = "Availability zone"
  type        = string
  default     = "us-east-1c"
}

variable "sg" {
  description = "Security Group"
  type        = string
  default     = "sg-0c8af926ac3390d7e"
}
