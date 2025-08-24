resource "aws_instance" "Jenkins_Master" {
    ami = var.ami
    instance_type = var.instance
    key_name = var.key
    subnet_id = var.subnet

    vpc_security_group_ids = [aws_security_group.jenkins_master_sg.id]

    root_block_device {
      volume_size = 15  # 15 GB disk
      volume_type = "gp3"

    }

    user_data = file("${path.module}/userdata.sh")

    tags = {
      Name = "Jenkins_Master"
    }  

  
}

data "aws_subnet" "selected" {
    id = var.subnet
  
}

resource "aws_security_group" "jenkins_master_sg" {
    name = "jenkins-master-sg"
    description = "Allow SSH and Jenkins UI"
    vpc_id = data.aws_subnet.selected.vpc_id

    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Jenkins UI"
        from_port = 8080
        to_port = 8080
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
      Name = "Jenkins-master-sg"
    }
  
}

output "Jenins_master_public_IP" {
    value = aws_instance.Jenkins_Master.public_ip
  
}

output "Jenkins_master_vpc_id" {
    value = data.aws_subnet.selected.vpc_id
  
}
