variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-west-2"
}

variable "name" {
  description = "Name prefix for the VPC and EKS cluster."
  type        = string
  default     = "consul-ent"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version. Check the consul-k8s compatibility matrix before changing."
  type        = string
  default     = "1.33"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway (cheaper) instead of one per AZ (HA)."
  type        = bool
  default     = true
}

variable "node_instance_types" {
  type    = list(string)
  default = ["m5.large"]
}

variable "node_count" {
  description = "Worker nodes. Keep >= 3 so the 3 Consul servers land in separate AZs."
  type        = number
  default     = 3
}

variable "consul_version" {
  description = "Consul Enterprise version (without the -ent suffix). Also used as the Helm chart version."
  type        = string
  default     = "2.0.4"
}

variable "consul_namespace" {
  type    = string
  default = "consul"
}

variable "consul_datacenter" {
  type    = string
  default = "dc1"
}

variable "consul_server_replicas" {
  type    = number
  default = 3
}

variable "consul_license_file" {
  description = "Path to your Consul Enterprise .hclic license file."
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
