resource "aws_key_pair" "key" {
    key_name   = "terraform"
    public_key = "${var.aws_key_pair}"
}

resource "aws_vpc" "elastic-vpc" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true
  tags = {
      Name = "Elastic VPC"
  }
}

resource "aws_internet_gateway" "elastic-ig" {
  vpc_id = "${aws_vpc.elastic-vpc.id}"
  tags   = {
      Name = "Elastic IG"
  }
}

resource "aws_route" "quadzero" {
  route_table_id         = "${aws_vpc.elastic-vpc.default_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.elastic-ig.id}"
}

resource "aws_security_group" "allow_ssh" {
    name         = "allow_ssh"
    description  = "Allow SSH Inbound Traffic"
    vpc_id       = "${aws_vpc.elastic-vpc.id}"
    
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Use = "General"
    }
}

resource "aws_security_group" "es_kb_home" {
    name         = "es_kb_home"
    description  = "Allow access to ES and KB from home"
    vpc_id       = "${aws_vpc.elastic-vpc.id}"
    
    ingress {
        from_port   = 9200
        to_port     = 9200
        protocol    = "tcp"
        cidr_blocks = ["${var.home_ip}"]
    }
    ingress {
        from_port   = 9200
        to_port     = 9200
        protocol    = "tcp"
        cidr_blocks = ["${var.vpc_cidr_block}"]
    }
    ingress {
        from_port   = 9300
        to_port     = 9300
        protocol    = "tcp"
        cidr_blocks = ["${var.vpc_cidr_block}"]
    }
    tags = {
        Use = "Elastic"
    }
}

resource "aws_security_group" "egress" {
  name        = "allow_egress"
  description = "Allow egress to the internet"
  vpc_id      = "${aws_vpc.elastic-vpc.id}"

  egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Use = "General"
    }
}

### AZ 1
resource "aws_subnet" "subnet_az1" {
  vpc_id                  = "${aws_vpc.elastic-vpc.id}"
  cidr_block              = "${var.az1_subnet_cidr_block}"
  availability_zone       = "${var.aws_avail_zone_1}"
  map_public_ip_on_launch = true
  tags = {
      Name = "Elastic AZ1"
  }
}

resource "aws_instance" "elastic-master-az1" {
    ami                      = "${var.aws_ami}"
    instance_type            = "${var.aws_instance_type}"
    key_name                 = "${aws_key_pair.key.key_name}"
    subnet_id                = "${aws_subnet.subnet_az1.id}"
    iam_instance_profile     = "ec2_discovery"
    vpc_security_group_ids   = ["${aws_security_group.allow_ssh.id}","${aws_security_group.egress.id}","${aws_security_group.es_kb_home.id}"]
    tags {
        User = "terraform-user",
        Name = "elastic-master-az1"
        role = "master"
    }
    ebs_block_device {
        device_name           = "/dev/xvdb"
        volume_size           = "50"
        volume_type           = "gp2"
        delete_on_termination = true
    }
    connection {
          type     = "ssh"
          user     = "ubuntu"
          private_key = "${file("id_rsa.priv")}"
        }
    provisioner "remote-exec" {
        inline = [
            "sudo apt update",
            "sudo apt install -y openjdk-8-jre-headless",
            "wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -",
            "sudo apt-get install apt-transport-https",
            "echo 'deb https://artifacts.elastic.co/packages/7.x/apt stable main' | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list",
            "sudo apt-get update",
            "sudo apt-get -y install elasticsearch",
            "sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch discovery-ec2"
        ]
    }
    provisioner "file" {
        source      = "elasticsearch.yml"
        destination = "/tmp/elasticsearch.yml"
    }
    provisioner "remote-exec" {
        inline = [
            "sudo mv /tmp/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml",
            "echo 'node.name: \"${self.tags.Name}\"' | sudo tee -a /etc/elasticsearch/elasticsearch.yml",
            "sudo systemctl start elasticsearch"
        ]
    }
}

### AZ 2
resource "aws_subnet" "subnet_az2" {
  vpc_id                  = "${aws_vpc.elastic-vpc.id}"
  cidr_block              = "${var.az2_subnet_cidr_block}"
  availability_zone       = "${var.aws_avail_zone_2}"
  map_public_ip_on_launch = true
  tags = {
      Name = "Elastic AZ2"
  }
}

resource "aws_instance" "elastic-master-az2" {
    ami                      = "${var.aws_ami}"
    instance_type            = "${var.aws_instance_type}"
    key_name                 = "${aws_key_pair.key.key_name}"
    subnet_id                = "${aws_subnet.subnet_az2.id}"
    iam_instance_profile     = "ec2_discovery"
    vpc_security_group_ids   = ["${aws_security_group.allow_ssh.id}","${aws_security_group.egress.id}","${aws_security_group.es_kb_home.id}"]
    tags {
        User = "terraform-user",
        Name = "elastic-master-az2"
        role = "master"
    }
    ebs_block_device {
        device_name           = "/dev/xvdb"
        volume_size           = "50"
        volume_type           = "gp2"
        delete_on_termination = true
    }
    connection {
          type     = "ssh"
          user     = "ubuntu"
          private_key = "${file("id_rsa.priv")}"
        }
    provisioner "remote-exec" {
        inline = [
            "sudo apt update",
            "sudo apt install -y openjdk-8-jre-headless",
            "wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -",
            "sudo apt-get install apt-transport-https",
            "echo 'deb https://artifacts.elastic.co/packages/7.x/apt stable main' | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list",
            "sudo apt-get update",
            "sudo apt-get -y install elasticsearch",
            "sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch discovery-ec2"
        ]
    }
    provisioner "file" {
        source      = "elasticsearch.yml"
        destination = "/tmp/elasticsearch.yml"
    }
    provisioner "remote-exec" {
        inline = [
            "sudo mv /tmp/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml",
            "echo 'node.name: \"${self.tags.Name}\"' | sudo tee -a /etc/elasticsearch/elasticsearch.yml",
            "sudo systemctl start elasticsearch"
        ]
    }
}

### AZ 3
resource "aws_subnet" "subnet_az3" {
  vpc_id                  = "${aws_vpc.elastic-vpc.id}"
  cidr_block              = "${var.az3_subnet_cidr_block}"
  availability_zone       = "${var.aws_avail_zone_3}"
  map_public_ip_on_launch = true
  tags = {
      Name = "Elastic AZ3"
  }
}

resource "aws_instance" "elastic-master-az3" {
    ami                      = "${var.aws_ami}"
    instance_type            = "${var.aws_instance_type}"
    key_name                 = "${aws_key_pair.key.key_name}"
    subnet_id                = "${aws_subnet.subnet_az3.id}"
    iam_instance_profile     = "ec2_discovery"
    vpc_security_group_ids   = ["${aws_security_group.allow_ssh.id}","${aws_security_group.egress.id}","${aws_security_group.es_kb_home.id}"]
    tags {
        User = "terraform-user",
        Name = "elastic-master-az3"
        role = "master"
    }
    ebs_block_device {
        device_name           = "/dev/xvdb"
        volume_size           = "50"
        volume_type           = "gp2"
        delete_on_termination = true
    }
    connection {
          type     = "ssh"
          user     = "ubuntu"
          private_key = "${file("id_rsa.priv")}"
        }
    provisioner "remote-exec" {
        inline = [
            "sudo apt update",
            "sudo apt install -y openjdk-8-jre-headless",
            "wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -",
            "sudo apt-get install apt-transport-https",
            "echo 'deb https://artifacts.elastic.co/packages/7.x/apt stable main' | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list",
            "sudo apt-get update",
            "sudo apt-get -y install elasticsearch",
            "sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch discovery-ec2"
        ]
    }
    provisioner "file" {
        source      = "elasticsearch.yml"
        destination = "/tmp/elasticsearch.yml"
    }
    provisioner "remote-exec" {
        inline = [
            "sudo mv /tmp/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml",
            "echo 'node.name: \"${self.tags.Name}\"' | sudo tee -a /etc/elasticsearch/elasticsearch.yml",
            "sudo systemctl start elasticsearch"
        ]
    }
}

