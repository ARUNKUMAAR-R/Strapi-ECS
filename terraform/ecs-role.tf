resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role-strapi"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  # Attach policies for ECS task execution and CloudWatch Logs
  inline_policy {
    name = "ecs_task_execution_policy"

    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "ecs:RunTask",
            "ecs:StopTask",
            "ecs:DescribeTasks",
            "ecs:ListTasks",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:PutRetentionPolicy"
          ],
          Resource = "*"
        }
      ]
    })
  }
}

# Attach Amazon ECS managed policy for task execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

