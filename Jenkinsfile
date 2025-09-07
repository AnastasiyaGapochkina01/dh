def GIT_URL = "git@github.com:AnastasiyaGapochkina01/dh.git"

pipeline {
  agent any

  parameters {
    gitParameter type: 'PT_BRANCH', name: 'REVISION', defaultValue: 'main', selectedValue: 'DEFAULT', sortMode: 'DESCENDING_SMART'
  }

  environment {
    COMPOSE_FILE = 'compose.yml'
    DOCKER_REPO = 'anestesia01/downhill'
    TOKEN = credentials('docker_token')
    BLUE_APP_IMAGE = 'anestesia01/downhill:blue'
    GREEN_APP_IMAGE = 'anestesia01/downhill:green'
    USERNAME = 'anestesia01'
    CURRENT_COLOR = 'blue'
  }

  stages {
    stage ('Fetch repo') {
      steps {
        git branch: "{params.REVISION}", url: "${GIT_URL}"
      }
    }
    stage ('Prepare env') {
      steps {
        script {
          loadEnv()
          env.TARGET_COLOR = (env.CURRENT_COLOR == 'blue') ? 'green' : 'blue'
          env.APP_IMAGE = (env.TARGET_COLOR == 'blue') ? env.BLUE_APP_IMAGE : env.GREEN_APP_IMAGE
          echo "Deploy ${env.APP_IMAGE}
        }
      }
    }
    stage('Build & Push') {
      steps {
        script {
          sh """
            docker build -t "${env.DOCKER_REPO}:${env.TARGET_COLOR}" ./
            docker login -u ${env.USERNAME} -p ${env.TOKEN}
            docker push "${env.DOCKER_REPO}:${env.TARGET_COLOR}"
          """
        }
      }
    }
    stage('Deploy') {
      steps {
        script {
          sh "export \$(cat .env | xargs); APP_IMAGE=${env.APP_IMAGE} docker compose -f ${env.COMPOSE_FILE} up -d app-${env.TARGET_COLOR}"
          waitAppHealth("app-${env.TARGET_COLOR}")
          testApp("app-${env.TARGET_COLOR}")
        }
      }
    }
    stage('Switch traffic') {
      steps {
        script {
          switchTraffic(${env.TARGET_COLOR})
          env.CURRENT_COLOR = ${env.TARGET_COLOR}
          updateColor(env.CURRENT_COLOR)
        }
      }
    }
  }
}

def loadEnv() {
  sh 'cp env.example .env'
  def envFile = readFile('.env')
  def lines = envFile.split('\n')

  lines.each { line ->
    if (line.trim() && !line.trim().startsWith('#')) {
      def parts = line.split('=', 2)
      if (patrs.size() == 2) {
        env[parts[0].trim() = parts[1].trim()
      }
    }
  }
}

def waitAppHealth(svcName, timeout = 60) {
  def health = sh(script: "docker compose -f ${env.COMPOSE_FILE} ps -q ${svcName}", returnStdout: true).trim()
  def counter = 0
  while (counter < timeout) {
    def status = sh(script: "docker inspect --format='{{.State.Health.Status}}' ${health}, returnStdout: true).trim())
    if (status == 'healthy') {
      echo "${svcName} is healthy"
      return true
    }
                    
    sleep (5)
    counter += 5
    echo "Waiting for ${svcName} to become healthy... (${counter}s)"
  }
  error("Timeout is gone")
}

def testApp(svcName) {
  sh """
    for i in {1..5}; do
      if docker compose -f ${env.COMPOSE_FILE} exec ${svcName} curl -f http://localhost:8000/healthcheck; then
        echo "App responded correct"
        exit 0
      fi
      sleep 5
    done
    echo "App failed to response"
    exit 1
  """
}

                    
def switchTraffic(color) {
  sh """
    sed -i 's/proxy_pass http:\\/\\/app-.*;/proxy_pass http:\\/\\/app-${color}' ./nginx/dowhhill.conf
    docker compose -f ${env.COMPOSE_FILE} exec load-balancer nginx -s reload
  """
  echo "Traffic switched ${color}"
}

def updateColor(color) {
  sh "echo 'CURRENT_COLOR=${color}' > current_color.env
}
                    

                    
