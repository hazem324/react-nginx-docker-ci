pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verify Environment') {
            steps {
                sh '''
                    echo "=== Checking Docker CLI ==="
                    docker --version

                    echo "=== Checking Docker daemon ==="
                    docker info > /dev/null

                    echo "=== Checking Docker Buildx ==="
                    docker buildx version
                '''
            }
        }

        stage('Build image') {
            steps {
                sshagent(credentials: ['github-ssh-key']) {
                    sh '''
                        echo "=== Building Docker image ==="
                        docker buildx build \
                          --ssh default \
                          -t react-nginx:ci \
                          .
                    '''
                }
            }
        }

        stage('Validate image') {
            steps {
                sh '''
                    echo "=== Validating Docker image ==="
                    docker image inspect react-nginx:ci > /dev/null
                '''
            }
        }

        stage('Run container test') {
            steps {
                sh '''
                    echo "=== Running container for test ==="
                    docker run -d -p 8080:80 --name react-front react-nginx:ci

                    echo "=== Waiting for container to start ==="
                    sleep 5

                    echo "=== Checking running container ==="
                    docker ps | grep react-front
                '''
            }
        }

        stage('Push to Docker Hub') {
            when {
                branch 'main'
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-credential',
                    usernameVariable: 'USERNAME',
                    passwordVariable: 'PASSWORD'
                )]) {
                    sh '''
                        echo "=== Logging into Docker Hub ==="
                        echo "$PASSWORD" | docker login -u "$USERNAME" --password-stdin

                        echo "=== Tagging image ==="
                        docker tag react-nginx:ci $USERNAME/react-nginx:latest

                        echo "=== Pushing image to Docker Hub ==="
                        docker push $USERNAME/react-nginx:latest
                    '''
                }
            }
        }
    }

    post {
        always {
            sh '''
                echo "=== Cleaning up ==="
                docker rm -f react-front || true
                docker rmi react-nginx:ci || true
            '''
        }
    }
}
