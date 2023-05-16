#locals {
#  demoname               = "${var.event_name}-demo-2"
#  deployment_name        = "${var.event_name}-keda-deployment"
#  deployment_sb_env_name = "sb_connectionstring"
#}
#
#resource "kubernetes_namespace" "meetup_demo_2" {
#  metadata {
#    name = local.demoname
#  }
#}
#
#resource "kubernetes_service" "meetup_demo_2_frontend" {
#  metadata {
#    name      = "meetup-demo-2-frontend-svc"
#    namespace = kubernetes_namespace.meetup_demo_2.metadata[0].name
#  }
#
#  spec {
#    selector = {
#      app = kubernetes_deployment.meetup_demo_2.metadata[0].name
#    }
#
#    port {
#      port        = 80
#      target_port = 80
#      protocol    = "TCP"
#    }
#    type = "LoadBalancer"
#  }
#}
#
#resource "kubernetes_deployment" "meetup_demo_2" {
#  metadata {
#    name = local.deployment_name
#    labels = {
#      name = local.deployment_name
#      app  = local.deployment_name
#    }
#    namespace = kubernetes_namespace.meetup_demo_2.metadata[0].name
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
#          app  = local.deployment_name
#        }
#      }
#
#      spec {
#        container {
#          image = "timdaha/cn_meetup_demo_frontend:1.0.1"
#          name  = local.deployment_name
#
#          port {
#            container_port = 80
#          }
#
#          env {
#            name  = local.deployment_sb_env_name
#            value = var.sb.connection_string
#          }
#
#          env {
#            name  = "sb_topic"
#            value = var.sb.topicname
#          }
#        }
#      }
#    }
#  }
#}
#
#resource "kubernetes_deployment" "meetup_demo_2_worker" {
#  metadata {
#    name = "${local.demoname}-survey-worker"
#    labels = {
#      name = "${local.demoname}-survey-worker"
#      app  = "${local.demoname}-survey-worker"
#    }
#    namespace = kubernetes_namespace.meetup_demo_2.metadata[0].name
#  }
#
#  spec {
#    replicas = 1
#
#    selector {
#      match_labels = {
#        name = "${local.demoname}-survey-worker"
#        app  = "${local.demoname}-survey-worker"
#      }
#    }
#
#    template {
#      metadata {
#        labels = {
#          name = "${local.demoname}-survey-worker"
#          app  = "${local.demoname}-survey-worker"
#        }
#      }
#
#      spec {
#        container {
#          image = "timdaha/cn_meetup_keda_survey_worker:1.0.3"
#          name  = "worker"
#
#          env {
#            name  = "reportUrl"
#            value = "http://cn-meetup-keda-report-app-svc"
#          }
#          env {
#            name  = local.deployment_sb_env_name
#            value = var.sb.connection_string
#          }
#          env {
#            name  = "sb_topic"
#            value = var.sb.topicname
#          }
#        }
#      }
#    }
#  }
#}
#
#resource "kubectl_manifest" "scaled_object" {
#  depends_on = [kubernetes_deployment.meetup_demo_2_worker]
#  yaml_body = yamlencode({
#    "apiVersion" = "keda.sh/v1alpha1"
#    "kind"       = "ScaledObject"
#    "metadata" = {
#      "name"      = "${local.demoname}-worker-scaledobject"
#      "namespace" = kubernetes_namespace.meetup_demo_2.metadata[0].name
#    }
#    "spec" = {
#      "scaleTargetRef" = {
#        "name" = kubernetes_deployment.meetup_demo_2_worker.metadata[0].name
#      }
#      "pollingInterval" = 3
#      "cooldownPeriod"  = 5
#      "triggers" = [
#        {
#          "type" = "azure-servicebus"
#          "metadata" = {
#            "topicName"         = var.sb.topicname
#            "subscriptionName"  = var.sb.subscriptionname
#            "namespace"         = var.sb.namespacename
#            "connectionFromEnv" = local.deployment_sb_env_name
#          }
#        }
#      ]
#    }
#  })
#}
#
#
#
#
#resource "kubernetes_service" "meetup_demo_2_report" {
#  metadata {
#    name      = "cn-meetup-keda-report-app-svc"
#    namespace = kubernetes_namespace.meetup_demo_2.metadata[0].name
#  }
#
#  spec {
#    selector = {
#      app = kubernetes_deployment.demo2_report.metadata[0].name
#    }
#
#    port {
#      port        = 80
#      target_port = 80
#      protocol    = "TCP"
#    }
#    type = "LoadBalancer"
#  }
#}
#
#resource "kubernetes_deployment" "demo2_report" {
#  metadata {
#    name = "cn-meetup-keda-report-app"
#    labels = {
#      name = "cn-meetup-keda-report-app"
#      app  = "cn-meetup-keda-report-app"
#    }
#    namespace = kubernetes_namespace.meetup_demo_2.metadata[0].name
#  }
#
#  spec {
#    replicas = 1
#
#    selector {
#      match_labels = {
#        name = "cn-meetup-keda-report-app"
#        app  = "cn-meetup-keda-report-app"
#      }
#    }
#
#    template {
#      metadata {
#        labels = {
#          name = "cn-meetup-keda-report-app"
#          app  = "cn-meetup-keda-report-app"
#        }
#      }
#
#      spec {
#        container {
#          image = "timdaha/cn_meetup_reportapp:1.0.2"
#          name  = "cn-meetup-keda-report-app"
#
#          port {
#            container_port = 80
#          }
#
#          env {
#            name  = "PORT"
#            value = 80
#          }
#
#          env {
#            name  = local.deployment_sb_env_name
#            value = var.sb.connection_string
#          }
#
#          env {
#            name  = "sb_topic"
#            value = var.sb.topicname
#          }
#        }
#      }
#    }
#  }
#}
