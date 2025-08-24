data "aws_subnet" "node" {
    id = var.subnet  
}

resource "aws_instance" "Jenkins_node" {
    ami = var.ami
    instance_type = var.instance
    key_name = var.key
    subnet_id = var.subnet
    vpc_security_group_ids = [aws_security_group.Jenkins_node_sg.id]

    user_data = file("${path.module}/userdata.sh")
    
  
}


resource "aws_security_group" "Jenkins_node_sg" {
    name = "Jenkins-node-sg"
    description = "Allow SSH and deploy app"
    vpc_id = data.aws_subnet.node.vpc_id

    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }

    ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTPS"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "App running port"
        from_port = 8000
        to_port = 8000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "Jenkins-node-sg"
    }
  
}

output "Jenkins_node_public_IP" {
    value = aws_instance.Jenkins_node.public_ip
  
}