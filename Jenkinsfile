pipeline {

    agent any

    environment {
        DOCKER_IMAGE      = 'rupeshyad27/react-app'
        DOCKER_TAG        = "${BUILD_NUMBER}"
        DOCKER_CREDS      = credentials('dockerhub-creds')
        K8S_DEPLOYMENT    = 'k8s-deployment.yaml'
        K8S_SERVICE       = 'k8s-service.yaml'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    triggers {
        pollSCM('H/2 * * * *')
    }

    stages {

        stage('Checkout') {
            steps {
                git url: 'https://github.com/RUSH1999/jenkins-kubernetes-deployment.git',
                    branch: 'main'
            }
        }

        stage('Install') {
            steps {
                sh 'npm ci --prefer-offline'
            }
        }

        stage('Docker Build') {
            steps {
                sh """
                    docker build \
                        -t ${DOCKER_IMAGE}:${DOCKER_TAG} \
                        -t ${DOCKER_IMAGE}:latest \
                        .
                """
            }
        }

        stage('Docker Push') {
            steps {
                sh """
                    echo "${DOCKER_CREDS_PSW}" | \
                        docker login -u "${DOCKER_CREDS_USR}" --password-stdin
                    docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    docker push ${DOCKER_IMAGE}:latest
                    docker logout
                """
            }
        }

        stage('Update K8s Manifest') {
            steps {
                sh """
                    sed -i 's|${DOCKER_IMAGE}:.*|${DOCKER_IMAGE}:${DOCKER_TAG}|g' \
                        ${K8S_DEPLOYMENT}
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                    kubectl apply -f ${K8S_SERVICE}
                    kubectl apply -f ${K8S_DEPLOYMENT}
                    kubectl rollout status deployment/react-app --timeout=120s
                """
            }
        }

        stage('Verify') {
            steps {
                sh """
                    kubectl get pods -l app=react-app
                    kubectl get svc react-app-service
                """
            }
        }

    }

    post {
        success {
            echo "✅  Build #${BUILD_NUMBER} deployed successfully."
        }
        failure {
            echo "❌  Build #${BUILD_NUMBER} failed. Check logs above."
        }
        always {
            // Safe cleanup — only runs if the image tag variable is available
            script {
                try {
                    sh "docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true"
                    sh "docker rmi ${DOCKER_IMAGE}:latest || true"
                } catch (err) {
                    echo "Docker cleanup skipped: ${err.getMessage()}"
                }
            }
        }
    }
}
