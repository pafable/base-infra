variable "code_location" {
  type        = string
  description = "Location of code"
}

variable "disk_size" {
  type        = number
  description = "EBS volume size"
  default     = 20
}

variable "eks_nodegroup_instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.medium"
}

variable "eks_version" {
  type        = number
  description = "Kubernetes version"
}

variable "email" {
  type        = string
  description = "Email for project"
}

variable "environment" {
  type        = string
  description = "Environment for this project. Default is poc = proof of concept "
  default     = "poc"
}

variable "kubernetes_namespace" {
  type        = string
  description = "Sets kubernetes namespace"
  default     = "default"
}

variable "owner" {
  type        = string
  description = "Owner of this cluster"
}

variable "project" {
  type        = string
  description = "project name"
}

variable "region" {
  type        = string
  description = "AWS region to deploy the cluster to"
}

variable "vpc_id" {
  type        = string
  description = "VPC id to deploy node groups to"
}

variable "monitoring_namespace" {
  type        = string
  description = "Monitoring namespace"
  default     = "monitoring"
}

variable "isDefaultVpc" {
  type        = bool
  description = "Use default VPC?"
}