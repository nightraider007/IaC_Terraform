variable "app_environment" {
   type=map(object(
    {
      virtualnetworkname=string
      virtualnetworkcidrblock=string
      subnets=map(object(
    {
        cidrblock=string
    }))
      networkinterfacename=string
      publicipaddressname=string
      virtualmachinename=string
    }
   ))
}

variable "adminpassword" {
  type = string
  description = "This is the admin password for the virtual machine"
  sensitive = true
}
