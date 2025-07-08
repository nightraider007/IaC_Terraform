resource "random_string" "prefix1" {

  length  = 120
  special = true
  upper   = true

}

//variable "A" {

//}

//variable "B" {
//  type    = string
//  default = "myapp"
//}



locals {
  prefix    = random_string.prefix1.result
  app_name  = var.Application_name   
  full_name = "${local.prefix}-${local.app_name}"

}

output "C" {
  value = local.full_name


}