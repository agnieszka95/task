provider "aws" {
  region = "eu-north-1"
}

resource "aws_db_instance" "my_postgres_db" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "14.2"
  instance_class       = "db.t3.micro"
  db_name              = "database"
  username             = "dbuser"
  password             = "password"  
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.my_db_sg.id]
}

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my_db_subnet_group"
  subnet_ids = [/* Subnet IDs  for VPC */]
}

resource "aws_security_group" "my_db_sg" {
  name = "my_db_security_group"
}
