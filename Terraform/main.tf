resource "aws_instance" "mono_app" {
    ami = var.ami
    key_name = var.key
    instance_type = var.instance
    subnet_id = var.subnet  
}