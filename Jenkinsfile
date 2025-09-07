def GIT_URL = "git@github.com:AnastasiyaGapochkina01/dh.git"

pipeline {
    agent any

    
    environment {
        COMPOSE_FILE = 'compose.yml'
        BLUE_APP_IMAGE = 'anestesia01/demo:blue'
        GREEN_APP_IMAGE = 'anestesia01/demo:green'
        CURRENT_COLOR = 'blue'
        DOCKER_REPO = "anestesia01/demo"
        TOKEN = credentials('docker_token')
        USERNAME = "anestesia01"
    }
    stages {
        stage('Fetch repo') {
            steps {
                git branch: "main", url: "${GIT_URL}"
            }
        }
        stage('Prepare') {
            steps {
                script {
                    loadEnvironmentVariables()
                    echo "${env.CURRENT_COLOR}"
                    
                    env.TARGET_COLOR = (env.CURRENT_COLOR == 'blue') ? 'green' : 'blue'
                    echo "Deploying to ${env.TARGET_COLOR} environment"
                    
                    env.APP_IMAGE = (env.TARGET_COLOR == 'blue') ? env.BLUE_APP_IMAGE : env.GREEN_APP_IMAGE
                    echo "Deploying image ${env.APP_IMAGE}"
                }
            }
        }
        
    }
}

def loadEnvironmentVariables() {
    sh 'cp env.example .env'

    def envFile = readFile('.env')
    def lines = envFile.split('\n')
    
    lines.each { line ->
        if (line.trim() && !line.trim().startsWith('#')) {
            def parts = line.split('=', 2)
            if (parts.size() == 2) {
                env[parts[0].trim()] = parts[1].trim()
            }
        }
    }
}

def waitForHealth(serviceName, timeout = 60) {
    def id = sh(script: "docker compose -f ${env.COMPOSE_FILE} ps -q ${serviceName}", returnStdout: true).trim()
    def counter = 0
    
    while (counter < timeout) {
        def status = sh(script: "docker inspect --format='{{.State.Health.Status}}' ${id}", returnStdout: true).trim()
        
        if (status == 'healthy') {
            echo "${serviceName} is healthy"
            return true
        }
        
        sleep(5)
        counter += 5
        echo "Waiting for ${serviceName} to become healthy... (${counter}s)"
    }
    
    error("Timeout waiting for ${serviceName} to become healthy")
}

def testApplication(serviceName) {    
    sh """
        for i in {1..5}; do
            if docker compose -f ${env.COMPOSE_FILE} exec ${serviceName} curl -f http://localhost:8000/healthcheck; then
                echo "Application ${serviceName} is responding correctly"
                exit 0
            fi
            sleep 5
        done
        echo "Application ${serviceName} failed to respond"
        exit 1
    """
}

def switchTraffic(color) {
    sh """
        export APP_NAME=app-${color} ; envsubst < ./nginx/downhill.conf.tmpl > ./nginx/downhill.conf
        #sed -i 's/proxy_pass http:\\/\\/app-.*;/proxy_pass http:\\/\\/app-${color}:8000;/' ./nginx/downhill.conf
        docker compose -f ${env.COMPOSE_FILE} up -d load-balancer
        # Перезагружаем nginx
        #docker compose -f ${env.COMPOSE_FILE} exec load-balancer nginx -s reload
    """
    
    echo "Traffic switched to ${color} environment"
}

def updateCurrentColor(color) {
    sh "echo 'CURRENT_COLOR=${color}' > current_color.env"
}
                    

                    
