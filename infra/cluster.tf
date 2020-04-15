resource "aws_ecs_cluster" "main-cluster" {
  name = "${var.cluster_name}-cluster"
}

resource "aws_launch_template" "launch-config" {
  name_prefix   = var.cluster_name
  image_id      = "ami-1a2b3c"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "cluster-node-group" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = "${aws_launch_template.launch-config.id}"
    version = "$Latest"
  }
}

resource "aws_ecs_capacity_provider" "cluster-capacity" {
  name = "cluster-capacity"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.cluster-node-group.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      # Min/max of containers that can be scaled at a time
      maximum_scaling_step_size = 10
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 90
    }
  }
}