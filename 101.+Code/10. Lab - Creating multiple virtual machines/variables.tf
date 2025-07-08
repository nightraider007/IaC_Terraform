variable "network_interface_count" {
  type=number
  description = "This defines the number of network interfaces to create"
}

variable "subnet_information" {
    type=map(object(
    {
        cidrblock=string
    }))
}