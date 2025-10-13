resource "aws_security_group" "webapp_sg" {
  name        = "webapp-sg"
  description = "Allows HTTP/HTTPs trafic"
  ingress = [
    {
        protocol = "tcp"
        from_port = 80
        to_port = 80
        cidr_blocks = [ "0.0.0.0/0" ]
    },
    {
        protocol = "tcp"
        from_port = 443 
        to_port = 443 
        cidr_blocks = [ "0.0.0.0/0" ]
    },
    {
        protocol = "tcp"
        from_port = 22
        to_port = 22 
        cidr_blocks = [ "0.0.0.0/0" ]
    }
  ]
}

resource "aws_instance" "webapp_instance" {
  ami             = var.image_id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.webapp_sg]
  key_name        = var.key_name
  region          = var.region
}
