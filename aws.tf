#AWS resources

resource "aws_vpc" "vpc" {
  cidr_block = "192.168.0.0/24"

  tags = {
    "Name" = "bv-vpc"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "192.168.0.0/25"
  availability_zone = "eu-west-2b"
  map_public_ip_on_launch = true
  
  tags = {
    "Name" = "bv-subnet"
  }
}

resource "aws_key_pair" "key" {
  key_name = "bv"
  public_key = file("aws-ssh.pub")
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "bv-vpc"
  }
}

resource "aws_security_group" "ssh" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "security_group_ssh"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "bv-route_table"
  }
}

resource "aws_route" "route" {
    route_table_id = aws_route_table.route_table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id

}

resource "aws_route_table_association" "association" {
  subnet_id = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_instance" "instance" {
  ami = "ami-0fbec3e0504ee1970"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet.id
  key_name = aws_key_pair.key.key_name
  vpc_security_group_ids = [ aws_security_group.ssh.id ]

  tags = {
    "Name" = "bv-instance"
  }
}