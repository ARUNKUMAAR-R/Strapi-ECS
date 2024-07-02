resource "aws_ecs_cluster" "strapi_cluster" {
  name = "strapi-cluster"
}


resource "aws_ecs_task_definition" "strapi" {
  family                   = "strapi"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"

  container_definitions = jsonencode([
    {
      name      = "strapi-db"
      image     = "arunrascall/strapi-postgres:development"
      essential = true
      environment = [
        {
          name  = "POSTGRES_DB"
          value = "strapi"
        },
        {
          name  = "POSTGRES_USER"
          value = "strapi_user"
        },
        {
          name  = "POSTGRES_PASSWORD"
          value = "strapi_password"
        }
      ],
      portMappings = [
        {
          containerPort = 5432
          protocol      = "tcp"
        }
      ]
    },
    {
      name      = "strapi-server"
      image     = "arunrascall/strapi:development1" # Replace with your Docker image if it's different
      essential = true
      dependsOn = [{
        containerName = "strapi-db"
        condition     = "START"
      }],
      environment = [
        {
          name  = "DATABASE_CLIENT"
          value = "postgres"
        },
        {
          name  = "DATABASE_HOST"
          value = "localhost"
        },
        {
          name  = "DATABASE_PORT"
          value = "5432"
        },
        {
          name  = "DATABASE_NAME"
          value = "strapi"
        },
        {
          name  = "DATABASE_USERNAME"
          value = "strapi_user"
        },
        {
          name  = "DATABASE_PASSWORD"
          value = "strapi_password"
        }
      ],
      portMappings = [
        {
          containerPort = 1337
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "strapi_service" {
  name            = "strapi-service"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_subnet1.id]
    security_groups  = [aws_security_group.strapi-sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.strapi_tg.arn
    container_name   = "strapi-server"
    container_port   = 1337
  }

}

resource "aws_lb" "strapi_lb" {
  name               = "strapi-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.strapi-sg.id]
  subnets            = [aws_subnet.public_subnet1.id,aws_subnet.public_subnet2.id] # Replace with your subnets
}

resource "aws_lb_target_group" "strapi_tg" {


  name     = "strapi-target-group"
  port     = 1337
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.strapi_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi_tg.arn
  }
}
