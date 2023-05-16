terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}


provider "kubectl" {
  host                   = var.kube_config_obj.host
  username               = var.kube_config_obj.username
  password               = var.kube_config_obj.password
  client_certificate     = var.kube_config_obj.client_certificate
  client_key             = var.kube_config_obj.client_key
  cluster_ca_certificate = var.kube_config_obj.cluster_ca_certificate
  load_config_file       = false
}