pipeline {
    agent { label 'vinod' }

    options {
        timeout(time: 15, unit: 'MINUTES')   // kill runaway builds — saves compute cost
        skipDefaultCheckout(true)             // we control checkout manually
        buildDiscarder(logRotator(numToKeepStr: '10'))  // keep only last 10 builds — saves disk
    }

    environment {
        HEALTH_REPORT = ''
        DEPLOY_NEEDED = 'true'
    }

    stages {
        stage('Parallel: Health Check + Checkout') {
            parallel {
                stage('Instance Health Check') {
                    steps {
                        script {
                            HEALTH_REPORT = sh(script: '''
                                echo "===== INSTANCE HEALTH REPORT ====="

                                echo "\n--- OS & Kernel ---"
                                uname -r
                                cat /etc/os-release | grep PRETTY_NAME

                                echo "\n--- CPU Utilization ---"
                                top -bn1 | grep "Cpu(s)" | awk '{print "User: "$2"  System: "$4"  Idle: "$8}'

                                echo "\n--- CPU Core Count ---"
                                nproc

                                echo "\n--- Memory Usage ---"
                                free -h

                                echo "\n--- Swap Usage ---"
                                swapon --show 2>/dev/null || echo "No swap configured"

                                echo "\n--- Disk Usage ---"
                                df -h --output=source,size,used,avail,pcent,target | grep -v tmpfs

                                echo "\n--- Load Average (1m / 5m / 15m) ---"
                                uptime | awk -F'load average:' '{print $2}'

                                echo "\n--- Uptime ---"
                                uptime -p

                                echo "\n--- Network I/O ---"
                                cat /proc/net/dev | awk 'NR>2 && $1!~/lo/{print "Interface: "$1, " RX bytes: "$2, " TX bytes: "$10}'

                                echo "\n--- Open File Descriptors ---"
                                ls /proc/*/fd 2>/dev/null | wc -l

                                echo "\n--- Process Count (running/total) ---"
                                ps aux | awk 'NR>1{total++; if($8=="R") running++} END{print "Running: "running"  Total: "total}'

                                echo "\n--- Top 5 CPU-consuming Processes ---"
                                ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -6

                                echo "\n--- Top 5 Memory-consuming Processes ---"
                                ps -eo pid,comm,%cpu,%mem --sort=-%mem | head -6

                                echo "\n--- Pending Security Updates ---"
                                apt-get -s upgrade 2>/dev/null | grep -i "security" | wc -l || echo "N/A"

                                echo "\n=================================="
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
            }
        }

        stage('Check If Deploy Needed') {
            steps {
                script {
                    // skip deploy if index.html hasn't changed — saves time and cost
                    def changed = sh(script: "git diff HEAD~1 --name-only 2>/dev/null | grep -c 'index.html' || echo '1'", returnStdout: true).trim()
                    DEPLOY_NEEDED = changed != '0' ? 'true' : 'false'
                    echo "Deploy needed: ${DEPLOY_NEEDED}"
                }
            }
        }

        stage('AI Code Review') {
            steps {
                sh '[ -x review.sh ] || chmod +x review.sh'
                sh './review.sh index.html'
            }
        }

        stage('Deploy') {
            when {
                expression { DEPLOY_NEEDED == 'true' }
            }
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
