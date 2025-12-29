pipeline {
    agent any 
    stages {
        stage('Checkout'){
            steps{
               checkout scm
            }
        }
        stage('Verify Environment'){
            steps{
            sh'''
             echo "=== Checking Docker CLI ==="
            docker --version 

            echo "=== Checking Docker daemon ==="
            docker info > /dev/null

            echo "=== Checking Docker Buildx ==="
            docker buildx version
            
            ''' 
            }
        } 
        stage('Build image'){
            steps{
                sshagent(credentials:['github-ssh-key']){
                    sh ''' 
                    echo 'build docker image '
                    docker buildx build \
                    --ssh default \
                    -t react-nginx:ci \
                    .
                    '''
                }
            }
        } 
        stage('validate image'){
            steps {
                steps {
                    sh '''
                    echo "validating docker image
                    docker image inspect react-nginx:ci > /dev/null
                    '''
                }
            }
        }
        stage('Run container test'){
            steps{
                steps{
                    sh '''
                     echo " running container for test "
                     docker run -p 8080:8080 --name react-front react-nginx:ci

                     echo "Waiting for container to start..."
                     sleep 5

                     echo " Checking running container..."
                     docker ps | grep react-front
                    '''
                }
            }
        } 
        stage('pushto docker hub'){
            when {
                branch 'main'
            }
            steps{
                withCredentials([usernamePassword(
                    credentialsId: 'docker-credential',
                    usernameVariabel: 'USERNAME',
                    passwordVariable: 'PASSWORD'
                )]){
                    sh '''
                     echo " Logging into Docker Hub..."
                     echo "$PASSWORD" | docker login -u "$USERNAME" --password-stdin

                     echo " Tagging image..."
                     docker tag react-nginx:ci $USERNAME/react-nginx:latest

                     echo " Pushing image to Docker Hub..."
                     docker push $USERNAME/react-nginx:latest
                    '''
                }
             
            }
        } 
    }
            post {
            always {    
                sh '''
                   echo " Cleaning up..."

                  docker rm -f react-front || true
                  docker rmi react-nginx:ci || true
                '''
            }
        }
}       
