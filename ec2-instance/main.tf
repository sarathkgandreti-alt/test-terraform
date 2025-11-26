# ===== VPC1 - Linux Instance =====
resource "aws_vpc" "vpc1" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "VPC1"
  }
}

resource "aws_subnet" "subnet1" {    
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet1"
  }
}

# Security Group for Linux (VPC1)
resource "aws_security_group" "sg_vpc1" {
  name        = "sg-vpc1-linux"
  description = "Security group for Linux instance in VPC1"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-vpc1"
  }
}

# Linux Instance (Amazon Linux 2) in VPC1
resource "aws_instance" "linux_instance" {
  ami                         = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 in us-east-2
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet1.id
  vpc_security_group_ids      = [aws_security_group.sg_vpc1.id]
  associate_public_ip_address = true

  tags = {
    Name = "Linux-Instance"
  }
}

# ===== VPC2 - Windows Instance =====
resource "aws_vpc" "vpc2" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "VPC2"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.vpc2.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet2"
  }
}

# Security Group for Windows (VPC2)
resource "aws_security_group" "sg_vpc2" {
  name        = "sg-vpc2-windows"
  description = "Security group for Windows instance in VPC2"
  vpc_id      = aws_vpc.vpc2.id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5985
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Allow from VPC1
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-vpc2"
  }
}

# Windows Instance in VPC2
resource "aws_instance" "windows_instance" {
  ami                         = "ami-0bb3fad3c0286ebd5" # Windows Server 2019 Base in us-east-2
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet2.id
  vpc_security_group_ids      = [aws_security_group.sg_vpc2.id]
  associate_public_ip_address = true

  tags = {
    Name = "Windows-Instance"
  }
}

# ===== VPC Peering =====
resource "aws_vpc_peering_connection" "peering" {
  vpc_id      = aws_vpc.vpc1.id
  peer_vpc_id = aws_vpc.vpc2.id
  auto_accept = false

  tags = {
    Name = "vpc1-vpc2-peering"
  }
}

resource "aws_vpc_peering_connection_accepter" "accepter" {
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  auto_accept               = true

  tags = {
    Name = "vpc1-vpc2-peering-accepter"
  }
}

# ===== Route Tables =====
resource "aws_route_table" "route_table_vpc1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "rt-vpc1"
  }
}

resource "aws_route_table" "route_table_vpc2" {
  vpc_id = aws_vpc.vpc2.id

  tags = {
    Name = "rt-vpc2"
  }
}

# Associate subnets with route tables
resource "aws_route_table_association" "vpc1_association" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.route_table_vpc1.id
}

resource "aws_route_table_association" "vpc2_association" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.route_table_vpc2.id
}

# Routes for peering
resource "aws_route" "route_to_vpc2" {
  route_table_id            = aws_route_table.route_table_vpc1.id
  destination_cidr_block    = aws_vpc.vpc2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}

resource "aws_route" "route_to_vpc1" {
  route_table_id            = aws_route_table.route_table_vpc2.id
  destination_cidr_block    = aws_vpc.vpc1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}


