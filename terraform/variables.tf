variable "creator" {
  description = "Name of creator"
  type        = string
  default     = "your_name"
}

variable "region" {
  description = "Cluster's region"
  type        = string
  default     = "eu-west-1"
}

variable "cluster_name" {
  description = "Name of EKS cluster"
  type        = string
  default     = "eks-portworx-lab"
}

variable "cluster_version" {
  description = "Cluster kubernetes version"
  type        = string
  default     = "1.27"
}

variable "instance_count" {
  description = "Amount of nodes in the cluster"
  default     = 4
}

variable "instance_type" {
  description = "EC2 type"
  type        = string
  default     = "t2.large"
}

variable "capacity_type" {
  description = "Capacity type"
  type        = string
  default     = "SPOT"
}

variable "aws_load_balancer_controller" {
  description = "Enable ingress"
  type        = bool
  default     = true
}

variable "s3_name" {
  description = "Name of S3"
  type        = string
  default     = "eks-portworx-lab-s3"
}


