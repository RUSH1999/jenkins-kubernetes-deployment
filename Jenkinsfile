// ─────────────────────────────────────────────────────────────────
//  Jenkinsfile  —  React App CI/CD Pipeline
//  Repo   : https://github.com/RUSH1999/jenkins-kubernetes-deployment
//  Image  : rupeshyad27/react-app
// ─────────────────────────────────────────────────────────────────

pipeline {

    agent any   // run on any available Jenkins agent

    // ── Configurable variables ────────────────────────────────────
    environment {
        DOCKER_IMAGE   = 'rupeshyad27/react-app'
        DOCKER_TAG     = "${BUILD_NUMBER}"          // unique per build
        DOCKER_LATEST  = "${DOCKER_IMAGE}:latest"
        DOCKER_VERSIONED = "${DOCKER_IMAGE}:${DOCKER_TAG}"
        // 'dockerhub-creds' is a Username/Password credential stored
        // in Jenkins → Manage Jenkins → Credentials
        DOCKER_CREDS   = credentials('dockerhub-creds')
        K8S_DEPLOYMENT = 'k8s-deployment.yaml'
        K8S_SERVICE    = 'k8s-service.yaml'
    }

    // ── Pipeline options ──────────────────────────────────────────
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    // ── Trigger: poll GitHub every 2 minutes  ─────────────────────
    triggers {
        pollSCM('H/2 * * * *')
    }

    // ═══════════════════════════════════════════════════════════════
    stages {

        // ── 1. Checkout ───────────────────────────────────────────
        stage('Checkout') {
            steps {
                echo "Checking out branch: ${env.BRANCH_NAME}"
                git url: 'https://github.com/RUSH1999/jenkins-kubernetes-deployment.git',
                    branch: 'main'
            }
        }

        // ── 2. Install deps & run tests ───────────────────────────
        stage('Install & Test') {
            steps {
                sh 'npm ci --prefer-offline'
                // Uncomment if you have tests:
                // sh 'npm test -- --watchAll=false --passWithNoTests'
            }
        }

        // ── 3. Build Docker image ─────────────────────────────────
        stage('Docker Build') {
            steps {
                sh """
                    docker build \
                        -t ${DOCKER_VERSIONED} \
                        -t ${DOCKER_LATEST} \
                        .
                """
            }
        }

        // ── 4. Push to Docker Hub ─────────────────────────────────
        stage('Docker Push') {
            steps {
                sh """
                    echo "${DOCKER_CREDS_PSW}" | \
                        docker login -u "${DOCKER_CREDS_USR}" --password-stdin
                    docker push ${DOCKER_VERSIONED}
                    docker push ${DOCKER_LATEST}
                    docker logout
                """
            }
        }

        // ── 5. Update image tag in deployment YAML ────────────────
        stage('Update K8s Manifest') {
            steps {
                sh """
                    sed -i 's|${DOCKER_IMAGE}:.*|${DOCKER_VERSIONED}|g' \
                        ${K8S_DEPLOYMENT}
                """
            }
        }

        // ── 6. Deploy to Kubernetes ───────────────────────────────
        stage('Deploy to Kubernetes') {
            steps {
                sh """
                    kubectl apply -f ${K8S_SERVICE}
                    kubectl apply -f ${K8S_DEPLOYMENT}
                    kubectl rollout status deployment/react-app \
                        --timeout=120s
                """
            }
        }

        // ── 7. Verify deployment ──────────────────────────────────
        stage('Verify') {
            steps {
                sh """
                    kubectl get pods -l app=react-app
                    kubectl get svc react-app-service
                """
            }
        }

    } // end stages

    // ═══════════════════════════════════════════════════════════════
    post {
        success {
            echo "✅  Build #${BUILD_NUMBER} deployed successfully."
            // Optional: add Slack/email notification here
        }
        failure {
            echo "❌  Build #${BUILD_NUMBER} failed. Check logs above."
        }
        always {
            // Clean up local Docker images to save disk space
            sh """
                docker rmi ${DOCKER_VERSIONED} || true
                docker rmi ${DOCKER_LATEST}    || true
            """
        }
    }
}