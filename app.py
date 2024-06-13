import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError, ClientError

# S3 configurations
s3 = boto3.client('s3')
bucket_name = 'testtss'
file_key = 'aws blog.txt'

# Glue configurations
glue_database = 'your-glue-database'
glue_table_name = 'your-glue-table'

def read_from_s3():
    try:
        obj = s3.get_object(Bucket=bucket_name, Key=file_key)
        text_data = obj['Body'].read().decode('utf-8')
        return text_data
    except (NoCredentialsError, PartialCredentialsError):
        print("Credentials not available")
        return None
    except ClientError as e:
        print(f"Error fetching file from S3: {e}")
        return None

def update_glue_table():
    glue = boto3.client('glue')

    # Since it's a text file, we assume a single column 'content'
    column_types = [
        {
            'Name': 'content',
            'Type': 'string'
        }
    ]

    response = glue.update_table(
        DatabaseName=glue_database,
        TableInput={
            'Name': glue_table_name,
            'StorageDescriptor': {
                'Columns': column_types,
                'Location': f's3://{bucket_name}/{file_key}',
                'InputFormat': 'org.apache.hadoop.mapred.TextInputFormat',
                'OutputFormat': 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat',
                'Compressed': False,
                'SerdeInfo': {
                    'SerializationLibrary': 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe',
                    'Parameters': {'serialization.format': '1'}
                },
            },
        }
    )
    print("Glue table updated")
    return response

def lambda_handler(event, context):
    text_data = read_from_s3()
    if text_data is not None:
        print("File content:")
        print(text_data)
        update_glue_table()

# This part of the code ensures that if you run the script locally,
# it will still execute the `main()` function.
if __name__ == "__main__":
    lambda_handler(None, None)
