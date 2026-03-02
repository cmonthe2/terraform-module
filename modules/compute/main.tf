data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM Role for EC2 instances — SSM needs this to register with the service
resource "aws_iam_role" "app" {
  name = "${var.project_name}-${var.environment}-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# Attach SSM managed policy — this is what allows Session Manager to work
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance profile — wraps the IAM role so EC2 can use it
resource "aws_iam_instance_profile" "app" {
  name = "${var.project_name}-${var.environment}-app-profile"
  role = aws_iam_role.app.name
}

resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids
  tags = { Name = "${var.project_name}-${var.environment}-alb" }
}

resource "aws_lb_target_group" "app" {
  name     = "${var.project_name}-${var.environment}-tg-app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    matcher             = "200"
  }
  tags = { Name = "${var.project_name}-${var.environment}-tg-app" }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-${var.environment}-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  # No key_name — SSM replaces SSH entirely

  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }

  # IMDSv2 — security best practice
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.app_sg_id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd

    cat > /var/www/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html>
    <head><title>3-Tier VPC</title></head>
    <body style="font-family:monospace;padding:40px;background:#1a1a2e;color:#e0e0e0">
      <h1 style="color:#00d4ff">✅ 3-Tier VPC App</h1>
      <p>Instance: <strong id="i">...</strong></p>
      <p>Private IP: <strong id="ip">...</strong></p>
      <p>AZ: <strong id="az">...</strong></p>
      <p style="color:#888">Internet → WAF → IGW → ALB → This EC2 (private subnet)</p>
      <script>
        // Using IMDSv2 — requires token first
        fetch('http://169.254.169.254/latest/api/token', {
          method: 'PUT',
          headers: { 'X-aws-ec2-metadata-token-ttl-seconds': '21600' }
        })
        .then(r => r.text())
        .then(token => {
          const h = { 'X-aws-ec2-metadata-token': token };
          fetch('http://169.254.169.254/latest/meta-data/instance-id', { headers: h }).then(r=>r.text()).then(t=>document.getElementById('i').textContent=t);
          fetch('http://169.254.169.254/latest/meta-data/local-ipv4', { headers: h }).then(r=>r.text()).then(t=>document.getElementById('ip').textContent=t);
          fetch('http://169.254.169.254/latest/meta-data/placement/availability-zone', { headers: h }).then(r=>r.text()).then(t=>document.getElementById('az').textContent=t);
        });
      </script>
    </body></html>
    HTML

    echo "OK" > /var/www/html/health
    systemctl start httpd
    systemctl enable httpd
  EOF
  )

  lifecycle { create_before_destroy = true }
}

resource "aws_autoscaling_group" "app" {
  name                = "${var.project_name}-${var.environment}-asg"
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity
  vpc_zone_identifier = var.private_app_subnet_ids
  target_group_arns   = [aws_lb_target_group.app.arn]
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-app"
    propagate_at_launch = true
  }
}