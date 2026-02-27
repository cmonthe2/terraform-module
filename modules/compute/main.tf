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

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.bastion_instance_type
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [var.bastion_sg_id]
  key_name                    = var.key_pair_name
  associate_public_ip_address = true
  tags                        = { Name = "${var.project_name}-${var.environment}-bastion" }
}

resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids
  tags               = { Name = "${var.project_name}-${var.environment}-alb" }
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
  key_name      = var.key_pair_name

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
        fetch('http://169.254.169.254/latest/meta-data/instance-id').then(r=>r.text()).then(t=>document.getElementById('i').textContent=t);
        fetch('http://169.254.169.254/latest/meta-data/local-ipv4').then(r=>r.text()).then(t=>document.getElementById('ip').textContent=t);
        fetch('http://169.254.169.254/latest/meta-data/placement/availability-zone').then(r=>r.text()).then(t=>document.getElementById('az').textContent=t);
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
