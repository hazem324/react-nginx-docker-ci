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
                    ''' 
                    echo 'build docker image '
                    docker buildx build \
                    --ssh default \
                    
                    '''
                }
            }
        }
    }
}