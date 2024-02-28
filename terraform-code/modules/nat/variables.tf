variable "subnet_id" {
  description = "ID of the public subnet where the NAT Gateway will reside."
  type        = string
}

variable "private_subnet_id" {
  description = "ID of a private subnet."
  type        = string
}

variable "route_table_id" {
  description = "ID of the route table associated with the private subnet."
  type        = string
}
