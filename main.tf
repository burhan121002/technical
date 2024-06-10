provider "aws" {
  region = "us-west-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

variable "aws_access_key" {}
variable "aws_secret_key" {}

resource "aws_s3_bucket" "bucket" {
  bucket = "my-s3-bucket"
}

resource "aws_rds_instance" "db" {
  allocated_storage    = 10
  engine               = "postgres"
  engine_version       = "12.3"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "admin"
  password             = "password"
  parameter_group_name = "default.postgres12"
  skip_final_snapshot  = true
}

resource "aws_ecr_repository" "repo" {
  name = "my-repo"
}

resource "aws_lambda_function" "my_lambda" {
  function_name = "my_lambda_function"
  role          = aws_iam_role.iam_for_lambda.arn
  image_uri     = "${aws_ecr_repository.repo.repository_url}:latest"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
