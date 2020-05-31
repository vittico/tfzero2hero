provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.200.0.0/16"

  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name     = "Main Test VPC"
    Ambiente = "Globant Cloud Academy"
    Meta     = "Creado con Terraform"
  }

}


resource "aws_default_route_table" "rt" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id


  tags = {
    Name     = "MAIN VPC - RT"
    Ambiente = "Globant Cloud Academy"
    Meta     = "Creado con Terraform"
  }

}



resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol    = -1
    self        = true
    from_port   = 0
    to_port     = 0
    description = "This vpc default sg"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name     = "MAIN VPC - DEFAULT - SG"
    Ambiente = "Globant Cloud Academy"
    Meta     = "Creado con Terraform"
  }


}


resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.vpc.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  lifecycle {
    ignore_changes = [subnet_ids]
  }

  tags = {
    Name     = "MAIN VPC - NACL"
    Ambiente = "Globant Cloud Academy"
    Meta     = "Creado con Terraform"
  }

}

## Subnets

data "aws_availability_zones" "available" {
  state = "available"
}


resource "aws_subnet" "pub-subnets" {
  count             = 3
  cidr_block        = [{ block = "10.200.0.0/24" }, { block = "10.200.1.0/24" }, { block = "10.200.2.0/24" }][count.index].block
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.vpc.id

  tags = {
    Name     = "TEST_VPC_PUB-0${count.index}"
    Ambiente = "Globant Cloud Academy"
    Meta     = "Creado con Terraform"
  }

}

resource "aws_subnet" "priv-subnets" {
  count             = 3
  cidr_block        = [{ block = "10.200.4.0/24" }, { block = "10.200.5.0/24" }, { block = "10.200.6.0/24" }][count.index].block
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.vpc.id

  tags = {
    Name     = "TEST_VPC_PRI-0${count.index}"
    Ambiente = "Globant Cloud Academy"
    Meta     = "Creado con Terraform"
  }

}

// Salida subnets publicas
resource "aws_internet_gateway" "vpcigw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name     = "Main VPC - IGW"
    Ambiente = "Globant Cloud Academy"
    Meta     = "Creado con Terraform"
  }
}

resource "aws_route_table" "igwrt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpcigw.id
  }

  tags = {
    Name     = "MAIN VCP - IGW RT"
    Ambiente = "Globant Cloud Academy"
    Meta     = "Creado con Terraform"
  }
}

resource "aws_route_table_association" "igwrt-assoc" {
  count          = 3
  route_table_id = aws_route_table.igwrt.id
  subnet_id      = aws_subnet.pub-subnets[count.index].id

}


resource "aws_eip" "natgwip" {
  count = 3

  tags = {
    Name     = "Main VPC - NATGW EIP"
    Ambiente = "Globant Cloud Academy"
    Meta     = "Creado con Terraform"
  }
}

resource "aws_nat_gateway" "natgw" {
  count         = 3
  allocation_id = aws_eip.natgwip[count.index].id
  subnet_id     = aws_subnet.pub-subnets[count.index].id

  tags = {
    Name     = "MAIN VPC - NATGW 0${count.index}"
    Ambiente = "Globant Cloud Academy"
    Meta     = "Creado con Terraform"
  }
}


resource "aws_route_table" "natgwrt" {
  count  = 3
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw[count.index].id
  }

  tags = {
    Name     = "Main VPC - NATGW RT 0${count.index}"
    Ambiente = "Globant Cloud Academy"
    Meta     = "Creado con Terraform"
  }
}

resource "aws_route_table_association" "natrt-assoc" {
  count          = 3
  route_table_id = aws_route_table.natgwrt[count.index].id
  subnet_id      = aws_subnet.priv-subnets[count.index].id
}






