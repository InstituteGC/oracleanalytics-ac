# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "MyVPC"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyIGW"
  }
}

# Create a Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"  # Change this to your desired availability zone
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet"
  }
}

# Create a Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"  # Change this to your desired availability zone
  map_public_ip_on_launch = true

  tags = {
    Name = "PrivateSubnet"
  }
}

# Create a Route Table for the Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

# Associate the Public Subnet with the Public Route Table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create a Security Group
resource "aws_security_group" "mydb_sg" {
  name        = "mydb-sg"
  vpc_id = aws_vpc.my_vpc.id
  description = "Security group for mydb instance"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MyDB-SG"
  }
}

# Create a DB Subnet Group
resource "aws_db_subnet_group" "mydb_subnet_group" {
  name        = "mydb-subnet-group"
  description = "MyDB Subnet Group"
  subnet_ids  = [aws_subnet.private_subnet.id, aws_subnet.public_subnet.id]
}

# Create an RDS DB Instance
resource "aws_db_instance" "mydb" {
  identifier             = "mydb-instance"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  username               = "admin"
  password               = "Password1"
  parameter_group_name   = "default.mysql5.7"
  publicly_accessible    = true
  backup_retention_period = 7
  multi_az               = false

  vpc_security_group_ids = [aws_security_group.mydb_sg.id]
  db_subnet_group_name      = aws_db_subnet_group.mydb_subnet_group.name  # Reference to the subnet group

  tags = {
    Name = "MyDB"
  }
}
