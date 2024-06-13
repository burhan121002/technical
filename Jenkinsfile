pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
    }

    stages {
        stage('Clone Git') {
            steps {
                git url: 'https://github.com/burhan121002/technical.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build('your-repo-name')
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    docker.withRegistry('654654311847.dkr.ecr.your-region.amazonaws.com', 'aws-credentials') {
                        dockerImage.push()
                    }
                }
            }
        }

        stage('Deploy with Terraform') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                    credentialsId: 'aws-credentials'
                ]]) {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }
}
