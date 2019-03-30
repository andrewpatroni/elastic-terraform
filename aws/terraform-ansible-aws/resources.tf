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
        cidr_blocks = ["71.38.35.16/32"]     
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]        
    }
}

resource "aws_security_group" "kibana" {
    name     = "allow_kibana"
    description = "Allow kibana access from specific IPs"
    ingress {
        from_port   = 5601
        to_port     = 5601
        protocol    = "tcp"
        cidr_blocks = ["71.38.35.16/32"]
    }
}


resource "aws_instance" "elastic-master" {
    count           = 2
    ami             = "${var.aws_ami}"
    instance_type   = "${var.aws_instance_type_es}"
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
    provisioner "local-exec" {
        command = "sleep 90 && ansible-galaxy --roles-path=.ansible/ install elastic.elasticsearch && ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook --become -u ${var.aws_ami_user} --private-key ~/andrewpatroni-github/andrewpatroni-github -i '${self.public_ip},'  elasticsearch-lvm.yml && ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook --become -u ${var.aws_ami_user} --private-key ~/andrewpatroni-github/andrewpatroni-github -i '${self.public_ip},' --extra-vars 'prihost=${aws_instance.elastic-master.0.public_ip} es_live_version=${var.es_revision}' elasticsearch-master.yml"
    }
}
resource "aws_instance" "elastic-data" {
    count           = 1
    ami             = "${var.aws_ami}"
    instance_type   = "${var.aws_instance_type_es}"
    key_name        = "${aws_key_pair.key.key_name}"
    security_groups = ["${aws_security_group.allow_ssh.name}"]
    tags {
        User = "terraform-user",
        Name = "elastic-data-${count.index + 1}"
    }
    ebs_block_device {
        device_name  = "/dev/xvdb"
        volume_size           = "50"
        volume_type           = "gp2"
        delete_on_termination = true
    }
    provisioner "local-exec" {
        command = "sleep 90 && ansible-galaxy --roles-path=.ansible/ install elastic.elasticsearch && ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook --become -u ${var.aws_ami_user} --private-key ~/andrewpatroni-github/andrewpatroni-github -i '${self.public_ip},'  elasticsearch-lvm.yml && ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook --become -u ${var.aws_ami_user} --private-key ~/andrewpatroni-github/andrewpatroni-github -i '${self.public_ip},' --extra-vars 'prihost=${aws_instance.elastic-master.0.public_ip} es_live_version=${var.es_revision}' elasticsearch-master.yml"
    }
}
resource "aws_instance" "elastic-kibana" {
    count           = 1
    ami             = "${var.aws_ami}"
    instance_type   = "${var.aws_instance_type_kb}"
    key_name        = "${aws_key_pair.key.key_name}"
    security_groups = ["${aws_security_group.allow_ssh.name}", "${aws_security_group.kibana.name}"]
    tags {
        User = "terraform-user",
        Name = "elastic-kibana-${count.index + 1}"
    }
    provisioner "local-exec" {
        command = "sleep 90 && ansible-galaxy --roles-path=.ansible/ install geerlingguy.kibana && ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook --become -u ${var.aws_ami_user} --private-key ~/andrewpatroni-github/andrewpatroni-github -i '${self.public_ip},' --extra-vars 'prihost=${aws_instance.elastic-master.0.public_ip} kibip=0.0.0.0 es_live_version=${var.es_revision}' kibana.yml"
    }
}