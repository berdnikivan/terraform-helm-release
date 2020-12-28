resource helm_release this {
  count            = var.app["deploy"] ? 1 : 0
  namespace        = var.namespace
  repository       = var.repository
  name             = var.app["name"]
  version          = var.app["version"]
  chart            = var.app["chart"]
  force_update     = lookup(var.app, "force_update", true)
  wait             = lookup(var.app, "wait", true)
  recreate_pods    = lookup(var.app, "recreate_pods", true)
  max_history      = lookup(var.app, "max_history", 0)
  lint             = lookup(var.app, "lint", false)
  create_namespace = lookup(var.app, "create_namespace", false)
  skip_crds        = lookup(var.app, "skip_crds", false)
  atomic           = lookup(var.app, "atomic", false)

  dynamic "set" {
    iterator = item
    for_each = var.set == null ? [] : var.set

    content {
      name  = item.value.name
      value = item.value.value
    }
  }

  dynamic "set_sensitive" {
    iterator = item
    for_each = var.set_sensitive == null ? [] : var.set_sensitive

    content {
      name  = item.value.path
      value = item.value.value
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  }

provider "helm" {
  version = "~> 1.0"
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    load_config_file       = false
    }
