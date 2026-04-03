pipeline {
    agent any

    environment {
        HEALTH_REPORT = ''
    }

    stages {
        stage('Instance Health Check') {
            steps {
                script {
                    HEALTH_REPORT = sh(script: '''
                        echo "===== INSTANCE HEALTH REPORT ====="
                        echo ""
                        echo "--- CPU Utilization ---"
                        top -bn1 | grep "Cpu(s)" | awk '{print "User: "$2"  System: "$4"  Idle: "$8}'

                        echo ""
                        echo "--- Memory Usage ---"
                        free -h | awk 'NR==1{print $0} NR==2{print $0}'

                        echo ""
                        echo "--- Disk Usage ---"
                        df -h --output=source,size,used,avail,pcent,target | head -6

                        echo ""
                        echo "--- Load Average (1m / 5m / 15m) ---"
                        uptime | awk -F'load average:' '{print $2}'

                        echo ""
                        echo "--- Uptime ---"
                        uptime -p

                        echo ""
                        echo "--- Top 5 CPU-consuming Processes ---"
                        ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -6

                        echo ""
                        echo "--- Top 5 Memory-consuming Processes ---"
                        ps -eo pid,comm,%cpu,%mem --sort=-%mem | head -6

                        echo ""
                        echo "=================================="
                    ''', returnStdout: true).trim()

                    echo "${HEALTH_REPORT}"
                }
            }
        }

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
Console Output: ${env.BUILD_URL}console

${HEALTH_REPORT}"""
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
Console Output: ${env.BUILD_URL}console

${HEALTH_REPORT}"""
        }
    }
}
