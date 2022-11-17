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
