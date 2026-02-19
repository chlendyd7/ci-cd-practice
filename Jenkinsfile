pipeline {
    agent any

    stages {
        stage('Hello') {
            steps {
                echo 'Building...'
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
