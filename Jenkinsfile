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
            mail to: 'surajharer100@gmail.com',
                 subject: "❌ Jenkins Pipeline FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                 body: """Pipeline: ${env.JOB_NAME}
Build Number: ${env.BUILD_NUMBER}
Status: FAILED

Possible Reasons for Failure:
- Code review found critical issues in index.html
- Deployment failed (permission issue or missing directory)
- Shell script error in review.sh

Suggestions:
- Check the console output for the exact error
- Fix any issues flagged in the AI code review report
- Ensure /var/www/html exists and Jenkins has write permission
- Re-run the pipeline after fixing the issue

Build URL: ${env.BUILD_URL}
Console Output: ${env.BUILD_URL}console"""
        }
        success {
            echo "🚀 Pipeline completed — site deployed."
            mail to: 'surajharer100@gmail.com',
                 subject: "✅ Jenkins Pipeline SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                 body: """Pipeline: ${env.JOB_NAME}
Build Number: ${env.BUILD_NUMBER}
Status: SUCCESS

What was done:
- Code checked out from GitHub
- AI static code review passed
- index.html deployed to /var/www/html

Build URL: ${env.BUILD_URL}
Console Output: ${env.BUILD_URL}console"""
        }
    }
}
