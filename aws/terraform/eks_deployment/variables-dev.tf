variable "cluster_name" {
  type = string
  default = "MyEKScluster"
  description = "eks cluster name"
}

variable "node_group" {
  type = string 
  default = "MyNode"
  description = "eks node group"
}

variable "sub_net_1" {
  default = "subnet-0f7a70d255c5e800b"
  type = string
}

variable "sub_net_2" {
  default = "subnet-0053acfccbeccb228"
  type = string
}

variable "vpc" {
  default = "vpc-08f53ec4c13d47c08"
  type = string
}

variable "instance_type" {
  default = "t2.micro"
  type = string
}