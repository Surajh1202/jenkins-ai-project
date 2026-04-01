pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('AI Code Review') {
            steps {
                sh 'chmod +x review.sh'
                sh './review.sh index.html'
            }
        }

        stage('Deploy') {
            steps {
                sh 'mkdir -p /var/www/html'
                sh 'cp index.html /var/www/html/index.html'
                echo "✅ Deployed index.html successfully"
            }
        }
    }

    post {
        failure {
            echo "❌ Pipeline failed — check AI review report."
        }
        success {
            echo "🚀 Pipeline completed — site deployed."
        }
    }
}
