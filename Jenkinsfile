pipeline {
    agent {
        docker {
            image 'rezaunnabi/isec6000-node16-docker-agent:latest'
            args '--user 1000:1000'
        }
    }

    environment {
        DOCKER_IMAGE = 'rezaunnabi/isec6000-node-app'
    }

    options {
        // keep only the latest 10 pipeline builds
        buildDiscarder(logRotator(numToKeepStr: '10'))

        // add timestamps to pipeline logs
        timestamps()
    }

    stages {
        stage('Install Dependencies') {
            steps {
                echo 'installing node dependencies'

                sh 'node --version'
                sh 'npm --version'
                sh 'docker --version'

                sh 'npm ci'
            }
        }

        stage('Unit Tests') {
            steps {
                echo 'running unit tests'

                sh 'npm test'
            }

            post {
                always {
                    // save test result information as an artifact
                    sh 'npm test -- --json --outputFile=test-results.json || true'

                    archiveArtifacts artifacts: 'test-results.json',
                                     allowEmptyArchive: true
                }
            }
        }

        stage('Security Scan') {
            steps {
                echo 'checking dependencies for high or critical vulnerabilities'

                // fail the pipeline if high or critical vulnerabilities are found
                sh 'npm audit --audit-level=high'
            }

            post {
                always {
                    // save the dependency security report
                    sh 'npm audit --json > npm-audit.json || true'

                    archiveArtifacts artifacts: 'npm-audit.json',
                                     allowEmptyArchive: true
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'building docker image'

                sh '''
                    docker build \
                        -t ${DOCKER_IMAGE}:${BUILD_NUMBER} \
                        -t ${DOCKER_IMAGE}:latest \
                        .
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                echo 'pushing docker image to docker hub'

                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_TOKEN'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_TOKEN" | docker login \
                            -u "$DOCKER_USERNAME" \
                            --password-stdin

                        docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                        docker push ${DOCKER_IMAGE}:latest

                        docker logout
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'pipeline completed successfully'
        }

        failure {
            echo 'pipeline failed - check the stage logs'
        }
    }
}