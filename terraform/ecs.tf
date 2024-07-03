resource "aws_ecs_cluster" "strapi_cluster" {
  name = "strapi-cluster"
}


resource "aws_ecs_task_definition" "strapi" {
  family                   = "strapi"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = "4096"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
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
      ],
      logConfiguration : {
        logDriver = "awslogs",
        options = {
          #awslogs-create-group  = "true",
          awslogs-group         = aws_cloudwatch_log_group.strapi_db.name,
          awslogs-region        = "ap-northeast-1",
          awslogs-stream-prefix = "awslogs-db"
        }
      }
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
      logConfiguration : {
        logDriver = "awslogs",
        options = {
          #awslogs-create-group  = "true",
          awslogs-group         = aws_cloudwatch_log_group.strapi_server.name,
          awslogs-region        = "ap-northeast-1",
          awslogs-stream-prefix = "awslogs-strapi1"
        }
      }
    },
    {
      name      = "strapi-nginx"
      image     = "arunrascall/strapi-nginx:development"
      essential = true
      dependsOn = [{
        containerName = "strapi-server"
        condition     = "START"
      }],
      portMappings = [
        {
          containerPort = 443
          protocol      = "tcp"
        },

        {
          containerPort = 80
          protocol      = "tcp"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          #awslogs-create-group  = "true",
          awslogs-group         = aws_cloudwatch_log_group.strapi_nginx.name,
          awslogs-region        = "ap-northeast-1",
          awslogs-stream-prefix = "awslogs-nginx"
        }
      }
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

}
