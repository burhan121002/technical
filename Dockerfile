
FROM python:3.9


WORKDIR /app


RUN pip install --no-cache-dir boto3 pandas


COPY . .


CMD ["python", "app.py"]
