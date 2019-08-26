variable "region" {
  default = "eu-west-1"
}

variable "remote_state_key" {}
variable "remote_state_bucket" {}

#application variables for task
variable "ecs_service_name" {}
variable "docker_image_url" {}
variable "memory" {}
variable "docker_container_port" {}
variable "spring_profile" {}
variable "desired_task_number" {}