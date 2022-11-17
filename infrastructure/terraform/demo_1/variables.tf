variable "event_name" {
  type = string
}

variable "sb" {
  type = object({
    topicname         = string
    subscriptionname  = string
    namespacename     = string
    connection_string = string
  })
}
