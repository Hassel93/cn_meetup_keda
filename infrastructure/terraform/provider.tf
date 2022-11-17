terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.30.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.15.0"
    }
  }
}

provider "kubernetes" {
  host                   = module.cluster.kube_config_obj.host
  username               = module.cluster.kube_config_obj.username
  password               = module.cluster.kube_config_obj.password
  client_certificate     = module.cluster.kube_config_obj.client_certificate
  client_key             = module.cluster.kube_config_obj.client_key
  cluster_ca_certificate = module.cluster.kube_config_obj.cluster_ca_certificate
}

/* provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "my-context"
} */

provider "azurerm" {
  features {}
}
