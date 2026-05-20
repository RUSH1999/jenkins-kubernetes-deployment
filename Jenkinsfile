pipeline {
    agent any
    
    environment {
        DOCKER_REPO   = 'rupeshyad27/react-app'
        IMAGE_TAG     = "${BUILD_NUMBER}"
        DOCKER_CRED   = 'docker-hub-credentials' // Must match the ID created in Jenkins Credentials
    }
    
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/RUSH1999/jenkins-kubernetes-deployment.git'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building minimized multi-stage Docker image on port 3000..."
                    sh "docker build -t ${DOCKER_REPO}:${IMAGE_TAG} ."
                    sh "docker build -t ${DOCKER_REPO}:latest ."
                }
            }
        }
        
        stage('Push to Registry') {
            steps {
                script {
                    // Authenticate and securely push images to Docker Hub
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CRED}", passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                        sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                        sh "docker push ${DOCKER_REPO}:${IMAGE_TAG}"
                        sh "docker push ${DOCKER_REPO}:latest"
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo "Dynamically updating 'BUILD_NUMBER' placeholder to tag ${IMAGE_TAG}..."
                    // Automatically replaces the string BUILD_NUMBER with the actual build count inside the manifest
                    sh "sed -i 's/BUILD_NUMBER/${IMAGE_TAG}/g' k8s-deployment.yaml"
                    
                    echo "Applying manifest changes to Kubernetes cluster..."
                    sh "kubectl apply -f k8s-deployment.yaml"
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                // Ensure the pods successfully transition to a running state
                sh "kubectl rollout status deployment/react-app-deployment"
                sh "kubectl get services react-app-service"
            }
        }
    }
    
    post {
        always {
            echo "Cleaning up build workspace to preserve storage space..."
            sh "docker rmi ${DOCKER_REPO}:${IMAGE_TAG} ${DOCKER_REPO}:latest || true"
        }
    }
}