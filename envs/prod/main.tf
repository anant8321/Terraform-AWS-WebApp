module "vpc" {
  source = "../../modules/vpc"

  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr
  az_list = var.az_list
  public_sub_cidrs = var.public_sub_cidrs
  private_sub_cidrs = var.private_sub_cidrs
}

module "iam" {
  source = "../../modules/iam"

  project_name = var.project_name
}

module "alb"{
  source = "../../modules/alb"

  project_name = var.project_name
  vpc_id = module.vpc.vpc_id
  public_sub_ids = module.vpc.public_subnet_ids
  app_port = var.app_port
}

module "Compute" {
  source = "../../modules/compute"

  project_name = var.project_name
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_id = module.vpc.vpc_id

  ami_id = var.ami_id
  instance_type = var.instance_type
  app_port = var.app_port

  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn = module.alb.target_group_arn
  instance_profile_name = module.iam.instance_profile_name

  desired_capacity = var.desired_capacity
  max_size = var.max_size
  min_size = var.min_size  
}

module "monitoring" {
  source = "../../modules/monitoring"

  project_name = var.project_name
  asg_name = module.Compute.asg_name
}