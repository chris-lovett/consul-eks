output "cluster_name" {
  value = module.eks.cluster_name
}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "consul_token_command" {
  value = "kubectl get secret -n ${var.consul_namespace} consul-bootstrap-acl-token -o jsonpath='{.data.token}' | base64 -d"
}

output "consul_ui_command" {
  value = "kubectl port-forward -n ${var.consul_namespace} svc/consul-ui 8501:443"
}
