locals {
  public-subnets = {
    "subnet-1" = { cidr_block = "10.10.1.0/24", az = "us-east-1a", tag-name = "pub-subnet-1a" },
    "subnet-2" = { cidr_block = "10.10.2.0/24", az = "us-east-1b", tag-name = "pub-subnet-1b" },
    "subnet-3" = { cidr_block = "10.10.3.0/24", az = "us-east-1c", tag-name = "pub-subnet-1c" }
  }

  private-subnets = {
    "subnet-1" = { cidr_block = "10.10.4.0/24", az = "us-east-1d", tag-name = "private-subnet-1d" },
    "subnet-2" = { cidr_block = "10.10.5.0/24", az = "us-east-1e", tag-name = "private-subnet-1e" },
    "subnet-3" = { cidr_block = "10.10.6.0/24", az = "us-east-1f", tag-name = "private-subnet-1f" }
  }
}

module "wordpress_vpc" {
  source   = "../modules/vpc"
  vpc_name = "Wordpress-Vpc"
  cidr_vpc = "10.10.0.0/16"
}

module "wordpress_sg" {
  source          = "../modules/sg"
  sg_name         = "wordpress_sg"
  protocol        = "tcp"
  cidr_block_sg   = ["0.0.0.0/0"]
  vpc_id          = module.wordpress_vpc.vpc_id
  ingress_ports   = [22, 80, 443]
  security_groups = []
  egress_ports    = [0]
  egress_protocol = "-1"
}

module "wordpress_igw" {
  source   = "../modules/igw"
  igw_name = "wordepress_igw"
  vpc_id   = module.wordpress_vpc.vpc_id
}

module "nat_gateway" {
  source    = "../modules/nat-gw"
  subnet_id = module.public-subnet["subnet-1"].subnet_id
  nat_name  = "NAT Gateway - Wordpress"
}

module "worpress_public-rt" {
  source  = "../modules/public-rt"
  vpc_id  = module.wordpress_vpc.vpc_id
  iwg_id  = module.wordpress_igw.igw_id
  cidr_rt = "0.0.0.0/0"
  rt_name = "wordpress-public-rt"
}

module "worpress_private-rt" {
  source  = "../modules/private-rt"
  vpc_id  = module.wordpress_vpc.vpc_id
  nat_id  = module.nat_gateway.nat_id
  cidr_rt = "0.0.0.0/0"
  rt_name = "wordpress-private-rt"
}

module "public-subnet" {
  source           = "../modules/subnet"
  vpc_id           = module.wordpress_vpc.vpc_id
  for_each         = local.public-subnets
  subnet_name      = each.value.tag-name
  cidr_subnet      = each.value.cidr_block
  az               = each.value.az
  assign_public_ip = true
}

module "private-subnet" {
  source      = "../modules/subnet"
  vpc_id      = module.wordpress_vpc.vpc_id
  for_each    = local.private-subnets
  subnet_name = each.value.tag-name
  cidr_subnet = each.value.cidr_block
  az          = each.value.az
}

module "public-route_table_association" {
  source         = "../modules/rt-sub"
  for_each       = module.public-subnet
  subnet_id      = each.value.subnet_id
  route_table_id = module.worpress_public-rt.rt_id
}

module "private-route_table_association" {
  source         = "../modules/rt-sub"
  for_each       = module.private-subnet
  subnet_id      = each.value.subnet_id
  route_table_id = module.worpress_private-rt.rt_id
}

module "rds-sg" {
  source          = "../modules/sg"
  sg_name         = "rds-sg"
  vpc_id          = module.wordpress_vpc.vpc_id
  protocol        = "tcp"
  ingress_ports   = [3306]
  cidr_block_sg   = []
  security_groups = [module.wordpress_sg.sg_id]
  egress_ports    = [0]
  egress_protocol = "-1"
}

module "mysql" {
  source               = "../modules/db"
  db_name              = "wordpress" #DB INDENTIFIER
  db_engine            = "MySQL"
  db_engine_version    = "8.0.35"
  db_storage           = 20
  db_instance_class    = "db.t3.micro"
  username             = "admin"      #Database username can be changed
  password             = "adminadmin" #Database password can be changed
  db_subnet_group_name = "private_subnet-db_name"
  subnet_ids           = [module.private-subnet["subnet-3"].subnet_id, module.private-subnet["subnet-1"].subnet_id, module.private-subnet["subnet-2"].subnet_id]
  security_groups      = [module.rds-sg.sg_id]
  depends_on           = [module.private-subnet]
}

module "worpress-ec2" {
  source          = "../modules/ec2"
  instance_name   = "wordpress-ec2"
  instance_type   = "t2.micro"
  ami_id          = "ami-0fff1b9a61dec8a5f"
  security_groups = [module.wordpress_sg.sg_id]
  subnet_id       = module.public-subnet["subnet-1"].subnet_id
  key_name        = "YOUR KEY NAME"
  key_pair        = "YOUR PUBLIC SSH KEY PAIR"
  user_data = templatefile("wordpress-setup.sh", { #Using Wordpress-setup.sh file to install and configure wordpress 
    db_name      = module.mysql.db_name
    db_username  = module.mysql.username
    db_password  = module.mysql.password
    rds_endpoint = module.mysql.rds_endpoint
  })
  depends_on = [module.mysql]
}

