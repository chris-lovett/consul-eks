provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
  }
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
    }
  }
}

resource "kubernetes_namespace_v1" "consul" {
  metadata {
    name = var.consul_namespace
  }

  depends_on = [module.eks]
}

# NOTE: the license ends up in Terraform state. Use an encrypted remote backend.
resource "kubernetes_secret_v1" "consul_license" {
  metadata {
    name      = "consul-ent-license"
    namespace = kubernetes_namespace_v1.consul.metadata[0].name
  }

  data = {
    key = trimspace(file(var.consul_license_file))
  }
}

resource "kubernetes_storage_class_v1" "gp3" {
  metadata {
    name = "gp3"
  }

  storage_provisioner    = "ebs.csi.aws.com"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type      = "gp3"
    encrypted = "true"
  }

  depends_on = [module.eks]
}

resource "helm_release" "consul" {
  name       = "consul"
  namespace  = kubernetes_namespace_v1.consul.metadata[0].name
  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  version    = var.consul_version

  wait    = true
  timeout = 900

  values = [file("${path.module}/consul-values.yaml")]

  set = [
    { name = "global.image", value = "hashicorp/consul-enterprise:${var.consul_version}-ent" },
    { name = "global.datacenter", value = var.consul_datacenter },
    { name = "server.replicas", value = tostring(var.consul_server_replicas) },
    { name = "server.storageClass", value = kubernetes_storage_class_v1.gp3.metadata[0].name },
  ]

  depends_on = [kubernetes_secret_v1.consul_license]
}
