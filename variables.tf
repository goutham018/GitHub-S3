variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "S3 bucket for CI logs"
  type        = string
  default     = "ci-failure-logs-bucket-123456"
}

variable "key_pair" {
  description = "EC2 Key Pair for SSH"
  type        = string
  default     = "aws-login"
}
