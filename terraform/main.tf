locals {
  name = "cn-meetup-keda"
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.name}-rg"
  location = "Switzerland North"
}

resource "azurerm_servicebus_namespace" "sb" {
  name                = "${local.name}-sb-ns"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

}

resource "azurerm_servicebus_topic" "tp" {
  name         = "${local.name}-sb-topic"
  namespace_id = azurerm_servicebus_namespace.sb.id

  enable_partitioning = true
}

resource "azurerm_servicebus_subscription" "sub" {
  name               = "${local.name}-sb-sub"
  topic_id           = azurerm_servicebus_topic.tp.id
  max_delivery_count = 1
}

resource "kubernetes_namespace" "keda_ns" {
  metadata {
    name = "keda"
  }
}

resource "helm_release" "keda" {
  name       = "kedacore"
  repository = "https://kedacore.github.io/charts"
  chart      = "keda"
  namespace  = kubernetes_namespace.keda_ns.metadata[0].name
}

resource "kubernetes_namespace" "meetup_sb" {
  depends_on = [helm_release.keda]
  metadata {
    name = "meetup-sb"
  }
}

resource "kubernetes_deployment" "meetup_sb" {
  metadata {
    name = "cn-meetup-keda-sb-deployment"
    labels = {
      name = "cn-meetup-keda-sb-deployment"
    }
    namespace = kubernetes_namespace.meetup_sb.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        name = "cn-meetup-keda-sb-deployment"
      }
    }

    template {
      metadata {
        labels = {
          name = "cn-meetup-keda-sb-deployment"
        }
      }

      spec {
        container {
          image = "nginx"
          name  = "nginx"

          env {
            name  = "AzureServiceBus_ConnectionString"
            value = azurerm_servicebus_namespace.sb.default_primary_connection_string
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "scaled_object" {
  depends_on = [kubernetes_deployment.meetup_sb, helm_release.keda]

  manifest = {
    "apiVersion" = "keda.sh/v1alpha1"
    "kind"       = "ScaledObject"
    "metadata" = {
      "name"      = "cn-meetup-keda-sb-scaledobject"
      "namespace" = kubernetes_namespace.meetup_sb.metadata[0].name
    }
    "spec" = {
      "scaleTargetRef" = {
        "name" = kubernetes_deployment.meetup_sb.metadata[0].name
      }
      "pollingInterval" = 3
      "cooldownPeriod"  = 5
      "triggers" = [
        {
          "type" = "azure-servicebus"
          "metadata" = {
            "topicName"         = azurerm_servicebus_topic.tp.name
            "subscriptionName"  = azurerm_servicebus_subscription.sub.name
            "namespace"         = azurerm_servicebus_namespace.sb.name
            "connectionFromEnv" = "AzureServiceBus_ConnectionString"
          }
        }
      ]
    }
  }
}
