pipeline {
  agent any

  environment {
    IMAGE_NAME = "rupeshyad27/react-app"
    IMAGE_TAG = "latest"
    FULL_IMAGE = "rupeshyad27/react-app:latest"
  }

  stages {

    stage('Checkout Source') {
      steps {
        git branch: 'main',
            url: 'https://github.com/RUSH1999/jenkins-kubernetes-deployment.git'
      }
    }

    stage('Build & Push Docker Image (Kaniko)') {
      steps {
        script {
          sh """
          /kaniko/executor \
            --context ${WORKSPACE} \
            --dockerfile ${WORKSPACE}/Dockerfile \
            --destination ${FULL_IMAGE} \
            --cleanup
          """
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        script {
          kubernetesDeploy(
            configs: "deployment.yaml,service.yaml",
            kubeconfigId: "kubeconfig"
          )
        }
      }
    }
  }
}
