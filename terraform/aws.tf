
provider "aws" {
  version = "~> 2.0"
  region = var.region
  access_key = var.awsAccessKey
  secret_key = var.awsSecretKey
}

variable "awsAccessKey" { }

variable "awsSecretKey" { }

variable "region" {
  default = "eu-west-1"
}

variable "key_name" {
  default = "id_rsa"
}

variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "private_key_path" {
  default = "~/.ssh/id_rsa"
}

variable "ssh_user" {
  default = "ubuntu"
}

resource "aws_key_pair" "auth" {
  key_name = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_vpc" "edmm" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "edmm" {
  vpc_id = aws_vpc.edmm.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "edmm" {
  vpc_id = aws_vpc.edmm.id
}

resource "aws_route_table" "public_routes" {
  vpc_id = aws_vpc.edmm.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.edmm.id
  }
}

resource "aws_route_table_association" "public_route_association" {
  subnet_id = aws_subnet.edmm.id
  route_table_id = aws_route_table.public_routes.id
}

resource "aws_security_group" "center1_vm_security_group" {
  name = "center1_vm_security_group"
  vpc_id = aws_vpc.edmm.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "center1_vm" {
  ami = "ami-0701e7be9b2a77600"
  instance_type = "t2.micro"
  key_name = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.center1_vm_security_group.id]
  subnet_id = aws_subnet.edmm.id
  connection {
    type  = "ssh"
    user  = var.ssh_user
    agent = true
    private_key = file(var.private_key_path)
    host = self.public_ip
  }
  provisioner "file" {
    source      = "./env.sh"
    destination = "~/env.sh"
  }
}

resource "aws_security_group" "camera_ins_security_group" {
  name = "camera_ins_security_group"
  vpc_id = aws_vpc.edmm.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "camera_ins" {
  ami = "ami-0701e7be9b2a77600"
  instance_type = "t2.micro"
  key_name = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.camera_ins_security_group.id]
  subnet_id = aws_subnet.edmm.id
  connection {
    type  = "ssh"
    user  = var.ssh_user
    agent = true
    private_key = file(var.private_key_path)
    host = self.public_ip
  }
  provisioner "file" {
    source      = "./env.sh"
    destination = "~/env.sh"
  }
}

resource "aws_security_group" "gate_vm_security_group" {
  name = "gate_vm_security_group"
  vpc_id = aws_vpc.edmm.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "gate_vm" {
  ami = "ami-0701e7be9b2a77600"
  instance_type = "t2.micro"
  key_name = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.gate_vm_security_group.id]
  subnet_id = aws_subnet.edmm.id
  connection {
    type  = "ssh"
    user  = var.ssh_user
    agent = true
    private_key = file(var.private_key_path)
    host = self.public_ip
  }
  provisioner "file" {
    source      = "./env.sh"
    destination = "~/env.sh"
  }
}

resource "aws_security_group" "watch_security_group" {
  name = "watch_security_group"
  vpc_id = aws_vpc.edmm.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "watch" {
  ami = "ami-0701e7be9b2a77600"
  instance_type = "t2.micro"
  key_name = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.watch_security_group.id]
  subnet_id = aws_subnet.edmm.id
  connection {
    type  = "ssh"
    user  = var.ssh_user
    agent = true
    private_key = file(var.private_key_path)
    host = self.public_ip
  }
  provisioner "file" {
    source      = "./env.sh"
    destination = "~/env.sh"
  }
}

resource "aws_security_group" "camera_security_group" {
  name = "camera_security_group"
  vpc_id = aws_vpc.edmm.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "camera" {
  ami = "ami-0701e7be9b2a77600"
  instance_type = "t2.micro"
  key_name = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.camera_security_group.id]
  subnet_id = aws_subnet.edmm.id
  connection {
    type  = "ssh"
    user  = var.ssh_user
    agent = true
    private_key = file(var.private_key_path)
    host = self.public_ip
  }
  provisioner "file" {
    source      = "./env.sh"
    destination = "~/env.sh"
  }
}

resource "aws_security_group" "mobile_ins_security_group" {
  name = "mobile_ins_security_group"
  vpc_id = aws_vpc.edmm.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "mobile_ins" {
  ami = "ami-0701e7be9b2a77600"
  instance_type = "t2.micro"
  key_name = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.mobile_ins_security_group.id]
  subnet_id = aws_subnet.edmm.id
  connection {
    type  = "ssh"
    user  = var.ssh_user
    agent = true
    private_key = file(var.private_key_path)
    host = self.public_ip
  }
  provisioner "file" {
    source      = "./env.sh"
    destination = "~/env.sh"
  }
}

resource "aws_security_group" "cluster_security_group" {
  name = "cluster_security_group"
  vpc_id = aws_vpc.edmm.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "cluster" {
  ami = "ami-0701e7be9b2a77600"
  instance_type = "t2.micro"
  key_name = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.cluster_security_group.id]
  subnet_id = aws_subnet.edmm.id
  connection {
    type  = "ssh"
    user  = var.ssh_user
    agent = true
    private_key = file(var.private_key_path)
    host = self.public_ip
  }
  provisioner "file" {
    source      = "./env.sh"
    destination = "~/env.sh"
  }
}

resource "aws_security_group" "comp_security_group" {
  name = "comp_security_group"
  vpc_id = aws_vpc.edmm.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "comp" {
  ami = "ami-0701e7be9b2a77600"
  instance_type = "t2.micro"
  key_name = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.comp_security_group.id]
  subnet_id = aws_subnet.edmm.id
  connection {
    type  = "ssh"
    user  = var.ssh_user
    agent = true
    private_key = file(var.private_key_path)
    host = self.public_ip
  }
  provisioner "file" {
    source      = "./env.sh"
    destination = "~/env.sh"
  }
}

resource "aws_security_group" "mobile_security_group" {
  name = "mobile_security_group"
  vpc_id = aws_vpc.edmm.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "mobile" {
  ami = "ami-0701e7be9b2a77600"
  instance_type = "t2.micro"
  key_name = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.mobile_security_group.id]
  subnet_id = aws_subnet.edmm.id
  connection {
    type  = "ssh"
    user  = var.ssh_user
    agent = true
    private_key = file(var.private_key_path)
    host = self.public_ip
  }
  provisioner "file" {
    source      = "./env.sh"
    destination = "~/env.sh"
  }
}

resource "aws_security_group" "center1_ins_security_group" {
  name = "center1_ins_security_group"
  vpc_id = aws_vpc.edmm.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "center1_ins" {
  ami = "ami-0701e7be9b2a77600"
  instance_type = "t2.micro"
  key_name = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.center1_ins_security_group.id]
  subnet_id = aws_subnet.edmm.id
  connection {
    type  = "ssh"
    user  = var.ssh_user
    agent = true
    private_key = file(var.private_key_path)
    host = self.public_ip
  }
  provisioner "file" {
    source      = "./env.sh"
    destination = "~/env.sh"
  }
}

resource "aws_security_group" "cluster_ins_security_group" {
  name = "cluster_ins_security_group"
  vpc_id = aws_vpc.edmm.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "cluster_ins" {
  ami = "ami-0701e7be9b2a77600"
  instance_type = "t2.micro"
  key_name = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.cluster_ins_security_group.id]
  subnet_id = aws_subnet.edmm.id
  connection {
    type  = "ssh"
    user  = var.ssh_user
    agent = true
    private_key = file(var.private_key_path)
    host = self.public_ip
  }
  provisioner "file" {
    source      = "./env.sh"
    destination = "~/env.sh"
  }
}

resource "aws_security_group" "watch_ins_security_group" {
  name = "watch_ins_security_group"
  vpc_id = aws_vpc.edmm.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "watch_ins" {
  ami = "ami-0701e7be9b2a77600"
  instance_type = "t2.micro"
  key_name = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.watch_ins_security_group.id]
  subnet_id = aws_subnet.edmm.id
  connection {
    type  = "ssh"
    user  = var.ssh_user
    agent = true
    private_key = file(var.private_key_path)
    host = self.public_ip
  }
  provisioner "file" {
    source      = "./env.sh"
    destination = "~/env.sh"
  }
}

resource "aws_security_group" "publiccloudprovider_ins_security_group" {
  name = "publiccloudprovider_ins_security_group"
  vpc_id = aws_vpc.edmm.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "publiccloudprovider_ins" {
  ami = "ami-0701e7be9b2a77600"
  instance_type = "t2.micro"
  key_name = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.publiccloudprovider_ins_security_group.id]
  subnet_id = aws_subnet.edmm.id
  connection {
    type  = "ssh"
    user  = var.ssh_user
    agent = true
    private_key = file(var.private_key_path)
    host = self.public_ip
  }
  provisioner "file" {
    source      = "./env.sh"
    destination = "~/env.sh"
  }
}

resource "aws_security_group" "alarm_security_group" {
  name = "alarm_security_group"
  vpc_id = aws_vpc.edmm.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "alarm" {
  ami = "ami-0701e7be9b2a77600"
  instance_type = "t2.micro"
  key_name = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.alarm_security_group.id]
  subnet_id = aws_subnet.edmm.id
  connection {
    type  = "ssh"
    user  = var.ssh_user
    agent = true
    private_key = file(var.private_key_path)
    host = self.public_ip
  }
  provisioner "file" {
    source      = "./env.sh"
    destination = "~/env.sh"
  }
}

resource "aws_security_group" "gate_ins_security_group" {
  name = "gate_ins_security_group"
  vpc_id = aws_vpc.edmm.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "gate_ins" {
  ami = "ami-0701e7be9b2a77600"
  instance_type = "t2.micro"
  key_name = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.gate_ins_security_group.id]
  subnet_id = aws_subnet.edmm.id
  connection {
    type  = "ssh"
    user  = var.ssh_user
    agent = true
    private_key = file(var.private_key_path)
    host = self.public_ip
  }
  provisioner "file" {
    source      = "./env.sh"
    destination = "~/env.sh"
  }
}

resource "aws_security_group" "comp_ins_security_group" {
  name = "comp_ins_security_group"
  vpc_id = aws_vpc.edmm.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "comp_ins" {
  ami = "ami-0701e7be9b2a77600"
  instance_type = "t2.micro"
  key_name = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.comp_ins_security_group.id]
  subnet_id = aws_subnet.edmm.id
  connection {
    type  = "ssh"
    user  = var.ssh_user
    agent = true
    private_key = file(var.private_key_path)
    host = self.public_ip
  }
  provisioner "file" {
    source      = "./env.sh"
    destination = "~/env.sh"
  }
}

resource "aws_security_group" "publiccloudprovider_vm_security_group" {
  name = "publiccloudprovider_vm_security_group"
  vpc_id = aws_vpc.edmm.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "publiccloudprovider_vm" {
  ami = "ami-0701e7be9b2a77600"
  instance_type = "t2.micro"
  key_name = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.publiccloudprovider_vm_security_group.id]
  subnet_id = aws_subnet.edmm.id
  connection {
    type  = "ssh"
    user  = var.ssh_user
    agent = true
    private_key = file(var.private_key_path)
    host = self.public_ip
  }
  provisioner "file" {
    source      = "./env.sh"
    destination = "~/env.sh"
  }
}

resource "aws_security_group" "center2_vm_security_group" {
  name = "center2_vm_security_group"
  vpc_id = aws_vpc.edmm.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "center2_vm" {
  ami = "ami-0701e7be9b2a77600"
  instance_type = "t2.micro"
  key_name = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.center2_vm_security_group.id]
  subnet_id = aws_subnet.edmm.id
  connection {
    type  = "ssh"
    user  = var.ssh_user
    agent = true
    private_key = file(var.private_key_path)
    host = self.public_ip
  }
  provisioner "file" {
    source      = "./env.sh"
    destination = "~/env.sh"
  }
}

resource "aws_security_group" "alarm_ins_security_group" {
  name = "alarm_ins_security_group"
  vpc_id = aws_vpc.edmm.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "alarm_ins" {
  ami = "ami-0701e7be9b2a77600"
  instance_type = "t2.micro"
  key_name = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.alarm_ins_security_group.id]
  subnet_id = aws_subnet.edmm.id
  connection {
    type  = "ssh"
    user  = var.ssh_user
    agent = true
    private_key = file(var.private_key_path)
    host = self.public_ip
  }
  provisioner "file" {
    source      = "./env.sh"
    destination = "~/env.sh"
  }
}

resource "aws_security_group" "center2_ins_security_group" {
  name = "center2_ins_security_group"
  vpc_id = aws_vpc.edmm.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "center2_ins" {
  ami = "ami-0701e7be9b2a77600"
  instance_type = "t2.micro"
  key_name = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.center2_ins_security_group.id]
  subnet_id = aws_subnet.edmm.id
  connection {
    type  = "ssh"
    user  = var.ssh_user
    agent = true
    private_key = file(var.private_key_path)
    host = self.public_ip
  }
  provisioner "file" {
    source      = "./env.sh"
    destination = "~/env.sh"
  }
}



