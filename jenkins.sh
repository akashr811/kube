node {
    
    stage('Git checkout') {
    git branch: 'main', url: 'https://github.com/akashr811/kube.git'
    }
    stage('sending docker file to ansible server over ssh'){
        sshagent(['ansible_demo']) {
            sh 'ssh -o StrictHostKeyChecking=no ubuntu@172.31.6.207'#ansible ipaddress
            sh 'scp /var/lib/jenkins/workspace/pipline-demo/* ubuntu@172.31.6.207:/home/ubuntu'#ansible ipaddress
        }
    }
    stage('Docker Build Images'){
        sshagent(['ansible_demo']) {
            sh 'ssh -o StrictHostKeyChecking=no ubuntu@172.31.6.207 cd /home/ubuntu/'#ansible ipaddress
            sh 'ssh -o StrictHostKeyChecking=no ubuntu@172.31.6.207 docker image build -t $JOB_NAME:v1.$BUILD_ID .'#ansible ipaddress
            
        }
    }
    stage('Docker image tagging'){
        sshagent(['ansible_demo']){
            sh 'ssh -o StrictHostKeyChecking=no ubuntu@172.31.6.207 cd /home/ubuntu/'#ansible ipaddress
            sh 'ssh -o StrictHostKeyChecking=no ubuntu@172.31.6.207 docker image tag $JOB_NAME:v1.$BUILD_ID akash39/$JOB_NAME:v1.$BUILD_ID'#ansible ipaddress
            sh 'ssh -o StrictHostKeyChecking=no ubuntu@172.31.6.207 docker image tag $JOB_NAME:v1.$BUILD_ID akash39/$JOB_NAME:latest'#ansible ipaddress
        }
    }
        
    stage('push docker images to docker hub'){
        sshagent(['ansible_demo']){
            withCredentials([string(credentialsId: 'dockerhub_password', variable: 'dockerhub_password')]){
                sh "ssh -o StrictHostKeyChecking=no ubuntu@172.31.6.207 docker login -u akash39 -p ${dockerhub_password}"#ansible ipaddress
                sh 'ssh -o StrictHostKeyChecking=no ubuntu@172.31.6.207 docker image push akash39/$JOB_NAME:v1.$BUILD_ID'#ansible ipaddress
                sh 'ssh -o StrictHostKeyChecking=no ubuntu@172.31.6.207 docker image push akash39/$JOB_NAME:latest'#ansible ipaddress
                sh 'ssh -o StrictHostKeyChecking=no ubuntu@172.31.6.207 docker image rm akash39/$JOB_NAME:v1.$BUILD_ID akash39/$JOB_NAME:latest $JOB_NAME:v1.$BUILD_ID'#ansible ipaddress
            }
                            
        }   
    }
    stage('copy files from ansible to kubernetes server'){
        sshagent(['kubernets_server']){
            sh 'ssh -o StrictHostKeyChecking=no ubuntu@172.31.27.37'#kubernets ipaddress
            sh 'scp /var/lib/jenkins/workspace/pipline-demo/* ubuntu@172.31.27.37:/home/ubuntu'#kubernets ipaddress
        }
    }
    stage('kubernets deployment using ansible'){
        sshagent(['ansible_demo']){
            sh 'ssh -o StrictHostKeyChecking=no ubuntu@172.31.6.207 cd /home/ubuntu/'#ansible ipaddress
            sh 'ssh -o StrictHostKeyChecking=no ubuntu@172.31.6.207 ansible -m ping node'#ansible ipaddress
            sh 'ssh -o StrictHostKeyChecking=no ubuntu@172.31.6.207 ansible-playbook ansible.yml'#ansible ipaddress
            
        }
    }
                
}
