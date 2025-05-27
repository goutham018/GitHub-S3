
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc"
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = "ci-failure-logs-bucket-27355052"
}

module "lambda" {
  source          = "./modules/lambda"
  bucket_name     = module.s3.bucket_name
  fastapi_url     = "http://${module.ec2_fastapi.public_ip}:8000/trigger-workflow"
  depends_on      = [module.s3]
}

module "ec2_fastapi" {
  source = "./modules/ec2_fastapi"
  subnet_id = module.vpc.public_subnet_id
  vpc_security_group_ids = [module.vpc.default_sg_id]
}
