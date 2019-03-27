resource "aws_key_pair" "key" {
    key_name   = "terraform"
    public_key = "${var.aws_key_pair}"
}

resource "aws_security_group" "allow_ssh" {
    name         = "allow_ssh"
    description  = "Allow SSH Inbound Traffic"
    
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "elastic-master" {
    count           = 3
    ami             = "${var.aws_ami}"
    instance_type   = "${var.aws_instance_type}"
    key_name        = "${aws_key_pair.key.key_name}"
    security_groups = ["${aws_security_group.allow_ssh.name}"]
    tags {
        User = "terraform-user",
        Name = "elastic-master-${count.index + 1}"
    }
    ebs_block_device {
        device_name  = "/dev/xvdb"
        volume_size           = "50"
        volume_type           = "gp2"
        delete_on_termination = true
    }
}