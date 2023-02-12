provider "kubernetes" {
    #load_config_file = "false"
    host = data.aws_eks_cluster.myapp-cluster.endpoint
    token = data.aws_eks_cluster_auth.myapp-cluster-auth.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.myapp-cluster.certificate_authority.0.data)

}

data "aws_eks_cluster" "myapp-cluster" {
    name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "myapp-cluster-auth" {
    name = module.eks.cluster_id
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.7.0"
  cluster_name = "myapp-eks-cluster"
  cluster_version = "1.21"
  
  vpc_id = module.myapp-vpc.vpc_id
  subnet_ids = module.myapp-vpc.private_subnets

  eks_managed_node_group_defaults = {
    disk_size = 8
  }
eks_managed_node_groups = {
    general = {
      desired_size = 1
      min_size     = 1
      max_size     = 2

      labels = {
        role = "general"
      }

      instance_types = ["t2.micro"]
      capacity_type  = "ON_DEMAND"
    }

    spot = {
      desired_size = 1
      min_size     = 1
      max_size     = 2

      labels = {
        role = "spot"
      }

      instance_types = ["t2.micro"]
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    environment = "development"
    application = "myapp"
  }
  
}