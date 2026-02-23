pipeline {
    agent any

    environment {
        DOCKER_HUB_ID = "${env.DOCKER_HUB_ID}" // .env 파일의 값을 참조
        APP_NAME = 's14p11b201-app'
        IMAGE_NAME = "${DOCKER_HUB_ID}/${APP_NAME}"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        K8S_CREDENTIAL_ID = 'k8s-kubeconfig' // Jenkins에 등록된 Kubeconfig ID
        DOCKER_HUB_CREDENTIAL_ID = 'docker-hub-credentials' // Jenkins에 등록된 Docker Hub 자격 증명 ID
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    // Docker 이미지 빌드 및 푸시
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_HUB_CREDENTIAL_ID) {
                        def appImage = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                        appImage.push()
                        appImage.push("latest")
                    }
                }
            }
        }

        stage('K8s Deployment') {
            steps {
                script {
                    // Secret Text로 저장된 kubeconfig 내용을 가져와서 임시 파일로 저장
                    withCredentials([string(credentialsId: 'k8s-kubeconfig', variable: 'KUBE_CONTENT')]) {
                        writeFile file: 'kubeconfig', text: KUBE_CONTENT
                        sh """
                            export KUBECONFIG=kubeconfig
                            sed -i 's|\${DOCKER_IMAGE}|${IMAGE_NAME}:${IMAGE_TAG}|g' k8s/deployment.yaml
                            kubectl apply -f k8s/deployment.yaml
                            rm kubeconfig
                        """
                    }
                }
            }
        }
    }

    post {
        // 빌드 결과에 상관없이 항상 알림 전송
        always {
            script {
                // 빌드 상태에 따른 색상 설정
                def buildStatus = currentBuild.currentResult
                def color = (buildStatus == 'SUCCESS') ? '#00FF00' : '#FF0000'
                
                // GitLab 플러그인에서 제공하는 환경 변수 활용
                // 변수가 없을 경우를 대비해 기본값 설정
                def branch = env.gitlabSourceBranch ?: env.GIT_BRANCH ?: 'Unknown Branch'
                def user = env.gitlabUserName ?: 'Unknown User'
                def commit = env.gitlabAfter ?: env.GIT_COMMIT ?: 'No Commit Info'
                def commitMsg = env.gitlabMergeRequestTitle ?: 'Push Event'

                mattermostSend (
                    color: color,
                    channel: 'jetkins',
                    message: """
                        ### 🚀 빌드 알림: ${buildStatus}
                        - **프로젝트:** ${env.JOB_NAME} (Build #${env.BUILD_NUMBER})
                        - **작업자:** ${user}
                        - **브랜치:** `${branch}`
                        - **커밋:** `${commit.take(8)}`
                        - **메시지:** ${commitMsg}
                        - **결과 확인:** [Jenkins 빌드 로그](${env.BUILD_URL})
                    """.stripIndent()
                )
            }
        }
    }
}