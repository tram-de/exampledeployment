
module "backend-cluster" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.12.1"

  cluster_name = "exampledeployment-todo-backend-cluster"
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
    todo-backend = {
      cpu    = 256
      memory = 512

      volume = {
        tmp = {}
      }

      service_registries = {
        registry_arn   = aws_service_discovery_service.backend.arn
        container_name = "backend"
      }


      container_definitions = {
        backend = {
          image = "ghcr.io/tram-de/todo-backend:latest"
          repositoryCredentials = {
            credentialsParameter = "arn:aws:secretsmanager:eu-central-1:239339588929:secret:ghcr/-zPVrbg"
          }
          essential                 = true
          cpu                       = 256
          memory                    = 512
          enable_cloudwatch_logging = true
          portMappings = [
            {
              name          = "todo-backend"
              containerPort = 8000
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
          environment = [
            {
              name  = "POSTGRES_DB"
              value = var.postgres_db_name
            },
            {
              name  = "POSTGRES_USER"
              value = var.postgres_db_username
            },
            {
              name  = "POSTGRES_PASSWORD"
              value = var.postgres_db_password
            },
            {
              name  = "POSTGRES_HOST"
              value = aws_db_instance.postgres.address
            },
            {
              name  = "POSTGRES_PORT"
              value = "5432"
            }
          ]
          readonly_root_filesystem = false
        }
      }
      subnet_ids       = module.vpc.private_subnets
      assign_public_ip = false
    }
  }
  create_cloudwatch_log_group = false
  task_exec_secret_arns = [
    var.ghcr_pat_aws_secretsmanager_arn
  ]
  depends_on = [aws_db_instance.postgres]
}

resource "aws_service_discovery_private_dns_namespace" "backend" {
  name        = "backend.local"
  vpc         = module.vpc.vpc_id
  description = "Private DNS namespace for backend services"
}

resource "aws_service_discovery_service" "backend" {
  name        = "todo-backend"
  description = "Service discovery for todo backend"
  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.backend.id
    routing_policy = "MULTIVALUE"
    dns_records {
      type = "A"
      ttl  = 60
    }
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}