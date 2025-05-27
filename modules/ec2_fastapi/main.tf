data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_security_group" "fastapi_sg" {
  name        = "fastapi-sg"
  description = "Allow FastAPI HTTP access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "fastapi" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = var.key_pair
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.fastapi_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install python3-pip -y
              pip3 install fastapi uvicorn
              mkdir -p /opt/fastapi && cd /opt/fastapi
              cat <<EOL > main.py
              from fastapi import FastAPI
              from pydantic import BaseModel

              app = FastAPI()

              class LogPayload(BaseModel):
                  bucket: str
                  key: str
                  logs: str

              @app.post("/ci/logs")
              def process_logs(payload: LogPayload):
                  print(f"Received logs from {payload.key}")
                  classification = classify_log(payload.logs)
                  return {"classification": classification}

              def classify_log(logs: str):
                  if "timeout" in logs:
                      return {"class": "Timeout", "recommendation": "Increase timeout."}
                  elif "error" in logs:
                      return {"class": "BuildError", "recommendation": "Check dependencies."}
                  return {"class": "Unknown", "recommendation": "Manual review required."}
              EOL
              nohup uvicorn main:app --host 0.0.0.0 --port 8000 &
              EOF

  tags = {
    Name = "fastapi-server"
  }
}

output "fastapi_ip" {
  value = aws_instance.fastapi.public_ip
}
