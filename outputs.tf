
output "fastapi_public_ip" {
  value = module.ec2_fastapi.public_ip
}

output "bucket_name" {
  value = module.s3.bucket_name
}
