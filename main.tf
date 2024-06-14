provider "aws" {
  region = "ap-south-1"  # Replace with your desired AWS region
}

# Variables
variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "654654311847"  # Replace with your AWS Account ID
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1"  # Replace with your desired AWS region
}

variable "image_tag" {
  description = "Tag of the Docker image to deploy"
  type        = string
  default     = "26"  # Default to latest if not provided explicitly
}

resource "aws_s3_bucket" "data_bucket" {
  bucket = "testtss"  # Ensure this matches the bucket name used in your Python script
}

resource "aws_glue_catalog_database" "glue_db" {
  name = "your-glue-database"  # Ensure this matches the database name used in your Python script
}

resource "aws_glue_catalog_table" "glue_table" {
  name          = "your-glue-table"  # Ensure this matches the table name used in your Python script
  database_name = aws_glue_catalog_database.glue_db.name

  storage_descriptor {
    columns {
      name = "content"  # This matches the single column name in your Python script
      type = "string"
    }

    location      = "s3://testtss/aws blog.txt"  # Ensure this location matches the S3 path in your Python script
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "serialization.format" = "1"
      }
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "data_processor" {
  function_name    = "your-lambda-function"  # Replace with your desired Lambda function name
  role             = aws_iam_role.lambda_exec.arn
  package_type     = "Image"
  image_uri        = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/your-repo-name:${var.image_tag}"  # Use variables for flexibility
  timeout          = 900
}
