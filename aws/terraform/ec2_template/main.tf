resource "aws_instance" "my_ec2_instance" {
  ami                                  = var.ami_type
  instance_type                        = var.ec2_type
  availability_zone                    = var.availability_zone
  disable_api_termination              = false
  ebs_optimized                        = false
  monitoring                           = false
  instance_initiated_shutdown_behavior = "stop"
  security_groups                      = [var.sg]

  tags = {
    "Name" = var.instance_tag
  }
 
  user_data = <<-EOF
        #!/bin/bash
        # Update and install prerequisites
        sudo apt-get update -y
        sudo apt install golang-go git libcap2-bin -y

        # Create directory and clone repo
        mkdir -p /var/www/html
        cd /var/www/html
        git clone https://github.com/MBI-88/edutin-go-server.git

        # Build and run the Go application
        cd edutin-go-server
        sudo go build -buildvcs=false -o app
        sudo ./app
    EOF
  

  metadata_options {
    http_tokens = "optional"
  }
}
