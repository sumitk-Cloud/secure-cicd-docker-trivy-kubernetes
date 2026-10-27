pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        DOCKERHUB_REPO = 'sumitk5550/secure-cicd'
        IMAGE_NAME = "${DOCKERHUB_REPO}:${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t "$IMAGE_NAME" .
                '''
            }
        }

        
stage('Trivy Security Scan') {
    steps {
        sh '''
            set -eu

            echo "Checking image for HIGH and CRITICAL vulnerabilities..."

            # Display findings for troubleshooting.
            trivy image \
              --ignorefile /dev/null \
              --scanners vuln \
              --severity HIGH,CRITICAL \
              --ignore-unfixed \
              --exit-code 0 \
              "$IMAGE_NAME"

            # Enforce the security gate and save a JSON report.
            trivy image \
              --ignorefile /dev/null \
              --scanners vuln \
              --format json \
              --output scan-report.json \
              --severity HIGH,CRITICAL \
              --ignore-unfixed \
              --exit-code 1 \
              "$IMAGE_NAME"
        '''
    }
}


        stage('Push Approved Image') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DH_USER',
                        passwordVariable: 'DH_TOKEN'
                    )
                ]) {
                    sh '''
                        set -eu
                        set +x

                        echo "$DH_TOKEN" | docker login \
                          --username "$DH_USER" \
                          --password-stdin

                        docker push "$IMAGE_NAME"

                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    set -eu

                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml

                    kubectl set image deployment/secure-demo \
                      app="$IMAGE_NAME"

                    kubectl rollout status deployment/secure-demo \
                      --timeout=180s

                    kubectl get deployments
                    kubectl get pods
                    kubectl get services
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts(
                artifacts: 'scan-report.json',
                allowEmptyArchive: true
            )
        }

        success {
            echo 'Security scan passed and deployment completed.'
        }

        failure {
            echo 'Pipeline failed. Check the console output and scan report.'
        }
    }
}