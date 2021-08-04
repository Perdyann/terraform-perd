data "aws_eks_cluster" "terraform-cluster" {
    name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "terraform-cluster-auth" {
    name = module.eks.cluster_id
} 

provider "kubernetes" {
  host                   = data.aws_eks_cluster.terraform-cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.terraform-cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.terraform-cluster-auth.token
#   load_config_file       = false
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.1.0"
  # insert the 9 required variables here

  cluster_name = "terraform-eks-cluster"
  cluster_version = "1.21"

  subnets = module.terraform-vpc.private_subnets
  vpc_id = module.terraform-vpc.vpc_id


  tags = {
      environment = "development"
      application = "terraform"
  }

  worker_groups = [
      {
          instance_type = "t2.small"
          name = "worker-group-1"
          asg_desired_capacity = 2
      },
      {
          instance_type = "t2.medium"
          name = "worker-group-2"
          asg_desired_capacity = 1
      }
  ]
}