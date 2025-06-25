locals {
  azs = ["eu-central-1a", "eu-central-1b"]

  # Divide /16 into 6 /24 subnets
  subnet_cidrs = [for i in range(0, 6) : cidrsubnet("10.0.0.0/16", 8, i)]

  public_subnets   = [local.subnet_cidrs[0], local.subnet_cidrs[1]]
  private_subnets  = [local.subnet_cidrs[2], local.subnet_cidrs[3]]
  database_subnets = [local.subnet_cidrs[4], local.subnet_cidrs[5]]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name             = "exampledeployment-todo-vpc"
  cidr             = "10.0.0.0/16"
  azs              = local.azs
  public_subnets   = local.public_subnets
  private_subnets  = local.private_subnets
  database_subnets = local.database_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_flow_log = false
}

module "frontend-cluster" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.12.1"

  cluster_name = "exampledeployment-todo-frontend-cluster"
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  services = {
    todo-frontend = {
      cpu    = 256
      memory = 512

      volume = {
        tmp = {}
      }
      container_definitions = {
        frontend = {
          image = "ghcr.io/tram-de/todo-frontend:latest"
          repositoryCredentials = {
            credentialsParameter = "arn:aws:secretsmanager:eu-central-1:239339588929:secret:ghcr/-zPVrbg"
          }
          essential                 = true
          cpu                       = 256
          memory                    = 512
          enable_cloudwatch_logging = true
          portMappings = [
            {
              name          = "todo-frontend"
              containerPort = 3000
              hostPort      = 80
              protocol      = "tcp"
            }
          ]
          mountPoints = [
            {
              sourceVolume  = "tmp"
              containerPath = "/tmp"
              readOnly      = false
            }
          ]
          readonly_root_filesystem = false
        }
      }
      assign_public_ip = true
      subnet_ids       = module.vpc.public_subnets
    }
  }
  create_cloudwatch_log_group = false
  task_exec_secret_arns       = [
    var.ghcr_pat_aws_secretsmanager_arn
  ]
}

  