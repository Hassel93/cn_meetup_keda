output "connection_string" {
  value = azurerm_servicebus_namespace.sb.default_primary_connection_string
}

output "topic_name" {
  value = azurerm_servicebus_topic.tp.name
}

output "subscription_name" {
  value = azurerm_servicebus_subscription.sub.name
}

output "namespace_name" {
  value = azurerm_servicebus_namespace.sb.name
}
