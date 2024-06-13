pipeline {
    agent any

    environment {
        AWS_CREDENTIALS = credentials('aws-credentials')  // Ensure this matches the ID you used in Jenkins
    }

    stages {
        stage('Clone Git') {
            steps {
                git url: 'https://github.com/your-repo.git', credentialsId: 'github-credentials'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("your-repo-name")
                }
            }
        }
        stage('Push to ECR') {
            steps {
                script {
                    docker.withRegistry('https://your-aws-account-id.dkr.ecr.your-region.amazonaws.com', 'AWS_CREDENTIALS') {
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
                    credentialsId: 'aws-credentials'  // Ensure this matches the ID you used in Jenkins
                ]]) {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }
}
