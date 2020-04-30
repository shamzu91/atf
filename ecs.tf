#cluster

resource "aws_ecs_cluster" "testapp-cluster" {
  name = "testapp-cluster"
}

resource "aws_launch_configuration" "ecs-testapp-launchconfig" {
  name_prefix          = "ecs-launchconfig"
  image_id             = var.ECS_AMIS[var.AWS_REGION]
  instance_type        = var.ECS_INSTANCE_TYPE
  key_name             = aws_key_pair.mykeypair.key_name
  iam_instance_profile = aws_iam_instance_profile.ecs-ec2-role.id
  security_groups      = [aws_security_group.ecs-securitygroup.id]
  user_data            = "#!/bin/bash\necho 'ECS_CLUSTER=testapp-cluster' > /etc/ecs/ecs.config\nstart ecs"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs-testapp-autoscaling" {
  name                 = "ecs-testapp-autoscaling"
  vpc_zone_identifier  = [aws_subnet.testapp-public-1.id, aws_subnet.testapp-public-2.id]
  launch_configuration = aws_launch_configuration.ecs-testapp-launchconfig.name
  min_size             = 1
  max_size             = 1
  tag {
    key                 = "Name"
    value               = "ecs-ec2-container"
    propagate_at_launch = true
  }
}