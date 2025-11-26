resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "VPC1"
  }
}

resource "aws_subnet" "subnet1" {    
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2"
  tags = {
    Name = "test_subnet"
  }
}


# Define VPC2 resources
resource "aws_vpc" "vpc2" {
  cidr_block = "10.1.0.0/16"  # Specify CIDR block for VPC2
  tags = {
    Name = "VPC2"
  }
}
resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.vpc2.id
  cidr_block = "10.1.1.0/24"  # Specify CIDR block for Subnet1 in VPC2
  availability_zone = "us-east-2"  # Specify availability zone
}

# Create VPC peering connection
resource "aws_vpc_peering_connection" "peering" {
  vpc_id = aws_vpc.vpc1.id  # Specify requester VPC
  peer_vpc_id = aws_vpc.vpc2.id  # Specify accepter VPC
  auto_accept = false  # Specify if the peering connection should be automatically accepted
}
# Accept VPC peering connection on accepter side
provider "aws" {
  alias  = "accepter"
  region = "us-east-2"  # Specify the region where the VPC peering connection exists
}
resource "aws_vpc_peering_connection_accepter" "accepter" {
  provider = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}


# Update route tables
resource "aws_route_table" "route_table_vpc1" {
  vpc_id = aws_vpc.vpc1.id
}
resource "aws_route_table" "route_table_vpc2" {
  vpc_id = aws_vpc.vpc2.id
}
resource "aws_route" "route_to_vpc2" {
  route_table_id            = aws_route_table.route_table_vpc1.id  # Specify route table ID of VPC1
  destination_cidr_block    = aws_vpc.vpc2.cidr_block  # CIDR block of VPC2
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id  # Specify peering connection ID
}
resource "aws_route" "route_to_vpc1" {
  route_table_id            = aws_route_table.route_table_vpc2.id  # Specify route table ID of VPC2
  destination_cidr_block    = aws_vpc.vpc1.cidr_block  # CIDR block of VPC1
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id  # Specify peering connection ID
}


