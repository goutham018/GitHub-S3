provider "aws" {
  region = var.aws_region
}

module "ci_log_bucket" {
  source              = "./modules/s3"
  bucket_name         = var.bucket_name
  lambda_function_arn = module.ci_log_lambda.lambda_function_arn
}

module "ci_log_lambda" {
  source               = "./modules/lambda"
  bucket_name          = var.bucket_name
  environment_variables = {
    FASTAPI_URL = "http://${module.ec2_fastapi.fastapi_ip}:8000/ci/logs"
  }
}

module "ec2_fastapi" {
  source     = "./modules/ec2_fastapi"
  key_pair   = var.key_pair
  subnet_id  = var.subnet_id
  vpc_id     = var.vpc_id
}
