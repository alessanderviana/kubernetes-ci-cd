variable "cliente" {
  default = "kr8sswordz puzzle"
}
variable "region" {
  default = "us-east-1"
}
variable "zones" {
  description = "AZs to use"
  default = ["us-east-1a", "us-east-1d"]
  type = "list"
}
variable "aws_profile" {
  default = "alessander"
}
variable "vpc_range" {
  default = "10.19.0.0/21"
  # 10.19.0.1 - 10.19.7.254
}
variable "pub_subnets_ranges" {
  description = "Subnet CIDRs for public subnets (length must match configured availability_zones)"
  default = ["10.19.1.0/24", "10.19.3.0/24"]
  type = "list"
}
variable "priv_subnets_ranges" {
  description = "Subnet CIDRs for private subnets (length must match configured availability_zones)"
  default = ["10.19.2.0/24", "10.19.4.0/24"]
  type = "list"
}
variable "ami_id" {
  default = "ami-05ecb1463f8f1ee4b"
}
variable "instance_type" {
  default = "t3.medium"
}
variable "user" {
  default = "ubuntu"
}
variable "ssh_key" {
  default = "~/repositorios/terraform/alessander-tf.pub"
}
