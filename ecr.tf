
provider "aws" {
  region = var.AWS_REGION
}

#ECR

resource "aws_ecr_repository" "testapp" {
  name = "testapp"
}

#RDS

resource "aws_db_subnet_group" "db-subnet" {
  name        = "db-subnet"
  description = "RDS subnet group"
  subnet_ids  = [aws_subnet.testapp-private-1.id, aws_subnet.testapp-private-2.id]
}

resource "aws_db_parameter_group" "db-parameters" {
  name        = "db-parameters"
  family      = "mysql5.7"
  description = "DB parameter group"

  parameter {
    name  = "max_allowed_packet"
    value = "16777216"
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage       = 20 # 100 GB of storage, gives us more IOPS than a lower number
  engine                  = "mysql"
  engine_version          = "5.7.19"
  instance_class          = "db.t2.micro" # use micro if you want to use the free tier
  identifier              = "mysql"
  name                    = "mysql"
  username                = "panda"           # username
  password                = var.RDS_PASSWORD # password
  db_subnet_group_name    = aws_db_subnet_group.db-subnet.name
  parameter_group_name    = aws_db_parameter_group.db-parameters.name
  multi_az                = "false" # set to true to have high availability: 2 instances synchronized with each other
  vpc_security_group_ids  = [aws_security_group.allow-db.id]
  storage_type            = "gp2"
  backup_retention_period = 0                                         # how long you’re going to keep your backups
  availability_zone       = aws_subnet.testapp-private-1.availability_zone # prefered AZ
  skip_final_snapshot     = true                                        # skip final snapshot when doing terraform destroy
  tags = {
    Name = "db-instance"
  }
}