variable "ghcr_pat_aws_secretsmanager_arn" {
  description = "GitHub Container Registry Personal Access Token"
  type        = string
  default     = "arn:aws:secretsmanager:eu-central-1:239339588929:secret:ghcr/-zPVrbg"
}

variable "postgres_db_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "todo"
}

variable "postgres_db_username" {
  description = "Username for the PostgreSQL database"
  type        = string
  sensitive   = true
}

variable "postgres_db_password" {
  description = "Password for the PostgreSQL database"
  type        = string
  sensitive   = true
}