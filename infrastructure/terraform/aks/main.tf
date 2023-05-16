locals {
  clustername = "${var.event_name}-aks"
  dns_prefix  = replace(local.clustername, "-", "")
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.event_name}-aks-rg"
  location = "Switzerland North"
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = local.clustername
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = local.dns_prefix
  workload_autoscaler_profile {
    keda_enabled = true //https://learn.microsoft.com/en-us/azure/aks/keda-deploy-add-on-arm must be enable
  }

  default_node_pool {
    name       = "default"
    enable_auto_scaling = true
    min_count = 1
    max_count = 3
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}
