locals {
  name = "cn-meetup-keda"
}
module "servicebus" {
  source     = "./servicebus"
  event_name = local.name
}

module "cluster" {
  source     = "./aks"
  event_name = local.name
}

module "demo1" {
  source     = "./demo_1"
  event_name = local.name
  sb = {
    topicname         = module.servicebus.topic_name
    subscriptionname  = module.servicebus.subscription_name
    namespacename     = module.servicebus.namespace_name
    connection_string = module.servicebus.connection_string
  }
}



