pipeline {
    agent any
    
    environment {
        TF_IN_AUTOMATION = 'true'
        AWS_REGION = 'us-east-1'
    }
    
    stages {

        stage('1. Initialize IaC & Deploy Infrastructure') {
            steps {
                script {
                    echo "===== Stage 1: Initialize IaC & Deploy Infrastructure ====="

                    sh 'terraform init'
                    sh 'terraform validate'
                    sh 'terraform plan -out=tfplan'
                    sh 'terraform apply -auto-approve tfplan'

                    env.PRIVATE_IP = sh(
                        script: 'terraform output -raw private_ip',
                        returnStdout: true
                    ).trim()

                    env.PUBLIC_IP = sh(
                        script: 'terraform output -raw public_ip',
                        returnStdout: true
                    ).trim()

                    env.INSTANCE_ID = sh(
                        script: 'terraform output -raw instance_id',
                        returnStdout: true
                    ).trim()

                    echo "✓ Infrastructure Deployed Successfully"
                    echo "Instance ID: ${env.INSTANCE_ID}"
                }
            }
        }

        stage('2. Configure EC2 & Deploy Application') {
            steps {
                script {
                    echo "===== Stage 2: Configure EC2 & Deploy Application ====="

                    echo "Waiting for instance to be ready..."
                    sleep(time: 30, unit: 'SECONDS')

                    echo "Waiting for SSM agent to be online..."
                    sh """
                    timeout 300 bash -c '
                    until aws ssm describe-instance-information \
                        --region ${env.AWS_REGION} \
                        --filters "Key=InstanceIds,Values=${env.INSTANCE_ID}" \
                        --query "InstanceInformationList[0].PingStatus" \
                        --output text | grep -q "Online"
                    do
                        echo "Waiting for SSM agent..."
                        sleep 10
                    done'
                    """

                    echo "SSM agent is online."

                    def scriptBase64 = sh(
                        script: "base64 install_nginx.sh | tr -d '\\n'",
                        returnStdout: true
                    ).trim()

                    echo "Deploying 'install_nginx.sh' via SSM..."

                    def commandId = sh(
                        script: """
                        aws ssm send-command \
                            --instance-ids ${env.INSTANCE_ID} \
                            --document-name "AWS-RunShellScript" \
                            --parameters 'commands=["echo ${scriptBase64} | base64 -d | bash"]' \
                            --region ${env.AWS_REGION} \
                            --query 'Command.CommandId' \
                            --output text
                        """,
                        returnStdout: true
                    ).trim()

                    echo "Command ID: ${commandId}"

                    sh """
                    aws ssm wait command-executed \
                        --command-id ${commandId} \
                        --instance-id ${env.INSTANCE_ID} \
                        --region ${env.AWS_REGION}
                    """

                    def commandOutput = sh(
                        script: """
                        aws ssm get-command-invocation \
                            --command-id ${commandId} \
                            --instance-id ${env.INSTANCE_ID} \
                            --region ${env.AWS_REGION} \
                            --query 'StandardOutputContent' \
                            --output text
                        """,
                        returnStdout: true
                    ).trim()

                    echo "Command Output:\n${commandOutput}"
                    echo "✓ NGINX configured successfully via SSM"
                }
            }
        }

        stage('3. Deployment Validation') {
            steps {
                script {
                    echo "===== Stage 3: Deployment Validation ====="

                    sleep(time: 10, unit: 'SECONDS')

                    def response = sh(
                        script: "curl -s http://${env.PUBLIC_IP}",
                        returnStdout: true
                    ).trim()

                    echo "HTTP Response:\n${response}"

                    if (!response.contains(env.PRIVATE_IP)) {
                        error("✗ Validation Failed: Private IP not found in response")
                    }

                    echo "✓ Validation Successful"
                }
            }
        }

        stage('4. Output Results') {
            steps {
                script {
                    echo "===== Stage 4: Deployment Results ====="
                    echo "================================================"
                    echo "✓ DEPLOYMENT SUCCESSFUL"
                    echo "Instance ID : ${env.INSTANCE_ID}"
                    echo "Private IP  : ${env.PRIVATE_IP}"
                    echo "Public IP   : ${env.PUBLIC_IP}"
                    echo "URL         : http://${env.PUBLIC_IP}"
                    echo "================================================"
                }
            }
        }

        stage('5. Manual Approval & Destroy Infrastructure') {
            steps {
                script {
                    echo "===== Stage 5: Manual Approval for Destroy ====="
                    echo "⚠️ WARNING: This will DESTROY all Terraform-managed resources."

                    input message: """
Are you sure you want to destroy the infrastructure?

Instance ID : ${env.INSTANCE_ID}
Public IP  : ${env.PUBLIC_IP}

Click PROCEED to destroy.
Click ABORT to keep infrastructure.
""",
                    ok: 'PROCEED'

                    echo "Approval received. Destroying infrastructure..."

                    sh 'terraform init'
                    sh 'terraform destroy -auto-approve'

                    echo "✓ Infrastructure destroyed successfully"
                }
            }
        }
    }

    post {
        success {
            echo "✓ Pipeline completed successfully!"
        }
        failure {
            echo "✗ Pipeline failed. Check logs for details."
        }
        always {
            cleanWs()
        }
    }
}
