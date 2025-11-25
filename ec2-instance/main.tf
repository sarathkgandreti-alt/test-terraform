resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/26"
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/28"
  tags = {
    Name = "test_subnet"
  }
}

resource "aws_network_interface" "example" {
  subnet_id   = aws_subnet.main.id
  private_ips = ["10.0.1.5"]

  tags = {
    Name = "primary_network_interface"
  }
}


resource "aws_instance" "example" {
  ami           = "ami-0f5fcdfbd140e4ab7" # us-west-2
  instance_type = "t3.micro"

  primary_network_interface {
    network_interface_id = aws_network_interface.example.id
  }

  credit_specification {
    cpu_credits = "standard"
  }
}
