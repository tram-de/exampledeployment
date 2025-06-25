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

resource "aws_security_group" "postgres_sg" {
  name        = "exampledeployment-todo-postgres-sg"
  description = "Security group for PostgreSQL RDS instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

resource "aws_db_subnet_group" "postgres" {
  name       = "exampledeployment-todo-postgres-subnet-group"
  subnet_ids = module.vpc.database_subnets

  tags = {
    Name = "exampledeployment-todo-postgres-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier             = "exampledeployment-todo-postgres"
  engine                 = "postgres"
  engine_version         = "15.8"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20 # Minimum 20 for PostgreSQL
  db_name                = var.postgres_db_name
  username               = var.postgres_db_username
  password               = var.postgres_db_password
  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [aws_security_group.postgres_sg.id]
  skip_final_snapshot    = true
  storage_encrypted      = true

  tags = {
    Name = "exampledeployment-todo-postgres"
  }
}