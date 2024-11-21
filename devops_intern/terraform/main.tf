### Networking ###

# Create a VPC
resource "aws_vpc" "aa_vpc_1" {
  cidr_block = "10.0.0.0/16"
}

# Create public subnets
resource "aws_subnet" "aa_subnet_1" {
  vpc_id                  = aws_vpc.aa_vpc_1.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "aa_subnet_2" {
  vpc_id                  = aws_vpc.aa_vpc_1.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

# Gateway
resource "aws_internet_gateway" "aa_gw" {
  vpc_id = aws_vpc.aa_vpc_1.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.aa_vpc_1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aa_gw.id
  }
}

resource "aws_route_table_association" "aa_subnet_1" {
  subnet_id      = aws_subnet.aa_subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "aa_subnet_2" {
  subnet_id      = aws_subnet.aa_subnet_2.id
  route_table_id = aws_route_table.public.id
}

### Security Groups ###

# Load Balancer Security Group
resource "aws_security_group" "lb_sg" {
  name        = "lb_sg"
  description = "ALB App Security Group"
  vpc_id      = aws_vpc.aa_vpc_1.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "EC2 App Servers Security Group"
  vpc_id      = aws_vpc.aa_vpc_1.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    description     = "Allow HTTP Traffic from Load Balancer"
    security_groups = [aws_security_group.lb_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "SSH from Everywhere" # Open to the world to facilitate testing - Not recommended for production
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### EC2 ###

# Key Pair
resource "aws_key_pair" "aa_key_pair" {
  key_name   = "aa_key_pair"
  public_key = file("~/.ssh/aa_id_rsa.pub")
}

# EC2 Instances
resource "aws_instance" "aa_ec2_1" {
  ami             = "ami-012967cc5a8c9f891" # Amazon Linux 2 AMI
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.aa_key_pair.key_name
  subnet_id       = aws_subnet.aa_subnet_1.id
  security_groups = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "AppInstance1"
  }
}

resource "aws_instance" "aa_ec2_2" {
  ami             = "ami-012967cc5a8c9f891" # Amazon Linux 2 AMI
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.aa_key_pair.key_name
  subnet_id       = aws_subnet.aa_subnet_2.id
  security_groups = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "AppInstance2"
  }
}

### Application Load Balancer ###

# ALB
resource "aws_lb" "aa_lb" {
  name               = "aa-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.aa_subnet_1.id, aws_subnet.aa_subnet_2.id]
}

# ALB Target Group
resource "aws_lb_target_group" "aa_tg" {
  name     = "aa-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.aa_vpc_1.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "80"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 4
    interval            = 10
  }
}

# ALB Listener
resource "aws_lb_listener" "aa_listener" {
  load_balancer_arn = aws_lb.aa_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aa_tg.arn
  }
}

# ALB Target Group Attachments
resource "aws_lb_target_group_attachment" "aa_tg_attachment_1" {
  target_group_arn = aws_lb_target_group.aa_tg.arn
  target_id        = aws_instance.aa_ec2_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "aa_tg_attachment_2" {
  target_group_arn = aws_lb_target_group.aa_tg.arn
  target_id        = aws_instance.aa_ec2_2.id
  port             = 80
}