provider "aws" {
  region     = "us-east-1"
  access_key = "<Here was your access key>"
  secret_key = "<Here was your secret key>"
}


/*1. Create vpc*/
resource "aws_vpc" "prod_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "production"
  }
}

/*2. Create internet gateway*/
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name = "main"
  }
}

/*3. Create custom route tables*/
resource "aws_route_table" "prod_route_table" {
  vpc_id = aws_vpc.prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "prod"
  }
}

/*4. Create subnet*/
resource "aws_subnet" "subnet_1" {
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "prod_subnet"
  }
}

/*5. Associate subnet with Route Table*/
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.prod_route_table.id
}


/*6. Create Security group to allow port 22,80,443*/
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    description = "HTTPS"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
        ingress {
    description = "HTTP"
    from_port   = 4243
    to_port     = 4243
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
      ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 
  ingress {
    description = "HTTP"
    from_port   = 9091
    to_port     = 9091
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 
    ingress {
    description = "HTTPS"
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
      ingress {
    description = "SSH"
    from_port   = 32768
    to_port     = 60999
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 
  # ingress {
  #   description = "All ports is open (ingress)"
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  egress {
    description = "All ports is open (egress)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

/*7. Create a network interface with an ip in the subnet that was created in step 4*/
resource "aws_network_interface" "web_server" {
  subnet_id       = aws_subnet.subnet_1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

  /*attachment {
    instance     = aws_instance.test.id
    device_index = 1
  }*/
}

/*8. Assign an elastic IP to the network created in step7*/
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web_server.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw]
}

/*9. Create instance*/
resource "aws_instance" "example_instance" {
  ami               = "ami-00874d747dde814fa"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "for_terra"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web_server.id
  }
  user_data = file("user_data.sh")

  
  root_block_device {
    volume_size = 10
  }
  /*"JinD_master" = jenkins in docker*/
  tags = {
    Name  = "JinD_master"
    Owner = "Olchedai_Oleksii"
  }
}
/*-----------------------------------------------*/
/*10. Create instance*/
resource "aws_instance" "example_instance_second" {
  ami               = "ami-00874d747dde814fa"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "for_terra"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web_server2.id
  }
  user_data = file("target_setup.sh")

  
  root_block_device {
    volume_size = 10
  }
  /*"JinD_master" = jenkins in docker*/
  tags = {
    Name  = "Target_server"
    Owner = "Olchedai_Oleksii"
  }
}


/*11(7). Create a network interface with an ip in the subnet that was created in step 4*/
resource "aws_network_interface" "web_server2" {
  subnet_id       = aws_subnet.subnet_1.id
  private_ips     = ["10.0.1.51"]
  security_groups = [aws_security_group.allow_web.id]
}

/*12(8). Assign an elastic IP to the network created in step7*/
resource "aws_eip" "two" {
  vpc                       = true
  network_interface         = aws_network_interface.web_server2.id
  associate_with_private_ip = "10.0.1.51"
  depends_on                = [aws_internet_gateway.gw]
}




