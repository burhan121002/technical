pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
        AWS_ACCOUNT_ID = '654654311847'
        
        
        AWS_ACCESS_KEY_ID = 'AKIAZQ3DQBWT6BIRFIYP'
        AWS_SECRET_ACCESS_KEY = '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'
     ##(not recommended to use aws credentials in the script in for real use cases , use jenkins manage credentials plugin )
      (for testing purpose immediately delete the keys after testing)
    }

    stages {
        stage('Clone Git') {
            steps {
                git url: 'https://github.com/burhan121002/technical.git', branch: 'main'
            }
        }

        stage('Create ECR Repository') {
            steps {
                script {
                    sh """
                    aws ecr describe-repositories --repository-names your-repo-name --region ${AWS_DEFAULT_REGION} || \
                    aws ecr create-repository --repository-name your-repo-name --region ${AWS_DEFAULT_REGION}
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/your-repo-name:26")
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                    sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/your-repo-name:26"
                }
            }
        }

        stage('Deploy with Terraform') {
            steps {
                sh 'terraform init'
                sh """
                terraform apply -auto-approve \
                    -var="aws_access_key=${AWS_ACCESS_KEY_ID}" \
                    -var="aws_secret_key=${AWS_SECRET_ACCESS_KEY}"
                """
            }
        }
    }
}
