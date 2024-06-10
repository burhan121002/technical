import boto3
import psycopg2
import os

def read_from_s3(bucket_name, file_key):
    s3 = boto3.client('s3')
    s3_object = s3.get_object(Bucket=bucket_name, Key=file_key)
    data = s3_object['Body'].read().decode('utf-8')
    return data

def push_to_rds(data, db_host, db_name, db_user, db_password):
    conn = psycopg2.connect(
        host=db_host,
        database=db_name,
        user=db_user,
        password=db_password
    )
    cur = conn.cursor()
    # Assuming data is a CSV and we are inserting it into a table named 'my_table'
    cur.execute("COPY my_table FROM STDIN WITH CSV", data)
    conn.commit()
    cur.close()
    conn.close()

if __name__ == "__main__":
    bucket_name = os.getenv('S3_BUCKET_NAME')
    file_key = os.getenv('S3_FILE_KEY')
    db_host = os.getenv('DB_HOST')
    db_name = os.getenv('DB_NAME')
    db_user = os.getenv('DB_USER')
    db_password = os.getenv('DB_PASSWORD')

    # Update the bucket name and file key with Terraform created values
    bucket_name = "my-s3-bucket"  # Update with your bucket name
    file_key = "Dockerfile"  # Update with the file key in S3

    # Update RDS parameters with Terraform created values
    db_host = "mydb.cabcdefg123.us-west-2.rds.amazonaws.com"  # Update with your RDS endpoint
    db_name = "mydb"  # Update with your RDS database name
    db_user = "admin"  # Update with your RDS username
    db_password = "password"  # Update with your RDS password

    data = read_from_s3(bucket_name, file_key)
    push_to_rds(data, db_host, db_name, db_user, db_password)
