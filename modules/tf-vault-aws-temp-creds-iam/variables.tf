variable "aws_secret_backend_path" {
  type        = string
  description = "path to the aws secrets backend"
}

variable "aws_role_arn" {
  type        = string
  description = "aws role to generate temporary credentials for"
}

