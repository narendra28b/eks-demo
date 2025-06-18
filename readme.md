Terraform EKS Cluster Setup

What This Does
This Terraform configuration provisions an Amazon EKS cluster with:
- A VPC with public/private subnets
- 2 EKS worker nodes (t3.medium)
- Outputs for the EKS cluster endpoint and kubeconfig path

How to Run

bash
terraform init
terraform apply -auto-approve
