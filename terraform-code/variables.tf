# VPC related variables
variable "vpc_cidr_block" {
  description = "CIDR block for the main VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

# EKS Cluster Variables
variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "cluster_role_arn" {
  description = "ARN of the IAM role used by the EKS cluster."
  type        = string
}

variable "node_role_arn" {
  description = "ARN of the IAM role used by the worker nodes."
  type        = string
}

# EKS Node Group Variables
variable "node_instance_type" {
  description = "Instance type for the worker nodes."
  type        = string
  default     = "t3.medium"
}

variable "node_group_desired_size" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 5
}

variable "node_group_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 1
}
