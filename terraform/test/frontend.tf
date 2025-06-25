
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
  task_exec_secret_arns = [
    var.ghcr_pat_aws_secretsmanager_arn
  ]
}
