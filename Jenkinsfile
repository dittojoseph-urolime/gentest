pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID="857752673193"
        AWS_DEFAULT_REGION="us-east-2" 
        APP = 'gentest'
        REPOSITORY = 'nginx'
        ECR_REGISTRY = '857752673193.dkr.ecr.us-east-2.amazonaws.com'
        SERVICENAME = 'Ecs-service'
        TASKFAMILY = 'sample-website'
        CLUSTERNAME = 'test'
    }
   
    stages {

    stage('Cleanup') {
      steps {
           cleanWs()
        }
      } 	
    stage('Checkout source repo') {
      steps {
         checkout scm
      }
    }
    stage('Building the Docker Image') {
         steps {
            // sh ''' docker build -t ${APP}:${GIT_BRANCH}-${BUILD_NUMBER} . '''
           sh '''sudo -u "ec2-user" docker build -t ${APP}/${GIT_BRANCH}:${BUILD_NUMBER} . '''
          
          }
      }
        
         stage('Logging into AWS ECR') {
            steps {
                script {
                sh """ sudo -u "ec2-user" aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | sudo -u "ec2-user" docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com """
                }
                 
            }
        }
        
   
    // Uploading Docker images into AWS ECR
    stage('Pushing to ECR') {
     steps{  
         script {
                sh """ sudo -u "ec2-user" docker tag "${APP}/${GIT_BRANCH}:${BUILD_NUMBER}" ${ECR_REGISTRY}/${REPOSITORY}:${BUILD_NUMBER} """
                sh """ sudo -u "ec2-user" docker push ${ECR_REGISTRY}/${REPOSITORY}:${BUILD_NUMBER} """
         }
        }
      }
    stage('Deploying the new Image to ECS Cluster') {
        steps {            
            script {
                def NEW_DOCKER_IMAGE="${ECR_REGISTRY}/${REPOSITORY}:${BUILD_NUMBER}"        
                sh """
                set -e
	        echo "Creating new TD with the new Image"
	        OLD_TASK_DEFINITION=\$(sudo -u "ec2-user" aws ecs describe-task-definition --task-definition ${env.TASKFAMILY} --region ${AWS_DEFAULT_REGION})
	        NEW_TASK_DEFINTIION=\$(echo \$OLD_TASK_DEFINITION | jq --arg IMAGE ${NEW_DOCKER_IMAGE} '.taskDefinition | .containerDefinitions[0].image = \$IMAGE | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.compatibilities)')           
	        NEW_TASK_INFO=\$(sudo -u "ec2-user" aws ecs register-task-definition --region ${AWS_DEFAULT_REGION} --cli-input-json "\$NEW_TASK_DEFINTIION")
                NEW_REVISION=\$(echo \$NEW_TASK_INFO | jq '.taskDefinition.revision')
                echo "Updating the service with new TD"
                sudo -u "ec2-user" aws ecs update-service --cluster ${env.CLUSTERNAME} --service ${env.SERVICENAME} --task-definition ${env.TASKFAMILY}:\$NEW_REVISION --region ${AWS_DEFAULT_REGION}
            	    	    
                """
            }
         }
      } 

    }
}
