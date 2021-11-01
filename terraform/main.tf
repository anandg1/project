#########################################################################################################
#  Creating VPC 
#########################################################################################################

resource "aws_vpc" "vpc01"{

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
          Name = "${var.project_name}-vpc"
 }

}

#########################################################################################################
#  Listing the available AWS Availability Zones within the region configured
#########################################################################################################

data "aws_availability_zones" "az" {

state = "available"

}

#########################################################################################################
#  Creating Internet Gateway
#########################################################################################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc01.id
  tags = {
           Name = "${var.project_name}-igw"
  }
}

#########################################################################################################
#  Creating 3 public subnets
#########################################################################################################
resource "aws_subnet" "pub1" {

  vpc_id = aws_vpc.vpc01.id
  map_public_ip_on_launch = true
  cidr_block = cidrsubnet(var.vpc_cidr , var.subnet_bit , 0)
  availability_zone = data.aws_availability_zones.az.names[0]
  tags = {
          Name = "${var.project_name}-pub1"
 }
}

resource "aws_subnet" "pub2" {

  vpc_id = aws_vpc.vpc01.id
  map_public_ip_on_launch = true
  cidr_block = cidrsubnet(var.vpc_cidr , var.subnet_bit , 1)
  availability_zone = data.aws_availability_zones.az.names[1]
  tags = {
          Name = "${var.project_name}-pub2"
 }
}

resource "aws_subnet" "pub3" {

  vpc_id = aws_vpc.vpc01.id
  map_public_ip_on_launch = true
  cidr_block = cidrsubnet(var.vpc_cidr , var.subnet_bit , 2)
  availability_zone = data.aws_availability_zones.az.names[0]
  tags = {
          Name = "${var.project_name}-pub3"
 }
}

#########################################################################################################
# Elastic IP creation
#########################################################################################################

resource "aws_eip" "elastic_ip" {
  vpc      = true
  tags     = {
              Name = "${var.project_name}-elastic-ip"
 }
}

#########################################################################################################
# Creating route table
#########################################################################################################

resource "aws_route_table" "rt_public" {

  vpc_id= aws_vpc.vpc01.id
  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
       }
        tags = {
                Name = "${var.project_name}-public-rt"
 }
}

#########################################################################################################
#  Creating an association between a route table and a subnet
#########################################################################################################

resource "aws_route_table_association" "public_asso1" {

  subnet_id      = aws_subnet.pub1.id
  route_table_id = aws_route_table.rt_public.id
}


resource "aws_route_table_association" "public_asso2" {

  subnet_id      = aws_subnet.pub2.id
  route_table_id = aws_route_table.rt_public.id
}


resource "aws_route_table_association" "public_asso3" {

  subnet_id      = aws_subnet.pub3.id
  route_table_id = aws_route_table.rt_public.id
}

#########################################################################################################
# Key pair Creation from local key file
#########################################################################################################

resource "aws_key_pair" "tfkey" {

  key_name   = "tfkey"
  public_key = file("tfkey.pub")
  tags       = {
  Name = "keyfile"
  }
}

#########################################################################################################
# Creating Security groups for the 3 instances
#########################################################################################################


resource "aws_security_group" "webserver" {

  name        = "${var.project_name}-webserver"
  description = "allow 22,80,443 from outside"
  vpc_id      =  aws_vpc.vpc01.id

  ingress  {

      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

  ingress  {

      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

  ingress  {

      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

  egress  {

      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
      tags = {
    Name = "${var.project_name}-webserver-sec"
  }
}

resource "aws_security_group" "database" {

  name        = "${var.project_name}-database"
  description = "3306 ans 22 open"
  vpc_id      =  aws_vpc.vpc01.id

  ingress  {

      from_port        = 3306
      to_port          = 3306
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

   ingress  {

      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  egress  {

      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }


  tags = {
    Name = "${var.project_name}-database-sec"
  }
}

resource "aws_security_group" "flaskapp" {

  name        = "${var.project_name}-flaskapp"
  description = " Ports 5000 and 22 open"
  vpc_id      =  aws_vpc.vpc01.id

  ingress  {

      from_port        = 5000
      to_port          = 5000
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

   ingress  {

      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  egress  {

      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }


  tags = {
    Name = "${var.project_name}-database-sec"
  }
}

#########################################################################################################
# Creating instance for webserver
#########################################################################################################

resource "aws_instance" "webserver-instance" {
  ami                         = var.ami
  instance_type               = var.type
  subnet_id                   = aws_subnet.pub1.id
  key_name                    = aws_key_pair.tfkey.id
  vpc_security_group_ids      = [aws_security_group.webserver.id]
  tags = {
    Name = "${var.project_name}-webserver"
  }
}

#########################################################################################################
# Associating elastic IP with webserver instance
#########################################################################################################

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.webserver-instance.id
  allocation_id = aws_eip.elastic_ip.id
}

#########################################################################################################
# Creating instance for Database
#########################################################################################################


resource "aws_instance" "database-instance" {
  ami                         = var.ami
  instance_type               = var.type
  subnet_id                   = aws_subnet.pub3.id
  key_name                    = aws_key_pair.tfkey.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.database.id]
  tags = {
    Name = "${var.project_name}-database"
  }
}

#########################################################################################################
# Creating instance for FlaskApp
#########################################################################################################

resource "aws_instance" "flaskapp-instance" {
  ami                         = var.ami
  instance_type               = var.type
  subnet_id                   = aws_subnet.pub2.id
  key_name                    = aws_key_pair.tfkey.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.flaskapp.id]
  tags = {
    Name = "${var.project_name}-flaskapp"
  }
}

#########################################################################################################
# Getting IPs as Output values
#########################################################################################################


output "public_ip_web" {

value = aws_eip.elastic_ip.public_ip
description = "The public IP of the web server"

}



output "public_ip_db" {

value = aws_instance.database-instance.public_ip

description = "The public IP of the database server"

}

output "public_ip_flask" {
  value = aws_instance.flaskapp-instance.public_ip
  description = "The public IP of the flask app"
}


output "private_ip_flask" {
  value = aws_instance.flaskapp-instance.private_ip
  description = "The public IP of the flask app"
}
