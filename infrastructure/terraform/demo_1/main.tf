#locals {
#  demoname               = "${var.event_name}-demo-1"
#  deployment_name        = "${var.event_name}-keda-nginx-deployment"
#  deployment_sb_env_name = "${var.event_name}_sb_connection_string"
#}
#
#resource "kubernetes_namespace" "meetup_demo_1" {
#  metadata {
#    name = local.demoname
#  }
#}
#
#resource "kubernetes_deployment" "meetup_demo_1" {
#  metadata {
#    name = local.deployment_name
#    labels = {
#      name = local.deployment_name
#    }
#    namespace = kubernetes_namespace.meetup_demo_1.metadata[0].name
#  }
#
#  spec {
#    replicas = 1
#
#    selector {
#      match_labels = {
#        name = local.deployment_name
#      }
#    }
#
#    template {
#      metadata {
#        labels = {
#          name = local.deployment_name
#        }
#      }
#
#      spec {
#        container {
#          image = "nginx"
#          name  = "nginx"
#
#          env {
#            name  = local.deployment_sb_env_name
#            value = var.sb.connection_string
#          }
#        }
#      }
#    }
#  }
#}
#
#resource "kubectl_manifest" "scaled_object" {
#  depends_on = [kubernetes_deployment.meetup_demo_1]
#  yaml_body = yamlencode({
#    "apiVersion" = "keda.sh/v1alpha1"
#    "kind"       = "ScaledObject"
#    "metadata" = {
#      "name"      = "${local.demoname}-nginx-scaledobject-2"
#      "namespace" = kubernetes_namespace.meetup_demo_1.metadata[0].name
#    }
#    "spec" = {
#      "scaleTargetRef" = {
#        "name" = kubernetes_deployment.meetup_demo_1.metadata[0].name
#      }
#      "pollingInterval" = 3  # Optional. Default: 30 seconds
#      "cooldownPeriod"  = 5  # Optional. Default: 300 seconds
#      "idleReplicaCount" = 30  # Optional. Default: ignored, must be less than minReplicaCount 
#      "minReplicaCount"  = 0  # Optional. Default: 0
#      "maxReplicaCount"  = 100  # Optional. Default: 100
#      "triggers" = [
#        {
#          "type" = "azure-servicebus"
#          "metadata" = {
#            "topicName"         = var.sb.topicname
#            "subscriptionName"  = var.sb.subscriptionname
#            "namespace"         = var.sb.namespacename
#            "connectionFromEnv" = local.deployment_sb_env_name
#            "messageCount"      = "5"
#            "activationMessageCount" = "0"
#          }
#        }
#      ]
#    }
#  })
#}
