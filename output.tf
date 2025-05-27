output "bucket_name" {
  value = module.ci_log_bucket.bucket_id
}

output "lambda_arn" {
  value = module.ci_log_lambda.lambda_function_arn
}

output "fastapi_ip" {
  value = module.ec2_fastapi.fastapi_ip
}
output "fastapi_public_ip" {
  value = module.ec2_fastapi.public_ip
}
