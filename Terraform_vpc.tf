Create Folder VPC_Projectjiem
Run Below Command First----
mkdir vpc-project
cd vpc-project/
vim vpc.tf
# Configure the AWS Provider
provider "aws" {
  region     = "us-west-2"
  access_key = "abcdefghijklm145"
  secret_key = "541adcdfrgt52ubjsacnklkvn"
}

#Create VPC 
resource "aws_vpc" "jiemvpc" {
  cidr_block       = "172.20.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "jiem"
  }
}

#Create Public Subnet
resource "aws_subnet" "Public-subnet" {
  vpc_id     = aws_vpc.Jiemvpc.id
  cidr_block = "172.20.10.0/24"

  tags = {
    Name = "Public-subnet"
  }
}

#Create Private Subnet
resource "aws_subnet" "Private-subnet" {
  vpc_id     = aws_vpc.Jiemvpc.id
  cidr_block = "172.20.20.0/24"

  tags = {
    Name = "Private-subnet"
  }
}

#Create Security Group
resource "aws_security_group" "cloudjiemsg" {
  name        = " cloudjiemsg "
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.jiemvpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [“0.0.0.0/0”]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jiem_SG"
  }
}

#Create IGW
resource "aws_internet_gateway" "jiem-igw" {
  vpc_id = aws_vpc.jiemvpc.id

  tags = {
    Name = "jiem-igw"
  }
}

#Create Route Table(public)
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.jiemvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jiem-igw.id
  }

  
  tags = {
    Name = "public-rt"
  }
}

#Create Route Table(Private)

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.jiemvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = “aws_nat_gateway.jiem-nat.id”

  }

  
  tags = {
    Name = "private-rt"
  }
}

#Create Route Table Association(Private)
resource "aws_route_table_association" "private-asso" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}

#Create Route Table Association(Public)
resource "aws_route_table_association" "public-asso" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

#Before that we Create Key
Command-----
#Ssh-keygen    (Gen Key)
 #jiemkey     (keyName)

resource "aws_key_pair" "jiemkey" {
  key_name   = "jiem-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

Note—here go to key and Copy that public key pate here.
#Create Instance (Public and Private )
resource "aws_instance" "jiem-instance" {
  ami           = “ami-04d29b6966df1535” (go to ec2 and Choose which ami you have)
  instance_type = "t2.micro"
  subnet-id = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws-security_group.jiemsg.id]
  key_name = “jiemkey”

  tags = {
    Name = "jiemIndia"
  }
}

resource "aws_instance" "jiemdb-instance" {
  ami           = “ami-04d29b6966df1535” (go to ec2 and Choose which ami you have)
  instance_type = "t2.micro"
  subnet-id = aws_subnet.private-subnet.id
  vpc_security_group_ids = [aws-security_group.jiemsg.id]
  key_name = “jiemkey”

  tags = {
    Name = "jiemdbIndia"
  }
}

#Create EIP
resource "aws_eip" "jiem-ip" {
  instance = aws_instance. jiem-instance.id
  vpc      = true
}

#Create Public IP

resource "aws_eip" "jiem-natip" {
  vpc      = true
}

#Create Nat Gateway
resource "aws_nat_gateway" "jiem-nat" {
  allocation_id = aws_eip. jiem-natip.id
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "jiem NAT"
  }




