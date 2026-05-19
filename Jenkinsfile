pipeline {
  agent {
    kubernetes {
      yaml '''
      apiVersion: v1
      kind: Pod
      spec:
        containers:
        # We use the -debug version because Kaniko needs a shell execution environment for Jenkins
        - name: kaniko
          image: gcr.io/kaniko-project/executor:v1.23.1-debug
          command:
          - sleep
          args:
          - 99d
          volumeMounts:
          - name: jenkins-docker-config
            mountPath: /kaniko/.docker
        volumes:
        - name: jenkins-docker-config
          secret:
            secretName: regcred # <--- Make sure this Kubernetes secret exists with your DockerHub credentials
      '''
    }
  }

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
        // Crucial: This forces Jenkins to run the commands INSIDE the Kaniko container defined above
        container('kaniko') {
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