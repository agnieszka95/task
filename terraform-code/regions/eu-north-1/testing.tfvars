vpc_cidr_block = "10.10.0.0/16"
public_subnet_cidrs = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidrs = ["10.10.10.0/24", "10.10.11.0/24"]

cluster_name = "my-production-cluster"

# IAM role ARNs (replace with actual ARNs)
cluster_role_arn = ""
# arn:aws:iam::123456789012:role/eks-cluster-role
node_group_role_arn = ""
# arn:aws:iam::123456789012:role/eks-nodegroup-role

node_group_desired_size = 3
node_group_max_size = 5
node_group_min_size = 1
