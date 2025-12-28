pipeline {
    agent any 
    stages {
        stage('Checkout'){
            steps{
               checkout scm
            }
        } stage('Verify Environment'){
            sh'''
            echo "checking docker installed ...."
            docker --version 
            
            echo "checking docker diamen ...."
            docker info > /dev/null

            echo "checking docker buildx ...."
            docker buildx version
            
            '''
        }
    }
}