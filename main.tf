provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "Dev-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Development-vpc"
  }
}
resource "aws_subnet" "public-subnet" {
    vpc_id = aws_vpc.Dev-vpc.id
    cidr_block = "10.0.10.0/24"
    availability_zone = "us-east-1a"
    tags = {
      Name = "public subnet"
    }
}
resource "aws_internet_gateway" "my-internet-gateway" {
    vpc_id = aws_vpc.Dev-vpc.id
    tags = {
      Name = "my-internet-gateway"
    }
  
}
# Create a routing table
resource "aws_route_table" "rt-public-subnet" {
  vpc_id = aws_vpc.Dev-vpc.id
  tags = {
    Name = "my-routing-table"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-internet-gateway.id
  }
}
resource "aws_route_table_association" "rt-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.rt-public-subnet.id
}

resource "aws_security_group" "myapp-sg" {
    name = "myapp-sg"
    vpc_id = aws_vpc.Dev-vpc.id
    tags = {
      Name = "app-sg"
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

 
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ngnix-ec2" {
  ami = "ami-02f3f602d23f1659d"
  instance_type = "t2.micro"              # Change to your preferred instance type
  key_name      = "general key"
  subnet_id = aws_subnet.public-subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]
  tags = {
    Name = "ngnix-instance"
  }
 
}

