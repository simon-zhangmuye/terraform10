#!/bin/sh

SERVICE_NAME="springbootapp"
SERVICE_TAG="v1"
ECR_REPO_URL="351555610119.dkr.ecr.eu-west-1.amazonaws.com/${SERVICE_NAME}"

if [ "$1" = "build" ];then
    echo "Building the application..."
    cd ..
    sh mvnw clean install
elif [ "$1" = "dockerize" ];then
    find ../target/ -type f \( -name "*.jar" -not -name "*sources.jar" \) -exec cp {} ../infrastructure/$SERVICE_NAME.jar \;
    $(aws ecr get-login --no-include-email --region eu-west-1)
    aws ecr create-repository --repository-name ${SERVICE_NAME:?} || true
    docker build -t ${SERVICE_NAME}:${SERVICE_TAG} .
    docker tag ${SERVICE_NAME}:${SERVICE_TAG}
    docker push ${ECR_REPO_URL}:${SERVICE_TAG}
elif [ "$1" = "plan" ];then
    terraform init -backend-config="app-prod.config"
    terraform plan -var-file="production.tfvars" -var "docker_image_url=${ECR_REPO_URL}:${SERVICE_TAG}"
elif [ "$1" = "deploy" ];then
    terraform init -backend-config="app-prod.config"
    terraform taint -allow-missing aws_ecs_task_definition.springbootapp-task-definition
    terraform apply -var-file="production.tfvars" -var "docker_image_url=${ECR_REPO_URL}:${SERVICE_TAG}" -auto-approve
elif [ "$1" = "destroy" ];then
    terraform init -backend-config="app-prod.config"
    terraform destroy -var-file="production.tfvars" -var "docker_image_url=${ECR_REPO_URL}:${SERVICE_TAG}" -auto-approve
fi