# Create ALB security group
resource "aws_security_group" "alb-sg" {
  name        = "alb_security_group"
  description = "ALB security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "Allow HTTP traffice from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb_security_group"
  }
}

# Create an ALB
resource "aws_alb" "alb" {
  name               = "apache-alb"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets         = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id, aws_subnet.public_subnet_3.id]
  #subnets            = [for subnet in aws_subnet.public : subnet.id]

}

resource "aws_alb_target_group" "alb-tg" {
  name        = "apache-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id

  health_check {
    path = "/" # root path
    port = 80
  }
}

# Create ALB listener
resource "aws_alb_listener" "http_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.alb-tg.arn
    type = "forward"
  }
}

# resource "aws_lb_target_group_attachment" "alb-tg" {
#   target_group_arn = aws_lb_target_group.alb-tg.arn
#   target_id        = aws_instance.alb-tg.id
#   port             = 80
# }
