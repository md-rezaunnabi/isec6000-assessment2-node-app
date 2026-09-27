pipeline {
    agent any

    environment {
        // docker hub image name
        DOCKER_IMAGE = 'rezaunnabi/isec6000-node-app'
    }

    options {
        // keep only the latest 10 builds
        buildDiscarder(logRotator(numToKeepStr: '10'))

        // add timestamps to pipeline logs
        timestamps()
    }

    stages {
        stage('Install Dependencies') {
            agent {
                docker {
                    // use node 16 docker image as the build agent
                    image 'node:16-bullseye'
                    args '--user 1000:1000'
                    reuseNode true
                }
            }

            steps {
                echo 'installing node dependencies'

                sh 'node --version'
                sh 'npm --version'
                sh 'npm ci'
            }
        }

        stage('Unit Tests') {
            agent {
                docker {
                    // run tests using node 16
                    image 'node:16-bullseye'
                    args '--user 1000:1000'
                    reuseNode true
                }
            }

            steps {
                echo 'running unit tests'

                sh 'npm test -- --json --outputFile=test-results.json'
            }

            post {
                always {
                    // save test results as an artifact
                    archiveArtifacts artifacts: 'test-results.json',
                                     allowEmptyArchive: true
                }
            }
        }

        stage('Security Scan') {
            agent {
                docker {
                    // run dependency security scan using node 16
                    image 'node:16-bullseye'
                    args '--user 1000:1000'
                    reuseNode true
                }
            }

            steps {
                echo 'checking dependencies for high or critical vulnerabilities'

                // fail pipeline if high or critical vulnerabilities are found
                sh 'npm audit --audit-level=high'
            }

            post {
                always {
                    // save full npm audit report
                    sh 'npm audit --json > npm-audit.json || true'

                    archiveArtifacts artifacts: 'npm-audit.json',
                                     allowEmptyArchive: true
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'checking docker connection'

                sh 'docker version'

                echo 'building application docker image'

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