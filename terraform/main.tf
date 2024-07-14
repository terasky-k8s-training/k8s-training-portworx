#---------------------------------------------------------------
# EKS Cluster
#---------------------------------------------------------------

module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.32.1"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  managed_node_groups = {
    worker_nodes = {
      
      name = join("-", [var.cluster_name, "worker"])
      node_group_name         = join("-", [var.cluster_name, "nodegroup"])

      instance_types          = [var.instance_type]
      capacity_type           = var.capacity_type
      min_size                = 4
      desired_size            = 4
      max_size                = 4
      subnet_ids              = module.vpc.private_subnets

      tags = merge({
        "Name" = join("-", [var.cluster_name, "worker"])
      }, local.tags)
    }
  }

  tags = local.tags
}

#---------------------------------------------------------------
# EKS Addons
#---------------------------------------------------------------

module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.12.0" 

  # EKS Details
  cluster_name      = var.cluster_name
  cluster_endpoint  = module.eks_blueprints.eks_cluster_endpoint
  cluster_version   = var.cluster_version
  oidc_provider_arn = module.eks_blueprints.eks_oidc_provider_arn

  eks_addons = {
    # aws-ebs-csi-driver = {
    #   most_recent = true
    # }
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  # Ingress Controller
  enable_aws_load_balancer_controller = var.aws_load_balancer_controller
}


#---------------------------------------------------------------
# EKS Resources
#---------------------------------------------------------------

resource "kubernetes_namespace" "portworx-poc" {
  metadata {
    name = "portworx-poc"
  }
}