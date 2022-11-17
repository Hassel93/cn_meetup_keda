resource "azurerm_resource_group" "rg" {
  name     = "${var.event_name}-sb-rg"
  location = "Switzerland North"
}

resource "azurerm_servicebus_namespace" "sb" {
  name                = "${var.event_name}-sbn"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

}

resource "azurerm_servicebus_topic" "tp" {
  name         = "${var.event_name}-sbt"
  namespace_id = azurerm_servicebus_namespace.sb.id

  enable_partitioning = true
}

resource "azurerm_servicebus_subscription" "sub" {
  name               = "${var.event_name}-sbs"
  topic_id           = azurerm_servicebus_topic.tp.id
  max_delivery_count = 1
}
