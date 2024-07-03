resource "aws_cloudwatch_log_group" "strapi_db" {
  name              = "awslogs-strapi"
  retention_in_days = 30
  
}

resource "aws_cloudwatch_log_group" "strapi_server" {
  name              = "awslogs-strapi"
  retention_in_days = 30
  depends_on        = [aws_cloudwatch_log_group.strapi_db]
}

resource "aws_cloudwatch_log_group" "strapi_nginx" {
  name              = "awslogs-strapi"
  retention_in_days = 30
  depends_on        = [aws_cloudwatch_log_group.strapi_server]

}
